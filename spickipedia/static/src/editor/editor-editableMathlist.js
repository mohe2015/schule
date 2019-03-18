/**
 * This module contains the definition of a data structure representing a list
 * of math atoms that can be edited. It is an in-memory representation of a
 * mathematical expression whose elements, math atoms, can be removed,
 * inserted or re-arranged. In addition, the data structure keeps track
 * of a selection, which can be either an insertion point — the selection is
 * then said to be _collapsed_ — or a range of atoms.
 *
 * See {@linkcode EditableMathlist}
 *
 * @module editor/editableMathlist
 * @private
 */
import Definitions from '../core/definitions.js';
import MathAtom from '../core/mathAtom.js';
import Lexer from '../core/lexer.js';
import ParserModule from '../core/parser.js';
import MathPath from './editor-mathpath.js';
import Shortcuts from './editor-shortcuts.js';


/**
 *
 * **Note**
 * - Method names that _begin with_ an underbar `_` are private and meant
 * to be used only by the implementation of the class.
 * - Method names that _end with_ an underbar `_` are selectors. They can
 * be invoked by calling [`MathField.$perform()`]{@link MathField#$perform}.
 * They will be dispatched to an instance of `MathEditableList` as necessary.
 * Note that the selector name does not include the underbar.
 *
 * For example:
 * ```
 *    mf.$perform('selectAll');
 * ```
 *
 * @param {Object.<string, any>} config
 * @param {Element} target - A target object passed as the first argument of 
 * callback functions. Typically, a MathField.
 * @property {MathAtom[]} root - The root element of the math expression.
 * @property {Object[]} path - The path to the element that is the
 * anchor for the selection.
 * @property {number} extent - Number of atoms in the selection. `0` if the
 * selection is collapsed.
 * @property {Object.<string, any>} config
 * @property {boolean} suppressSelectionChangeNotifications - If true,
 * the handlers for notification change won't be called. @todo This is an
 * inelegant solution to deal with iterating the expression, which has the
 * side effect of temporarily changing the path. We should have an iterator
 * that doesn't change the path instead.
 * @class
 * @global
 * @private
 * @memberof module:editor/editableMathlist
 */
function EditableMathlist(config, target) {
    this.root = MathAtom.makeRoot();
    this.path = [{relation: 'body', offset: 0}];
    this.extent = 0;

    this.config = Object.assign({}, config);
    this.target = target;

    this.suppressContentChangeNotifications = false;
    this.suppressSelectionChangeNotifications = false;
}

function clone(mathlist) {
    const result = Object.assign(new EditableMathlist(mathlist.config, mathlist.target), mathlist);
    result.path = MathPath.clone(mathlist.path);
    return result;
}


EditableMathlist.prototype._announce = function(command, mathlist, atoms) {
    if (typeof this.config.onAnnounce === 'function') {
        this.config.onAnnounce(this.target, command, mathlist, atoms);
    }
}

/**
 * Iterate over each atom in the expression, starting with the focus.
 *
 * Return an array of all the paths for which the callback predicate
 * returned true.
 *
 * @param {function} cb - A predicate being passed a path and the atom at this
 * path. Return true to include the designated atom in the result.
 * @param {number} dir - `+1` to iterate forward, `-1` to iterate backward.
 * @return {MathAtom[]} The atoms for which the predicate is true
 * @method EditableMathlist#filter
 * @private
 */
EditableMathlist.prototype.filter = function(cb, dir) {
    const suppressed = this.suppressSelectionChangeNotifications;
    this.suppressSelectionChangeNotifications = true;

    dir = dir < 0 ? -1 : +1;

    const result = [];
    const originalExtent = this.extent;
    if (dir >= 0) {
        this.collapseForward();
    } else {
        this.collapseBackward();
    }
    const initialPath = MathPath.pathToString(this.path);
    do {
        console.assert(this.anchor(), MathPath.pathToString(this.path));
        if (this.anchor() && cb.bind(this)(this.path, this.anchor())) {
            result.push(this.toString());
        }
        if (dir >= 0) {
            this.next({iterateAll: true});
        } else {
            this.previous({iterateAll: true});
        }
    } while (initialPath !== MathPath.pathToString(this.path));

    this.extent = originalExtent;

    this.suppressSelectionChangeNotifications = suppressed;

    return result;
}

/**
 * Enumerator
 * @param {function} cb - A callback called for each atom in the mathlist.
 */
EditableMathlist.prototype.forEach = function(cb) {
    this.root.forEach(cb);
}

/**
 * 
 * @param {function} cb - A callback called for each selected atom in the 
 * mathlist.
 */
EditableMathlist.prototype.forEachSelected = function(cb) {
    const siblings = this.siblings()
    const firstOffset = this.startOffset() + 1;
    const lastOffset = this.endOffset() + 1;
    for (let i = firstOffset; i < lastOffset; i++) {
        if (siblings[i] && siblings[i].type !== 'first') siblings[i].forEach(cb);
    }
}



/**
 * Return a string representation of the selection.
 * @todo This is a bad name for this function, since it doesn't return
 * a representation of the content, which one might expect...
 *
 * @return {string}
 * @method EditableMathlist#toString
 * @private
 */
EditableMathlist.prototype.toString = function() {
    return MathPath.pathToString(this.path, this.extent);
}


/**
 * When changing the selection, if the former selection is an empty list,
 * insert a placeholder if necessary. For example, if in an empty numerator.
*/
EditableMathlist.prototype.adjustPlaceholder = function() {
    // Should we insert a placeholder?
    // Check if we're an empty list that is the child of a fraction
    const siblings = this.siblings();
    if (siblings && siblings.length <= 1) {
        let placeholder;
        const relation = this.relation();
        if (relation === 'numer') {
            placeholder = 'numerator';
        } else if (relation === 'denom') {
            placeholder = 'denominator';
        } else if (this.parent().type === 'surd' && relation === 'body') {
            // Surd (roots)
            placeholder = 'radicand';
        } else if (this.parent().type === 'overunder' && relation === 'body') {
            placeholder = 'base';
        } else if (relation === 'underscript' || relation === 'overscript') {
            placeholder = 'annotation';
        }
        if (placeholder) {
            // ◌ ⬚
            const placeholderAtom = [new MathAtom.MathAtom('math', 'placeholder', '⬚')];
            Array.prototype.splice.apply(siblings, [1, 0].concat(placeholderAtom));
        }
}

}

EditableMathlist.prototype.selectionWillChange = function() {
    if (typeof this.config.onSelectionWillChange === 'function' && !this.suppressSelectionChangeNotifications) {
        this.config.onSelectionWillChange(this.target);
    }
}

EditableMathlist.prototype.selectionDidChange = function() {
    if (typeof this.config.onSelectionDidChange === 'function' && !this.suppressSelectionChangeNotifications) {
        this.config.onSelectionDidChange(this.target);
    }
}

EditableMathlist.prototype.contentWillChange = function() {
    if (typeof this.config.onContentWillChange === 'function' && !this.suppressContentChangeNotifications) {
        this.config.onContentWillChange(this.target);
    }
}

EditableMathlist.prototype.contentDidChange = function() {
    if (typeof this.config.onContentDidChange === 'function' && !this.suppressContentChangeNotifications) {
        this.config.onContentDidChange(this.target);
    }
}


/**
 *
 * @param {string|Array} selection
 * @param {number} extent the length of the selection
 * @return {boolean} true if the path has actually changed
 */
EditableMathlist.prototype.setPath = function(selection, extent) {
    // Convert to a path array if necessary
    if (typeof selection === 'string') {
        selection = MathPath.pathFromString(selection);
    } else if (Array.isArray(selection)) {
        // need to temporarily change the path of this to use 'sibling()'
        const newPath = MathPath.clone(selection);
        const oldPath = this.path;
        this.path = newPath;
        if (extent === 0 && this.anchor().type === 'placeholder') {
            // select the placeholder
            newPath[newPath.length - 1].offset = 0;
            extent = 1;             
        }
        selection = {
            path: newPath,
            extent: extent || 0
        };
        this.path = oldPath;
    }

    const pathChanged = MathPath.pathDistance(this.path, selection.path) !== 0;
    const extentChanged = selection.extent !== this.extent;

    if (pathChanged || extentChanged) {
        if (pathChanged) {
            this.adjustPlaceholder();
        }
        this.selectionWillChange();

        this.path = MathPath.clone(selection.path);


        if (this.siblings().length < this.anchorOffset()) {
            // The new path is out of bounds.
            // Reset the path to something valid
            console.log('invalid selection: ' + this.toString() + ' for ' + this.root.toLatex());

            this.path = [{relation: 'body', offset: 0}];
            this.extent = 0;
        } else {
           this.setExtent(selection.extent);
        }

        this.selectionDidChange();
    }

    return pathChanged || extentChanged;
}



/**
 * Extend the selection between `from` and `to` nodes
 *
 * @param {string[]} from
 * @param {string[]} to
 * @method EditableMathlist#setRange
 * @return {boolean} true if the range was actually changed
 * @private
 */
EditableMathlist.prototype.setRange = function(from, to) {
    // Measure the 'distance' between `from` and `to`
    const distance = MathPath.pathDistance(from, to);
    if (distance === 0) {
        // `from` and `to` are equal.
        // Set the path to a collapsed insertion point
        return this.setPath(from, 0);
    }

    if (distance === 1) {
        // They're siblings, set an extent
        const extent = (to[to.length - 1].offset - from[from.length - 1].offset);
        return this.setPath(MathPath.clone(from), extent);
    }

    // They're neither identical, not siblings.

    // Find the common ancestor between the nodes
    let commonAncestor = MathPath.pathCommonAncestor(from, to);
    const ancestorDepth = commonAncestor.length;
    if (from.length === ancestorDepth || to.length === ancestorDepth ||
        from[ancestorDepth].relation !== to[ancestorDepth].relation) {
        return this.setPath(commonAncestor, -1);
    }

    commonAncestor.push(from[ancestorDepth]);
    commonAncestor = MathPath.clone(commonAncestor);

    let extent = to[ancestorDepth].offset - from[ancestorDepth].offset + 1;

    if (extent <= 0) {
        if (to.length > ancestorDepth + 1) {
            // axb/c+y -> select from y to x
            commonAncestor[ancestorDepth].relation = to[ancestorDepth].relation;
            commonAncestor[ancestorDepth].offset = to[ancestorDepth].offset;
            commonAncestor[commonAncestor.length - 1].offset -=  1;
            extent = -extent + 2;
        } else {
            // x+(ayb/c) -> select from y to x
            commonAncestor[ancestorDepth].relation = to[ancestorDepth].relation;
            commonAncestor[ancestorDepth].offset = to[ancestorDepth].offset;
            extent = -extent + 1;
        }
    } else if (to.length <= from.length) {
        // axb/c+y -> select from x to y
        commonAncestor[commonAncestor.length - 1].offset -=  1;
    } else {
        // last case: x+(ayb/c) -> select from x to y
        extent -= 1;
    }

    return this.setPath(commonAncestor, extent);
}

/**
 * Convert am array row/col into an array index.
 * @param {MathAtom} atom
 * @param {object} rowCol
 * @return {number}
 */
function arrayIndex(atom, rowCol) {
    let result = 0;

    if (Array.isArray(atom.array)) {
        for (let i = 0; i < rowCol.row; i++) {
            for (let j = 0; j < atom.array[i].length; j++) {
                result += 1;
            }
        }
        result += rowCol.col;
    }

    return result;
}


/**
 * Convert an array index (scalar) to an array row/col.
 * @param {MathAtom} atom
 * @param {number} index
 */
function arrayColRow(atom, index) {
    const result = {row: 0, col: 0};
    while (index > 0) {
        result.col += 1;
        if (!atom.array[result.row] || result.col >= atom.array[result.row].length) {
            result.col = 0;
            result.row += 1;
        }
        index -= 1;
    }

    return result;
}



/**
 * Return the array cell corresponding to colrow or null (for example in
 * a sparse array)
 *
 * @param {MathAtom|MathAtom[]} atom
 * @param {any} colrow
 */
function arrayCell(atom, colrow) {
    let result;
    if (Array.isArray(atom.array)) {
        if (typeof colrow === 'number') colrow = arrayColRow(atom, colrow);
        if (Array.isArray(atom.array[colrow.row])) {
            result = atom.array[colrow.row][colrow.col] || null;
        }
    }
    // If the 'first' math atom is missing, insert it
    if (result && (result.length === 0 || result[0].type !== 'first')) {
        const firstAtom = new MathAtom.MathAtom(atom.parseMode, 'first', null);
        result.unshift(firstAtom);
    }
    return result;
}

/**
 * Total numbers of cells (include sparse cells) in the array.
 * @param {MathAtom} atom
 */
function arrayCellCount(atom) {
    let result = 0;
    if (Array.isArray(atom.array)) {
        let numRows = 0;
        let numCols = 1;
        for (const row of atom.array) {
            numRows += 1;
            if (row.length > numCols) numCols = row.length;
        }
        result = numRows * numCols;
    }
    return result;
}

/**
 * @param {number} ancestor distance from self to ancestor.
 * - `ancestor` = 0: self
 * - `ancestor` = 1: parent
 * - `ancestor` = 2: grand-parent
 * - etc...
 * @return {MathAtom}
 * @method EditableMathlist#ancestor
 * @private
 */
EditableMathlist.prototype.ancestor = function(ancestor) {
    // If the requested ancestor goes beyond what's available,
    // return null
    if (ancestor > this.path.length) return null;

    // Start with the root
    let result = this.root;

    // Iterate over the path segments, selecting the appropriate
    for (let i = 0; i < (this.path.length - ancestor); i++) {
        const segment = this.path[i];
        if (segment.relation.startsWith('cell')) {
            const cellIndex = parseInt(segment.relation.match(/cell([0-9]*)$/)[1]);
            result = arrayCell(result, cellIndex)[segment.offset];
        } else if (!result[segment.relation]) {
            // There is no such relation... (the path got out of sync with the tree)
            return null;
        } else {
            // Make sure the 'first' atom has been inserted, otherwise
            // the segment.offset might be invalid
            if (result[segment.relation].length === 0 || result[segment.relation][0].type !== 'first') {
                const firstAtom = new MathAtom.MathAtom(result.parseMode, 'first', null);
                result[segment.relation].unshift(firstAtom);
            }
            const offset = Math.min(segment.offset, result[segment.relation].length - 1);
            result = result[segment.relation][offset];
        }
    }

    return result;
}

/**
 * The atom where the selection starts. When the selection is extended
 * the anchor remains fixed. The anchor could be either before or
 * after the focus.
 *
 * @method EditableMathlist#anchor
 * @private
 */
EditableMathlist.prototype.anchor = function() {
    if (this.relation().startsWith('cell')) {
        const cellIndex = parseInt(this.relation().match(/cell([0-9]*)$/)[1]);
        return arrayCell(this.parent(), cellIndex)[this.anchorOffset()];
    }
    const siblings = this.siblings();
    return siblings[Math.min(siblings.length - 1, this.anchorOffset())];
}


EditableMathlist.prototype.parent = function() {
    return this.ancestor(1);
}

EditableMathlist.prototype.relation = function() {
    return this.path.length > 0 ? this.path[this.path.length - 1].relation : '';
}

EditableMathlist.prototype.anchorOffset = function() {
    return this.path.length > 0 ? this.path[this.path.length - 1].offset : 0;
}

EditableMathlist.prototype.focusOffset = function() {
    return this.path.length > 0 ?
        this.path[this.path.length - 1].offset + this.extent : 0;
}

/**
 * Offset of the first atom included in the selection
 * i.e. `=1` => selection starts with and includes first atom
 * With expression _x=_ and atoms :
 * - 0: _<first>_
 * - 1: _x_
 * - 2: _=_
 *
 * - if caret is before _x_:  `start` = 0, `end` = 0
 * - if caret is after _x_:   `start` = 1, `end` = 1
 * - if _x_ is selected:      `start` = 1, `end` = 2
 * - if _x=_ is selected:   `start` = 1, `end` = 3
 * @method EditableMathlist#startOffset
 * @private
 */
EditableMathlist.prototype.startOffset = function() {
    return Math.min(this.focusOffset(), this.anchorOffset());
}

/**
 * Offset of the first atom not included in the selection
 * i.e. max value of `siblings.length`
 * `endOffset - startOffset = extent`
 * @method EditableMathlist#endOffset
 * @private
 */
EditableMathlist.prototype.endOffset = function() {
    return Math.max(this.focusOffset(), this.anchorOffset());
}

/**
 * If necessary, insert a `first` atom in the sibling list.
 * If there's already a `first` atom, do nothing.
 * The `first` atom is used as a 'placeholder' to hold the blinking caret when
 * the caret is positioned at the very beginning of the mathlist.
 * @method EditableMathlist#insertFirstAtom
 * @private
 */
EditableMathlist.prototype.insertFirstAtom = function() {
    this.siblings();
}


/**
 * @return {MathAtom[]} array of children of the parent
 * @method EditableMathlist#siblings
 * @private
 */
EditableMathlist.prototype.siblings = function() {
    if (this.path.length === 0) return [];

    let siblings;
    if (this.relation().startsWith('cell')) {
        const cellIndex = parseInt(this.relation().match(/cell([0-9]*)$/)[1]);
        siblings = arrayCell(this.parent(), cellIndex);
    } else {
        siblings = this.parent()[this.relation()] || [];
        if (typeof siblings === 'string') siblings = [];
    }

    // If the 'first' math atom is missing, insert it
    if (siblings.length === 0 || siblings[0].type !== 'first') {
        const firstAtom = new MathAtom.MathAtom(this.parent().parseMode, 'first', null);
        siblings.unshift(firstAtom);
    }

    return siblings;
}


/**
 * Sibling, relative to `anchor`
 * `sibling(0)` = start of selection
 * `sibling(-1)` = sibling immediately left of start offset
 * @return {MathAtom}
 * @method EditableMathlist#sibling
 * @private
 */
EditableMathlist.prototype.sibling = function(offset) {
    const siblingOffset = this.startOffset() + offset;
    const siblings = this.siblings();
    if (siblingOffset < 0 || siblingOffset > siblings.length) return null;

    return siblings[siblingOffset]
}


/**
 * @return {boolean} True if the selection is an insertion point.
 * @method EditableMathlist#isCollapsed
 */
EditableMathlist.prototype.isCollapsed = function() {
    return this.extent === 0;
}

/**
 * @param {number} extent
 * @method EditableMathlist#setExtent
 * @private
 */
EditableMathlist.prototype.setExtent = function(extent) {
    this.extent = extent;
}

EditableMathlist.prototype.collapseForward = function() {
    if (this.extent === 0) return false;

    this.setSelection(this.endOffset());
    return true;
}

EditableMathlist.prototype.collapseBackward = function() {
    if (this.extent === 0) return false;

    this.setSelection(this.startOffset());
    return true;
}



/**
 * Select all the atoms in the current group, that is all the siblings.
 * When the selection is in a numerator, the group is the numerator. When
 * the selection is a superscript or subscript, the group is the supsub.
 * @method EditableMathlist#selectGroup_
 */
EditableMathlist.prototype.selectGroup_ = function() {
    this.setSelection(0, 'end');
}


/**
 * Select all the atoms in the math field.
 * @method EditableMathlist#selectAll_
 */
EditableMathlist.prototype.selectAll_ = function() {
    this.path = [{relation: 'body', offset: 0}];
    this.setSelection(0, 'end');
}


/**
 * Delete everything in the field
 * @method EditableMathlist#deleteAll_
 */
EditableMathlist.prototype.deleteAll_ = function() {
    this.selectAll_();
    this.delete_();
}

/**
 *
 * @param {MathAtom} atom
 * @param {MathAtom} target
 * @return {boolean} True if  `atom` is the target, or if one of the
 * children of `atom` contains the target
 * @function atomContains
 * @private
 */
function atomContains(atom, target) {
    if (!atom) return false;
    if (Array.isArray(atom)) {
        for (const child of atom) {
            if (atomContains(child, target)) return true;
        }
    } else {
        if (atom === target) return true;

        if (['body', 'numer', 'denom',
            'index', 'subscript', 'superscript',
            'underscript', 'overscript']
            .some(function(value) {
                return value === target || atomContains(atom[value], target)
            } )) return true;
        if (atom.array) {
            for (let i = arrayCellCount(atom); i >= 0; i--) {
                if (atomContains(arrayCell(atom, i), target)) {
                    return true;
                }
            }
        }
    }
    return false;
}


/**
 * @param {MathAtom} atom
 * @return {boolean} True if `atom` is within the selection range
 * @todo: poorly named, since this is specific to the selection, not the math
 * field
 * @method EditableMathlist#contains
 * @private
 */
EditableMathlist.prototype.contains = function(atom) {
    if (this.isCollapsed()) return false;
    const siblings = this.siblings()
    const firstOffset = this.startOffset();
    const lastOffset = this.endOffset();
    for (let i = firstOffset; i < lastOffset; i++) {
        if (atomContains(siblings[i], atom)) return true;
    }
    return false;
}

/**
 * @return {MathAtom[]} The currently selected atoms, or `null` if the
 * selection is collapsed
 * @method EditableMathlist#extractContents
 * @private
 */
EditableMathlist.prototype.extractContents = function() {
    if (this.isCollapsed()) return null;
    const result = [];
    const siblings = this.siblings()
    const firstOffset = this.startOffset() + 1;
    const lastOffset = this.endOffset() + 1;
    for (let i = firstOffset; i < lastOffset; i++) {
        if (siblings[i] && siblings[i].type !== 'first') result.push(siblings[i]);
    }

    return result;
}




/**
 * Return a 'string' version of the atom. This is used when matching auto-inline
 * replacements for example, so we make a best attempt at getting a string
 * version of the atom. Some atom types are effectively 'hard' barriers
 * in the string because they're not obvious to translate to a string.
 * We don't want them to be transparent, so we map them to 
 * '\ufffd' (REPLACEMENT CHARACTER).
 * 
 * For example, '-\sqrt{2}=' should not trigger a replacement of '-='
 * 
 * @param {MathAtom} atom
 */
function getString(atom) {
    if (!atom) return '';
    if (Array.isArray(atom)) {
        let result = '';
        for (const subAtom of atom) {
            result += getString(subAtom);
        }
        return result;
    }
    if (atom.type === 'array' || atom.type === 'surd' || atom.type === 'rule' ||
        atom.type === 'overunder' || atom.type === 'box' ||
        atom.type === 'enclose' || atom.type === 'placeholder' || atom.type === 'command') {
        // Don't decompose these.
        return '\ufffd';
    }
    if (atom.type === 'genfrac') {
        return '(' + getString(atom.numer) + ')/(' + getString(atom.denom) + ')';
    }
    if (atom.type === 'leftright') {
        return (atom.leftDelim || '') + 
            getString(atom.body) + 
            (atom.rightDelim === '?' ? '' : (atom.rightDelim || ''));
    }
    if (atom.type === 'delim' || atom.type === 'sizeddelim') {
        return atom.delim;
    }
    if (atom.type === 'spacing' || atom.type === 'space') {
        return ' '; // a single space
    }
    if (atom.type === 'mathstyle' || atom.type === 'sizing' || atom.type === 'first') {
        return '';
    }
    // 'group', 'root', 'line', 'overlap', 'font', 'accent',
    // 'mord', 'minner', 'mbin', 'mrel', 'mpunct', 'mopen', 'mclose',
    // 'textord', 'mop', 'color',
    if (typeof atom.body === 'string') {
        return atom.body;
    }
    if (Array.isArray(atom.body)) {
        let result = '';
        for (const subAtom of atom.body) {
            result += getString(subAtom);
        }
        return result;
    }

    return '';
}

/**
 * @param {number} count -- The number of atoms back we should return. Note
 * that since an atom can map to multiple characters, the length of the string
 * may be greater than this argument. It could also be smaller.
 * @return {string}
 * @method EditableMathlist#extractCharactersBeforeInsertionPoint
 * @private
 */
EditableMathlist.prototype.extractCharactersBeforeInsertionPoint = function(count) {
    const siblings = this.siblings();
    if (siblings.length <= 1) return '';

    // Going backwards, accumulate
    let result = '';
    let offset = this.startOffset();
    while (offset >= 1 && count > 0) {
        result = getString(siblings[offset]) + result;
        count -= 1;
        offset -= 1;
    }
    return result;
}


/**
 * Return a `{start:, end:}` for the offsets of the command around the insertion
 * point, or null.
 * - `start` is the first atom which is of type `command`
 * - `end` is after the last atom of type `command`
 * @return {object}
 * @method EditableMathlist#commandOffsets
 * @private
 */
EditableMathlist.prototype.commandOffsets = function() {
    const siblings = this.siblings();
    if (siblings.length <= 1) return null;

    let start = Math.min(this.endOffset(), siblings.length - 1);
    // let start = Math.max(0, this.endOffset());
    if (siblings[start].type !== 'command') return null;
    while (start > 0 && siblings[start].type === 'command') start -= 1;

    let end = this.startOffset() + 1;
    while (end <= siblings.length - 1 && siblings[end].type === 'command') end += 1;
    if (end > start) {
        return {start: start + 1, end: end};
    }
    return null;
}

/**
 * @return {string}
 * @method EditableMathlist#extractCommandStringAroundInsertionPoint
 * @private
 */
EditableMathlist.prototype.extractCommandStringAroundInsertionPoint = function() {
    let result = '';

    const command = this.commandOffsets();
    if (command) {
        const siblings = this.siblings();
        for (let i = command.start; i < command.end; i++) {
            // All these atoms are 'command' atom with a body that's
            // a single character
            result += siblings[i].body || '';
        }
    }
    return result;
}

/**
 * @param {boolean} value If true, decorate the command string around the
 * insertion point with an error indicator (red dotted underline). If false,
 * remove it.
 * @method EditableMathlist#decorateCommandStringAroundInsertionPoint
 * @private
 */
EditableMathlist.prototype.decorateCommandStringAroundInsertionPoint = function(value) {
    const command = this.commandOffsets();
    if (command) {
        const siblings = this.siblings();
        for (let i = command.start; i < command.end; i++) {
            siblings[i].error = value;
        }
    }
}

/**
 * @return {string}
 * @method EditableMathlist#commitCommandStringBeforeInsertionPoint
 * @private
 */
EditableMathlist.prototype.commitCommandStringBeforeInsertionPoint = function() {
    const command = this.commandOffsets();
    if (command) {
        const siblings = this.siblings();
        const anchorOffset = this.anchorOffset() + 1;
        for (let i = command.start; i < anchorOffset; i++) {
            siblings[i].suggestion = false;
        }
    }
}


EditableMathlist.prototype.spliceCommandStringAroundInsertionPoint = function(mathlist) {
    const command = this.commandOffsets();
    if (command) {
        // Dispatch notifications
        this.contentWillChange();

        Array.prototype.splice.apply(this.siblings(),
            [command.start, command.end - command.start].concat(mathlist));

        let newPlaceholders = [];
        for (const atom of mathlist) {
            newPlaceholders = newPlaceholders.concat(atom.filter(
                atom => atom.type === 'placeholder'));
        }
        this.setExtent(0);

        // Set the anchor offset to a reasonable value that can be used by
        // leap(). In particular, the current offset value may be invalid
        // if the length of the mathlist is shorter than the name of the command
        this.path[this.path.length - 1].offset = command.start - 1;

        if (newPlaceholders.length === 0 || !this.leap(+1, false)) {
            this.setSelection(command.start + mathlist.length - 1);
        }

        // Dispatch notifications
        this.contentDidChange();
    }
}

/**
 * @return {string}
 * @method EditableMathlist#extractContentsOrdInGroupBeforeInsertionPoint
 * @private
 */
EditableMathlist.prototype.extractContentsOrdInGroupBeforeInsertionPoint = function() {
    const result = [];
    const siblings = this.siblings();

    if (siblings.length <= 1) return [];

    let i = this.startOffset();
    while (i >= 1 && (siblings[i].type === 'mord' ||
        siblings[i].type === 'surd'     ||
        siblings[i].type === 'leftright' ||
        siblings[i].type === 'font'
        )) {
        result.unshift(siblings[i]);
        i--
    }

    return result;
}


/**
 * @param {number} offset
 * - &gt;0: index of the child in the group where the selection will start from
 * - <0: index counting from the end of the group
 * @param {number|string} [extent=0] Number of items in the selection:
 * - 0: collapsed selection, single insertion point
 * - &gt;0: selection extending _after_ the offset
 * - <0: selection extending _before_ the offset
 * - `'end'`: selection extending to the end of the group
 * - `'start'`: selection extending to the beginning of the group
 * @param {string} relation e.g. `'body'`, `'superscript'`, etc...
 * @return {boolean} False if the relation is invalid (no such children)
 * @method EditableMathlist#setSelection
 * @private
 */
EditableMathlist.prototype.setSelection = function(offset, extent, relation) {
    offset = offset || 0;
    extent = extent || 0;

    // If no relation ("children", "superscript", etc...) is specified
    // keep the current relation
    const oldRelation = this.path[this.path.length - 1].relation;
    if (!relation) relation = oldRelation;

    // If the relation is invalid, exit and return false
    const parent = this.parent();
    const arrayRelation = relation.startsWith('cell');
    if (!parent && relation !== 'body') return false;
    if ((!arrayRelation && !parent[relation]) ||
        (arrayRelation && !parent.array)) return false;

    const relationChanged = relation !== oldRelation;
    // Temporarily set the path to the potentially new relation to get the
    // right siblings
    this.path[this.path.length - 1].relation = relation;

    // Invoking siblings() will have the side-effect of adding the 'first'
    // atom if necessary
    // ... and we want the siblings with the potentially new relation...
    const siblings = this.siblings();
    const siblingsCount = siblings.length;

    // Restore the relation
    this.path[this.path.length - 1].relation = oldRelation;

    const oldExtent = this.extent;
    if (extent === 'end') {
        extent = siblingsCount - offset - 1;
    } else if (extent === 'start') {
        extent = -offset;
    }
    this.setExtent(extent);
    const extentChanged = this.extent !== oldExtent;
    this.setExtent(oldExtent);

    // Calculate the new offset, and make sure it is in range
    // (setSelection can be called with an offset that greater than
    // the number of children, for example when doing an up from a
    // numerator to a smaller denominator, e.g. "1/(x+1)".
    if (offset < 0) {
        offset = siblingsCount + offset;
    }
    offset = Math.max(0, Math.min(offset, siblingsCount - 1));

    const oldOffset = this.path[this.path.length - 1].offset;
    const offsetChanged = oldOffset !== offset;

    if (relationChanged || offsetChanged || extentChanged) {
        if (relationChanged) {
            this.adjustPlaceholder();
        }
        this.selectionWillChange();

        this.path[this.path.length - 1].relation = relation;
        this.path[this.path.length - 1].offset = offset;
        this.setExtent(extent);

        this.selectionDidChange();
    }

    return true;
}



/**
 * Move the anchor to the next permissible atom
 * @method EditableMathlist#next
 * @private
 */
EditableMathlist.prototype.next = function(options) {
    options = options || {};

    const NEXT_RELATION = {
        'body': 'numer',
        'numer': 'denom',
        'denom': 'index',
        'index': 'overscript',
        'overscript': 'underscript',
        'underscript': 'subscript',
        'subscript': 'superscript'
    }


    if (this.anchorOffset() === this.siblings().length - 1) {
        this.adjustPlaceholder();

        this.selectionWillChange();

        // We've reached the end of this list.
        // Is there another list to consider?
        let relation = NEXT_RELATION[this.relation()];
        while (relation && !this.setSelection(0, 0, relation)) {
            relation = NEXT_RELATION[relation];
        }
        // We found a new relation/set of siblings...
        if (relation) {
            this.selectionDidChange();
            return;
        }


        // No more siblings, check if we have a sibling cell in an array
        if (this.relation().startsWith('cell')) {
            const maxCellCount = arrayCellCount(this.parent());
            let cellIndex = parseInt(this.relation().match(/cell([0-9]*)$/)[1]) + 1;
            while (cellIndex < maxCellCount) {
                const cell = arrayCell(this.parent(), cellIndex);
                // Some cells could be null (sparse array), so skip them
                if (cell && this.setSelection(0, 0, 'cell' + cellIndex)) {
                    this.selectionDidChange();
                    return;
                }
                cellIndex += 1;
            }
        }

        // No more siblings, go up to the parent.
        if (this.path.length === 1) {
            // Invoke handler and perform default if they return true.
            if (this.suppressSelectionChangeNotifications || 
                !this.config.onMoveOutOf || 
                this.config.onMoveOutOf(this, 'forward')) {
                // We're at the root, so loop back
                this.path[0].offset = 0;
            }
        } else {
            // We've reached the end of the siblings. If we're a group
            // with skipBoundary, when exiting, move one past the next atom
            const skip = !options.iterateAll && this.parent().skipBoundary;
            this.path.pop();
            if (skip) {
                this.next(options);
            }
        }

        this.selectionDidChange();
        return;
    }

    // Still some siblings to go through. Move on to the next one.
    this.setSelection(this.anchorOffset() + 1);

    // If the new anchor is a compound atom, dive into its components
    const anchor = this.anchor();
    // Only dive in if the atom allows capture of the selection by
    // its sub-elements
    if (anchor && !anchor.captureSelection) {
        let relation;
        if (anchor.array) {
            // Find the first non-empty cell in this array
            let cellIndex = 0;
            relation = '';
            const maxCellCount = arrayCellCount(anchor);
            while (!relation && cellIndex < maxCellCount) {
                // Some cells could be null (sparse array), so skip them
                if (arrayCell(anchor, cellIndex)) {
                    relation = 'cell' + cellIndex.toString();
                }
                cellIndex += 1;
            }
            console.assert(relation);
            this.path.push({relation:relation, offset: 0});
            this.setSelection(0, 0 , relation);
            return;
        }
        relation = 'body';
        while (relation) {
           if (Array.isArray(anchor[relation])) {
                this.path.push({relation:relation, offset: 0});
                this.insertFirstAtom();
                if (!options.iterateAll && anchor.skipBoundary) this.next(options);
                return;
            }
            relation = NEXT_RELATION[relation];
        }
    }
}



EditableMathlist.prototype.previous = function(options) {
    options = options || {};

    const PREVIOUS_RELATION = {
        'numer': 'body',
        'denom': 'numer',
        'index': 'denom',
        'overscript': 'index',
        'underscript': 'overscript',
        'subscript': 'underscript',
        'superscript': 'subscript'
    }
    if (!options.iterateAll && this.anchorOffset() === 1 && this.parent() && this.parent().skipBoundary) {
        this.setSelection(0);
    }
    if (this.anchorOffset() < 1) {
        // We've reached the first of these siblings.
        // Is there another set of siblings to consider?
        let relation = PREVIOUS_RELATION[this.relation()];
        while (relation && !this.setSelection(-1, 0 , relation)) {
            relation = PREVIOUS_RELATION[relation];
        }
        // Ignore the body of the subsup scaffolding and of 
        // 'mop' atoms (for example, \sum): their body is not editable.
        const parentType = this.parent() ? this.parent().type : 'none';
        if (relation === 'body' && (parentType === 'msubsup' || parentType === 'mop')) {
            relation = null;
        }
        // We found a new relation/set of siblings...
        if (relation) return;

        this.adjustPlaceholder();

        this.selectionWillChange();

        // No more siblings, check if we have a sibling cell in an array
        if (this.relation().startsWith('cell')) {
            let cellIndex = parseInt(this.relation().match(/cell([0-9]*)$/)[1]) - 1;
            while (cellIndex >= 0) {
                const cell = arrayCell(this.parent(), cellIndex);
                if (cell && this.setSelection(-1, 0, 'cell' + cellIndex)) {
                    this.selectionDidChange();
                    return;
                }
                cellIndex -= 1;
            }
        }


        // No more siblings, go up to the parent.
        if (this.path.length === 1) {
            // Invoke handler and perform default if they return true.
            if (this.suppressSelectionChangeNotifications || 
                !this.config.onMoveOutOf || 
                this.config.onMoveOutOf.bind(this)(-1)) {
                // We're at the root, so loop back
                this.path[0].offset = this.root.body.length - 1;
            }
        } else {
            this.path.pop();
            this.setSelection(this.anchorOffset() - 1);
        }

        this.selectionDidChange();
        return;
    }

    // If the new anchor is a compound atom, dive into its components
    const anchor = this.anchor();
    // Only dive in if the atom allows capture of the selection by
    // its sub-elements
    if (!anchor.captureSelection) {
        let relation;
        if (anchor.array) {
            relation = '';
            const maxCellCount = arrayCellCount(anchor);
            let cellIndex = maxCellCount - 1;
            while (!relation && cellIndex < maxCellCount) {
                // Some cells could be null (sparse array), so skip them
                if (arrayCell(anchor, cellIndex)) {
                    relation = 'cell' + cellIndex.toString();
                }
                cellIndex -= 1;
            }
            cellIndex += 1;
            console.assert(relation);
            this.path.push({relation:relation,
                offset: arrayCell(anchor, cellIndex).length - 1});
            this.setSelection(-1, 0 , relation);
            return;
        }
        relation = 'superscript';
        while (relation) {
            if (Array.isArray(anchor[relation])) {
                this.path.push({relation:relation,
                    offset: anchor[relation].length - 1});

                this.setSelection(-1, 0, relation);
                return;
            }
            relation = PREVIOUS_RELATION[relation];
        }
    }
    // There wasn't a component to navigate to, so...
    // Still some siblings to go through: move on to the previous one.
    this.setSelection(this.anchorOffset() - 1);

    if (!options.iterateAll && this.sibling(0) && this.sibling(0).skipBoundary) {
        this.previous(options);
    }
}

EditableMathlist.prototype.move = function(dist, options) {
    options = options || {extend: false};
    const extend = options.extend || false;

    this.removeSuggestion();

    if (extend) {
        this.extend(dist, options);
    } else {
        const oldPath = clone(this);
        // const previousParent = this.parent();
        // const previousRelation = this.relation();
        // const previousSiblings = this.siblings();

        if (dist > 0) {
            if (this.collapseForward()) dist--;
            while (dist > 0) {
                this.next();
                dist--;
            }
        } else if (dist < 0) {
            if (this.collapseBackward()) dist++;
            while (dist !== 0) {
                this.previous();
                dist++;
            }
        }

        // ** @todo: can't do that without updating the path.
        // If the siblings list we left was empty, remove the relation
        // if (previousSiblings.length <= 1) {
        //     if (['superscript', 'subscript', 'index'].includes(previousRelation)) {
        //         previousParent[previousRelation] = null;
        //     }
        // }
        this._announce('move', oldPath);
    }
}

EditableMathlist.prototype.up = function(options) {
    options = options || {extend: false};
    const extend = options.extend || false;

    this.collapseForward();

    if (this.relation() === 'denom') {
        if (extend) {
            this.selectionWillChange();
            this.path.pop();
            this.path[this.path.length - 1].offset -= 1;
            this.setExtent(1);
            this.selectionDidChange();
        } else {
            this.setSelection(this.anchorOffset(), 0, 'numer');
        }
        this._announce('moveUp');
    } else {
        this._announce('line');
    }
}

EditableMathlist.prototype.down = function(options) {
    options = options || {extend: false};
    const extend = options.extend || false;

    this.collapseForward();

    if (this.relation() === 'numer') {
        if (extend) {
            this.selectionWillChange();
            this.path.pop();
            this.path[this.path.length - 1].offset -= 1;
            this.setExtent(1);
            this.selectionDidChange();
        } else {
            this.setSelection(this.anchorOffset(), 0, 'denom');
        }
        this._announce('moveDown');
    } else {
        this._announce('line');
    }
}

/**
 * Change the range of the selection
 *
 * @param {number} dist - The change (positive or negative) to the extent
 * of the selection. The anchor point does not move.
 * @method EditableMathlist#extend
 * @private
 */
EditableMathlist.prototype.extend = function(dist) {
    let offset = this.path[this.path.length - 1].offset;
    let extent = 0;
    const oldPath = clone(this);

    extent = this.extent + dist;

    const newFocusOffset = offset + extent;
    if (newFocusOffset < 0 && extent !== 0) {
        // We're trying to extend beyond the first element.
        // Go up to the parent.
        if (this.path.length > 1) {
            this.selectionWillChange();
            this.path.pop();
            // this.path[this.path.length - 1].offset -= 1;
            this.setExtent(-1);
            this.selectionDidChange();
            this._announce('move', oldPath);
            return; 
        }
        // @todo exit left extend
        // If we're at the very beginning, nothing to do.
        offset = this.path[this.path.length - 1].offset;
        extent = this.extent;

    } else if (newFocusOffset >= this.siblings().length) {
        // We're trying to extend beyond the last element.
        // Go up to the parent
        if (this.path.length > 1) {
            this.selectionWillChange();
            this.path.pop();
            this.path[this.path.length - 1].offset -= 1;
            this.setExtent(1);
            this.selectionDidChange();
            this._announce('move', oldPath);
            return; 
        }
        // @todo exit right extend
        if (this.isCollapsed()) {
            offset -= 1;
        }
        extent -= 1;
    }
    this.setSelection(offset, extent);
    this._announce('move', oldPath);
}



/**
 * Move the selection focus to the next/previous point of interest.
 * A point of interest is an atom of a different type (mbin, mord, etc...)
 * than the current focus.
 * If `extend` is true, the selection will be extended. Otherwise, it is
 * collapsed, then moved.
 * @param {number} dir +1 to skip forward, -1 to skip back
 * @param {Object.<string, any>} options
 * @method EditableMathlist#skip
 * @private
 */
EditableMathlist.prototype.skip = function(dir, options) {
    options = options || {extend: false};
    const extend = options.extend || false;
    dir = dir < 0 ? -1 : +1;

    const oldPath = clone(this);
    const siblings = this.siblings();
    const focus = this.focusOffset();
    let offset = focus + (dir > 0 ? 1 : 0);
    offset = Math.max(0, Math.min(offset, siblings.length - 1));
    const type = siblings[offset].type;
    if ((offset === 0 && dir < 0) ||
        (offset === siblings.length - 1 && dir > 0)) {
        // If we've reached the end, just moved out of the list
        this.move(dir, options);
        return;
    } else if ((type === 'mopen' && dir > 0) ||
                (type === 'mclose' && dir < 0)) {
        // We're right before (or after) an opening (or closing)
        // fence. Skip to the balanced element (in level, but not necessarily in
        // fence symbol).
        let level = type === 'mopen' ? 1 : -1;
        offset += dir > 0 ? 1 : -1;
        while (offset >= 0 && offset < siblings.length && level !== 0) {
            if (siblings[offset].type === 'mopen') {
                level += 1;
            } else if (siblings[offset].type === 'mclose') {
                level -= 1;
            }
            offset += dir;
        }
        if (level !== 0) {
            // We did not find a balanced element. Just move a little.
            offset = focus + dir;
        }
        if (dir > 0) offset = offset - 1;
    } else {
        while (offset >= 0 && offset < siblings.length && siblings[offset].type === type) {
            offset += dir;
        }
        offset -= (dir > 0 ? 1 : 0);
    }
    if (extend) {
        this.extend(offset - focus);
    } else {
        this.setSelection(offset);
    }
    this._announce('move', oldPath);
}

/**
 * Move to the next/previous expression boundary
 * @method EditableMathlist#jump
 * @private
 */
EditableMathlist.prototype.jump = function(dir, options) {
    options = options || {extend: false};
    const extend = options.extend || false;
    dir = dir < 0 ? -1 : +1;

    const siblings = this.siblings();
    let focus = this.focusOffset();
    if (dir > 0) focus = Math.min(focus + 1, siblings.length - 1);

    const offset = dir < 0 ? 0 : siblings.length - 1;

    if (extend) {
        this.extend(offset - focus);
    } else {
        this.move(offset - focus);
    }
}

EditableMathlist.prototype.jumpToMathFieldBoundary = function(dir, options) {
    options = options || {extend: false};
    const extend = options.extend || false;
    dir = dir || +1;
    dir = dir < 0 ? -1 : +1;

    const oldPath = clone(this);
    const path = [this.path[0]];
    let extent;

    if (!extend) {
        // Change the anchor to the end/start of the root expression
        path[0].offset = dir < 0 ? 0 : this.root.body.length - 1;
        extent = 0;
    } else {
        // Don't change the anchor, but update the extent
        if (dir < 0) {
            if (path[0].offset > 0) {
                extent = -path[0].offset;
            } else {
                // @todo exit left extend
            }
        } else {
            if (path[0].offset < this.siblings().length - 1) {
                extent = this.siblings().length - path[0].offset;
            } else {
                // @todo exit right extend
            }
        }
    }

    this.setPath(path, extent);
    this._announce('move', oldPath);
}

/**
 * Move to the next/previous placeholder or empty child list.
 * @return {boolean} False if no placeholder found and did not move
 * @method EditableMathlist#leap
 * @private
 */
EditableMathlist.prototype.leap = function(dir, callHandler) {
    dir = dir || +1;
    dir = dir < 0 ? -1 : +1;
    callHandler = callHandler || true;

    const oldPath = clone(this);
    this.move(dir);

    if (this.anchor().type === 'placeholder') {
        // If we're already at a placeholder, move by one more (the placeholder
        // is right after the insertion point)
        this.move(dir);
    }
    // Candidate placeholders are atom of type 'placeholder'
    // or empty children list (except for the root: if the root is empty,
    // it is not a valid placeholder)
    const placeholders = this.filter((path, atom) =>
        atom.type === 'placeholder' ||
        (path.length > 1 && this.siblings().length === 1), dir);

    // If no placeholders were found, call handler
    if (placeholders.length === 0) {
        if (callHandler) {
            if (this.config.onTabOutOf) {
                this.config.onTabOutOf(this.target, dir > 0 ? 'forward' : 'backward');
            } else if (document.activeElement) {
                const focussableElements = `a[href]:not([disabled]),
                    button:not([disabled]),
                    textarea:not([disabled]),
                    input[type=text]:not([disabled]),
                    select:not([disabled]),
                    [contentEditable="true"],
                    [tabindex]:not([disabled]):not([tabindex="-1"])`;
                // Get all the potentially focusable elements
                // and exclude (1) those that are invisible (width and height = 0)
                // (2) not the active element
                // (3) the ancestor of the active element

                const focussable = Array.prototype.filter.call(document.querySelectorAll(focussableElements),  element =>
                    ((element.offsetWidth > 0 || element.offsetHeight > 0) &&
                    !element.contains(document.activeElement)) ||
                    element === document.activeElement
                );
                let index = focussable.indexOf(document.activeElement) + dir;
                if (index < 0) index = focussable.length - 1;
                if (index >= focussable.length) index = 0;
                focussable[index].focus();
            }
        }
        return false;
    }

    // Set the selection to the next placeholder
    this.setPath(placeholders[0]);
    if (this.anchor().type === 'placeholder') this.setExtent(-1);
    this._announce('move', oldPath);
    return true;
}



EditableMathlist.prototype.parseMode = function() {
    const context = this.anchor();
    if (context) {
        if (context.type === 'commandliteral' ||
            context.type === 'esc' ||
            context.type === 'command') return 'command';
    }
    return 'math';
}


function removeParen(list) {
    if (!list) return undefined;

    if (list && list.length === 1 && list[0].type === 'leftright' &&
        list[0].leftDelim === '(') {
        list = list[0].body;
    }

    return list;
}


/**
 * @param {string} s
 * @param {Object.<string, any>} options
 * @param {string} options.insertionMode -
 *    * 'replaceSelection' (default)
 *    * 'replaceAll'
 *    * 'insertBefore'
 *    * 'insertAfter'
 *
 * @param {string} options.selectionMode - Describes where the selection
 * will be after the insertion:
 *    * `'placeholder'`: the selection will be the first available placeholder
 * in the item that has been inserted) (default)
 *    * `'after'`: the selection will be an insertion point after the item that
 * has been inserted),
 *    * `'before'`: the selection will be an insertion point before
 * the item that has been inserted) or 'item' (the item that was inserted will
 * be selected).
 *
 * @param {string} options.placeholder - The placeholder string, if necessary
 *
 * @param {string} options.format - The format of the string `s`:
 *    * `'auto'`: the string is interpreted as a latex fragment or command or 
 * MathASCII (default)
 *    * `'latex'`: the string is interpreted strictly as a latex fragment
 *
 * @param {string} options.smartFence - If true, promote plain fences, e.g. `(`,
 * as `\left...\right` or `\mleft...\mright`
 *
 * @param {boolean} options.suppressContentChangeNotifications - If true, the
 * handlers for the contentWillChange and contentDidChange notifications will 
 * not be invoked. Default `false`.
 * 
 * @method EditableMathlist#insert
 */
EditableMathlist.prototype.insert = function(s, options) {
    options = options || {};
    const suppressedContentChangeNotifications = this.suppressContentChangeNotifications;
    if (options.suppressContentChangeNotifications) {
        this.suppressContentChangeNotifications = true;
    }
    // Dispatch notifications
    this.contentWillChange();
    const contentWasChanging = this.suppressContentChangeNotifications;
    this.suppressContentChangeNotifications = true;


    if (!options.insertionMode) options.insertionMode = 'replaceSelection';
    if (!options.selectionMode) options.selectionMode = 'placeholder';
    if (!options.format) options.format = 'auto';
    options.macros = options.macros || this.config.macros;

    const parseMode = this.parseMode();
    let mathlist;

    // Save the content of the selection, if any
    const args = [this.extractContents()];

    // If a placeholder was specified, use it
    if (options.placeholder !== undefined) {
        args['?'] = options.placeholder;
    }

    // Delete any selected items
    if (options.insertionMode === 'replaceSelection' && !this.isCollapsed()) {
        this.delete_();
    } else if (options.insertionMode === 'replaceAll') {
        // Remove all the children of root, save for the 'first' atom
        this.root.body.splice(1);
        this.path = [{relation: 'body', offset: 0}];
        this.extent = 0;
    } else if (options.insertionMode === 'insertBefore') {
        this.collapseBackward();
    } else if (options.insertionMode === 'insertAfter') {
        this.collapseForward();
    }

    // Delete any placeholders before or after the insertion point
    const siblings = this.siblings();
    const firstOffset = this.startOffset();
    if (firstOffset + 1 < siblings.length && siblings[firstOffset + 1] && siblings[firstOffset + 1].type === 'placeholder') {
        this.delete_(1);
    } else if (firstOffset > 0 && siblings[firstOffset] && siblings[firstOffset].type === 'placeholder') {
        this.delete_(-1);
    }

    if (options.format === 'auto') {
        if (parseMode === 'command') {
            // Short-circuit the tokenizer and parser if in command mode
            mathlist = [];
            for (const c of s) {
                const symbol = Definitions.matchSymbol('command', c);
                if (symbol) {
                    mathlist.push(new MathAtom.MathAtom('command', 'command',
                        symbol.value, 'main'));
                }
            }
        } else if (s === '\u001b') {
            mathlist = [new MathAtom.MathAtom('command', 'command', '\\', 'main')];
        } else {
            s = parseMathString(s, this.config);

            // If we're inserting a latex fragment that includes a #@ argument
            // substitute the preceding `mord` atoms for it.
            if (args[0]) {
                // There was a selection, we'll use it for #@
                s = s.replace(/(^|[^\\])#@/g, '$1#0');

            } else if (/(^|[^\\])#@/.test(s)) {
                s = s.replace(/(^|[^\\])#@/g, '$1#0');
                args[0] = this.extractContentsOrdInGroupBeforeInsertionPoint();
                // Delete the implicit argument
                this._deleteAtoms(-args[0].length);
                // If the implicit argument was empty, remove it from the args list.
                if (Array.isArray(args[0]) && args[0].length === 0) args[0] = undefined;

            } else {
                // No selection, no 'mord' before. Let's make '#@' a placeholder.
                s = s.replace(/(^|[^\\])#@/g, '$1#?');
            }

            mathlist = ParserModule.parseTokens(
                Lexer.tokenize(Definitions.unicodeStringToLatex(s)),
                    parseMode, args, options.macros, options.smartFence);

            // Simplify result.
            // If it's a fraction with a parenthesized numerator or denominator
            // remove the parentheses.
            if (mathlist.length === 1 && 
                mathlist[0].type === 'genfrac' && 
                this.config.removeExtraneousParentheses) {
                mathlist[0].numer = removeParen(mathlist[0].numer);
                mathlist[0].denom = removeParen(mathlist[0].denom);
            }
        }
    } else if (options.format === 'latex') {
        mathlist = ParserModule.parseTokens(
            Lexer.tokenize(s), parseMode, args, options.macros, options.smartFence);
    }

    // Insert the mathlist at the position following the anchor
    Array.prototype.splice.apply(this.siblings(),
        [this.anchorOffset() + 1, 0].concat(mathlist));

    // If needed, make sure there's a first atom in the siblings list
    this.insertFirstAtom();

    // Update the anchor's location
    if (options.selectionMode === 'placeholder') {
        // Move to the next placeholder
        let newPlaceholders = [];
        for (const atom of mathlist) {
            newPlaceholders = newPlaceholders.concat(atom.filter(
                atom => atom.type === 'placeholder'));
        }
        if (newPlaceholders.length === 0 || !this.leap(+1, false)) {
            // No placeholder found, move to right after what we just inserted
            this.setSelection(this.anchorOffset() + mathlist.length);
            // this.path[this.path.length - 1].offset += mathlist.length;
        } else {
            this._announce('move');   // should have placeholder selected
        }
    } else if (options.selectionMode === 'before') {
        // Do nothing: don't change the anchorOffset.
    } else if (options.selectionMode === 'after') {
        this.setSelection(this.anchorOffset() + mathlist.length);
    } else if (options.selectionMode === 'item') {
        this.setSelection(this.anchorOffset() + 1, mathlist.length);
    }

    // Dispatch notifications
    this.suppressContentChangeNotifications = contentWasChanging;
    this.contentDidChange();

    this.suppressContentChangeNotifications = suppressedContentChangeNotifications;
}



/**
 * Insert a smart fence '(', '{', '[', etc...
 * If not handled (because `fence` wasn't a fence), return false.
 * @param {string} fence
 * @return {boolean}
 */
EditableMathlist.prototype._insertSmartFence = function(fence) {
    if (!this.config.smartFence) return false;

    const parent = this.parent();

    // We're inserting a middle punctuation, for example as in {...|...}
    if (parent && (parent.type === 'leftright' && parent.leftDelim !== '|')) {
        if (/\||\\vert|\\Vert|\\mvert|\\mid/.test(fence)) {
            this.insert('\\,\\middle' + fence + '\\, ');
            return true;
         }
    }
    if (fence === '{') fence = '\\lbrace';
    if (fence === '[') fence = '\\lbrack';
    if (fence === '}') fence = '\\rbrace';
    if (fence === ']') fence = '\\rbrack';

    const rDelim = Definitions.RIGHT_DELIM[fence];
    if (rDelim && !(parent && (parent.type === 'leftright' && parent.leftDelim === '|'))) {
        // We have a valid open fence as input
        let s = '';
        const collapsed = this.isCollapsed() || this.anchor().type === 'placeholder';

        if (this.sibling(0).isFunction) {
            // We're before a function (e.g. `\sin`)
            // This is an argument list. Use `\mleft...\mright'.
            s = '\\mleft' + fence + '\\mright';
        } else {
            s = '\\left' + fence + '\\right';
        }
        s += (collapsed ? '?' : rDelim);

        this.insert(s, { format: 'latex' });
        if (collapsed) this.move(-1);
        return true;
    }
    // We did not have a valid open fence. Maybe it's a close fence?
    // Note that '.' is the universal closing fence, so it will match anything
    let lDelim;
    if (fence === '.') { 
        lDelim = '.';   // Could be any value, just means we've found a match
    } else {
        for (const delim  in Definitions.RIGHT_DELIM) {
            if (Definitions.RIGHT_DELIM.hasOwnProperty(delim)) {
                if (fence === Definitions.RIGHT_DELIM[delim]) lDelim = delim;
            }
        }
    }
    if (lDelim) {
        // We found the matching open fence, so it was a valid close fence.
        // Note that `lDelim` may not match `fence`. That's OK.

        // If we're the last atom inside a 'leftright',
        // update the parent
        if (parent && parent.type === 'leftright' &&
                this.endOffset() === this.siblings().length - 1) {
            this.contentWillChange();
            parent.rightDelim = fence;
            this.move(+1);
            this.contentDidChange();
            return true;
        }

        // If we have a 'leftright' sibling to our left
        // move what's between us and the 'leftright' inside the leftright
        const siblings = this.siblings();
        let i;
        for (i = this.endOffset(); i >= 0; i--) {
            if (siblings[i].type === 'leftright') break;
        }
        if (i >= 0) {
            this.contentWillChange();
            siblings[i].rightDelim = fence;
            siblings[i].body = siblings[i].body.concat(siblings.slice(i + 1, this.endOffset() + 1));
            siblings.splice(i + 1, this.endOffset() - i);
            this.setSelection(i);
            this.contentDidChange();
            return true;
        }

        // If we're inside a 'leftright', but not the last atom,
        // adjust the body (put everything after the insertion point outside)
        if (parent && parent.type === 'leftright') {
            this.contentWillChange();
            parent.rightDelim = fence;

            const tail = siblings.slice(this.endOffset() + 1);
            siblings.splice(this.endOffset() + 1);
            this.path.pop();

            Array.prototype.splice.apply(this.siblings(),
                [this.endOffset() + 1, 0].concat(tail));
            this.contentDidChange();

            return true;
        }

        // Is our grand-parent a 'leftright'?
        // If `\left(\frac{1}{x|}\right?` with the caret at `|`
        // go up to the 'leftright' and apply it there instead
        const grandparent = this.ancestor(2);
        if (grandparent && grandparent.type === 'leftright' &&
            this.endOffset() === siblings.length - 1) {
            this.move(1);
            return this._insertSmartFence(fence);
        }

        // Meh... We couldn't find a matching open fence. Just insert the
        // closing fence as a regular character
        this.insert(fence);
        return true;
    }

    return false;
}



EditableMathlist.prototype.positionInsertionPointAfterCommitedCommand = function() {
    const siblings = this.siblings();
    const command = this.commandOffsets();
    let i = command.start;
    while (i < command.end && !siblings[i].suggestion) {
        i++;
    }
    this.setSelection(i - 1);
}



EditableMathlist.prototype.removeSuggestion = function() {
    const siblings = this.siblings();
    // Remove all `suggestion` atoms
    for (let i = siblings.length - 1; i >= 0; i--) {
        if (siblings[i].suggestion) {
            siblings.splice(i, 1);
        }
    }
}

EditableMathlist.prototype.insertSuggestion = function(s, l) {
    this.removeSuggestion();

    const mathlist = [];

    // Make a mathlist from the string argument with the `suggestion` property set
    const subs = s.substr(l);
    for (const c of subs) {
        const atom = new MathAtom.MathAtom('command', 'command', c, 'main');
        atom.suggestion = true;
        mathlist.push(atom);
    }

    // Splice in the mathlist after the insertion point, but don't change the
    // insertion point
    Array.prototype.splice.apply(this.siblings(),
        [this.anchorOffset() + 1, 0].concat(mathlist));

}

/**
 * Delete sibling atoms
 * @method EditableMathlist#_deleteAtoms
 * @private
 */
EditableMathlist.prototype._deleteAtoms = function(count) {
    if (count > 0) {
        this.siblings().splice(this.anchorOffset() + 1, count);
    } else {
        this.siblings().splice(this.anchorOffset() + count + 1, -count);
        this.setSelection(this.anchorOffset() + count);
    }
}

/**
 * Delete multiple characters
 * @method EditableMathlist#delete
 */
EditableMathlist.prototype.delete = function(count) {
    count = count || 0;

    if (count === 0) {
        this.delete_(0);
    } else if (count > 0) {
        while (count > 0) {
            this.delete_(+1);
            count--;
        }
    } else {
        while (count < 0) {
            this.delete_(-1);
            count++;
        }
    }
}


/**
 * @param {number} dir If the selection is not collapsed, and dir is
 * negative, delete backwards, starting with the anchor atom.
 * That is, delete(-1) will delete only the anchor atom.
 * If dir = 0, delete only if the selection is not collapsed
 * @method EditableMathlist#delete_
 * @instance
 */
EditableMathlist.prototype.delete_ = function(dir) {
    // Dispatch notifications
    this.contentWillChange();
    const contentWasChanging = this.suppressContentChangeNotifications;
    this.suppressContentChangeNotifications = true;

    dir = dir || 0;
    dir = dir < 0 ? -1 : (dir > 0 ? +1 : dir);

    this.removeSuggestion();

    const siblings = this.siblings();

    if (!this.isCollapsed()) {
        // There is a selection extent. Delete all the atoms within it.
        const first = this.startOffset() + 1;
        const last = this.endOffset() + 1;

        this._announce('deleted', null, siblings.slice(first, last));
        siblings.splice(first, last - first);

        // Adjust the anchor
        this.setSelection(first - 1);
    } else {
        const anchorOffset = this.anchorOffset();
        if (dir < 0) {
            if (anchorOffset !== 0) {
                // We're not at the begining of the sibling list.
                // If the previous sibling is a compound (fractions, group),
                // just move into it, otherwise delete it
                const sibling = this.sibling(0);
                if (sibling.type === 'leftright') {
                    sibling.rightDelim = '?';
                    this.move(-1);
                } else if (!sibling.captureSelection &&
                    /^(group|array|genfrac|surd|leftright|font|overlap|overunder|color|box|mathstyle|sizing)$/.test(sibling.type)) {
                    this.move(-1);
                } else {
                    this._announce('delete', null, siblings.slice(anchorOffset, anchorOffset + 1));
                    siblings.splice(anchorOffset, 1);
                    this.setSelection(anchorOffset - 1);
                }
            } else {
                // We're at the beginning of the sibling list.
                // Delete what comes before
                const relation = this.relation();
                if (relation === 'superscript' || relation === 'subscript') {
                    const supsub = this.parent()[relation].filter(atom =>
                        atom.type !== 'placeholder' && atom.type !== 'first');
                    this.parent()[relation] = null;
                    this.path.pop();
                    Array.prototype.splice.apply(this.siblings(),
                        [this.anchorOffset(), 0].concat(supsub));
                    this.setSelection(this.anchorOffset() - 1);
                    this._announce('deleted: ' + relation);
                } else if (relation === 'denom') {
                    // Fraction denominator
                    const numer = this.parent().numer.filter(atom =>
                        atom.type !== 'placeholder' && atom.type !== 'first');
                    const denom = this.parent().denom.filter(atom =>
                        atom.type !== 'placeholder' && atom.type !== 'first');
                    this.path.pop();
                    Array.prototype.splice.apply(this.siblings(),
                        [this.anchorOffset(), 1].concat(denom));
                    Array.prototype.splice.apply(this.siblings(),
                        [this.anchorOffset(), 0].concat(numer));
                    this.setSelection(this.anchorOffset() + numer.length - 1);
                    this._announce('deleted: denominator');
                } else if (relation === 'body') {
                    const body = this.siblings().filter(atom => atom.type !== 'placeholder');
                    if (this.path.length > 1) {
                        body.shift();    // Remove the 'first' atom
                        this.path.pop();
                        Array.prototype.splice.apply(this.siblings(),
                            [this.anchorOffset(), 1].concat(body));
                        this.setSelection(this.anchorOffset() - 1);
                        this._announce('deleted: root');
                    }
                } else {
                    this.move(-1);
                    this.delete(-1);
                }

            }
        } else if (dir > 0) {
            if (anchorOffset !== siblings.length - 1) {
                if (/^(group|array|genfrac|surd|leftright|font|overlap|overunder|color|box|mathstyle|sizing)$/.test(this.sibling(1).type)) {
                    this.move(+1);
                } else {
                    this._announce('delete', null, siblings.slice(anchorOffset + 1, anchorOffset + 2));
                    siblings.splice(anchorOffset + 1, 1);
                }
            } else {
                // We're at the end of the sibling list, delete what comes next
                const relation = this.relation();
                if (relation === 'numer') {
                    const numer = this.parent().numer.filter(atom =>
                        atom.type !== 'placeholder' && atom.type !== 'first');
                    const denom = this.parent().denom.filter(atom =>
                        atom.type !== 'placeholder' && atom.type !== 'first');
                    this.path.pop();
                    Array.prototype.splice.apply(this.siblings(),
                        [this.anchorOffset(), 1].concat(denom));
                    Array.prototype.splice.apply(this.siblings(),
                        [this.anchorOffset(), 0].concat(numer));
                    this.setSelection(this.anchorOffset() + numer.length - 1);
                    this._announce('deleted: numerator');

                } else {
                    this.move(1);
                    this.delete(1);
                }
            }
        }
    }
    // Dispatch notifications
    this.suppressContentChangeNotifications = contentWasChanging;
    this.contentDidChange();
}


/**
 * @method EditableMathlist#moveToNextPlaceholder_
 */
EditableMathlist.prototype.moveToNextPlaceholder_ = function() {
    this.leap(+1);
}

/**
 * @method EditableMathlist#moveToPreviousPlaceholder_
 */
EditableMathlist.prototype.moveToPreviousPlaceholder_ = function() {
    this.leap(-1);
}

/**
 * @method EditableMathlist#moveToNextChar_
 */
EditableMathlist.prototype.moveToNextChar_ = function() {
    this.move(+1);
}

/**
 * @method EditableMathlist#moveToPreviousChar_
 */
EditableMathlist.prototype.moveToPreviousChar_ = function() {
    this.move(-1);
}

/**
 * @method EditableMathlist#moveUp_
 */
EditableMathlist.prototype.moveUp_ = function() {
    this.up();
}

/**
 * @method EditableMathlist#moveDown_
 */
EditableMathlist.prototype.moveDown_ = function() {
    this.down();
}

/**
 * @method EditableMathlist#moveToNextWord_
 */
EditableMathlist.prototype.moveToNextWord_ = function() {
    this.skip(+1);
}

/**
 * @method EditableMathlist#moveToPreviousWord_
 */
EditableMathlist.prototype.moveToPreviousWord_ = function() {
    this.skip(-1);
}

/**
 * @method EditableMathlist#moveToGroupStart_
 */
EditableMathlist.prototype.moveToGroupStart_ = function() {
    this.setSelection(0);
}

/**
 * @method EditableMathlist#moveToGroupEnd_
 */
EditableMathlist.prototype.moveToGroupEnd_ = function() {
    this.setSelection(-1);
}

/**
 * @method EditableMathlist#moveToMathFieldStart_
 */
EditableMathlist.prototype.moveToMathFieldStart_ = function() {
    this.jumpToMathFieldBoundary(-1);
}

/**
 * @method EditableMathlist#moveToMathFieldEnd_
 */
EditableMathlist.prototype.moveToMathFieldEnd_ = function() {
    this.jumpToMathFieldBoundary(+1);
}

/**
 * @method EditableMathlist#deleteNextChar_
 */
EditableMathlist.prototype.deleteNextChar_ = function() {
    this.delete_(+1);
}

/**
 * @method EditableMathlist#deletePreviousChar_
 */
EditableMathlist.prototype.deletePreviousChar_ = function() {
    this.delete_(-1);
}

/**
 * @method EditableMathlist#deleteNextWord_
 */
EditableMathlist.prototype.deleteNextWord_ = function() {
    this.extendToNextBoundary();
    this.delete_();
}

/**
 * @method EditableMathlist#deletePreviousWord_
 */
EditableMathlist.prototype.deletePreviousWord_ = function() {
    this.extendToPreviousBoundary();
    this.delete_();
}

/**
 * @method EditableMathlist#deleteToGroupStart_
 */
EditableMathlist.prototype.deleteToGroupStart_ = function() {
    this.extendToGroupStart();
    this.delete_();
}

/**
 * @method EditableMathlist#deleteToGroupEnd_
 */
EditableMathlist.prototype.deleteToGroupEnd_ = function() {
    this.extendToMathFieldStart();
    this.delete_();
}

/**
 * @method EditableMathlist#deleteToMathFieldEnd_
 */
EditableMathlist.prototype.deleteToMathFieldEnd_ = function() {
    this.extendToMathFieldEnd();
    this.delete_();
}

/**
 * Swap the characters to either side of the insertion point and advances
 * the insertion point past both of them. Does nothing to a selected range of
 * text.
 * @method EditableMathlist#transpose_
 */
EditableMathlist.prototype.transpose_ = function() {
    // @todo
}

/**
 * @method EditableMathlist#extendToNextChar_
 */
EditableMathlist.prototype.extendToNextChar_ = function() {
    this.extend(+1);
}

/**
 * @method EditableMathlist#extendToPreviousChar_
 */
EditableMathlist.prototype.extendToPreviousChar_ = function() {
    this.extend(-1);
}

/**
 * @method EditableMathlist#extendToNextWord_
 */
EditableMathlist.prototype.extendToNextWord_ = function() {
    this.skip(+1, {extend:true});
}

/**
 * @method EditableMathlist#extendToPreviousWord_
 */
EditableMathlist.prototype.extendToPreviousWord_ = function() {
    this.skip(-1, {extend:true});
}

/**
 * If the selection is in a denominator, the selection will be extended to
 * include the numerator.
 * @method EditableMathlist#extendUp_
 */
EditableMathlist.prototype.extendUp_ = function() {
    this.up({extend:true});
}

/**
 * If the selection is in a numerator, the selection will be extended to
 * include the denominator.
 * @method EditableMathlist#extendDown_
 */
EditableMathlist.prototype.extendDown_ = function() {
    this.down({extend:true});
}

/**
 * Extend the selection until the next boundary is reached. A boundary
 * is defined by an atom of a different type (mbin, mord, etc...)
 * than the current focus. For example, in "1234+x=y", if the focus is between
 * "1" and "2", invoking `extendToNextBoundary_` would extend the selection
 * to "234".
 * @method EditableMathlist#extendToNextBoundary_
 */
EditableMathlist.prototype.extendToNextBoundary_ = function() {
    this.skip(+1, {extend:true});
}

/**
 * Extend the selection until the previous boundary is reached. A boundary
 * is defined by an atom of a different type (mbin, mord, etc...)
 * than the current focus. For example, in "1+23456", if the focus is between
 * "5" and "6", invoking `extendToPreviousBoundary` would extend the selection
 * to "2345".
 * @method EditableMathlist#extendToPreviousBoundary_
 */
EditableMathlist.prototype.extendToPreviousBoundary_ = function() {
    this.skip(-1, {extend:true});
}

/**
 * @method EditableMathlist#extendToGroupStart_
 */
EditableMathlist.prototype.extendToGroupStart_ = function() {
    this.setExtent(-this.anchorOffset());
}

/**
 * @method EditableMathlist#extendToGroupEnd_
 */
EditableMathlist.prototype.extendToGroupEnd_ = function() {
    this.setExtent(this.siblings().length - this.anchorOffset());
}

/**
 * @method EditableMathlist#extendToMathFieldStart_
 */
EditableMathlist.prototype.extendToMathFieldStart_ = function() {
    this.jumpToMathFieldBoundary(-1, {extend:true});
}

/**
 * Extend the selection to the end of the math field.
 * @method EditableMathlist#extendToMathFieldEnd_
 */
EditableMathlist.prototype.extendToMathFieldEnd_ = function() {
    this.jumpToMathFieldBoundary(+1, {extend:true});
}

/**
 * Switch the cursor to the superscript and select it. If there is no subscript
 * yet, create one.
 * @method EditableMathlist#moveToSuperscript_
 */
EditableMathlist.prototype.moveToSuperscript_ = function() {
    this.collapseForward();
    if (!this.anchor().superscript) {
        if (this.anchor().subscript) {
            this.anchor().superscript =
                [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
        } else {
            const sibling = this.sibling(1);
            if (sibling && sibling.superscript) {
                this.path[this.path.length - 1].offset += 1;
    //            this.setSelection(this.anchorOffset() + 1);
            } else if (sibling && sibling.subscript) {
                this.path[this.path.length - 1].offset += 1;
    //            this.setSelection(this.anchorOffset() + 1);
                this.anchor().superscript =
                    [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
            } else {
                this.siblings().splice(
                    this.anchorOffset() + 1,
                    0,
                    new MathAtom.MathAtom(this.parent().parseMode, 'msubsup', '\u200b'));
                this.path[this.path.length - 1].offset += 1;
    //            this.setSelection(this.anchorOffset() + 1);
                this.anchor().superscript =
                    [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
            }
        }
    }
    this.path.push({relation: 'superscript', offset: 0});
    this.selectGroup_();
}

/**
 * Switch the cursor to the subscript and select it. If there is no subscript
 * yet, create one.
 * @method EditableMathlist#moveToSubscript_
 */
EditableMathlist.prototype.moveToSubscript_ = function() {
    this.collapseForward();
    if (!this.anchor().subscript) {
        if (this.anchor().superscript) {
            this.anchor().subscript =
                [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
        } else {
            const sibling = this.sibling(1);
            if (sibling && sibling.subscript) {
                this.path[this.path.length - 1].offset += 1;
                // this.setSelection(this.anchorOffset() + 1);
            } else if (sibling && sibling.superscript) {
                this.path[this.path.length - 1].offset += 1;
                // this.setSelection(this.anchorOffset() + 1);
                this.anchor().subscript =
                    [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
            } else {
                this.siblings().splice(
                    this.anchorOffset() + 1,
                    0,
                    new MathAtom.MathAtom(this.parent().parseMode, 'msubsup', '\u200b'));
                this.path[this.path.length - 1].offset += 1;
                // this.setSelection(this.anchorOffset() + 1);
                this.anchor().subscript =
                    [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
            }
        }
    }
    this.path.push({relation: 'subscript', offset: 0});
    this.selectGroup_();
}

/**
 * If cursor is currently in:
 * - superscript: move to subscript, creating it if necessary
 * - subscript: move to superscript, creating it if necessary
 * - numerator: move to denominator
 * - denominator: move to numerator
 * - otherwise: do nothing and return false
 * @return {boolean} True if the move was possible. False is there is no
 * opposite to move to, in which case the cursors is left unchanged.
 * @method EditableMathlist#moveToOpposite_
 */
EditableMathlist.prototype.moveToOpposite_ = function() {
    const OPPOSITE_RELATIONS = {
        'superscript': 'subscript',
        'subscript': 'superscript',
        'denom': 'numer',
        'numer': 'denom',
    }
    const oppositeRelation = OPPOSITE_RELATIONS[this.relation()];
    if (!oppositeRelation) {
        this.moveToSuperscript_();
        return false;
    }

    if (!this.parent()[oppositeRelation]) {
        // Don't have children of the opposite relation yet
        // Add them
        this.parent()[oppositeRelation] =
            [new MathAtom.MathAtom(this.parent().parseMode, 'first', null)];
    }

    this.setSelection(1, 'end', oppositeRelation);

    return true;
}

/**
 * @method EditableMathlist#moveBeforeParent_
 */
EditableMathlist.prototype.moveBeforeParent_ = function() {
    if (this.path.length > 1) {
        this.path.pop();
        this.setSelection(this.anchorOffset() - 1);
    } else {
        this._announce('plonk');
    }
}

/**
 * @method EditableMathlist#moveAfterParent_
 */
EditableMathlist.prototype.moveAfterParent_ = function() {
    if (this.path.length > 1) {
        const oldPath = clone(this);
        this.path.pop();
        this.setExtent(0);
        this._announce('move', oldPath);
    } else {
        this._announce('plonk');
    }
}



/**
 * Internal primitive to add a column/row in a matrix
 * @method EditableMathlist#_addCell
 * @private
 */
EditableMathlist.prototype._addCell = function(where) {
    // This command is only applicable if we're in an array
    const parent = this.parent();
    if (parent && parent.type === 'array' && Array.isArray(parent.array)) {
        const relation = this.relation();
        if (relation.startsWith('cell')) {
            const colRow = arrayColRow(parent,
                parseInt(relation.match(/cell([0-9]*)$/)[1]));

            if (where === 'after row' ||
                where === 'before row') {
                // Insert a row
                colRow.col = 0;
                colRow.row = colRow.row + (where === 'after row' ? 1 : 0);

                parent.array.splice(colRow.row, 0, [[]]);
            } else {
                // Insert a column
                colRow.col += (where === 'after column' ? 1 : 0);
                parent.array[colRow.row].splice(colRow.col, 0, []);
            }

            const cellIndex = arrayIndex(parent, colRow);

            this.selectionWillChange();
            this.path.pop();
            this.path.push({
                    relation: 'cell' + cellIndex.toString(),
                    offset: 0});
            this.insertFirstAtom();
            this.selectionDidChange();
        }
    }
}



/**
 * @method EditableMathlist#addRowAfter_
 */
EditableMathlist.prototype.addRowAfter_ = function() {
    this._addCell('after row');
}
/**
 * @method EditableMathlist#addRowBefore_
 */
EditableMathlist.prototype.addRowBefore_ = function() {
    this._addCell('before row');
}

/**
 * @method EditableMathlist#addColumnAfter_
 */
EditableMathlist.prototype.addColumnAfter_ = function() {
    this._addCell('after column');
}

/**
 * @method EditableMathlist#addColumnBefore_
 */
EditableMathlist.prototype.addColumnBefore_ = function() {
    this._addCell('before column');
}


function filterAtomsForStyle(atoms, style) {
    if (!atoms) return null;
    let result;
    if (Array.isArray(atoms)) {
        if (atoms.length === 1) {
            return filterAtomsForStyle(atoms[0], style);
        }
        result = [];
        for (const atom of atoms) {
            const filter = filterAtomsForStyle(atom, style);
            if (Array.isArray(filter)) {
                result = result.concat(filter);
            } else {
                result.push(filter);
            }
        }
        if (result.length === 0) return null;
    } else {
        if ((style.color && atoms.type === 'color') ||
            (style.backgroundColor && atoms.type === 'box')) {
            if (atoms.body[0].type === 'first') {
                atoms.body.shift();
            }
            result = filterAtomsForStyle(atoms.body, style);
        } else if (typeof atoms === 'object') {
            atoms.body = filterAtomsForStyle(atoms.body, style);
            atoms.superscript = filterAtomsForStyle(atoms.superscript, style);
            atoms.subscript = filterAtomsForStyle(atoms.subscript, style);
            atoms.index = filterAtomsForStyle(atoms.index, style);
            atoms.denom = filterAtomsForStyle(atoms.denom, style);
            atoms.numer = filterAtomsForStyle(atoms.numer, style);
            atoms.array = filterAtomsForStyle(atoms.array, style);
            result = atoms;
        } else {
            result = atoms;
        }
    }
    return result;
}



/**
 * @method EditableMathlist#applyStyle
 */

EditableMathlist.prototype._applyStyle = function(style) {
    let selection = null;
    const isCollapsed = this.isCollapsed();
    const selectionDirection = this.startOffset() === this.anchorOffset() ? +1 : -1;

    if (!isCollapsed) {
        // If the selection is the entire content of a style atom, select the
        // atom instead.
        const parent = this.parent();
        if (parent && (parent.type === 'box' || parent.type === 'color')) {
            if (this.startOffset() <= 1 && this.endOffset() === this.siblings().length) {
                this.path.pop();
                this.setSelection(this.startOffset(), 1);
            }
        }

        selection = this.extractContents();
        if (selection.length === 1 &&
            ((style.color &&
                selection[0].type === 'color' &&
                selection[0].textcolor === style.color) ||
            (style.backgroundColor &&
                selection[0].type === 'box' &&
                selection[0].backgroundcolor === style.backgroundColor) )) {
            // The selection is already with this style.
            // Toggle it
            selection = selection[0].body;
            if (selection[0].type === 'first') {
                selection.shift();
            }
            Array.prototype.splice.apply(this.siblings(),
                [this.startOffset(), 1].concat(selection));
            this.setSelection(this.startOffset(), selection ? selection.length : 0);
            return;
        }
        // Otherwise, remove existing style
        selection = filterAtomsForStyle(selection, style);
        if (!Array.isArray(selection)) selection = [selection];
        this.siblings().splice(this.startOffset() + 1,
            this.endOffset() - this.startOffset());
        // then apply this style.
    }

    if (style.color) {
        const styleAtom = new MathAtom.MathAtom(this.parseMode(), 'color', selection);
        styleAtom.latex = '\\textcolor';
        styleAtom.textcolor = style.color;
        styleAtom.skipBoundary = true;
        if (!styleAtom.body) {
            styleAtom.body = [new MathAtom.MathAtom(this.parseMode(), 'first', null)]
        } else if (styleAtom.body[0].type !== 'first') {
            styleAtom.body.unshift(new MathAtom.MathAtom(this.parseMode(), 'first', null))
        }
        const removeStyle = style.color === 'transparent' ||
            style.color === 'black' || style.color === '#000' || style.color === '#000000' ||
            (this.parent() && this.parent().type === 'color' && this.parent().textcolor === style.color);
        if (isCollapsed && this.parent() && this.parent().type === 'color') {
            this.path.pop();
            this.setSelection(this.startOffset(), 0);
            if (removeStyle) {
                return;
            }
            this.siblings().splice(this.startOffset() +  1 , 0, styleAtom);
        } else if (!isCollapsed && removeStyle) {
            if (this.parent() && this.parent().type === 'color') {
                styleAtom.textcolor = '#000';
                this.siblings().splice(this.startOffset(), 0, styleAtom);
            } else {
                if (selection.length > 0 && selection[0].type === 'first') {
                    selection.shift();
                }
                Array.prototype.splice.apply(this.siblings(), [this.startOffset(), 0].concat(selection));
                this.setSelection(this.startOffset(), selection.length);
                return;
            }
        } else {
            this.siblings().splice(this.startOffset() + (isCollapsed ? 1 : 0), 0, styleAtom);
        }


        selection = [this.sibling(0)];
    }


    if (style.backgroundColor) {
        const styleAtom = new MathAtom.MathAtom(this.parseMode(), 'box', selection);
        styleAtom.latex = '\\colorbox';
        styleAtom.backgroundcolor = style.backgroundColor;
        styleAtom.skipBoundary = true;
        if (!styleAtom.body) {
            styleAtom.body = [new MathAtom.MathAtom(this.parseMode(), 'first', null)]
        } else if (styleAtom.body[0].type !== 'first') {
            styleAtom.body.unshift(new MathAtom.MathAtom(this.parseMode(), 'first', null))
        }
        if (isCollapsed && this.parent() && this.parent().type === 'box') {
            const parentSameColor = style.backgroundColor === 'transparent' ||
                style.backgroundColor === 'white' || style.backgroundColor === '#fff' ||
                style.backgroundColor === '#ffffff' ||
                this.parent().backgroundcolor === style.backgroundColor;
            this.path.pop();
            this.setSelection(this.startOffset(), 0);
            if (parentSameColor) {
                return;
            }
            this.siblings().splice(this.startOffset() +  1 , 0, styleAtom);
        } else {
            this.siblings().splice(this.startOffset() + (isCollapsed ? 1 : 0), 0, styleAtom);
        }
    }
    if (isCollapsed) {
        this.setSelection(this.startOffset() + 1, 0);
        this.path.push({relation:'body', offset: 0});
        this.setSelection(0, 0);
        this.insertFirstAtom();
    } else {
        this.setExtent(selectionDirection);
    }
}




/**
 * Attempts to parse and interpret a string in an unknown format, possibly
 * MathASCII and return a canonical LaTeX string.
 * 
 * The format recognized are one of these variations:
 * - ASCIIMath: Only supports a subset 
 * (1/2x)
 * 1/2sin x                     -> \frac {1}{2}\sin x
 * 1/2sinx                      -> \frac {1}{2}\sin x
 * (1/2sin x (x^(2+1))          // Unbalanced parentheses
 * (1/2sin(x^(2+1))             -> \left(\frac {1}{2}\sin \left(x^{2+1}\right)\right)
 * alpha + (pi)/(4)             -> \alpha +\frac {\pi }{4}
 * x=(-b +- sqrt(b^2 – 4ac))/(2a)
 * alpha/beta
 * sqrt2 + sqrtx + sqrt(1+a) + sqrt(1/2)
 * f(x) = x^2 "when" x >= 0
 * AA n in QQ
 * AA x in RR "," |x| > 0
 * AA x in RR "," abs(x) > 0
 * 
 * - UnicodeMath (generated by Microsoft Word): also only supports a subset
 *      - See https://www.unicode.org/notes/tn28/UTN28-PlainTextMath-v3.1.pdf
 * √(3&x+1)
 * {a+b/c}
 * [a+b/c]
 * _a^b x 
 * lim_(n->\infty) n
 * \iint_(a=0)^\infty  a
 *
 * - "JavaScript Latex": a variant that is LaTeX, but with escaped backslashes
 *  \\frac{1}{2} \\sin x
 * @param {string} s 
 */
function parseMathString(s, config) {
    if (!s) return '';

    // Nothing to do if a single character
    if (s.length <= 1) return s;

    if (/\\/.test(s) && /{|}/.test(s)) {
        // If the string includes a '\' and a '{' or a '}'
        // it's probably a LaTeX string
        // (that's not completely true, it could be a UnicodeMath string, since
        // UnicodeMath supports some LaTeX commands. However, we need to pick
        // one in order to correctly interpret {} (which are argument delimiters
        // in LaTeX, and are fences in UnicodeMath)
        return s;
    }


    // Replace double-backslash (coming from JavaScript) to a single one
    s = s.replace(/\\\\/g, '\\');

    s = s.replace(/\u2061/gu, '');       // Remove function application
    s = s.replace(/\u3016/gu, '{');     // WHITE LENTICULAR BRACKET (grouping)
    s = s.replace(/\u3017/gu, '}');     // WHITE LENTICULAR BRACKET (grouping)


    s = s.replace(/([^\\])sinx/g,       '$1\\sin x');   // common typo
    s = s.replace(/([^\\])cosx/g,       '$1\\cos x ');  // common typo
    s = s.replace(/\u2013/g,            '-');      // EN-DASH, sometimes used as a minus sign

    let done = false;
    let m;

    if (!done && s[0] === '^' || s[0] === '_') {
        // Superscript and subscript
        m = parseMathArgument(s.substr(1), config);
        s = s[0] + '{' + parseMathString(m.match, config) + '}';
        s += parseMathString(m.rest, config);
        done = true;
    }

    if (!done) {
        m = s.match(/^(sqrt|\u221a)(.*)/);
        if (m) {
            // Square root
            m = parseMathArgument(m[2], config);
            const m2 = m.match.match(/(.*)&(.*)/);
            if (m2) {
                s = '\\sqrt[' + m2[1] + ']{' + parseMathString(m2[2], config) + '}';
            } else {
                s = '\\sqrt{' + parseMathString(m.match, config) + '}';
            }
            s += parseMathString(m.rest, config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^(\\cbrt|\u221b)(.*)/);
        if (m) {
            // Cube root
            m = parseMathArgument(m[2], config);
            s = '\\sqrt[3]{' + parseMathString(m.match, config) + '}';
            s += parseMathString(m.rest, config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^abs(.*)/);
        if (m) {
            // Absolute value
            m = parseMathArgument(m[1], config);
            s = '\\left|' + parseMathString(m.match, config) + '\\right|';
            s += parseMathString(m.rest, config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^"(.*)"(.*)/);
        if (m) {
            // Quoted text
            s = "\\text{ " + m[1] + ' }';
            s += parseMathString(m[2], config);
            done = true;
        }
    }

    if (!done) {
        m = parseMathArgument(s, config);
        if (m.match && m.rest[0] === '/') {
            // Fraction
            const m2 = parseMathArgument(m.rest.substr(1), config);
            if (m2.match) {
                s = '\\frac{' + parseMathString(m.match, config) + 
                    '}{' + parseMathString(m2.match, config) + 
                    '}' + parseMathString(m2.rest, config);
            }
            done = true;
        } else if (m.match && /\(|\{|\[/.test(s[0])) {
            const lFence = {'(' : '(', '{' : '\\{', '[' : '\\lbrack '}[s[0]] || '.';
            const rFence = {'(' : ')', '{' : '\\}', '[' : '\\rbrack '}[s[0]] || '.';
            s = '\\left' + lFence + parseMathString(m.match, config) + 
                '\\right' + rFence + parseMathString(m.rest, config);
            done = true;
        } else if (m.match) {
            s = m.match;
            s += parseMathString(m.rest, config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^(\s+)(.*)/);
        // Whitespace
        if (m) {
            s = ' ' + parseMathString(m[2], config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^([^a-zA-Z({[_^\\\s]+)(.*)/);
        // A string of symbols...
        if (m) {
            s = paddedShortcut(m[1], config);
            s += parseMathString(m[2], config);
            done = true;
        }
    }

    if (!done) {
        m = s.match(/^([a-zA-Z]+)(.*)/);
        if (m) {
            // Some alphabetical string...
            s = m[1];
            s += parseMathString(m[2], config);
            done = true;
        }
    }

    return s;
}

/**
 * Parse a math argument, as defined by ASCIIMath and UnicodeMath:
 * - Either an expression fenced in (), {} or []
 * - a sequence of digits
 * - a sequence of [a-zA-Z] letters
 * - a LaTeX command (\pi)
 * @param {string} s 
 */
function parseMathArgument(s, config) {
    let match = '';
    let rest = s;
    const lFence = s.charAt(0);
    const rFence = {'(' : ')', '{' : '}', '[' : ']'}[lFence];
    if (rFence) {
        // It's a fence
        let level = 1;
        let i = 1;
        while (i < s.length && level > 0) {
            if (s[i] === lFence) level++;
            if (s[i] === rFence) level--;
            i++;
        }
        if (level === 0) {
            // We've found the matching closing fence
            match = s.substring(1, i - 1);
            rest = s.substring(i);
        } else {
            // Unbalanced fence...
            match = s.substring(1, i);
            rest = '';
        }
    } else {
        let m = s.match(/^([0-9]+|[a-zA-Z]+)/);
        if (m) {
            // It's a string of digits or a string of letters
            rest = s.substring(m[1].length);
            match = paddedShortcut(m[1], config);
        } else if (!/^\\(left|right)/.test(s)) {
            // It's a LaTeX command (but not a \left\right)
            m = s.match(/^(\\[a-zA-Z]+)/);
            if (m) {
                rest = s.substring(m[1].length);
                match = m[1];
            }
        }
    }

    return { match: match, rest: rest };
}

function paddedShortcut(s, config) {
    let result = Shortcuts.forString(s, config);
    if (result) {
        result = result.replace('_{#?}', '');
        result = result.replace('^{#?}', '');
        result += ' '
    } else {
        result = s;
    }
    return result;
}

export default {
    EditableMathlist: EditableMathlist
}

(function (factory) {
        if (typeof define === 'function' && define.amd) {
            define(['jquery'], factory);
        } else if (typeof module === 'object' && module.exports) {
            module.exports = factory(require('jquery'));
        } else {
            factory(window.jQuery);
        }
    }(function ($) {
      
          // Extends summernote
          $.extend(true, $.summernote, {

            options: {
              popover: {
                math: [
                  ['math', ['edit-math', 'delete-math']],
                ],
              },
            },

            lang: {
              'de-DE': {
                math: {
                  title: 'Formel einfügen',
                },
              },
            },

          });
      
        $.extend($.summernote.plugins, {
            'mathPlugin': function (context) {
                var self = this,
                    ui = $.summernote.ui,
                    dom = $.summernote.dom,
                    $note = context.layoutInfo.note,
                    $editor = context.layoutInfo.editor,
                    $editable = context.layoutInfo.editable,
                    $toolbar = context.layoutInfo.toolbar,
                    options = context.options,
                    lang = options.langInfo;

                context.memo('button.math', function () {
                    var button = ui.button({
                        contents: '<i class="fas fa-calculator"/>',
                        tooltip: 'Formel einfügen',
                        click: function(e) {
                            context.invoke('mathPlugin.insertMath');
                        }
                    });
                    return button.render(); 
                });
                
                context.memo('button.edit-math', function () {
                    var button = ui.button({
                        contents: '<i class="fas fa-pen"/>',
                        tooltip: 'Formel ändern',
                        click: function(e) {
                            context.invoke('mathPlugin.editMath');
                        }
                    });
                    return button.render(); 
                });
                
                context.memo('button.delete-math', function () {
                    var button = ui.button({
                        contents: '<i class="fas fa-trash"/>',
                        tooltip: 'Formel löschen',
                        click: function(e) {
                            context.invoke('mathPlugin.deleteMath');
                        }
                    });
                    return button.render(); 
                });
                
                self.events = {
                      'summernote.keyup summernote.mouseup summernote.change summernote.scroll': function() {
                        self.update();
                      },
                      'summernote.dialog.shown': function() {
                          self.$popover.hide();
                      },
                };
                
                this.initialize = function () {
                  var $container = options.dialogsInBody ? $(document.body) : $editor;
                  this.$dialog = ui.dialog({
                      title: "Formel einfügen",
                      fade: options.dialogsFade,
                      body: '<span id="formula"> \\( e=mc^2 \\) </span>',
                      footer: '<button type="button" class="btn btn-secondary" data-dismiss="modal">Abbrechen</button><button type="button" class="btn btn-primary note-mathPlugin-btn">Einfügen</button>'
                  }).render().appendTo($container);
                  
                  self.$popover = ui.popover({
                      className: 'ext-math-popover',
                  }).render().appendTo('body');
                  var $content = self.$popover.find('.popover-content');
                   context.invoke('buttons.build', $content, options.popover.math);
                }
                self.update = function() {
                    // Prevent focusing on editable when invoke('code') is executed
                    if (!context.invoke('editor.hasFocus')) {
                      self.$popover.hide();
                      return;
                    }

                    var rng = context.invoke('editor.createRange');
                    var visible = false;

                    var formula = $(rng.sc).closest('.formula');
                    if (formula.length == 1) {
                      window.currentMathElement = formula[0];
                      var pos = dom.posFromPlaceholder(window.currentMathElement);
                      
                      self.$popover.css({
                        display: 'block',
                        left: pos.left,
                        top: pos.top,
                      });

                      visible = true;
                    }

                    // hide if not visible
                    if (!visible) {
                      self.$popover.hide();
                    }
                };
                this.destroy = function () {
                    ui.hideDialog(this.$dialog);
                    this.$dialog.remove();
                    
                    this.$popover.remove();
                    this.$popover = null;
                };
                this.insertMath = function () {
                    document.getElementById('formula').innerHTML = "\\( e=mc^2 \\)";
                    window.formula = MathLive.makeMathField(document.getElementById('formula'), { virtualKeyboardMode: 'manual' });
                  
                    var $img = $($editable.data('target'));
                    var editorInfo = {

                    };
                    this.openDialog(editorInfo).then(function (editorInfo) {
                        ui.hideDialog(self.$dialog);
                        
                        var node = document.createElement('span');
                        node.className = "formula";
                        node.innerHTML = "\\( " + window.formula.$latex() + " \\)";
                        
                        $("#formula").find("*").off();
                        window.formula = null;
                        
                        var parentNode = document.createElement('span');
                        parentNode.appendChild(document.createTextNode(' '));
                        parentNode.appendChild(node);
                        parentNode.appendChild(document.createTextNode(' '));
                        
                        MathLive.renderMathInElement(node);
                        $('article').summernote('insertNode', parentNode);
                    });
                };
                this.editMath = function () {
                  
                    document.getElementById('formula').innerHTML = "\\( " + MathLive.getOriginalContent(window.currentMathElement) + " \\)";
                    window.formula = MathLive.makeMathField(document.getElementById('formula'), { virtualKeyboardMode: 'manual' });
                  
                    var $img = $($editable.data('target'));
                    var editorInfo = {

                    };
                    this.openDialog(editorInfo).then(function (editorInfo) {
                        ui.hideDialog(self.$dialog);
                        
                        window.currentMathElement.innerHTML = "\\( " + window.formula.$latex() + " \\)";
                        
                        $("#formula").find("*").off();
                        window.formula = null;
                        
                        MathLive.renderMathInElement(window.currentMathElement);
                      //  window.currentMathElement.contentEditable = false;
                    });
                };
                this.deleteMath = function () {
                  window.currentMathElement.remove();
                  self.$popover.hide();
                };
                this.openDialog = function (editorInfo) {
                    return $.Deferred(function (deferred) {
                        var $insertBtn = self.$dialog.find('.note-mathPlugin-btn');
                        ui.onDialogShown(self.$dialog, function () {
                            context.triggerEvent('dialog.shown');
                            $insertBtn.click(function (e) {
                                e.preventDefault();
                                deferred.resolve({});
                            });
                        });
                        ui.onDialogHidden(self.$dialog, function () {
                            $insertBtn.off('click');
                            if (deferred.state() === 'pending') deferred.reject();
                        });
                        ui.showDialog(self.$dialog);
                    });
                };
            }
        })
    }));
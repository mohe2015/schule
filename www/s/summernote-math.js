/**
 * 
 * copyright 2019 Moritz Hedtke.
 * email: Moritz.Hedtke@t-online.de
 * license: GLP-3.0.
 * 
 */
(function (factory) {
        /* Global define */
        if (typeof define === 'function' && define.amd) {
            // AMD. Register as an anonymous module.
            define(['jquery'], factory);
        } else if (typeof module === 'object' && module.exports) {
            // Node/CommonJS
            module.exports = factory(require('jquery'));
        } else {
            // Browser globals
            factory(window.jQuery);
        }
    }(function ($) {
        /**
         * @class plugin.examplePlugin
         *
         * example Plugin
         */

        $.extend($.summernote.plugins, {
            /**
             *  @param {Object} context - context object has status of editor.
             */
            'mathPlugin': function (context) {
                var self = this,

                    // ui has renders to build ui elements
                    // for e.g. you can create a button with 'ui.button'
                    ui = $.summernote.ui,
                    $note = context.layoutInfo.note,

                    // contentEditable element
                    $editor = context.layoutInfo.editor,
                    $editable = context.layoutInfo.editable,
                    $toolbar = context.layoutInfo.toolbar,

                    // options holds the Options Information from Summernote and what we extended above.
                    options = context.options,

                    // lang holds the Language Information from Summernote and what we extended above.
                    lang = options.langInfo;

                context.memo('button.math', function () {
                    var button = ui.button({
                        contents: '<i class="fas fa-calculator"/>',
                        tooltip: 'Formel einfügen',
                        click: function(e) {
                            context.invoke('mathPlugin.insertMath');
                            //window.formula = MathLive.makeMathField(document.getElementById('formula'), { virtualKeyboardMode: 'manual' });
                            //$('#mathModal').modal('show');
                        }
                    });
                    return button.render(); 
                });
                this.initialize = function () {

                    // This is how we can add a Modal Dialog to allow users to interact with the Plugin.

                    // get the correct container for the plugin how it's attached to the document DOM.
                    var $container = options.dialogsInBody ? $(document.body) : $editor;

                    /*
                     *     
    <div class="modal fade" id="mathModal" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-full" role="document">
        <div class="modal-content h-100">
          <div class="modal-header">
            <h5 class="modal-title">Formel einfügen</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div id="formula">
              \(ax^2+bx+c = 
              a 
              \left( x - \frac{-b + \sqrt {b^2-4ac}}{2a} \right) 
              \left( x - \frac{-b - \sqrt {b^2-4ac}}{2a} \right)\)
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Abbrechen</button>
            <button id="insertMath" type="button" class="btn btn-primary">Einfügen</button>
          </div>
        </div>
      </div>
    </div>
    */
                  this.$dialog = ui.dialog({

                      // Set the title for the Dialog. Note: We don't need to build the markup for the Modal
                      // Header, we only need to set the Title.
                      title: "Formel einfügen",

                      // Set the Body of the Dialog.
                      body: '<div id="formula"> \( e=mc^2 \) </div>',

                      // Set the Footer of the Dialog.
                      footer: '<button type="button" class="btn btn-secondary" data-dismiss="modal">Abbrechen</button><button type="button" class="btn btn-primary note-mathPlugin-btn">Einfügen</button>'

                      // This adds the Modal to the DOM.
                  }).render().appendTo($container);
                }
                this.destroy = function () {
                    ui.hideDialog(this.$dialog);
                    this.$dialog.remove();
                };
                this.bindEnterKey = function ($input, $btn) {
                    $input.on('keypress', function (event) {
                        if (event.keyCode === 13) $btn.trigger('click');
                    });
                };
                this.bindLabels = function () {
                    self.$dialog.find('.form-control:first').focus().select();
                    self.$dialog.find('label').on('click', function () {
                        $(this).parent().find('.form-control:first').focus();
                    });
                };
                this.insertMath = function () {
                    var $img = $($editable.data('target'));
                    var editorInfo = {

                    };
                    this.showexamplePluginDialog(editorInfo).then(function (editorInfo) {
                        ui.hideDialog(self.$dialog);
                        $note.val(context.invoke('code'));
                        $note.change();
                    });
                };
                this.showexamplePluginDialog = function (editorInfo) {
                    return $.Deferred(function (deferred) {
                        ui.onDialogShown(self.$dialog, function () {
                            context.triggerEvent('dialog.shown');
                            var $insertBtn = self.$dialog.find('.note-mathPlugin-btn');
                            $insertBtn.click(function (e) {
                                e.preventDefault();
                                deferred.resolve({

                                });
                            });
                            self.bindEnterKey($insertBtn);
                            self.bindLabels();
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

(function (factory) {
        if (typeof define === 'function' && define.amd) {
            define(['jquery'], factory);
        } else if (typeof module === 'object' && module.exports) {
            module.exports = factory(require('jquery'));
        } else {
            factory(window.jQuery);
        }
    }(function ($) {
        $.extend($.summernote.plugins, {
            'mathPlugin': function (context) {
                var self = this,
                    ui = $.summernote.ui,
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
                this.initialize = function () {
                  var $container = options.dialogsInBody ? $(document.body) : $editor;
                  this.$dialog = ui.dialog({
                      title: "Formel einfügen",
                      fade: options.dialogsFade,
                      body: '<div id="formula"> \( e=mc^2 \) </div>',
                      footer: '<button type="button" class="btn btn-secondary" data-dismiss="modal">Abbrechen</button><button type="button" class="btn btn-primary note-mathPlugin-btn">Einfügen</button>'
                  }).render().appendTo($container);
                  
                  self.$popover = ui.popover({
                      className: 'ext-math-popover',
                  }).render().appendTo('body');
                  var $content = self.$popover.find('.popover-content');
                }
                this.destroy = function () {
                    ui.hideDialog(this.$dialog);
                    this.$dialog.remove();
                    
                    this.$popover.remove();
                    this.$popover = null;
                };
                this.insertMath = function () {
                    window.formula = MathLive.makeMathField(document.getElementById('formula'), { virtualKeyboardMode: 'manual' });
                  
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
                        var $insertBtn = self.$dialog.find('.note-mathPlugin-btn');
                        ui.onDialogShown(self.$dialog, function () {
                            context.triggerEvent('dialog.shown');
                            $insertBtn.click(function (e) {
                                e.preventDefault();
                                
                                window.formula.$revertToOriginalContent();
                                window.formula = null;
                                var node = document.createElement('div');
                                node.className = "formula";
                                node.innerHTML = $('#formula').html();
                                $('article').summernote('insertNode', node);
                                $('.formula').each(function (f) {
                                  MathLive.renderMathInElement(this);
                                  this.contentEditable = "false";
                                });
                                
                                deferred.resolve({
                                });
                            });
                        });
                        ui.onDialogHidden(self.$dialog, function () {
                            $insertBtn.off('click');
                            if (deferred.state() === 'pending') deferred.reject();
                            if (window.formula !== null) {
                              window.formula.$revertToOriginalContent();
                            }
                        });
                        ui.showDialog(self.$dialog);
                    });
                };
            }
        })
    }));

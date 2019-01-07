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
                            //window.formula = MathLive.makeMathField(document.getElementById('formula'), { virtualKeyboardMode: 'manual' });
                            //$('#mathModal').modal('show');
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

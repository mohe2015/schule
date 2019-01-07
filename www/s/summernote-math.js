/**
 * 
 * copyright [year] [your Business Name and/or Your Name].
 * email: your@email.com
 * license: Your chosen license, or link to a license file.
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
            'examplePlugin': function (context) {
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

                context.memo('button.examplePlugin', function () {

                    // Here we create a button
                    var button = ui.button({

                        // icon for button
                        contents: options.examplePlugin.icon,

                        // tooltip for button
                        tooltip: lang.examplePlugin.tooltip,
                        click: function (e) {
                            context.invoke('examplePlugin.show');
                        }
                    });
                    return button.render();
                });
                this.initialize = function () {

                    // This is how we can add a Modal Dialog to allow users to interact with the Plugin.

                    // get the correct container for the plugin how it's attached to the document DOM.
                    var $container = options.dialogsInBody ? $(document.body) : $editor;

                    // Build the Body HTML of the Dialog.
                    var body = '<div class="form-group">' +
                        '</div>';

                    // Build the Footer HTML of the Dialog.
                    var footer = '<button href="#" class="btn btn-primary note-examplePlugin-btn">' + lang.examplePlugin.okButton + '</button>'
                }
                this.$dialog = ui.dialog({

                    // Set the title for the Dialog. Note: We don't need to build the markup for the Modal
                    // Header, we only need to set the Title.
                    title: lang.examplePlugin.dialogTitle,

                    // Set the Body of the Dialog.
                    body: body,

                    // Set the Footer of the Dialog.
                    footer: footer

                    // This adds the Modal to the DOM.
                }).render().appendTo($container);
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
                this.show = function () {
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
                            $editBtn.click(function (e) {
                                e.preventDefault();
                                deferred.resolve({

                                });
                            });
                            self.bindEnterKey($editBtn);
                            self.bindLabels();
                        });
                        ui.onDialogHidden(self.$dialog, function () {
                            $editBtn.off('click');
                            if (deferred.state() === 'pending') deferred.reject();
                        });
                        ui.showDialog(self.$dialog);
                    });
                };
            }
        })
    }));

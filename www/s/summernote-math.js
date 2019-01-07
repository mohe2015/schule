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
                  ['math', ['math']],
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
                
                self.events = {
                      'summernote.keyup summernote.mouseup summernote.change summernote.scroll': function() {
                        self.update();
                      },
                      'summernote.dialog.shown': function() {
                        self.hidePopover();
                      },
                };
                
                this.initialize = function () {
                  var $container = options.dialogsInBody ? $(document.body) : $editor;
                  this.$dialog = ui.dialog({
                      title: "Formel einfügen",
                      fade: options.dialogsFade,
                      body: '<div id="formula"> \\( e=mc^2 \\) </div>',
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
                      self.hidePopover();
                      return;
                    }

                    var rng = context.invoke('editor.createRange');
                    var visible = false;

                    var formula = $(rng.sc).closest('.formula');
                    if (formula.length == 1) {
                      var pos = dom.posFromPlaceholder(formula[0]);
                      
                      self.$popover.css({
                        display: 'block',
                        left: pos.left,
                        top: pos.top,
                      });

                      visible = true;
                    }

                    // hide if not visible
                    if (!visible) {
                      self.hidePopover();
                    }
                };
                self.hidePopover = function() {
                  self.$popover.hide();
                };
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
                    this.openDialog(editorInfo).then(function (editorInfo) {
                        ui.hideDialog(self.$dialog);
                        
                        window.formula.$revertToOriginalContent();
                        window.formula = null;
                        
                        var node = document.createElement('div');
                        node.className = "formula";
                        node.innerHTML = $('#formula').html();
                        MathLive.renderMathInElement(node);
                        this.contentEditable = false;
                        $('article').summernote('insertNode', node);
                    });
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

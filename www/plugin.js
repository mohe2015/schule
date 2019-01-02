(function(factory) {
  /* global define */
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
}(function($) {
  // Extends plugins for adding hello.
  //  - plugin is external module for customizing.
  $.extend($.summernote.plugins, {
    /**
     * @param {Object} context - context object has status of editor.
     */
    'classesPlugin': function(context) {
      var self = this;

      // ui has renders to build ui elements.
      //  - you can create a button with `ui.button`
      var ui = $.summernote.ui;

      // add hello button
      context.memo('button.hello', function() {
        // create button
        var button = ui.button({
          contents: '<i class="fa fa-child"/> Hello',
          tooltip: 'hello',
          click: function() {
            self.$panel.show();
            self.$panel.hide(500);
            // invoke insertText method with 'hello' on editor module.
            context.invoke('editor.insertText', 'hello');
          },
        });

        // create jQuery object from button instance.
        var $hello = button.render();
        return $hello;
      });
    }
  });
}));
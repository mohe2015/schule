/*eslint-env browser, jquery*/
$(document).ready(function() {

    var FinishedButton = function (context) {
      var ui = $.summernote.ui;
      var button = ui.button({
        contents: '<i class="fa fa-check"/>',
        tooltip: 'Fertig',
        click: function () {
          $('article').summernote('destroy');
          $("#edit-button").show();
          $('.tooltip').hide();
        }
      });
      return button.render();
    }

    var CancelButton = function (context) {
      var ui = $.summernote.ui;
      var button = ui.button({
        contents: '<i class="fa fa-times"/>',
        tooltip: 'Abbrechen',
        click: function () {
            $('article').summernote('destroy');
            $("#edit-button").show();
            $('.tooltip').hide();
        }
      });

      return button.render();
    }

    
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
    'hello': function(context) {
      var self = this;

      // ui has renders to build ui elements.
      //  - you can create a button with `ui.button`
      var ui = $.summernote.ui;

     
      // This method will be called when editor is initialized by $('..').summernote();
      // You can create elements for plugin
      this.initialize = function() {
        // Find editor
            var $editor = $('.note-editor'),
                $toolbar = $editor.find('.note-toolbar');
            // Scrolling event
            var repositionToolbar = function() {
                var windowTop = $(window).scrollTop(),
                    editorTop = $editor.offset().top,
                    editorBottom = editorTop + $editor.height();
                if (windowTop > editorTop && windowTop < editorBottom) {
                    $toolbar.css('position', 'fixed');
                    $toolbar.css('top', '0px');
                    $toolbar.css('width', $editor.width() + 'px');
                    $toolbar.css('z-index', '1039');
                    $editor.css('padding-top', '42px');
                }
                else {
                    $toolbar.css('position', 'static');
                    $editor.css('padding-top', '0px');
                }
            };
            // Move it
            $(window).scroll(repositionToolbar);
            repositionToolbar();
      };

    },
  });
}));    
        
    $("#edit-button").click(function() {
        $("#edit-button").hide();
$('article').summernote({
  buttons: {
    finished: FinishedButton,
      cancel: CancelButton
  },
  toolbar: [
    ['style', ['bold', 'italic', 'underline', 'superscript', 'subscript']],
    ['para', ['ul', 'ol', 'indent', 'outdent',  'justifyLeft', 'justifyCenter' ]],
    ['insert', ['link', 'picture', 'video', 'table']],
    ['management', ['undo', 'redo', 'help', 'cancel', 'finished']]
  ]
});
});
    
    
   // $('.note-status-output').first().html(
//  '<div class="alert alert-danger">' +
//    'This is an error using a Bootstrap alert that has been restyled to fit here.' +
 // '</div>'
//);

   $.get("api/wiki/Startseite", function (data) {
        $('article').html( data );
   })
    .fail(function() {
      alert("Fehler beim Laden des Artikels!");
   });
    
    
    
});

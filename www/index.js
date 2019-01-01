/*eslint-env browser, jquery*/
$(document).ready(function() {

    var FinishedButton = function (context) {
      var ui = $.summernote.ui;
      var button = ui.button({
        contents: '<i class="fa fa-check"/>',
        tooltip: 'Fertig',
        click: function () {
          $('article').summernote('destroy');
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
            $('.tooltip').hide();
        }
      });

      return button.render();
    }

        
    $(".edit-button").click(function() {
        $('article').summernote({
          dialogsFade: true,
          focus: true,
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
        $('article').summernote('fullscreen.toggle');
    });
    
    
   // $('.note-status-output').first().html(
//  '<div class="alert alert-danger">' +
//    'This is an error using a Bootstrap alert that has been restyled to fit here.' +
 // '</div>'
//);

   $.get("api/wiki/Startseite", function (data) {
        $('article').html( data );
       
       $('#loading').fadeOut('slow');
      $('#page').fadeIn('slow');
       
   })
    .fail(function() {
      alert("Fehler beim Laden des Artikels!");
   });
    
    
    
});

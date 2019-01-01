/*eslint-env browser, jquery*/
$(document).ready(function() {

    var FinishedButton = function(context) {
        var ui = $.summernote.ui;
        var button = ui.button({
            contents: '<i class="fa fa-check"/>',
            tooltip: 'Fertig',
            click: function() {

                $('#publish-changes-modal').on('shown.bs.modal', function() {
                    $('#change-summary').trigger('focus')
                });

                // modal 1050
                // modal backdrop: 1040
                $('#publish-changes-modal').modal('show');


                // $('article').summernote('destroy');
                //  $('.tooltip').hide();
            }
        });
        return button.render();
    }

    var CancelButton = function(context) {
        var ui = $.summernote.ui;
        var button = ui.button({
            contents: '<i class="fa fa-times"/>',
            tooltip: 'Abbrechen',
            click: function() {
                $('article').summernote('destroy');
                $('.tooltip').hide();
            }
        });

        return button.render();
    }

    $('#publish-changes').click(function() {
        $('#publish-changes').hide();
        $('#publishing-changes').show();

        $.post("api/wiki/Startseite", function(data) {
            $('article').html(data);

            $('#loading').fadeOut('slow');
            $('#page').fadeIn('slow');

        })
        .fail(function() {
            alert("Fehler beim Laden des Artikels!");
        });
    });


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
                ['para', ['ul', 'ol', 'indent', 'outdent', 'justifyLeft', 'justifyCenter']],
                ['insert', ['link', 'picture', 'video', 'table']],
                ['management', ['undo', 'redo', 'help', 'cancel', 'finished']]
            ]
        });
        $('article').summernote('fullscreen.toggle');
    });

    $.get("api/wiki/Startseite", function(data) {
        $('article').html(data);

        $('#loading').fadeOut('slow');
        $('#page').fadeIn('slow');

    })
    .fail(function() {
        alert("Fehler beim Laden des Artikels!");
    });
});
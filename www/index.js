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

                $('#publish-changes-modal').modal('show');
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
                $('article').summernote('fullscreen.toggle');
                $('article').summernote('destroy');
                $('.tooltip').hide();
            }
        });

        return button.render();
    }

    function readCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for (var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) == ' ') c = c.substring(1, c.length);
                if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
            }
            return null;
        }
    
    $('#publish-changes').click(function() {
        $('#publish-changes').hide();
        $('#publishing-changes').show();

        var changeSummary = $('#change-summary').html();
        var newHtml = $('article').summernote('code');
        
        $.post("/api/wiki/Startseite", { summary: changeSummary, html: newHtml, csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            $('article').summernote('fullscreen.toggle');
            $('article').summernote('destroy');
            
            $('#publish-changes-modal').modal('hide');
            
            $('#publish-changes').show();
            $('#publishing-changes').hide();
        })
        .fail(function() {
            $('#publish-changes').show();
            $('#publishing-changes').hide();
          
            alert("Fehler beim Speichern des Artikels!");
        });
        
        // TODO dismiss should cancel request
    });

    
    function sendFile(file, editor, welEditable) {
        $('#uploadProgressModal').modal('show');
        data = new FormData();
        data.append("file", file);
        $.ajax({
            data: data,
            type: 'POST',
            xhr: function() {
                var myXhr = $.ajaxSettings.xhr();
                if (myXhr.upload) myXhr.upload.addEventListener('progress',progressHandlingFunction, false);
                return myXhr;
            },
            url: '/api/upload',
            cache: false,
            contentType: false,
            processData: false,
            success: function(url) {
                $('article').summernote('insertImage', '/api/file/' + url);
                $('#uploadProgressModal').modal('hide');
            }
        });
    }

    // update progress bar

    function progressHandlingFunction(e){
        if(e.lengthComputable){
            $('#uploadProgress').css('width', (100 * e.loaded / e.total) + '%');
            // reset progress on complete
            if (e.loaded == e.total) {
                $('#uploadProgress').attr('width','0%');
            }
        }
    }

    $(".edit-button").click(function() {
        $('article').summernote({
            callbacks: {
              onImageUpload: function(files) {
                sendFile(files[0]);
              }
            },
            dialogsFade: true,
            focus: true,
            buttons: {
                finished: FinishedButton,
                cancel: CancelButton
            },
            toolbar: [
                ['style', ['style', 'bold', 'italic', 'underline', 'strikethrough', 'superscript', 
'subscript']],
                ['para', ['ul', 'ol', 'indent', 'outdent', 'justifyLeft', 'justifyCenter']],
                ['insert', ['link', 'picture', 'video', 'table']],
                ['management', ['undo', 'redo', 'help', 'cancel', 'finished', 'codeview']]
            ]
        });
        $('article').summernote('fullscreen.toggle');
    });
    
    $("#show-history").click(function () {
        $('.my-tab').fadeOut({queue: false});
        $('#loading').fadeIn({queue: false});
        
        $.get("/api/history/Startseite", function(data) {
            //$('article').html(data);
            
            window.history.pushState(null, "Änderungsverlauf Startseite", "/wiki/Startseite/history");

            $('#loading').fadeOut({queue: false});
            $('#history').fadeIn({queue: false});
        })
        .fail(function() {
            alert("Fehler beim Laden des Änderungsverlaufs!");
        });
    });

    $.get("/api/wiki/Startseite", function(data) {
        $('article').html(data);

        $('.my-tab').fadeOut({queue: false});
        $('#page').fadeIn({queue: false});
    })
    .fail(function() {
        alert("Fehler beim Laden des Artikels!");
    });
    
    window.onpopstate = function (event) {
        //alert("TODO");
    };
    
    
});

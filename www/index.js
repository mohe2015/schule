/*eslint-env browser, jquery*/
$(document).ready(function() {

    function setFullscreen(value) {
      if (value && $('.fullscreen').length == 0) {
        console.log("enable fullscreen");
        $('article').summernote('fullscreen.toggle');
      } else if (!value && $('.fullscreen').length == 1) {
        console.log("disable fullscreen");
        $('article').summernote('fullscreen.toggle');
      }
    }
  
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
                window.history.back();
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
        
        $.post("/api/wiki/" + window.location.pathname.substr(6), { summary: changeSummary, html: newHtml, csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            replaceState(null, null, window.location.pathname.substr(window.location.pathname.lastIndexOf("/")));
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
        data.append("csrf_token", readCookie('CSRF_TOKEN'));
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
                $('#uploadProgressModal').modal('hide');
                $('article').summernote('insertImage', '/api/file/' + url);
            },
            error: function() {
              $('#uploadProgressModal').modal('hide');
              alert("Fehler beim Upload!");
            }
        });
    }

    function progressHandlingFunction(e){
        if(e.lengthComputable){
            $('#uploadProgress').css('width', (100 * e.loaded / e.total) + '%');
            // reset progress on complete
            if (e.loaded == e.total) {
                $('#uploadProgress').attr('width','0%');
            }
        }
    }

    function showEditor() {
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
        setFullscreen(true);
    }
    
    function hideEditor() {
      setFullscreen(false);
      $('article').summernote('destroy');
      $('.tooltip').hide(); 
    }
    
    $(".edit-button").click(function(e) {
        e.preventDefault();
        window.history.pushState(null, null, window.location.pathname + "/edit");
        updateState();
        return false;
    });
    
    $("#create-article").click(function(e) {
        e.preventDefault();
        window.history.pushState(null, null, window.location.pathname + "/create");
        updateState();
        return false;
    });
    
    $("#show-history").click(function () {
        $('.my-tab').fadeOut({queue: false});
        $('#loading').fadeIn({queue: false});
        
        $.get("/api/history/" + window.location.pathname.substr(6), function(data) {
            //$('article').html(data);
            
            window.history.pushState(null, "Änderungsverlauf " + window.location.pathname.substr(6), "/wiki/" + window.location.pathname.substr(6) + "/history");

            $('#loading').fadeOut({queue: false});
            $('#history').fadeIn({queue: false});
        })
        .fail(function() {
            alert("Fehler beim Laden des Änderungsverlaufs!");
        });
    });
    
    // /wiki/:name
    // /wiki/:name/history
    // /wiki/:name/discussion
    // /wiki/:name/edit
    // /wiki/:name/create
    // /search/:query
    
    function cleanup() {
      setFullscreen(false);
      $('article').summernote('destroy');
            
      $('#publish-changes-modal').modal('hide');
      
      $('#publish-changes').show();
      $('#publishing-changes').hide(); 
    }
    
    // the url should contain the main state and the state object may contain additional information which is not show in the url
    function updateState() {
      //if (history.state && history.state.currentState == 'create-article') {
        
        
        
      //  return;
      //}
      
      var pathname = window.location.pathname.split('/');
      console.log(pathname);
      if (pathname.length > 1 && pathname[1] == 'wiki') {
        if (pathname.length == 3) { // /wiki/:name
          $.get("/api/wiki/" + pathname[2], function(data) {
              $('article').html(data);

              $('.my-tab').fadeOut({queue: false});
              $('#page').fadeIn({queue: false});
              
              window.history.replaceState({ currentState: 'show-article' }, null, null);
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (textStatus === 'error' && errorThrown === 'Not Found') {
                  $('.my-tab').fadeOut({queue: false});
                  $('#not-found').fadeIn({queue: false});
                  
                  window.history.replaceState({ currentState: 'not-found' }, null, null);
              } else {
                alert("Fehler beim Laden des Artikels! " + textStatus + " | " + errorThrown);
                
                window.history.replaceState({ currentState: 'unknown-error' }, null, null);
              }
          });
        }
        if (pathname.length == 4 && pathname[3] == 'create') {
          $('article').html("");
      
          showEditor();
          
          $('.my-tab').fadeOut({queue: false});
          $('#page').fadeIn({queue: false});
        }
        if (pathname.length == 4 && pathname[3] == 'edit') {
          // TODO load article
          console.log("jo");
          
          showEditor();
          
          $('.my-tab').not('#page').fadeOut({queue: false});
          $('#page').fadeIn({queue: false});
        }
      }
    }
    
    window.onpopstate = function (event) {
      console.log('onpopstate');
      updateState();
    };
    
    updateState();
    
    window.onbeforeunload = function() {
        //return false;
    }
});

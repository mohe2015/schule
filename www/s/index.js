/*eslint-env browser, jquery*/
$(document).ready(function() {

  
  // TODO big issue - this code does never reload the page and therefore doesnt ask for an updated page...
  
    $( document ).ajaxError(function( event, jqxhr, settings, thrownError ) {
      console.log(thrownError);
      if (thrownError === 'Authorization Required') {
        var name = $('#inputName').val(localStorage.name);
        localStorage.removeItem('name');
        window.history.pushState({lastUrl: window.location.href, lastState: window.history.state}, null, "/login");
        updateState();
      }
    });
  
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

        var changeSummary = $('#change-summary').val();
        var tempDom = $('<output>').append($.parseHTML($('article').summernote('code')));
        tempDom.find('.formula').each(function() {
          this.innerHTML = "\\( " + MathLive.getOriginalContent(this) + " \\)";
        });
        
        var articlePath = window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/"));
        $.post("/api" + articlePath, { summary: changeSummary, html: tempDom.html(), csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            window.history.pushState(null, null, articlePath);
            updateState();
        })
        .fail(function() {
            $('#publish-changes').show();
            $('#publishing-changes').hide();
          
            alert("Fehler beim Speichern des Artikels!");
        });
        
        // TODO dismiss should cancel request
    });

    
    function sendFile(file, editor, welEditable) {
        console.log("show");
        $('#uploadProgressModal').modal('show');
        data = new FormData();
        data.append("file", file);
        data.append("csrf_token", readCookie('CSRF_TOKEN'));
        window.fileUploadFinished = false;
        window.fileUploadXhr = $.ajax({
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
                console.log("hide");
                window.fileUploadFinished = true;
                $('#uploadProgressModal').modal('hide');
                $('article').summernote('insertImage', '/api/file/' + url);
            },
            error: function() {
              if (!window.fileUploadFinished) {
                console.log("hide");
                window.fileUploadFinished = true;
                $('#uploadProgressModal').modal('hide');
                alert("Fehler beim Upload!");
              }
            }
        });
    }

    function progressHandlingFunction(e){
        if(e.lengthComputable){
            $('#uploadProgress').css('width', (100 * e.loaded / e.total) + '%');
            // reset progress on complete
        }
    }
    
    $('#uploadProgressModal').on('shown.bs.modal', function (e) {
      if (window.fileUploadFinished) {
        $('#uploadProgressModal').modal('hide');
      }
    });
    
    $('#uploadProgressModal').on('hide.bs.modal', function (e) {
      if (!window.fileUploadFinished) {
        window.fileUploadFinished = true;
        console.log("abort");
        window.fileUploadXhr.abort();
      }
    })
    
    $('#uploadProgressModal').on('hidden.bs.modal', function (e) {
      $('#uploadProgress').attr('width','0%');
    })

    
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
                ['insert', ['link', 'picture', 'video', 'table', 'math']],
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
        window.history.pushState(null, null, window.location.pathname + "/history");
        updateState();
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
    
    function showTab(id) {
      $('.my-tab').not(id).fadeOut();
      $(id).fadeIn();
    }
    
    // the url should contain the main state and the state object may contain additional information which is not show in the url
    function updateState() {
      //if (history.state && history.state.currentState == 'create-article') {
      
      // TODO maybe use less fading or shorter fading for faster navigation?
      
      if (localStorage.name !== undefined) {
       $('#nav-username').html(localStorage.name); 
      }
        
      //  return;
      //}
      
      var pathname = window.location.pathname.split('/');
      console.log(pathname);
      
      if (pathname.length > 1 && pathname[1] == 'logout') {
        // TODO don't allow this using get as then somebody can log you out by sending you a link
        showTab('#loading');
        
        $.post("/api/logout", { csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            localStorage.removeItem('name');
            window.history.replaceState(null, null, "/login");
            updateState();
        })
        .fail(function() {
            $('#errorMessage').text("Unbekannter Fehler beim Abmelden.");
            showTab('#error');
        });
        return;
      }
      
      if (pathname.length > 1 && pathname[1] == 'login') {
          if (localStorage.name !== undefined) {
            window.history.replaceState(null, null, "/wiki/Startseite");
            updateState();
            return;
          }
          
          $('#publish-changes-modal').modal('hide');
          showTab('#loading');
          
          $.get("/api/get-session", function(data) {
              showTab('#login');
              $('.login-hide').fadeOut(function() {
                  $('.login-hide').attr("style", "display: none !important");
              });
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              alert("Fehler beim Laden der Login-Seite");
          });
          return;
      } else {
          if (localStorage.name === undefined) {
              window.history.pushState({lastUrl: window.location.href, lastState: window.history.state}, null, "/login");
              updateState();
              return;
          }
          $('.login-hide').fadeIn(); 
      }
      
      if (pathname.length > 1 && pathname[1] == 'wiki') {
        if (pathname.length == 3) { // /wiki/:name
          cleanup();
          
          $.get("/api/wiki/" + pathname[2], function(data) {
              $('article').html(data);

              $(".formula").each(function() {
                MathLive.renderMathInElement(this);
                this.contentEditable = false;
              });
      
              showTab('#page');
              
              window.history.replaceState({ currentState: 'show-article' }, null, null);
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (textStatus === 'error' && errorThrown === 'Not Found') {
                  showTab('#not-found');
                  
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
          
          showTab('#page');
        }
        if (pathname.length == 4 && pathname[3] == 'edit') {
          // TODO load article
          console.log("jo");
          
          showEditor();
          
          showTab('#page');
        }
        if (pathname.length == 4 && pathname[3] == 'history') {
         
          // TODO only load if not cached
          
          showTab('loading');
          
          var articlePath = window.location.pathname.substr(6, window.location.pathname.lastIndexOf("/")-6);
          $.get("/api/history/" + articlePath, function(data) {
              
              console.log(data);
            
              $('#history-list').html('');
              
              for (page of data) {
                var t = $($('#history-item-template').html());
                t.find('.history-username').text(page.user);
                t.find('.history-date').text(moment(new Date(page.created)).locale('de').fromNow());
                t.find('.history-summary').text(page.summary);
                
                $('#history-list').append(t);
              }            
          })
          .fail(function() {
              alert("Fehler beim Laden des Änderungsverlaufs!");
          });
          
          showTab('#history');
        }
      }
      if (pathname.length > 1 && pathname[1] == 'search') {
          showTab('#search');
          $('#search-query').val(pathname[2]);
      }
    }
    
    $('#button-search').click(function() {
      //alert("search for " + $('#search-query').val());
      
      // TODO update url / only update when search button clicked
      
      $('#search-results-loading').stop().fadeIn();
      $('#search-results').stop().fadeOut();
      
      // TODO cancel previous requests
      $.get("/api/search/" + $('#search-query').val(), function(data) {
              console.log(data);
              
              $('#search-results-content').html('');
              
              if (data != null) {
                $('#no-search-results').hide();
                for (page of data) {
                  var t = $($('#search-result-template').html());
                  t.find('.s-title').text(page);
                  t.attr('href', "/wiki/" + page);
                  
                  $('#search-results-content').append(t);
                }
              } else {
                $('#search-create-article').attr('href', "/wiki/" + $('#search-query').val() + "/create");
                $('#no-search-results').show();
              }
              
              $('#search-results-loading').stop().fadeOut();
              $('#search-results').stop().fadeIn();
      })
      .fail(function() {
          alert("Fehler beim Laden der Suche!");
      });
          
    });
    
    $('#login-form').on('submit', function (e) {
      e.preventDefault();
      var name = $('#inputName').val();
      var password = $('#inputPassword').val();
      //alert(name);
      //alert(password);
      
      $('#login-button').prop("disabled",true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Anmelden...');
      
      
      $.post("/api/login", { csrf_token: readCookie('CSRF_TOKEN'), "name": name, "password": password }, function(data) {
            localStorage.name = name;
           
            if (window.history.state !== null && window.history.state.lastState !== undefined && window.history.state.lastUrl !== undefined) {
              window.history.replaceState(window.history.state.lastState, null, window.history.state.lastUrl);
              updateState();
            } else {
              window.history.replaceState(null, null, "/wiki/Startseite");
              updateState();
            }
        })
        .fail(function() {
            localStorage.removeItem('name');
            alert("Fehler beim Anmelden");
        }).always(function () {
           $('#login-button').prop("disabled",false).html('Anmelden');
            $('#inputPassword').val('');
        });
        
        return false;
    });
    
    window.onpopstate = function (event) {
      console.log('onpopstate');
      updateState();
    };
    
    updateState();
    
    window.onbeforeunload = function() {
        //return false;
    }
    
    $(document).on("input", "#search-query", function(e){
        //if (e.which == 13){
            $('#button-search').click();
       // }
    });
        
   // $('.selectpicker').selectpicker();
});

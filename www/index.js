/*eslint-env browser, jquery*/
$(document).ready(function() {

  // TODO big issue - this code does never reload the page and therefore doesnt ask for an updated page....f
  
    $("body").on("click",".history-pushState",function() {
        window.history.pushState(null, null, $(this).data('href'));
        updateState();
    });
  
    function handleError (thrownError) {
      console.log(thrownError);
      if (thrownError === 'Authorization Required') {
        var name = $('#inputName').val(window.localStorage.name);
        window.localStorage.removeItem('name');
        window.history.pushState({lastUrl: window.location.href, lastState: window.history.state}, null, "/login");
        updateState();
      } else if (thrownError === 'Forbidden') {
        var errorMessage = 'Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mit Bescheid, wenn du glaubst, dass dies ein Fehler ist.';
        alert(errorMessage);
      } else {
        var errorMessage = 'Unbekannter Fehler: ' + thrownError;
        alert(errorMessage);
      }
    };
  
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
          try {
          this.innerHTML = "\\( " + MathLive.getOriginalContent(this) + " \\)";
          } catch (err) {
              console.log(err);
          }
        });
        
        var articlePath = window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/"));
        $.post("/api" + articlePath, { summary: changeSummary, html: tempDom.html(), csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            window.history.pushState(null, null, articlePath);
            updateState();
        })
        .fail(function( jqXHR, textStatus, errorThrown) {
            $('#publish-changes').show();
            $('#publishing-changes').hide();
          
            handleError(errorThrown);
        });
        
        // TODO dismiss should cancel request
    });

    
    function sendFile(file, editor, welEditable) {
        console.log("show");
        $('#uploadProgressModal').modal('show');
        var data = new FormData();
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
                ['style', ['style', 'bold', 'italic', 'underline', 'superscript', 
'subscript']],
                ['para', ['ul', 'ol', 'indent', 'outdent']],
                ['insert', ['link', 'picture', 'video', 'table', 'math']],
                ['management', ['undo', 'redo', 'help', 'cancel', 'finished']]
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
    
    function GetURLParameter(sParam)
    {
        var sPageURL = window.location.search.substring(1);
        var sURLVariables = sPageURL.split('&');
        for (var i = 0; i < sURLVariables.length; i++)
        {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam)
            {
                return sParameterName[1];
            }
        }
    }
    
    function updateState() {
      // TODO maybe use less fading or shorter fading for faster navigation?
      
      if (window.localStorage.name !== undefined) {
       $('#logout').text(window.localStorage.name + " abmelden"); 
      } else {
        $('#logout').text('Abmelden');
      }

      var pathname = window.location.pathname.split('/');
      console.log(pathname);
      
      if (pathname.length == 2 && pathname[1] == '') {
        window.history.replaceState(null, null, "/wiki/Startseite");
        updateState();
        return;
      }
      
      if (pathname.length > 1 && pathname[1] == 'logout') {
        // TODO don't allow this using GET as then somebody can log you out by sending you a link
        showTab('#loading');
        
        $.post("/api/logout", { csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            window.localStorage.removeItem('name');
            window.history.replaceState(null, null, "/login");
            updateState();
        })
        .fail(function( jqXHR, textStatus, errorThrown) {
            handleError(errorThrown);
        });
        return;
      }
      
      if (pathname.length > 1 && pathname[1] == 'login') {
          if (window.localStorage.name !== undefined) {
            window.history.replaceState(null, null, "/wiki/Startseite");
            updateState();
            return;
          }
          
          $('#publish-changes-modal').modal('hide');
          
          var urlUsername = GetURLParameter('username');
          var urlPassword = GetURLParameter('password');
          
          if (urlUsername !== undefined && urlPassword !== undefined) {
            $('#inputName').val(urlUsername);
            $('#inputPassword').val(urlPassword);
          }
        
          showTab('#login');
          $('.login-hide').fadeOut(function() {
              $('.login-hide').attr("style", "display: none !important");
          });
          return;
      } else {
          if (window.localStorage.name === undefined) {
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
               // this.contentEditable = false;
              });
      
              showTab('#page');
              
              window.history.replaceState({ currentState: 'show-article' }, null, null);
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (errorThrown === 'Not Found') {
                  showTab('#not-found');
              } else {
                handleError(errorThrown);
              }
          });
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'create') {
          $('article').html("<h1>" + pathname[2] + "</h1>");
      
          showEditor();
          
          showTab('#page');
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'edit') {
          // TODO load article
          console.log("jo");
          
          showEditor();
          
          showTab('#page');
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'history') {
          showTab('loading');
          
          var articlePath = window.location.pathname.substr(6, window.location.pathname.lastIndexOf("/")-6);
          $.get("/api/history/" + articlePath, function(data) {
              
              console.log(data);
            
              $('#history-list').html('');
              
              for (var page of data) {
                var t = $($('#history-item-template').html());
                t.find('.history-username').text(page.user);
                t.find('.history-date').text(new Date(page.created));
                t.find('.history-summary').text(page.summary);
                t.find('.history-characters').text(page.size);
                
                t.find('.history-show').data('href', "/wiki/" + articlePath + "/history/" + page.id);
                
                $('#history-list').append(t);
              }            
          })
          .fail(function( jqXHR, textStatus, errorThrown) {
              handleError(errorThrown);
          });
          
          showTab('#history');
          return;
        }
      }
      if (pathname.length == 5 && pathname[3] == 'history') {
          cleanup();
          
          $.get("/api/revision/" + pathname[4], function(data) {
              $('article').html(data);

              $(".formula").each(function() {
                MathLive.renderMathInElement(this);
              });
      
              showTab('#page');
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (errorThrown === 'Not Found') {
                  showTab('#not-found');
              } else {
                handleError(errorThrown);
              }
          });
          return;
      }
      if (pathname.length > 1 && pathname[1] == 'search') {
          showTab('#search');
          $('#search-query').val(pathname[2]);
          return;
      }
      
      $('#errorMessage').text("Pfad nicht gefunden! Hast du dich vielleicht vertippt?");
      showTab('#error');
    }
    
    $('#button-search').click(function() {
      // TODO update url / only update when search button clicked
      
      $('#search-results-loading').stop().fadeIn();
      $('#search-results').stop().fadeOut();
      
      // TODO cancel previous requests
      $.get("/api/search/" + $('#search-query').val(), function(data) {
              console.log(data);
              
              $('#search-results-content').html('');
              
              if (data != null) {
                $('#no-search-results').hide();
                for (var page of data) {
                  var t = $($('#search-result-template').html());
                  t.find('.s-title').text(page.title);
                  t.attr('href', "/wiki/" + page.title);
                  t.find('.search-result-summary').html(page.summary);
                  
                  $('#search-results-content').append(t);
                }
              } else {
                $('#search-create-article').attr('href', "/wiki/" + $('#search-query').val() + "/create");
                $('#no-search-results').show();
              }
              
              $('#search-results-loading').stop().fadeOut();
              $('#search-results').stop().fadeIn();
      })
      .fail(function( jqXHR, textStatus, errorThrown) {
          handleError(errorThrown);
      });
    });
    
    $('#login-form').on('submit', function (e) {
      e.preventDefault();
      var name = $('#inputName').val();
      var password = $('#inputPassword').val();
      
      $('#login-button').prop("disabled",true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Anmelden...');
      
      $.post("/api/login", { csrf_token: readCookie('CSRF_TOKEN'), "name": name, "password": password }, function(data) {
            $('#inputPassword').val('');
            window.localStorage.name = name;
           
            if (window.history.state !== null && window.history.state.lastState !== undefined && window.history.state.lastUrl !== undefined) {
              window.history.replaceState(window.history.state.lastState, null, window.history.state.lastUrl);
              updateState();
            } else {
              window.history.replaceState(null, null, "/wiki/Startseite");
              updateState();
            }
        })
        .fail(function( jqXHR, textStatus, errorThrown) {
            window.localStorage.removeItem('name');
            if (errorThrown === 'Forbidden') {
              alert('Ungültige Zugangsdaten!');
              // TODO try two times because of CSRF cookie
            } else {
              handleError(errorThrown);
            }
        }).always(function () {
           $('#login-button').prop("disabled",false).html('Anmelden');
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
      $('#button-search').click();
    });
});

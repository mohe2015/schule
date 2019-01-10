/*eslint-env browser, jquery*/
window.onerror = function(message, source, lineno, colno, error) {
  alert("Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! " + message + " source: " + source + " lineno: " + lineno + " colno: " + colno + " error: " + error);
};

$(document).ready(function() {

  // TODO big issue - this code does never reload the page and therefore doesnt ask for an updated page....f
  
    $("body").on("click",".history-pushState",function(e) {
        e.preventDefault();
        window.history.pushState(null, null, $(this).data('href'));
        updateState();
        return false;
    });
    
    $('#refresh').click(function(e) {
      e.preventDefault();
      updateState();
      return false;
    })
  
    function handleError (thrownError, showErrorPage) {
      console.log(thrownError);
      if (thrownError === 'Authorization Required') {
        var name = $('#inputName').val(window.localStorage.name);
        window.localStorage.removeItem('name');
        window.history.pushState({lastUrl: window.location.href, lastState: window.history.state}, null, "/login");
        updateState();
      } else if (thrownError === 'Forbidden') {
        var errorMessage = 'Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mit Bescheid, wenn du glaubst, dass dies ein Fehler ist.';
        $('#errorMessage').text(errorMessage);
        if (showErrorPage) {
            $('#errorMessage').text(errorMessage);
            showTab('#error');
        } else {
          alert(errorMessage);
        }
      } else {
        var errorMessage = 'Unbekannter Fehler: ' + thrownError;
        if (showErrorPage) {
            $('#errorMessage').text(errorMessage);
            showTab('#error');
            // TODO refresh button
        } else {
          alert(errorMessage);
        }
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
                if (confirm('Möchtest du die Änderung wirklich verwerfen?')) {
                  window.history.back();
                }
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
          
            handleError(errorThrown, false);
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
              },
              /*onPaste: function (e) {
                  var bufferText = ((e.originalEvent || e).clipboardData || window.clipboardData).getData('text/html');
                  e.preventDefault();
                  console.log(bufferText);
                  $('article').summernote('pasteHTML', bufferText);
              },*/
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
            ],
           cleaner:{
                  action: 'both', // both|button|paste 'button' only cleans via toolbar button, 'paste' only clean when pasting content, both does both options.
                  newline: '<p><br></p>', // Summernote's default is to use '<p><br></p>'
                  notStyle: 'position:absolute;top:0;left:0;right:0', // Position of Notification
                  icon: '<i class="note-icon">[Your Button]</i>',
                  keepHtml: true, // Remove all Html formats
                  keepOnlyTags: ['<h1>', '<h2>', '<h3>', '<h4>', '<h5>', '<h6>', '<p>', '<br>', '<ul>', '<li>', '<b>', '<strong>','<i>', '<a>', '<sup>', '<sub>', '<img>'], // If keepHtml is true, remove all tags except these
                  keepClasses: false, // Remove Classes
                  badTags: ['style', 'script', 'applet', 'embed', 'noframes', 'noscript'], // Remove full tags with contents
                  badAttributes: ['style', 'start'], // Remove attributes from remaining tags
                  limitChars: false, // 0/false|# 0/false disables option
                  limitDisplay: 'both', // text|html|both
                  limitStop: false // true/false
            }
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
        
        var pathname = window.location.pathname.split('/');
        
        window.history.pushState(null, null, "/wiki/" + pathname[2] + "/edit");
        updateState();
        return false;
    });
    
    $("#create-article").click(function(e) {
        e.preventDefault();
        var pathname = window.location.pathname.split('/');
        window.history.pushState(null, null, "/wiki/" + pathname[2] + "/create");
        updateState();
        return false;
    });
    
    $("#show-history").click(function () {
        var pathname = window.location.pathname.split('/');
        window.history.pushState(null, null, "/wiki/" + pathname[2] + "/history");
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
        $(".edit-button").removeClass('disabled')
        window.history.replaceState(null, null, "/wiki/Hauptseite");
        updateState();
        return;
      }
      
      if (pathname.length == 2 && pathname[1] == 'logout') {
        $(".edit-button").addClass('disabled')
        // TODO don't allow this using GET as then somebody can log you out by sending you a link
        showTab('#loading');
        
        $.post("/api/logout", { csrf_token: readCookie('CSRF_TOKEN') }, function(data) {
            window.localStorage.removeItem('name');
            window.history.replaceState(null, null, "/login");
            updateState();
        })
        .fail(function( jqXHR, textStatus, errorThrown) {
            handleError(errorThrown, true);
        });
        return;
      }
      
      if (pathname.length == 2 && pathname[1] == 'login') {
          $(".edit-button").addClass('disabled')
          if (window.localStorage.name !== undefined) {
            window.history.replaceState(null, null, "/wiki/Hauptseite");
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
          $(".edit-button").removeClass('disabled')
          $('#is-outdated-article').addClass('d-none');
          $('#wiki-article-title').text(pathname[2]);
          cleanup();
          
          $.get("/api/wiki/" + pathname[2], function(data) {
              $('article').html(data);

              $(".formula").each(function() {
                MathLive.renderMathInElement(this);
               // this.contentEditable = false;
              });
      
              showTab('#page');
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (errorThrown === 'Not Found') {
                  showTab('#not-found');
              } else {
                handleError(errorThrown, true);
              }
          });
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'create') {
          $(".edit-button").addClass('disabled')
          $('#is-outdated-article').addClass('d-none');
          $('article').html("");
      
          showEditor();
          
          showTab('#page');
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'edit') {
          $(".edit-button").addClass('disabled')
          $('#is-outdated-article').addClass('d-none');
          $('#wiki-article-title').text(pathname[2]);
          cleanup();
          
          $.get("/api/wiki/" + pathname[2], function(data) {
              $('article').html(data);

              $(".formula").each(function() {
                MathLive.renderMathInElement(this);
              });
              
              showEditor();
              
              showTab('#page');
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (errorThrown === 'Not Found') {
                  showTab('#not-found');
              } else {
                handleError(errorThrown, true);
              }
          });
          return;
        }
        if (pathname.length == 4 && pathname[3] == 'history') {
          $(".edit-button").removeClass('disabled')
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
                t.find('.history-diff').data('href', "/wiki/" + articlePath + "/history/" + page.id + "/changes");
                
                $('#history-list').append(t);
              }            
          })
          .fail(function( jqXHR, textStatus, errorThrown) {
              handleError(errorThrown, true);
          });
          
          showTab('#history');
          return;
        }
      }
      // /wiki/:page/history/:id
      if (pathname.length == 5 && pathname[3] == 'history') {
          $(".edit-button").removeClass('disabled')
          cleanup();
          $('#wiki-article-title').text(pathname[2]);
          
          $.get("/api/revision/" + pathname[4], function(data) {
              $('#is-outdated-article').removeClass('d-none');
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
                handleError(errorThrown, true);
              }
          });
          return;
      }
      // /wiki/:page/history/:id/changes
      if (pathname.length == 6 && pathname[3] == 'history' && pathname[5] == 'changes') {
          $(".edit-button").addClass('disabled')
          $('#is-outdated-article').removeClass('d-none');
          cleanup();
          
          var currentRevision = null;
          var previousRevision = null;
          
          $.get("/api/revision/" + pathname[4], function(data) {
              currentRevision = data;

              $.get("/api/previous-revision/" + pathname[4], function(data) {
                    previousRevision = data;

                    //$(".formula").each(function() {
                    //  MathLive.renderMathInElement(this);
                    //});
            
                    var diffHTML = htmldiff(previousRevision, currentRevision);
                    $('article').html(diffHTML);
                    
                    showTab('#page'); 
              })
              .fail(function(jqXHR, textStatus, errorThrown) {
                  if (errorThrown === 'Not Found') {
                      showTab('#not-found');
                  } else {
                    handleError(errorThrown, true);
                  }
              });
          })
          .fail(function(jqXHR, textStatus, errorThrown) {
              if (errorThrown === 'Not Found') {
                  showTab('#not-found');
              } else {
                handleError(errorThrown, true);
              }
          });
          return;
      }
      
      if ((pathname.length == 2 || pathname.length == 3) && pathname[1] == 'search') {
          $(".edit-button").addClass('disabled')
          showTab('#search');
          $('#search-query').val(pathname[2]);
          return;
      }
      
      $('#errorMessage').text("Pfad nicht gefunden! Hast du dich vielleicht vertippt?");
      showTab('#error');
    }
    
    $('#button-search').click(function() {
      var query = $('#search-query').val();
      console.log("query: " + query);
      $('#search-create-article').data('href', "/wiki/" + query + "/create");
      
      window.history.replaceState(null, null, "/search/" + query);
      
      $('#search-results-loading').stop().fadeIn();
      $('#search-results').stop().fadeOut();
      
      if (window.searchXhr !== undefined) {
        //console.log("abort");
        window.searchXhr.abort(); 
      }
      
      window.searchXhr = $.get("/api/search/" + query, function(data) {
              //console.log(data);
              
              $('#search-results-content').html('');
              
              var resultsContainQuery = false;
              if (data != null) {
                for (var page of data) {
                  if (page.title == query) {
                      resultsContainQuery = true;
                  }
                  var t = $($('#search-result-template').html());
                  t.find('.s-title').text(page.title);
                  t.data('href', "/wiki/" + page.title);
                  t.find('.search-result-summary').html(page.summary);
                  
                  $('#search-results-content').append(t);
                }
              }
              if (resultsContainQuery) {
                $('#no-search-results').hide();
              } else {
                $('#no-search-results').show();
              }
              
              $('#search-results-loading').stop().fadeOut();
              $('#search-results').stop().fadeIn();
      })
      .fail(function( jqXHR, textStatus, errorThrown) {
        if (textStatus !== 'abort') {
            handleError(errorThrown, true);
          }
      });
    });
    
    $('#login-form').on('submit', function (e) {
      e.preventDefault();
      var name = $('#inputName').val();
      var password = $('#inputPassword').val();
      
      $('#login-button').prop("disabled",true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Anmelden...');
      
      $.post("/api/login", { csrf_token: readCookie('CSRF_TOKEN'), "name": name, "password": password }, function(data) {
            $('#login-button').prop("disabled",false).html('Anmelden');
            $('#inputPassword').val('');
            window.localStorage.name = name;
           
            if (window.history.state !== null && window.history.state.lastState !== undefined && window.history.state.lastUrl !== undefined) {
              window.history.replaceState(window.history.state.lastState, null, window.history.state.lastUrl);
              updateState();
            } else {
              window.history.replaceState(null, null, "/wiki/Hauptseite");
              updateState();
            }
        })
        .fail(function( jqXHR, textStatus, errorThrown) {
            window.localStorage.removeItem('name');
            if (errorThrown === 'Forbidden') {
                // quick and dirty copy and paste
                $.post("/api/login", { csrf_token: readCookie('CSRF_TOKEN'), "name": name, "password": password }, function(data) {
                    $('#inputPassword').val('');
                    window.localStorage.name = name;
                  
                    if (window.history.state !== null && window.history.state.lastState !== undefined && window.history.state.lastUrl !== undefined) {
                      window.history.replaceState(window.history.state.lastState, null, window.history.state.lastUrl);
                      updateState();
                    } else {
                      window.history.replaceState(null, null, "/wiki/Hauptseite");
                      updateState();
                    }
                })
                .fail(function( jqXHR, textStatus, errorThrown) {
                    window.localStorage.removeItem('name');
                    if (errorThrown === 'Forbidden') {
                      alert('Ungültige Zugangsdaten!');
                    } else {
                      handleError(errorThrown, true);
                    }
                }).always(function () {
                  $('#login-button').prop("disabled",false).html('Anmelden');
                });
            } else {
              $('#login-button').prop("disabled",false).html('Anmelden');
              handleError(errorThrown, true);
            }
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

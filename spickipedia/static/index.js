window.onerror = function(message, source, lineno, colno, error) {
  __PS_MV_REG = [];
  return alert(
    'Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! ' +
      message +
      ' source: ' +
      source +
      ' lineno: ' +
      lineno +
      ' colno: ' +
      colno +
      ' error: ' +
      error
  );
};
$('body').on('click', '.history-pushState', function(e) {
  e.preventDefault();
  pushState($(this).data('href'));
  __PS_MV_REG = [];
  return false;
});
$('#refresh').click(function(e) {
  e.preventDefault();
  updateState();
  __PS_MV_REG = [];
  return false;
});
function handleError(thrownError, showErrorPage) {
  if (thrownError === 'Authorization Required') {
    var name353 = $('#inputName').val(window.localStorage.name);
    window.localStorage.removeItem('name');
    __PS_MV_REG = [];
    return pushState('/login', {
      lastUrl: window.location.href,
      lastState: window.history.state
    })();
  } else {
    if (thrownError === 'Forbidden') {
      var errorMessage =
        'Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist.';
      $('#errorMessage').text(errorMessage);
      if (showErrorPage) {
        $('#errorMessage').text(errorMessage);
        __PS_MV_REG = [];
        return showTab('#error');
      } else {
        __PS_MV_REG = [];
        return alert(errorMessage);
      }
    } else {
      var errorMessage354 = 'Unbekannter Fehler: ' + thrownError;
      if (showErrorPage) {
        $('#errorMessage').text(errorMessage354);
        __PS_MV_REG = [];
        return showTab('#error');
      } else {
        __PS_MV_REG = [];
        return alert(errorMessage354);
      }
    }
  }
}
function setFullscreen(value) {
  if (value && $('.fullscreen').length === 0) {
    __PS_MV_REG = [];
    return $('article').summernote('fullscreen.toggle');
  } else {
    __PS_MV_REG = [];
    return !value && $('.fullscreen').length === 1
      ? $('article').summernote('fullscreen.toggle')
      : null;
  }
}
var finishedButton = function(context) {
  return $.summernote.ui
    .button({
      contents: '<i class="fa fa-check"/>',
      tooltip: 'Fertig',
      click: function() {
        $('#publish-changes-modal').on('shown.bs.modal', function() {
          __PS_MV_REG = [];
          return $('#change-summary').trigger('focus');
        });
        __PS_MV_REG = [];
        return $('#publish-changes-modal').modal('show');
      }
    })
    .render();
};
var cancelButton = function(context) {
  return $.summernote.ui
    .button({
      contents: '<i class="fa fa-times"/>',
      tooltip: 'Abbrechen',
      click: function() {
        __PS_MV_REG = [];
        return confirm('Möchtest du die Änderung wirklich verwerfen?')
          ? window.history.back()
          : null;
      }
    })
    .render();
};
var wikiLinkButton = function(context) {
  return $.summernote.ui
    .button({
      contents: 'S',
      tooltip: 'Spickipedia-Link einfügen',
      click: function() {
        $('#spickiLinkModal').on('shown.bs.modal', function() {
          __PS_MV_REG = [];
          return $('#article-link-title').trigger('focus');
        });
        __PS_MV_REG = [];
        return $('#spickiLinkModal').modal('show');
      }
    })
    .render();
};
function readCookie(name) {
  var nameEq = name + '=';
  var ca = document.cookie.split(';');
  var _js356 = ca.length;
  for (var _js355 = 0; _js355 < _js356; _js355 += 1) {
    var c = ca[_js355];
    if (c.trim().startsWith(nameEq)) {
      return c.substring(nameEq.length);
    }
  }
}
$('#publish-changes').click(function() {
  $('#publish-changes').hide();
  $('#publishing-changes').show();
  var changeSummary = $('#change-summary').val();
  var tempDom = $('<output>').append(
    $.parseHTML($('article').summernote('code'))
  );
  var articlePath = window.location.pathname.substr(
    0,
    window.location.pathname.lastIndexOf('/')
  );
  tempDom.find('.formula').each(function() {
    return (this.innerHTML =
      '\\( ' + MathLive.getOriginalContent(this) + ' \\)');
  });
  __PS_MV_REG = [];
  return $.post(
    '/api' + articlePath,
    {
      summary: changeSummary,
      html: tempDom.html(),
      csrf_token: readCookie('CSRF_TOKEN')
    },
    function(data) {
      __PS_MV_REG = [];
      return pushState(articlePath);
    }
  ).fail(function(jqXhr, textStatus, errorThrown) {
    $('#publish-changes').show();
    $('#publishing-changes').hide();
    __PS_MV_REG = [];
    return handleError(errorThrown, false);
  });
});
function sendFile(file, editor, welEditable) {
  $('#uploadProgressModal').modal('show');
  var data = new FormData();
  data.append('file', file);
  data.append('csrf_token', readCookie('CSRF_TOKEN'));
  window.fileUploadFinished = false;
  __PS_MV_REG = [];
  return (window.fileUploadXhr = $.ajax({
    data: data,
    type: 'POST',
    xhr: function() {
      var myXhr = $.ajaxSettings.xhr();
      if (myXhr.upload) {
        myXhr.upload.addEventListener(
          'progress',
          progressHandlingFunction,
          false
        );
      }
      return myXhr;
    },
    url: '/api/upload',
    cache: false,
    contentType: false,
    processData: false,
    success: function(url) {
      window.fileUploadFinished = true;
      $('#uploadProgressModal').modal('hide');
      __PS_MV_REG = [];
      return $('article').summernote('insertImage', '/api/file/' + url);
    },
    error: function() {
      if (!window.fileUploadFinished) {
        window.fileUploadFinished = true;
        $('#uploadProgressModal').modal('hide');
        __PS_MV_REG = [];
        return alert('Fehler beim Upload!');
      }
    }
  }));
}
function progressHandlingFunction(e) {
  __PS_MV_REG = [];
  return e.lengthComputable
    ? $('#uploadProgress').css('width', 100 * (e.loaded / e.total) + '%')
    : null;
}
$('#uploadProgressModal').on('shown.bs.modal', function(e) {
  __PS_MV_REG = [];
  return window.fileUploadFinished
    ? $('#uploadProgressModal').modal('hide')
    : null;
});
$('#uploadProgressModal').on('hide.bs.modal', function(e) {
  if (!window.fileUploadFinished) {
    window.fileUploadFinished = true;
    return window.fileUploadXhr.abort();
  }
});
$('#uploadProgressModal').on('hidden.bs.modal', function(e) {
  __PS_MV_REG = [];
  return $('#uploadProgress').attr('width', '0%');
});
function showEditor() {
  var canCall = true;
  $('article').summernote({
    lang: 'de-DE',
    callbacks: {
      onImageUpload: function(files) {
        __PS_MV_REG = [];
        return sendFile(files[0]);
      },
      onChange: function(contents, $editable) {
        if (!canCall) {
          return;
        }
        canCall = false;
        window.history.replaceState({ content: contents }, null, null);
        __PS_MV_REG = [];
        return setTimeout(function() {
          return (canCall = true);
        }, 1000);
      }
    },
    dialogsFade: true,
    focus: true,
    buttons: {
      finished: finishedButton,
      cancel: cancelButton,
      wikiLink: wikiLinkButton
    },
    toolbar: [
      [
        'style',
        ['style.p', 'style.h2', 'style.h3', 'superscript', 'subscript']
      ],
      ['para', ['ul', 'ol', 'indent', 'outdent']],
      ['insert', ['link', 'picture', 'table', 'math']],
      ['management', ['undo', 'redo', 'finished']]
    ],
    cleaner: {
      action: 'both',
      newline: '<p><br></p>',
      notStyle: 'position:absolute;top:0;left:0;right:0',
      icon: '<i class="note-icon">[Your Button]</i>',
      keepHtml: true,
      keepOnlyTabs: [
        '<h1>',
        '<h2>',
        '<h3>',
        '<h4>',
        '<h5>',
        '<h6>',
        '<p>',
        '<br>',
        '<ol>',
        '<ul>',
        '<li>',
        '<b>',
        '<strong>',
        '<i>',
        '<a>',
        '<sup>',
        '<sub>',
        '<img>'
      ],
      keepClasses: false,
      badTags: ['style', 'script', 'applet', 'embed', 'noframes', 'noscript'],
      badAttributes: ['style', 'start'],
      limitChars: false,
      limitDisplay: 'both',
      limitStop: false
    },
    popover: {
      math: ['math', ['edit-math', 'delete-math']],
      table: [
        'add',
        ['addRowDown', 'addRowUp', 'addColLeft', 'addColRight'],
        'delete',
        ['deleteRow', 'deleteCol', 'deleteTable'],
        'custom',
        ['tableHeaders']
      ],
      image: [
        'resize',
        ['resizeFull', 'resizeHalf', 'resizeQuarter', 'resizeNone'],
        'float',
        ['floatLeft', 'floatRight', 'floatNone'],
        'remove',
        ['removeMedia']
      ]
    },
    imageAttributes: {
      icon: '<i class=',
      noteIconPencil: '/>',
      removeEmpty: false,
      disableUpload: false
    }
  });
  __PS_MV_REG = [];
  return setFullscreen(true);
}
function hideEditor() {
  setFullscreen(false);
  $('article').summernote('destroy');
  __PS_MV_REG = [];
  return $('.tooltip').hide();
}
$('.edit-button').click(function(e) {
  e.preventDefault();
  var pathname357 = window.location.pathname.split('/');
  pushState('/wiki/' + pathname357[2] + '/edit', window.history.state);
  __PS_MV_REG = [];
  return false;
});
$('#create-article').click(function(e) {
  e.preventDefault();
  var pathname358 = window.location.pathname.split('/');
  pushState('/wiki/' + pathname358[2] + '/create', window.history.state);
  __PS_MV_REG = [];
  return false;
});
$('#show-history').click(function(e) {
  e.preventDefault();
  var pathname359 = window.location.pathname.split('/');
  pushState('/wiki/' + pathname359[2] + '/history', window.history.state);
  __PS_MV_REG = [];
  return false;
});
function cleanup() {
  setFullscreen(false);
  $('article').summernote('destroy');
  $('#publish-changes-modal').modal('hide');
  $('#publish-changes').show();
  __PS_MV_REG = [];
  return $('#publishing-changes').hide();
}
function showTab(id) {
  $('.my-tab')
    .not(id)
    .fadeOut();
  __PS_MV_REG = [];
  return $(id).fadeIn();
}
function getUrlParameter(param) {
  var pageUrl360 = window.location.search.substring(1);
  var urlVariables = pageUrl.split('&');
  var _js362 = urlVariables.length;
  for (var _js361 = 0; _js361 < _js362; _js361 += 1) {
    var parameterName = urlVariables[_js361];
    parameterName = parameterName.split('=');
    if (parameterName[0] === param) {
      return parameterName[1];
    }
  }
}
function updateState() {
  window.lastUrl = window.location.pathname;
  if ('undefined' === typeof window.localStorage.name) {
    $('#logout').text(window.localStorage.name + ' abmelden');
  } else {
    $('#logout').text('Abmelden');
  }
  if ('undefined' === typeof window.localStorage.name) {
    __PS_MV_REG = [];
    return pushState('/login', {
      lastUrl: window.location.href,
      lastState: window.history.state
    });
  } else {
    __PS_MV_REG = [];
    return;
  }
}
function replaceState(url, data) {
  window.history.replaceState(data, null, url);
  __PS_MV_REG = [];
  return updateState();
}
function pushState(url, data) {
  window.history.pushState(data, null, url);
  __PS_MV_REG = [];
  return updateState();
}
function handle(path) {
  if ((results = new RegExp('^/$').exec(path)) != null) {
    $('.edit-button').removeClass('disabled');
    __PS_MV_REG = [];
    return replaceState('/wiki/Hauptseite');
  }
}
function handleLogout(path) {
  if ((results = new RegExp('^/logout$').exec(path)) != null) {
    $('.edit-button').addClass('disabled');
    showTab('#loading');
    __PS_MV_REG = [];
    return $.post(
      '/api/logout',
      { csrf_token: readCookie('CSRF_TOEN') },
      function(data) {
        window.localStorage.removeItem('name');
        __PS_MV_REG = [];
        return replaceState('/login');
      }
    ).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    });
  }
}
function handleLogin(path) {
  if ((results = new RegExp('^/login$').exec(path)) != null) {
    $('.edit-button').addClass('disabled');
    $('#publish-changes-modal').modal('hide');
    var urlUsername = getUrlParameter('username');
    var urlPassword = getUrlParameter('password');
    if (
      'undefined' !== typeof urlUsername &&
      'undefined' !== typeof urlPassword
    ) {
      $('#inputName').val(decodeURIComponent(urlUsername));
      $('#inputPassword').val(decodeURIComponent(urlPassword));
    } else {
      if ('undefined' === typeof window.localStorage.name) {
        replaceState('/wiki/Hauptseite');
        __PS_MV_REG = [];
        return null;
      }
    }
    showTab('#login');
    $('.login-hide').fadeOut(function() {
      __PS_MV_REG = [];
      return $('.login-hide').attr('style', 'display: none !important');
    });
    __PS_MV_REG = [];
    return $('.navbar-collapse').removeClass('show');
  }
}
function handleArticles(path) {
  if ((results = new RegExp('^/articles$').exec(path)) != null) {
    showTab('#loading');
    __PS_MV_REG = [];
    return $.get('/api/articles', function(data) {
      data.sort(function(a, b) {
        return a.localeCompare(b);
      });
      $('#articles-list').html('');
      var _js364 = data.length;
      for (var _js363 = 0; _js363 < _js364; _js363 += 1) {
        var page = data[_js363];
        var templ = $($('#articles-entry').html());
        templ.find('a').text(page);
        templ.find('a').data('href', '/wiki/' + page);
        $('#articles-list').append(templ);
      }
      __PS_MV_REG = [];
      return showTab('#articles');
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    });
  }
}
function handleWikiName(path) {
  if ((results = new RegExp('^/wiki/([^/]*)$').exec(path)) != null) {
    var name = results[1];
    var pathname = window.location.pathname.split('/');
    showTab('#loading');
    $('.edit-button').removeClass('disabled');
    $('#is-outdated-article').addClass('d-none');
    $('#wiki-article-title').text(decodeURIComponent(pathname[2]));
    cleanup();
    __PS_MV_REG = [];
    return $.get('/api/wiki/' + pathname[2], function(data) {
      $('article').html(data);
      $('.formula').each(function() {
        return MathLive.renderMathInElement(this);
      });
      __PS_MV_REG = [];
      return showTab('#page');
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return errorThrown === 'Not Found'
        ? showTab('#not-found')
        : handleError(errorThrown, true);
    });
  }
}
function handleWikiNameCreate(path) {
  if ((results = new RegExp('^/wiki/([^/]*)/create$').exec(path)) != null) {
    var name = results[1];
    $('.edit-button').addClass('disabled');
    $('#is-outdated-article').addClass('d-none');
    if (window.history.state != null && window.history.state.content != null) {
      $('article').html(window.history.state.content);
    } else {
      $('article').html('');
    }
    showEditor();
    __PS_MV_REG = [];
    return showTab('#page');
  }
}
function handleWikiNameEdit(path) {
  if ((results = new RegExp('^/wiki/([^/]*)/edit$').exec(path)) != null) {
    var name = results[1];
    $('.edit-button').addClass('disabled');
    $('#is-outdated-article').addClass('d-none');
    $('#wiki-article-title').text(decodeURIComponent(pathname[2]));
    cleanup();
    if (window.history.state != null && window.history.state.content != null) {
      $('article').html(window.history.state.content);
      $('.formula').each(function() {
        return MathLive.renderMathInElement(this);
      });
      showEditor();
      __PS_MV_REG = [];
      return showTab('#page');
    } else {
      showTab('#loading');
      __PS_MV_REG = [];
      return $.get('/api/wiki/' + pathname[2], function(data) {
        $('article').html(data);
        $('.formula').each(function() {
          return MathLive.renderMathElement(this);
        });
        window.history.replaceState({ content: data }, null, null);
        showEditor();
        __PS_MV_REG = [];
        return showTab('#page');
      }).fail(function(jqXhr, textStatus, errorThrown) {
        __PS_MV_REG = [];
        return errorThrown === 'Not Found'
          ? showTab('#not-found')
          : handleError(errorThrown, true);
      });
    }
  }
}
function handleWikiNameHistory(path) {
  if ((results = new RegExp('^/wiki/([^/]*)/history$').exec(path)) != null) {
    var name = results[1];
    $('.edit-button').removeClass('disabled');
    showTab('#loading');
    var pathname = window.location.pathname.split('/');
    __PS_MV_REG = [];
    return $.get('/api/history/' + pathname[2], function(data) {
      $('#history-list').html('');
      var _js366 = data.length;
      for (var _js365 = 0; _js365 < _js366; _js365 += 1) {
        var page = data[_js365];
        var template = $($('#history-item-template').html());
        template.find('.history-username').text(page.user);
        template.find('.history-date').text(new Date(page.created));
        template.find('.history-summary').text(page.summary);
        template.find('.history-characters').text(page.size);
        template
          .find('.history-show')
          .data('href', '/wiki/' + pathname[2] + '/history/' + page.id);
        template
          .find('.history-diff')
          .data(
            'href',
            '/wiki/' + pathname[2] + '/history/' + page.id + '/changes'
          );
        $('#history-list').append(template);
      }
      __PS_MV_REG = [];
      return showTab('#history');
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    });
  }
}
function handleWikiPageHistoryId(path) {
  if (
    (results = new RegExp('^/wiki/([^/]*)/history/([^/]*)$').exec(path)) != null
  ) {
    var page = results[1];
    var id = results[2];
    showTab('#loading');
    $('.edit-button').removeClass('disabled');
    cleanup();
    $('#wiki-article-title').text(decodeURIComponent(pathname[2]));
    __PS_MV_REG = [];
    return $.get('/api/revision/' + id, function(data) {
      $('#currentVersionLink').data('href', '/wiki/' + page);
      $('#is-outdated-article').removeClass('d-none');
      $('article').html(data);
      window.history.replaceState({ content: data }, null, null);
      $('.formula').each(function() {
        return MathLive.renderMathInElement(this);
      });
      __PS_MV_REG = [];
      return showTab('#page');
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return errorThrown === 'Not Found'
        ? showTab('#not-found')
        : handleError(errorThrown, true);
    });
  }
}
function handleWikiPageHistoryIdChanges(path) {
  if (
    (results = new RegExp('^/wiki/([^/]*)/history/([^/]*)/changes$').exec(
      path
    )) != null
  ) {
    var page = results[1];
    var id = results[2];
    $('.edit-button').addClass('disabled');
    $('#currentVersionLink').data('href', '/wiki/' + page);
    $('#is-outdated-article').removeClass('d-none');
    cleanup();
    var currentRevision = null;
    var previousRevision = null;
    __PS_MV_REG = [];
    return $.get('/api/revision/' + id, function(data) {
      currentRevision = data;
      return $.get('/api/previous-revision/' + id, function(data) {
        previousRevision = data;
        var diffHtml = htmldiff(previousRevision, currentRevision);
        $('article').html(diffHtml);
        __PS_MV_REG = [];
        return showTab('#page');
      }).fail(function(jqXhr, textStatus, errorThrown) {
        __PS_MV_REG = [];
        return errorThrown === 'Not Found'
          ? showTab('#not-found')
          : handleError(errorThrown, true);
      });
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return errorThrown === 'Not Found'
        ? showTab('#not-found')
        : handleError(errorThrown, true);
    });
  }
}
function handleSearchQuery(path) {
  if ((results = new RegExp('^/search/([^/]*)$').exec(path)) != null) {
    var query = results[1];
    $('.edit-button').addClass('disabled');
    showTab('#search');
    __PS_MV_REG = [];
    return $('#search-query').val(query);
  }
}
function handleQuizCreate(path) {
  if ((results = new RegExp('^/quiz/create$').exec(path)) != null) {
    showTab('#loading');
    __PS_MV_REG = [];
    return $.post(
      '/api/quiz/create',
      { csrf_token: readCookie('CSRF_TOKEN') },
      function(data) {
        __PS_MV_REG = [];
        return pushState('/quiz/' + data + '/edit');
      }
    ).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    });
  }
}
function handleQuizIdEdit(path) {
  if ((results = new RegExp('^/quiz/([^/]*)/edit$').exec(path)) != null) {
    var id = results[1];
    __PS_MV_REG = [];
    return showTab('#edit-quiz');
  }
}
function handleQuizIdPlay(path) {
  if ((results = new RegExp('^/quiz/([^/]*)/play$').exec(path)) != null) {
    var id = results[1];
    __PS_MV_REG = [];
    return $.get('/api/quiz/' + id, function(data) {
      window.correctResponses = 0;
      window.wrongResponses = 0;
      __PS_MV_REG = [];
      return replaceState('/quiz/' + id + '/play/0', { data: data });
    }).fail(function(jqXhr, textStatus, errorThrown) {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    });
  }
}
function handleQuizIdPlayIndex(path) {
  if (
    (results = new RegExp('^/quiz/([^/]*)/play/([^/]*)$').exec(path)) != null
  ) {
    var id = results[1];
    var index = results[2];
    index = parseInt(index);
    if (window.history.state.data.questions.length === index) {
      replaceState('/quiz/' + id + '/results');
      __PS_MV_REG = [];
      return null;
    }
    window.currentQuestion = window.history.state.data.questions[index];
    if (window.currentQuestion.type === 'multiple-choice') {
      showTab('#multiple-choice-question');
      $('.question-html').text(window.currentQuestion.question);
      $('#answers-html').text('');
      for (var i = 0; i < window.currentQuestion.responses.length; i += 1) {
        var answer = window.currentQuestion.responses[i];
        var template = $($('#multiple-choice-answer-html').html());
        template.find('.custom-control-label').text(answer.text);
        template.find('.custom-control-label').attr('for', i);
        template.find('.custom-control-input').attr('id', i);
        $('#answers-html').append(template);
      }
    }
    if (window.currentQuestion.type === 'text') {
      showTab('#text-question-html');
      __PS_MV_REG = [];
      return $('.question-html').text(window.currentQuestion.question);
    }
  }
}
function handleQuizIdResults(path) {
  if ((results = new RegExp('^/quiz/([^/]*)/results$').exec(path)) != null) {
    var id = results[1];
    showTab('#quiz-results');
    __PS_MV_REG = [];
    return $('#result').text(
      'Du hast ' +
        window.correctResponses +
        ' Fragen richtig und ' +
        window.wrongResponses +
        ' Fragen falsch beantwortet. Das sind ' +
        (
          (window.correctResponses * 100) /
          (window.correctResponses + window.wrongResponses)
        )
          .toFixed(1)
          .toLocaleString() +
        ' %'
    );
  }
}
$('.multiple-choice-submit-html').click(function() {
  var everythingCorrect = true;
  var i = 0;
  var _js367 = window.currentQuestion.responses;
  var _js369 = _js367.length;
  for (var _js368 = 0; _js368 < _js369; _js368 += 1) {
    var answer = _js367[_js368];
    $('#' + i).removeClass('is-valid');
    $('#' + i).removeClass('is-invalid');
    if (answer.isCorrect === $('#' + i).prop('checked')) {
      $('#' + i).addClass('is-valid');
    } else {
      $('#' + i).addClass('is-invalid');
      everythingCorrect = false;
    }
    ++i;
  }
  if (everythingCorrect) {
    ++window.correctResponses;
  } else {
    ++window.wrongResponses;
  }
  $('.multiple-choice-submit-html').hide();
  __PS_MV_REG = [];
  return $('.next-question').show();
});
$('.text-submit-html').click(function() {
  if ($('#text-response').val() === window.currentQuestion.answer) {
    ++window.correctResponse;
    $('#text-response').addClass('is-valid');
  } else {
    ++window.wrongResponses;
    $('#text-response').addClass('is-invalid');
  }
  $('.text-submit-html').hide();
  __PS_MV_REG = [];
  return $('.next-question').show();
});
$('.next-question').click(function() {
  $('.next-question').hide();
  $('.text-submit-html').show();
  $('.multiple-choice-submit-html').show();
  var pathname370 = window.location.pathname.split('/');
  __PS_MV_REG = [];
  return replaceState(
    '/quiz/' + pathname370[2] + '/play/' + (parseInt(pathname370[4]) + 1)
  );
});
$('#button-search').click(function() {
  var query = $('#search-query').val();
  $('#search-create-article').data('href', '/wiki/' + query + '/create');
  window.history.replaceState(null, null, '/search/' + query);
  $('#search-results-loading')
    .stop()
    .fadeIn();
  $('#search-results')
    .stop()
    .fadeOut();
  if ('undefined' === typeof window.searchXhr) {
    window.searchXhr.abort();
  }
  __PS_MV_REG = [];
  return (window.searchXhr = $.get('/api/search' + query, function(data) {
    $('#search-results-content').html('');
    var resultsContainQuery = false;
    if (data != null) {
      var _js372 = data.length;
      for (var _js371 = 0; _js371 < _js372; _js371 += 1) {
        var page = data[_js371];
        if (page.title === query) {
          resultsContainQuery = true;
        }
        var template = $($('#search-result-template').html());
        template.find('.s-title').text(page.title);
        template.data('href', '/wiki' + page.title);
        template.find('.search-result-summary').html(page.summary);
        $('#search-results-content').append(template);
      }
    }
    if (resultsContainQuery) {
      $('#no-search-results').hide();
    } else {
      $('#no-search-results').show();
    }
    $('#search-results-loading')
      .stop()
      .fadeOut();
    __PS_MV_REG = [];
    return $('#search-results')
      .stop()
      .fadeIn();
  }).fail(function(jqXhr, textStatus, errorThrown) {
    __PS_MV_REG = [];
    return textStatus !== 'abort' ? handleError(errorThrown, true) : null;
  }));
});
$('#login-form').on('submit', function(e) {
  e.preventDefault();
  var name = $('#inputName').val();
  var password = $('#inputPassword').val();
  $('#login-button')
    .prop('disabled', true)
    .html(
      '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Anmelden...'
    );
  __PS_MV_REG = [];
  return loginPost(false);
});
function loginPost(repeated) {
  __PS_MV_REG = [];
  return $.post(
    '/api/login',
    { csrf_token: readCookie('CSRF_TOKEN'), name: name, password: password },
    function(data) {
      $('#login-button')
        .prop('disabled', false)
        .html('Anmelden');
      $('#inputPassword').val('');
      window.localStorage.name = name;
      __PS_MV_REG = [];
      return window.history.state != null &&
        'undefined' !== typeof window.history.state.lastState &&
        'undefined' !== typeof window.history.state.lastUrl
        ? replaceState(
            window.history.state.lastUrl,
            window.history.state.lastState
          )
        : replaceState('/wiki/Hauptseite');
    }
  ).fail(function(jqXhr, textStatus, errorThrown) {
    window.localStorage.removeItem('name');
    if (errorThrown === 'Forbidden') {
      if (repeated) {
        alert('Ungültige Zugansdaten!');
        __PS_MV_REG = [];
        return $('#login-button')
          .prop('disabled', false)
          .html('Anmelden');
      } else {
        __PS_MV_REG = [];
        return loginPost(true);
      }
    } else {
      __PS_MV_REG = [];
      return handleError(errorThrown, true);
    }
  });
}
$('.create-multiple-choice-question').click(function() {
  __PS_MV_REG = [];
  return $('#questions').append($($('#multiple-choice-question').html()));
});
$('.create-text-question').click(function() {
  __PS_MV_REG = [];
  return $('#questions').append($($('#text-question').html()));
});
$('body').on('click', '.add-response-possibility', function(e) {
  __PS_MV_REG = [];
  return $(this)
    .siblings('.responses')
    .append($($('#multiple-choice-response-possibility').html()));
});
$('.save-quiz').click(function() {
  var obj = new Object();
  var pathname373 = window.location.pathname.split('/');
  obj.questions = [];
  $('#questions')
    .children()
    .each(function() {
      if ($(this).attr('class') === 'multiple-choice-question') {
        obj.questions.push(multipleChoiceQuestion($(this)));
      }
      __PS_MV_REG = [];
      return $(this).attr('class') === 'text-question'
        ? obj.questions.push(textQuestion($(this)))
        : null;
    });
  __PS_MV_REG = [];
  return $.post(
    '/api/quiz' + pathname373[2],
    { csrf_token: readCookie('CSRF_TOKEN'), data: JSON.stringify(obj) },
    function(data) {
      return window.history.replaceState(
        null,
        null,
        '/quiz/' + pathname373[2] + '/play'
      );
    }
  ).fail(function(jqXhr, textStatus, errorThrown) {
    __PS_MV_REG = [];
    return handleError(errorThrown, true);
  });
});
function textQuestion(element) {
  return {
    type: 'text',
    question: element.find('.question').val(),
    answer: element.find('.answer').val()
  };
}
function multipleChoiceQuestion(element) {
  var obj = {
    type: 'multiple-choice',
    question: element.find('.question').val(),
    responses: []
  };
  element
    .find('.responses')
    .children()
    .each(function() {
      var isCorrect = $(this)
        .find('.multiple-choice-response-correct')
        .prop('checked');
      var responseText = $(this)
        .find('.multiple-choice-response-text')
        .val();
      __PS_MV_REG = [];
      return obj.responses.push({ text: responseText, isCorrect: isCorrect });
    });
  return obj;
}
window.onpopstate = function(event) {
  if (window.lastUrl) {
    var pathname = window.lastUrl.split('/');
    if (
      pathname.length === 4 &&
      pathname[1] === 'wiki' &&
      (pathname[3] === 'create' || pathname[3] === 'edit')
    ) {
      if (confirm('Möchtest du die Änderung wirklich verwerfen?')) {
        updateState();
      }
      __PS_MV_REG = [];
      return null;
    }
  }
  __PS_MV_REG = [];
  return updateState();
};
updateState();
window.onbeforeunload = function() {
  var pathname374 = window.location.pathname.split('/');
  return pathname374.length === 4 &&
    pathname374[1] === 'wiki' &&
    (pathname374[3] === 'create' || pathname374[3] === 'edit')
    ? true
    : null;
};
$(document).on('input', '#search-query', function(e) {
  __PS_MV_REG = [];
  return $('#button-search').click();
});

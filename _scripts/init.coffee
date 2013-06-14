jQuery('head').append(jQuery('<link rel="stylesheet" type="text/css" />').attr('href', '/lib/style.min.css'))

jQuery ($) ->

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()

  document.gignal.stream = new Stream [],
    url: 'http://dev.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'

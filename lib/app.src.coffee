document.gignal = 
  views: {}


class Post extends Backbone.Model
  idAttribute: 'stream_id'


class Stream extends Backbone.Collection
  
  model: Post

  calling: false
  parameters:
    cid: 0
    limit: 5
    sinceTime: 0

  initialize: ->
    @on 'add', @inset, @
    @update()
    #@setIntervalUpdate()

  inset: (model) ->
    switch model.get 'type'
      when 'text'
        view = new document.gignal.views.TextBox
          model: model
      when 'photo'
        view = new document.gignal.views.PhotoBox
          model: model
    document.gignal.widget.$el.prepend(view.render().el).isotope('reloadItems').isotope 
      sortBy: 'original-order'

  parse: (response) ->
    return response.stream

  update: =>
    return if @calling
    @calling = true
    sinceTimeCall = @parameters.sinceTime
    @fetch
      remove: false
      cache: true
      timeout: 15000
      jsonpCallback: 'callme'
      data:
        limit: @parameters.limit
        sinceTime: @parameters.sinceTime
        cid: @parameters.cid += 1
      success: =>
        @calling = false
        document.gignal.widget.refresh()
        # set latest
        @parameters.sinceTime = _.max(@pluck('created_on'))
        # reset cache id?
        if sinceTimeCall isnt @parameters.sinceTime
          @parameters.cid = 0
      error: (c, response) =>
        if response.statusText is 'timeout'
          @calling = false
        else
          #location.reload true


  setIntervalUpdate: ->
    window.setInterval ->
      document.gignal.stream.update()
    , 4500

class document.gignal.views.Event extends Backbone.View

  el: '#gignal-widget'
  columnWidth: 250
  isotoptions:
    itemSelector: '.gignal-outerbox'
    layoutMode: 'masonry'
    sortAscending: true

  initialize: ->
    # set Isotope masonry columnWidth
    radix = 10
    mainWidth = @$el.innerWidth()
    columnsAsInt = parseInt(mainWidth / @columnWidth, radix)
    @columnWidth = @columnWidth + (parseInt((mainWidth - (columnsAsInt * @columnWidth)) / columnsAsInt, radix) - 1)
    # init Isotope
    @$el.isotope @isotoptions

  refresh: =>
    @$el.imagesLoaded =>
      @$el.isotope @isotoptions


class document.gignal.views.Text extends Backbone.View
  tagName: 'p'
  className: 'gignal-text'
  re_links: /(\b(https?):\/\/[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/g
  render: =>
    text = @model.get 'text'
    text = text.replace(@re_links, '<a href="$1" target="_top">link</a>')
    @$el.html text
    return @


class document.gignal.views.TextBox extends Backbone.View
  tagName: 'blockquote'
  className: 'gignal-outerbox'
  initialize: ->
    # create elements
    @text = new document.gignal.views.Text(model: @model).render()
    @footer = new document.gignal.views.Footer(model: @model).render()
  render: =>
    @$el.data 'saved_on', @model.get('saved_on')
    @$el.css 'width', document.gignal.widget.columnWidth
    @$el.html @text.$el
    @$el.append @footer.$el
    return @


class document.gignal.views.PhotoBox extends Backbone.View
  tagName: 'blockquote'
  className: 'gignal-outerbox gignal-imagebox'
  initialize: ->
    # create elements
    @footer = new document.gignal.views.Footer(model: @model).render()
  render: =>
    @$el.data 'saved_on', @model.get 'saved_on'
    @$el.css 'width', document.gignal.widget.columnWidth
    @$el.css 'background-image', 'url(' + @model.get('thumb_photo') + ')'
    @$el.append @footer.$el
    return @


class document.gignal.views.Footer extends Backbone.View
  tagName: 'div'
  className: 'gignal-box-footer'
  initialize: ->
    @serviceImg = new Backbone.View(
      tagName: 'img'
      attributes:
        src: 'images/' + @model.get('service') + '.png'
        alt: 'Service'
    )
    @avatar = new Backbone.View(
      tagName: 'img'
      className: 'gignal-avatar'
      attributes:
        src: @model.get('user_image')
        alt: 'Avatar'
    )
    @serviceProfileLink = new Backbone.View(
      tagName: 'a'
      attributes:
        href: 'http://' + @model.get('service') + '.com/' + @model.get('username')
    )

  render: =>
    $(@serviceProfileLink.$el).append @avatar.$el
    $(@serviceProfileLink.$el).append @model.get('name')
    @$el.html @serviceImg.$el
    @$el.append @serviceProfileLink.$el
    return @

jQuery('head').append(jQuery('<link rel="stylesheet" type="text/css" />').attr('href', '/lib/style.min.css'))

jQuery ($) ->

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()

  document.gignal.stream = new Stream [],
    url: 'http://dev.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'

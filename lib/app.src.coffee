document.gignal = 
  views: {}


class Post extends Backbone.Model
  idAttribute: 'stream_id'


class Stream extends Backbone.Collection
  
  model: Post

  calling: false
  parameters:
    cid: 0
    limit: 30
    sinceTime: 0

  initialize: ->
    @on 'add', @inset
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
    #document.gignal.widget.refresh()

  parse: (response) ->
    return response.stream
    
  comparator: (item) ->
    return - item.get 'saved_on'

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
        # set latest
        @parameters.sinceTime = _.max(@pluck('saved_on'))
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
    , 4800

class document.gignal.views.Event extends Backbone.View

  el: '#gignal-widget'
  columnWidth: 240
  isotoptions:
    itemSelector: '.gignal-outerbox'
    layoutMode: 'masonry'
    sortAscending: true

  initialize: ->
    # set Isotope masonry columnWidth
    radix = 10
    magic = 10
    mainWidth = @$el.innerWidth()
    columnsAsInt = parseInt(mainWidth / @columnWidth, radix)
    @columnWidth = @columnWidth + (parseInt((mainWidth - (columnsAsInt * @columnWidth)) / columnsAsInt, radix) - magic)
    # init Isotope
    @$el.isotope @isotoptions

  refresh: =>
    @$el.imagesLoaded =>
      @$el.isotope @isotoptions


class document.gignal.views.TextBox extends Backbone.View
  tagName: 'div'
  className: 'gignal-outerbox'
  re_links: /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g
  render: =>
    @$el.css 'width', document.gignal.widget.columnWidth
    text = @model.get 'text'
    text = text.replace @re_links, '<a href="$1">link</a>'
    username = @model.get 'username'
    username = null if username.indexOf(' ') isnt -1
    @$el.html Templates.post.render
      message: text
      username: username
      name: @model.get 'name'
      creation: @model.get 'creation'
      original_id: @model.get 'original_id'
      service: @model.get 'service'
      user_image: @model.get 'user_image'
    return @


class document.gignal.views.PhotoBox extends Backbone.View
  tagName: 'div'
  className: 'gignal-outerbox'
  render: =>
    #@$el.data 'saved_on', @model.get 'saved_on'
    @$el.css 'width', document.gignal.widget.columnWidth
    #@$el.css 'background-image', 'url(' + @model.get('thumb_photo') + ')'
    text = @model.get 'text'
    text = text.replace @re_links, '<a href="$1">link</a>'
    text = null if text.indexOf(' ') is -1
    username = @model.get 'username'
    username = null if username.indexOf(' ') isnt -1
    @$el.html Templates.photo.render
      message: text
      username: username
      name: @model.get 'name'
      creation: @model.get 'creation'
      original_id: @model.get 'original_id'
      service: @model.get 'service'
      user_image: @model.get 'user_image'
      thumb_photo: @model.get 'thumb_photo'
    return @

jQuery ($) ->

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()

  document.gignal.stream = new Stream [],
    url: 'http://dev.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'

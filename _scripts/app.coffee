document.gignal = 
  views: {}


class Post extends Backbone.Model

  idAttribute: 'stream_id'
  re_links: /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g

  getData: =>
    text = @get 'text'
    text = text.replace @re_links, '<a href="$1" target="_blank">link</a>'
    text = null if text.indexOf(' ') is -1
    username = @get 'username'
    username = null if username.indexOf(' ') isnt -1
    switch @get 'service'
      when 'Twitter'
        direct = 'http://twitter.com/' + username + '/status/' + @get 'original_id'
      when 'Facebook'
        direct = 'http://facebook.com/' + @get 'original_id'
      when 'Instagram'
        direct = @get 'direct_url'
        if not direct
          @set 'direct_url', '#'
          $.getJSON('https://api.instagram.com/v1/media/' + @get('original_id') + '?client_id=3ebcc844a6df41169c1955e0f75d6fce&callback=?')
          .done (response) =>
            if response.data?
              @set 'direct_url', response.data.link
      else
        direct = '#'
    data =
      message: text
      username: username
      name: @get 'name'
      since: humaneDate @get 'creation'
      service: @get 'service'
      user_image: @get 'user_image'
      photo: @get 'large_photo'
      direct: direct
    return data


class Stream extends Backbone.Collection
  
  model: Post

  calling: false
  parameters:
    cid: 0
    limit: 25
    offset: 0
    sinceTime: 0

  initialize: ->
    @on 'add', @inset
    @update()
    @setIntervalUpdate()

  inset: (model) =>
    switch model.get 'type'
      when 'text'
        view = new document.gignal.views.TextBox
          model: model
      when 'photo'
        view = new document.gignal.views.PhotoBox
          model: model
    method = if not @append then 'prepend' else 'append'
    document.gignal.widget.$el[method](view.render().el).isotope('reloadItems').isotope 
      sortBy: 'original-order'
    document.gignal.widget.refresh()
    
    
  parse: (response) ->
    return response.stream
    
  comparator: (item) ->
    return - item.get 'saved_on'

  isScrolledIntoView: (elem) ->
    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()
    elemTop = $(elem).offset().top
    elemBottom = elemTop + $(elem).height()
    return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

  update: (@append) =>
    return if @calling
    return if not @append and not @isScrolledIntoView '#gignal-stream header'
    @calling = true
    if not @append
      sinceTime = _.max(@pluck('saved_on'))
      # hack until issue #49 is fixed
      if not _.isFinite sinceTime
        sinceTime = Math.round(+new Date() / 1000) - (2 * 60 * 60)
        #sinceTime = 0
      offset = 0
    else
      sinceTime = _.min(@pluck('saved_on'))
      offset = @parameters.offset += @parameters.limit
    #sinceTimeCall = _.max(@pluck('saved_on'))
    @fetch
      remove: false
      cache: true
      timeout: 15000
      jsonpCallback: 'callme'
      data:
        limit: @parameters.limit
        offset: offset
        sinceTime: sinceTime if _.isFinite sinceTime
        #cid: @parameters.cid += 1
      success: =>
        @calling = false
        # reset cache id?
        # if sinceTimeCall isnt _.max(@pluck('saved_on'))
        #   @parameters.cid = 0
      error: (c, response) =>
        if response.statusText is 'timeout'
          @calling = false
        else
          window.setTimeout ->
            location.reload true
          , 10000


  setIntervalUpdate: ->
    sleep = 5000
    # ceil by 5sec then add 5sec
    start = (sleep * (Math.floor(+new Date() / sleep))) + sleep
    window.setTimeout ->
      sleep = 5000
      window.setInterval document.gignal.stream.update, sleep
    , start

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

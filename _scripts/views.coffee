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
    @$el.html Templates.tweet.render
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
  className: 'gignal-outerbox gignal-imagebox'
  render: =>
    #@$el.data 'saved_on', @model.get 'saved_on'
    @$el.css 'width', document.gignal.widget.columnWidth
    @$el.css 'background-image', 'url(' + @model.get('thumb_photo') + ')'
    return @

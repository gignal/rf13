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
    #@$el.append @footer.$el
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
    # @serviceImg = new Backbone.View(
    #   tagName: 'img'
    #   attributes:
    #     src: 'images/' + @model.get('service') + '.png'
    #     alt: 'Service'
    # )
    @avatar = new Backbone.View(
      tagName: 'img'
      className: 'gignal-avatar'
      attributes:
        src: @model.get 'user_image'
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
    # @$el.html @serviceImg.$el
    # @$el.append @serviceProfileLink.$el
    @$el.html @serviceProfileLink.$el
    return @

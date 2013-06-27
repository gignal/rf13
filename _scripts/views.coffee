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
  # initialize: ->
  #   @listenTo @model, 'change', @render
  render: =>
    @$el.css 'width', document.gignal.widget.columnWidth
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    data = @model.getData()
    if not data.message
      document.gignal.widget.$el.isotope 'remove', @$el
    @$el.html Templates.post.render data,
      footer: Templates.footer
    return @


class document.gignal.views.PhotoBox extends Backbone.View
  tagName: 'div'
  className: 'gignal-outerbox'
  initialize: ->
    @listenTo @model, 'change', @render
  render: =>
    # set width
    @$el.css 'width', document.gignal.widget.columnWidth
    # owner?
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    # get data
    data = @model.getData()
    # img exist?
    if not data.photo
      document.gignal.widget.$el.isotope 'remove', @$el
      return
    # render
    @$el.html Templates.photo.render @model.getData(),
      footer: Templates.footer
    return @

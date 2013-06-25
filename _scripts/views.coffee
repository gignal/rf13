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
  render: =>
    @$el.css 'width', document.gignal.widget.columnWidth
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    @$el.html Templates.post.render @model.getData(),
      footer: Templates.footer
    return @


class document.gignal.views.PhotoBox extends Backbone.View
  tagName: 'div'
  className: 'gignal-outerbox'
  render: =>
    @$el.css 'width', document.gignal.widget.columnWidth
    @$el.html Templates.photo.render @model.getData(),
      footer: Templates.footer
    return @

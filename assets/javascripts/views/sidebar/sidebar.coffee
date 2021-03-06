class app.views.Sidebar extends app.View
  @el: '._sidebar'

  @events:
    focus: 'onFocus'
    select: 'onSelect'
    click: 'onClick'

  @shortcuts:
    altR: 'onAltR'
    escape: 'onEscape'

  init: ->
    @addSubview @hover  = new app.views.SidebarHover @el unless app.isMobile()
    @addSubview @search = new app.views.Search

    @search
      .on 'searching', @onSearching
      .on 'clear', @onSearchClear
    .scope
      .on 'change', @onScopeChange

    @results = new app.views.Results @, @search
    @docList = new app.views.DocList

    app.on 'ready', @onReady
    return

  display: ->
    @el.style.display = 'block'
    return

  resetDisplay: ->
    @el.style.display = '' unless @el.style.display is 'none'
    return

  showView: (view) ->
    unless @view is view
      @hover?.hide()
      @saveScrollPosition()
      @view?.deactivate()
      @view = view
      @render()
      @view.activate()
      @restoreScrollPosition()
    return

  render: ->
    @html @view
    return

  showDocList: ->
    @showView @docList
    return

  showResults: =>
    @display()
    @showView @results
    return

  reset: ->
    @display()
    @showDocList()
    @docList.reset()
    @search.reset()
    return

  onReady: =>
    @view = @docList
    @render()
    @view.activate()
    return

  onScopeChange: (newDoc, previousDoc) =>
    @docList.closeDoc(previousDoc) if previousDoc
    if newDoc then @docList.reveal(newDoc.toEntry()) else @scrollToTop()
    return

  saveScrollPosition: ->
    if @view is @docList
      @scrollTop = @el.scrollTop
    return

  restoreScrollPosition: ->
    if @view is @docList and @scrollTop
      @el.scrollTop = @scrollTop
      @scrollTop = null
    else
      @scrollToTop()
    return

  scrollToTop: ->
    @el.scrollTop = 0
    return

  onSearching: =>
    @showResults()
    return

  onSearchClear: =>
    @resetDisplay()
    @showDocList()
    return

  onFocus: (event) =>
    @display()
    $.scrollTo event.target, @el, 'continuous', bottomGap: 2 unless event.target is @el
    return

  onSelect: =>
    @resetDisplay()
    return

  onClick: (event) =>
    return if event.which isnt 1
    if event.target.hasAttribute? 'data-reset-list'
      $.stopEvent(event)
      @onAltR()
    return

  onAltR: =>
    @reset()
    @docList.reset(revealCurrent: true)
    @display()
    return

  onEscape: =>
    @reset()
    @scrollToTop()
    return

  onDocEnabled: ->
    @docList.onEnabled()
    @reset()
    return

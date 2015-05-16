{CompositeDisposable} = require 'event-kit'
_ = require 'lodash'
{$} = require 'space-pen'

module.exports =
class TreeViewOpenFilesPaneView

  constructor: ->
    @items = []
    @panes = []
    @activeItem = null
    @paneSub = new CompositeDisposable

    @element = document.createElement('ul')
    @element.classList.add('tree-view', 'list-tree', 'has-collapsable-children', 'focusable-panel')
    nested = document.createElement('li')
    nested.classList.add('list-nested-item', 'expanded')
    @container = document.createElement('ul')
    @container.classList.add('list-tree')
    header = document.createElement('div')
    header.classList.add('list-item')

    headerSpan = document.createElement('span')
    headerSpan.classList.add('name', 'icon', 'icon-file-directory')
    headerSpan.setAttribute('data-name', 'Git Modified')
    headerSpan.innerText = 'Git Modified'
    header.appendChild headerSpan
    nested.appendChild header
    nested.appendChild @container
    @element.appendChild nested

    $(@element).on 'click', '.list-nested-item > .list-item', ->
      nested = $(this).closest('.list-nested-item')
      nested.toggleClass('expanded')
      nested.toggleClass('collapsed')

    self = this

    $(@element).on 'click', '.list-item[is=tree-view-file]', ->
      atom.workspace.open(self.entryForElement(this).item)

    # TODO: Use getRepositories to support Atom 2.0 when available
    repo = atom.project.getRepo()

    if (repo)
      repo.onDidChangeStatuses => self.reloadStatuses self, repo
      repo.onDidChangeStatus (item) => self.reloadStatuses self, repo

  reloadStatuses: (self, repo) ->
    if repo?
      self.removeAll()
      for filePath of repo.statuses
        if repo.isPathModified(filePath)
          self.addItem filePath, 'status-modified'
        if repo.isPathNew(filePath)
          self.addItem filePath, 'status-added'

  setPane: (pane) ->
    @paneSub.add pane.observeActiveItem (item) =>
      @activeItem = item
      @setActiveEntry item

    @paneSub.add pane.onDidChangeActiveItem (item) =>
      if (!item)
        @activeEntry?.classList.remove 'selected'

    @paneSub.add pane.onDidChangeActive (isActive) =>
      @activeItem = pane.activeItem
      if (isActive)
        @setActiveEntry pane.activeItem

  addItem: (item, status) ->
    # Checks if item already exists to avoid adding it twice
    exists = _.findIndex @items, (itemsItem) -> itemsItem.item is item

    if (exists < 0)
      listItem = document.createElement('li')
      listItem.classList.add('file', 'list-item', status)
      listItem.setAttribute('is', 'tree-view-file')
      listItemName = document.createElement('span')
      listItemName.innerText = item.split('/')[item.split('/').length-1]
      listItemName.classList.add('name', 'icon', 'icon-file-text')
      listItemName.setAttribute('data-path', item)
      listItemName.setAttribute('data-name', item)
      listItem.appendChild listItemName
      @container.appendChild listItem

      @items.push item: item, element: listItem

      if (@activeItem)
        @setActiveEntry @activeItem

  updateTitle: (item, siblings=true, useLongTitle=false) ->
    title = item.getTitle()

    if siblings
      for entry in @items
        if entry.item isnt item and entry.item.getTitle?() == title
          useLongTitle = true
          @updateTitle entry.item, false, true

    if useLongTitle and item.getLongTitle?
      title = item.getLongTitle()

    if entry = @entryForItem(item)
      $(entry.element).find('.name').text title

  entryForItem: (item) ->
    _.detect @items, (entry) ->
      if item.buffer && item.buffer.file
        item.buffer.file.path.indexOf(entry.item) > -1

  entryForElement: (item) ->
    _.detect @items, (entry) -> entry.element is item

  setActiveEntry: (item) ->
    if item
      @activeEntry?.classList.remove 'selected'
      if entry = @entryForItem item
        entry.element.classList.add 'selected'
        @activeEntry = entry.element

  removeAll: ->
    for item in @items
      item.element.remove()
    @items = []

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @paneSub.dispose()

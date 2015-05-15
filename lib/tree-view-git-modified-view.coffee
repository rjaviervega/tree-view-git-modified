{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'event-kit'

TreeViewGitModifiedPaneView = require './tree-view-git-modified-pane-view'

module.exports =
class TreeViewGitModifiedView
  
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('tree-view-git-modified')

    @paneSub = new CompositeDisposable

    @treeViewGitModifiedPaneView = new TreeViewGitModifiedPaneView
    @element.appendChild @treeViewGitModifiedPaneView.element

    @paneSub.add atom.workspace.observePanes (pane) =>
      @treeViewGitModifiedPaneView.setPane pane
      # TODO: Implement tear down on pane destroy subscription if needed (TBD)
      # destroySub = pane.onDidDestroy =>
      #   destroySub.dispose()
      #   @removeTabGroup pane
      # @paneSub.add destroySub

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @paneSub.dispose()

  getElement: ->
    @element

  # Toggle the visibility of this view
  toggle: ->
    if @element.parentElement?
      @hide()
    else
      @show()

  hide: ->
    @element.remove()

  show: ->
    requirePackages('tree-view').then ([treeView]) =>
      treeView.treeView.find('.tree-view-scroller').css 'background', treeView.treeView.find('.tree-view').css 'background'
      treeView.treeView.prepend @element

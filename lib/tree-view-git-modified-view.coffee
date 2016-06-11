{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'event-kit'

TreeViewGitModifiedPaneView = require './tree-view-git-modified-pane-view'

module.exports =
class TreeViewGitModifiedView

  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('li')
    @treeViewGitModifiedPaneViewArray = []
    @paneSub = new CompositeDisposable
    @loadRepos()
    @paneSub.add atom.project.onDidChangePaths (path) =>
      @loadRepos()

  loadRepos: ->
    self = this

    # Remove all existing panels
    for tree in @treeViewGitModifiedPaneViewArray
      tree.hide()

    repos = atom.project.getRepositories()
    for repo in repos
      if repo == null
        for tree in self.treeViewGitModifiedPaneViewArray
          if repo.path == tree.repo.path
            tree.show()
      else
        treeViewGitModifiedPaneView = new TreeViewGitModifiedPaneView repo
        treeViewGitModifiedPaneView.setRepo repo
        self.treeViewGitModifiedPaneViewArray.push treeViewGitModifiedPaneView
        self.element.appendChild treeViewGitModifiedPaneView.element

        self.paneSub.add atom.workspace.observePanes (pane) =>
            treeViewGitModifiedPaneView.setPane pane

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
      parentElement = treeView.treeView.element.querySelector('.tree-view-scroller .tree-view')
      parentElement.insertBefore(@element, parentElement.firstChild)

{CompositeDisposable} = require 'atom'
{requirePackages} = require 'atom-utils'
TreeViewGitModifiedView = require './tree-view-git-modified-view'

module.exports = TreeViewGitModified =

  treeViewGitModifiedView: null
  subscriptions: null
  isVisible: true

  activate: (state) ->
    @treeViewGitModifiedView = new TreeViewGitModifiedView(state.treeViewGitModifiedViewState)
    @isVisible = state.isVisible

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view-git-modified:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view-git-modified:openAll': => @openAll()
    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view-git-modified:show': => @show()
    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view-git-modified:hide': => @hide()

    @subscriptions.add atom.project.onDidChangePaths (path) =>
      @show()

    requirePackages('tree-view').then ([treeView]) =>
      if (!@treeViewGitModifiedView)
        @treeViewGitModifiedView = new TreeViewGitModifiedView

      if (treeView.treeView && @isVisible) or (@isVisible is undefined)
        @treeViewGitModifiedView.show()

      atom.commands.add 'atom-workspace', 'tree-view:toggle', =>
        if treeView.treeView?.is(':visible')
          @treeViewGitModifiedView.hide()
        else
          if @isVisible
            @treeViewGitModifiedView.show()

      atom.commands.add 'atom-workspace', 'tree-view:show', =>
        if @isVisible
          @treeViewGitModifiedView.show()

  deactivate: ->
    @subscriptions.dispose()
    @treeViewGitModifiedView.destroy()

  serialize: ->
    isVisible: @isVisible
    treeViewGitModifiedViewState: @treeViewGitModifiedView.serialize()

  toggle: ->
    if @isVisible
      @treeViewGitModifiedView.hide()
    else
      @treeViewGitModifiedView.show()
    @isVisible = !@isVisible

  show: ->
    @treeViewGitModifiedView.show()
    @isVisible = true

  hide: ->
    @treeViewGitModifiedView.hide()
    @isVisible = false

  openAll: ->
    repo = atom.project.getRepo()
    if repo?
      for filePath of repo.statuses
        if repo.isPathModified(filePath) or repo.isPathNew(filePath)
          atom.workspace.open(filePath)
    else
      atom.beep()

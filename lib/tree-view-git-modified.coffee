TreeViewGitModifiedView = require './tree-view-git-modified-view'
{CompositeDisposable} = require 'atom'

module.exports = TreeViewGitModified =
  treeViewGitModifiedView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @treeViewGitModifiedView = new TreeViewGitModifiedView(state.treeViewGitModifiedViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @treeViewGitModifiedView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view-git-modified:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @treeViewGitModifiedView.destroy()

  serialize: ->
    treeViewGitModifiedViewState: @treeViewGitModifiedView.serialize()

  toggle: ->
    console.log 'TreeViewGitModified was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

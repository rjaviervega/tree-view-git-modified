# tree-view-git-modified package

Shows a list of git modified files on top of the tree-view for easy access. Opens all git modified files at once with a simple command.

This plugin was developed by using code samples from the following atom plugins:
- tree-view-open-files
- open-git-modified-files

## Usage

```
'ctrl-alt-o': 'tree-view-git-modified:toggle' // Shows or hides panel
'ctrl-cmd-o': 'tree-view-git-modified:openAll' // Open all git modified files
```

![A screenshot of your package](https://raw.githubusercontent.com/rjaviervega/tree-view-git-modified/master/screenshots/tree-view-git-modified.png)

## Issues

- This package doesn't work well when the package tree-view-git-projects is installed.
- This package doesn't work with multiple projects folders added to the workspace.

## TODO

- Include option to customize background color of selected items on tree-view.
- Include icons to show git statuses and icons to quickly add/remove from git index.
- Review why tree-view-git-projects breaks this package and try to make them compatible.
- Add support for multiple repos added to the workspace.
- Add additional test cases.

## License MIT.

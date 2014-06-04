# How to contribute

Third-party patches are essential for keeping lamamos great.
We want to keep it as easy as possible to contribute changes that
get things working in your use-case. There are a few guidelines that we
need contributors to follow so that we can have a chance of keeping on
top of things.

## Getting Started

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the develop branch. (the master branch contains only stable revisions)
  * To quickly create a topic branch based on master; `git branch
    my_contribution develop` then checkout the new branch with `git
    checkout my_contribution`.  Please avoid working directly on the
    `develop` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.

## Style

* Code: Two spaces, no tabs
* PHP : Use [Doxygen](http://www.doxygen.org) comments
* JS : Use [Yuidoc](http://yui.github.io/yuidoc/) comments
* No trailing whitespace. Blank lines should not have any space.

## Submitting Changes

* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository in the lamamos organization.

# Additional Resources

* [More information on contributing](https://github.com/lamamos/lamamos.github.io/wiki)
* [Issue tracker](https://github.com/lamamos/lamamos_installation_script/issues)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* Mailling list : [lamamos@freelists.org](lamamos@freelists.org)

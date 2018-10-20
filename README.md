Readme
======

## Importing the project
In RStudio go to File>New Project>Version Control>Git>Repository URL=
`https://github.com/brian--/probstat-project`.

### Staying updated
If you make a github account and give me your account info I'll add you to the
repo. Once you do that we can keep all the changes synced there.

There is a `Git` tab at the top right that can be used to keep your changes
synced.

`Diff` will tell you what you have changed.

The checkboxes next to filenames will stage them to be committed.

`Commit` will save the current version of staged files to local history. Do this
when something is working and you want to save it.

The down arrow pulls(downloads) others' changes from github. Do this before you
make changes or push.

The up arrow pushes(uploads) your changes to github. Only upload if your added
code is working.

## Navigating files
`R/deps.R` will pull a couple dependencies I've needed.

`R/data.R` generates a dataset and puts it in an RData file in the data folder.
This should be treated as an immutible cache and not modified.

`doc/paper.Rmd` is an R markdown file that we can use for writing the paper.
It'll be easier than trying to copypaste generated figures into Google Drive or
something.

## Building the project
You can just run the files individually in the order listed above. Once you've
run `deps.R` and `data.R`, you don't have to run them again. If you want to
refresh the cached data, just delete `data/fossils.RData` and run `data.R` again.

*This is probably not working yet for most if not everyone*

I added a makefile, so `make` or the build button in RStudio may be able to
refresh data if needed, download deps, and make some figures (currently not
saved anywhere). Also builds the tex file for paper, but should probably be
using sweave for ease of use and such so this part will change.


#!/bin/bash
# 
# sets up a sample git repo with a nice release history. This can be used to test the release-note functionality.

# cautionary statement: do not execute anything unless the user has understood what this code does
exit 0

git init
date > file
git add file
git commit -a -m 'First commit'
git branch release
date > file
git commit -a -m 'Commit A'
date >> file
git commit -a -m 'Commit B' -m 'FIX Fix bug #1' -m 'CHG refactoring'
date >> file
git commit -a -m 'Commit C' -m 'NEW Implement tab view' -m 'FIX Fix bug #2'
git checkout release
git merge master --no-ff --no-commit
VERSION=0.0.1
git commit -m "Release-$VERSION"
git tag -a "release-$VERSION" -m "Release-$VERSION"

git checkout master
git merge release --no-ff -m "After release-$VERSION"



date >> file
git commit -a -m 'Commit D' -m 'FIX Fix bug #3' -m 'TXT re-texted combobox' -m 'some other item (ignored)'
date >> file
git commit -a -m 'Commit E' -m 'NEW Implement another tab view which is supposed to replace the super duper first tab solution by a smooth new solution which is so wonderful and beautiful that it surely awes everyon who dares to behold it. Yes, it is indeed wonderful! May all future releases contain such marvellous changes.' -m 'to be ignored'
git checkout release
git merge master --no-ff --no-commit
VERSION=0.0.2
git commit -m "Release-$VERSION"
git tag -a "release-$VERSION" -m "Release-$VERSION"

git checkout master
git merge release --no-ff -m "After release-$VERSION"


git date >> file
git commit -a -m 'Commit F' -m 'some other item (ignored)' -m 'TXT Some label changes' 
date >> file
git commit -a -m 'Commit G' -m 'CHG Implement yet ANTHOER tab view (!!!) which is supposed to replace the super duper second tab solution by a smooth new solution which is so wonderful and beautiful that it surely awes everyon who dares to behold it. Yes, it is indeed wonderful! May all future releases contain such marvellous changes.' -m 'to be ignored'
git checkout release
git merge master --no-ff --no-commit
VERSION=0.0.3
git commit -m "Release-$VERSION"
git tag -a "release-$VERSION" -m "Release-$VERSION"

git checkout master
git merge release --no-ff -m "After release-$VERSION"


git date >> file
git commit -a -m 'Commit H' -m 'some other item (ignored)' -m 'TXT Some more label changes' 
git checkout release
git merge master --no-ff --no-commit
VERSION=0.0.4
git commit -m "Release-$VERSION"
git tag -a "release-$VERSION" -m "Release-$VERSION"

git checkout master
git merge release --no-ff -m "After release-$VERSION"

release-notes
=============

Generates release notes by scanning Git log messages between a release and the previous release.

## Installation

Put both scripts, `generate_release_notes.sh` and `generate_release_notes.pl` in the same directory, anywhere. 

*Remark:* It would make sense to choose some path containing executables, e.g. `/usr/local/bin`.   

## Usage 

The release to be analysed has to be given as parameter. The previous release will be found automatically if the release have been generated in line with a *first-parent* history (on a release branch).

Usage:

    generate_release_notes.sh VERSION

Parameter `VERSION` is the version number of the release for which you would like to generate the release notes. The tool will then search for a corresponding tag named `release-$VERSION`. This would be the Git object representing the desired release.

### Example

    generate_release_notes.sh 0.1.5

This would search for all commits between the tag `release-0.1.5` and its first-parent predecessor, analyze all log messages in between and generate a release log based on the found items.


## Precondition

The way releases are represented in Git is crucial for this tool to work. This tool assumes that the guidelines in the book "Git - Dezentrale Versionsverwaltung im Team", chapter 19 "Ein Release durchfuehren" is followed.

For all of you who have no access to the book, here are the rules:

1. there is a **separate release branch**, holding the [first parent] history of releases
2. each release is tagged with a **release tag** on the release branch
3. the **name of the release tag** is `release-X.Y.Z`. X, Y and Z are major, minor and patch version, respectively. X, Y and Z consist only of digits.
4. the previous release to any release can be found by going back one step in **first-parent history** of the release tag (i.e., on the release branch)

## Parameters:

`RELEASE` ... name of release to be analyzed, e.g. "0.1.5"

## Details on parsing log messages

The tool will first identify all commits between the previous release and the specified one. Then, it scans all commit messages of the affected commits for keywords, so-called **tags**.

Commit log messages can contain arbitrary text. Some of the text is considered a release log item, other text is not.

### Identify release log items

First, leading whitespace and a dash at the beginning of the line is stripped (ignored).

If (after leading whitespace and/or a dash) a line starts with a **tag**, it is considered an item for the release notes. The number and type of tags depend on the configuration (s. section "Configuration" below for details). Typical tags these are:

* `NEW` ... marks new features
* `CHG` ... marks changed features
* `TXT` ... marks textual or layout changes, thus cosmetic changes
* `FIX` ... marks bug fixes

Depending on the tag, the release note item will show up in the corresponding section of the release note. For example, all new features (tagged with `NEW`) will be listed in the section "New Features", whereas all items tagged with `FIX` will be listed in the section "Bugfixes".

### Parsing

If a tag has been found, the rest of the line plus all subsequent lines are considered to be the text of this one release note item **until a blank line** or the **end of commit message** are encountered.  

Such release log items consisting of multiple lines are joined into one line. Whitespace at the end or beginning of lines is trimmed to a single space.


## Example

Suppose you have the following commit messages between a release and the preceding release:

    commit 17af183515a0ea08855e7614ac2bfb47d91e2695
    tree e8704969a853f61935356dfc9ca75ab389e7b5a6
    parent 533b50809f8b69eea95f07bbaa184b3fe1089381
    author Andi Meier <andimeiergmx.net> 1407308548 +0200
    committer Andi Meier <andimeiergmx.net> 1407308548 +0200
    
        Nothing special.
        
        Nothing at all.
    
    commit 533b50809f8b69eea95f07bbaa184b3fe1089381
    tree f167e8c946d4dc5b9c34063fe4beb947123868f5
    parent 76f8c25043b4c7920593fc7d7cefe8fd8a03de1f
    author Andi Meier <andimeiergmx.net> 1407308456 +0200
    committer Andi Meier <andimeiergmx.net> 1407308456 +0200
    
        Some useful things:
        
        - NEW new feature "XZ"
        
        - FIX fixes issue #3
        
        - CHG refactoring bla bal asdfertio asklj asjkl sg;kljweqrtioaj sgjklad
          f;gkljeoritgja s;glkja eorigj a;lkgja;lsdfjkg a;ldkjfg aoeijrg a;ldfjkg
          a;ldjgrioearjg a;dlfg. There is much more to say about this fantastic 
    	  but there is not sufficient space to do so. Thus said, this is the end 
    	  of the change description.
        
        - NEW another feature B
    
    commit 76f8c25043b4c7920593fc7d7cefe8fd8a03de1f
    tree 01f2fe8dd174b94974152d806056ebf877ce3ebf
    author Andi Meier <andimeiergmx.net> 1407308428 +0200
    committer Andi Meier <andimeiergmx.net> 1407308428 +0200
    
        NEW new date file
    
    	TEXT replaced all "Exception" by "Event"
    	
    	This is not a NEW line
    	
    	FIX fixes issue #asdfsafd
	
The generated release log would look like this:

### Release 0.1.5

Release date: 2014-08-01

#### New Features

- new feature "XZ"
- another feature B
- new date file

#### Bugfixes

- fixes issue #3
- fixes issue #asdfsafd

#### Other Changes

- refactoring bla bal asdfertio asklj asjkl sg;kljweqrtioaj sgjklad f;gkljeoritgja s;glkja eorigj a;lkgja;lsdfjkg a;ldkjfg aoeijrg a;ldfjkg a;ldjgrioearjg a;dlfg. There is much more to say about this
fantastic  but there is not sufficient space to do so. Thus said, this is the end  of the change description.

#### Cosmetic Changes

- replaced all "Exception" by "Event"
 
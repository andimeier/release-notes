#!/bin/bash
#
# Generates release notes by scanning the log messages between a release and the previous release.
# The release to be analysed has to be given as parameter. The previous release will be found
# automatically if the release have been generated in line with first-parent (on a release branch).
#
# Precondition:
# The way released are represented in Git is crucial for this tool to work. This tool assumes
# that the guidelines in the book "Git - Dezentrale Versionsverwaltung im Team", chapter 19 "Ein
# Release durchfuehren" is followed.
#
# These are the rules:
#
# 1. there is a separate release branch, holding the [first parent] history of releases
#
# 2. each release is tagged with a release tag on the release branch
#
# 3. the name of the release tag is 'release-X.Y.Z'. X, Y and Z are major, minor and build version,
#    respectively. X, Y and Z consist only of digits.
#
# 4. the previous release to any release can be found by going back one step in first-parent history
#    of the release tag (i.e., on the release branch)
#
# Parameters:
#   RELEASE ... name of release to be analyzed, e.g. "0.1.5"

DEBUG=0 # 1 ... additional debug output

if [ "$1" == "" ] ; then
	echo "ERROR mandatory parameter VERSION (e.g. \"0.1.5\") missing."
	exit 1
fi

RELEASE=$1
RELEASE_TAG=release-$RELEASE

if ! echo $RELEASE | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null ; then
	echo "ERROR parameter RELEASE must consist solely of the version string, nothing else. E.g.: \"0.1.5\""
	exit 1
fi

# try to find the release tag
CHECK_TAG=`git tag -l $RELEASE_TAG`
if [ "$CHECK_TAG" == "" ] ; then
	echo "ERROR could not find tag $RELEASE_TAG"
	exit 1
fi

PREVIOUS_RELEASE=`git log --format=format:"%H" --first-parent ${RELEASE_TAG} | sed -n -e '2p'`
RELEASE_DATE=`git log --first-parent --format=format:"%ci" -1 ${RELEASE_TAG} | sed -e 's/ .*$//g'`

# check if a valid SHA1 hash has been determined for the previous release
if ! echo $PREVIOUS_RELEASE | grep -E '^[0-9a-f]{40}$' >/dev/null ; then
	echo "ERROR no previous release found. Unable to determine the diff to the previous release"
	exit 1
fi


if [ "$DEBUG" == "1" ] ; then
	echo "-----------------------------------------------------------------------"
	echo "Release:                       $RELEASE"
	echo "Release date:                  $RELEASE_DATE"
	echo "SHA1 hash of previous release: $PREVIOUS_RELEASE"
	echo "-----------------------------------------------------------------------"
fi

git --no-pager log --format=raw ${PREVIOUS_RELEASE}..${RELEASE_TAG} | `dirname $0`/generate_release_notes.pl $RELEASE $RELEASE_DATE

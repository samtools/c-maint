Making a release of htslib, samtools, and bcftools, or just one or two of them, has several stages: the source control gymnastics of tagging the desired source as a release; generating the release tarballs/packages; and uploading the release to GitHub and SourceForge and publicising it.

# Tagging the release

We follow the [git-flow] conventions, where releases are tagged on the **master** branch.  We also merge the release commit back to **develop**, so that `git describe` describes subsequent commits on the **develop** branch with respect to the newly-created latest release.

[git-flow]: http://nvie.com/posts/a-successful-git-branching-model/

## Merge to master

We first set up the merge commit that will eventually be tagged as the release:

    git checkout --track origin/master
    git merge --no-ff --no-commit develop

but do not commit it, as version numbers etc will be bumped within the merge commit -- so that no commits prior to this one (which will eventually be the one tagged as the release) contain the bumped version number.  In particular, for `H`/`S`/`B`, i.e., for HTSlib/SAMtools/BCFtools respectively, make the following edits:

* `HSB`  Update `PACKAGE_VERSION` in _Makefile_
* `HS `  Add to _NEWS_
* ` S `  Update version number in _README_ (on three lines)
* ` S `  Update version number in _bam.h_ (removing any `+` in the string)
* `HSB`  Update `.TH` date and version in manual pages
  - `H`: _htsfile.1 tabix.1_
  - `S`: _samtools.1 misc/wgsim.1_
  - `B`: `make DOC_VERSION=1.X DOC_DATE=YYYY-MM-DD docs`

And finally commit it:

    git add <various>
    git commit --no-verify -m 'Release X.Y.Z: summary'

## Tag release commit

Tag this merge commit, using "HTSlib [patch] release X.Y.Z: summary" etc as the subject line and the release notes copied from _NEWS_ as the body of the commit message.  You want to use an annotated (`-a`) or ideally signed (`-s`) tag:

    git tag -s VERSION

Keep the first (subject) line of the commit message short, so that `git tag -n` displays well in a standard-width terminal.  You have 63 characters.

If you are signing the tag, you may wish to prepare the message in a file and use `git tag -F msg.txt --cleanup=verbatim` so that you can preserve a trailing blank line at the end of the file to separate the `-----BEGIN PGP SIGNATURE-----` line from the release notes.

If you have done this on a separate mostly-offline machine that has your private GPG key on it, pull the tag back to your usual development machine with e.g.

    git pull --tags host:path/to/htslib VERSION

## Merge back to develop

Finally, and somewhat at your leisure, merge the version number bumps etc back to the **develop** branch:

    git checkout develop
    git fetch
    git merge --no-ff --no-commit master

* `HS `  Add new header to _NEWS_
* ` S `  Add `+` to `BAM_VERSION` in _bam.h_

    git add NEWS bam.h
    git commit -m 'Merge version number bump and NEWS file from master'


# Generate release tarballs

This repository's _Makefile_ contains recipes to build release tarballs from Git repositories alongside this directory, i.e., it expects to find appropriate repositories in _../htslib_, _../samtools_, and _../bcftools_.


# Uploading to GitHub and SourceForge


<!-- vim:set linebreak: -->

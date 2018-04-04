Making a release of htslib, samtools, and bcftools, or just one or two of them, has several stages: the source control gymnastics of tagging the desired source as a release; generating the release tarballs/packages; and uploading the release to GitHub and SourceForge and publicising it.

# Release process summary

* Update the version number in `mkrelease`

* Run `mkrelease`.  This will clone repositories into `$HOME/tmp/release/<version>`, merge changes to `master` with necessary changes and commit everything.  It will also reformat the NEWS file into versions suitable for GitHub, SourceForge and the release tag.

* **Check that `mkrelease` has worked correctly.**
  - Use `gitk --all` on each repository
  - Grep for the old version number to ensure it's been replaced everywhere
  - Check man pages have the correct date
  - If any errors are found, fix `mkrelease` and re-run it.

* Make any minor tweaks necessary to various _notes_ files

* Run `tag_release` to add the release tag and merge changes back to develop.

* **Check that `tag_release` has worked correctly.**
  - Use `gitk --all` on each repository

* Run `make tar TAG=<version> PREFIX_DIR=$HOME/tmp/release/<version>`
  - Will make tar files in this directory

* **Check the tar files are correct.**
  - Compare to previous tar files
  - Unpack, build and test on various platforms

* Make draft releases on GitHub
  - Copy in <repos>_notes_github.txt files
  - Upload tar files

* Make staged directory on SourceForge
  - `cat {htslib,samtools,bcftools}_notes_sf.txt > README.txt` and upload
  - Upload tar files

* Prepeare tweet and release announcement email

* Do release
  - **Check that everything is ready and correct.**
  - For each reposiotry in `$HOME/tmp/release/<version>` run `git push origin master develop <version>`
  - Fill in tag and publish release on GitHub repositories
  - Unstage the SourceForge directory
  - Select new samtools tarball for the download button.
  - **Check the published release pages are as expected (correct text and files attached).**

* Send tweet and email

* Update www.htslib.org
  - Update download buttons to point to the new release
  - Run `make` to update the man pages
  - Push to your own fork of www.htslib.org gh-pages and check it looks OK.
  - When ready, push to samtools' www.htslib.org gh-pages

* Push any changes made to this repository.

# Tagging the release

We follow the [git-flow] conventions, where releases are tagged on the **master** branch.  We also merge the release commit back to **develop**, so that `git describe` describes subsequent commits on the **develop** branch with respect to the newly-created latest release.

[git-flow]: http://nvie.com/posts/a-successful-git-branching-model/

## Merge to master

NB: This stage can now be automated using the `mkrelease` script.  Simply update the version number at the top, and run it.

We first set up the merge commit that will eventually be tagged as the release:

    git checkout --track origin/master
    git merge --no-ff --no-commit develop

but do not commit it, as version numbers etc will be bumped within the merge commit -- so that no commits prior to this one (which will eventually be the one tagged as the release) contain the bumped version number.  In particular, for `H`/`S`/`B`, i.e., for HTSlib/SAMtools/BCFtools respectively, make the following edits:

* `HSB`  Update `VERSION` in _version.sh_
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

NB: This stage (and "merge back to develop") can now be done using the `tag_release` script.

Tag this merge commit, using "HTSlib [patch] release X.Y.Z: summary" etc as the subject line and the release notes copied from _NEWS_ as the body of the tag message.  You want to use an annotated (`-a`) or ideally signed (`-s`) tag:

    git tag -s VERSION

Keep the first (subject) line of the message short, so that `git tag -n` displays well in a standard-width terminal.  You have 63 characters.

If you are signing the tag, you may wish to prepare the message in a file and use `git tag -F msg.txt --cleanup=verbatim` so that you can preserve a trailing blank line at the end of the file to separate the `-----BEGIN PGP SIGNATURE-----` line from the release notes.

If you have done this on a separate mostly-offline machine that has your private GPG key on it, pull the tag back to your usual development machine with e.g.

    git pull --tags host:path/to/htslib VERSION

## Merge back to develop

Finally, and somewhat at your leisure, merge the version number bumps etc back to the **develop** branch:

    git checkout develop
    git fetch
    git merge --no-ff --no-commit master

There is an edit to be made to _samtools/bam.h_, and also to _*/NEWS_ if you decide to add items along the way to a subsequent release:

* `HS `  Add new header to _NEWS_
* ` S `  Add `+` to `BAM_VERSION` in _bam.h_

And finally commit it to **develop**:

    git add NEWS bam.h
    git commit -m 'Merge version number bump and NEWS file from master'


# Generate release tarballs

This repository's _Makefile_ contains recipes to build release tarballs from Git repositories alongside this directory, i.e., it expects to find appropriate repositories in _../htslib_, _../samtools_, and _../bcftools_.

You can build tarballs of all three projects with

    make tar TAG=1.x

where the value supplied for `TAG` is really any commit-ish, but usually a tag.  This creates _htslib-\<tag\>.tar.bz2_ etc; the _samtools_/_bcftools_ tarballs contain their own copy of HTSlib and their _Makefile_ is adjusted to point to it.  _Aclocal_, _autoheader_, and _autoconf_ are run as appropriate before the tarballs are created.

Almost always the versions for SAMtools/BCFtools and the embedded HTSlib will be the same.  But if you need to inject a different version of HTSlib append `HTSTAG=1.y` to the command line above.

Test these tarballs by unpacking them and doing a trial build and `make test`.  You may also wish to diff a `tar tvf` listing with a listing of the previous release of each package, and ensure that all file additions and removals can be explained.

If you want to make a tarball of only one project, use

    make TAG=1.x samtools-1.x.tar.bz2

(It might be worthwhile altering the scripts and _Makefile_ so that `$(TAG)` can be derived from specified filenames, rather than repeating yourself.)


# Uploading to GitHub and SourceForge

We currently upload tarballs and release notes to both GitHub and SourceForge.  It is a fairly lengthy process.

1. Using the [web interface], create a new `1.x` subdirectory and mark it as "staged".

2. Using [scp or sftp], upload the release tarballs to SourceForge:

        $ sftp SF-USER@frs.sourceforge.net
        sftp> cd /home/frs/project/samtools/samtools/1.x
        sftp> put *-1.x.tar.bz2

    It will take some time before these files are replicated to the various mirrors.

3. Prepare the updates for [htslib.org].

    Also prepare the announcement email and tweets.

4. On the **Releases** page of each of the GitHub repositories to be released, use the "Draft a new release" button.  Leave the "Tag version" blank for now, as the tags have not yet been pushed to GitHub.  For now, fill in the release notes by copying from _NEWS_ and markdownifying the text, and attach the release tarball.  Add the following boilerplate to the bottom of the release notes:

        ---

        _The **[foo-1.x].tar.bz2** download is the full source code release. The “Source code” downloads are generated by GitHub and are incomplete as they [don't bundle HTSlib and] are missing some generated files._

    For now, save this as a draft.

5. Push your branch updates and new tags:

        git push origin master develop 1.x

    As soon as you push the tags, people are likely to notice and start tweeting about it(!), so you may wish to do the next steps fairly quickly.

6. Make the GitHub releases live: fill in the "Tag version" now that the tag exists on GitHub, check that the right tarball is attached to the right repository, and **publish** the release.

7. Push the website updates.

8. Concatenate the three sets of markdownified release notes as _README.md_ and upload it to SourceForge (likely via the [web interface]).

9. By now, the SourceForge files may have populated enough mirrors that you can locate your **samtools-1.x.tar.bz2** file in the [web interface] and select it (via the **(i)** button) as the default download.  Also unstage the directory.

10. Send the release announcement email (to `samtools-announce`, CCed to `-devel` and `-help`, with reply-to set to `-help`) and tweet from [@htslib].

[web interface]: https://sourceforge.net/projects/samtools/files/samtools/
[scp or sftp]: https://sourceforge.net/p/forge/documentation/Shell%20Services/
[htslib.org]: http://www.htslib.org/
[@htslib]: https://twitter.com/htslib


<!-- vim:set linebreak: -->

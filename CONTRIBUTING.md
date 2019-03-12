[open-ipcamera Project](https://github.com/open-ipcamera/open-ipcamera)\
[Developer: Terrence Houlahan](https://www.linkedin.com/in/terrencehoulahan/)\
Contact: terrence.houlahan@open-ipcamera.net
# Version 01.78.00


**NOTE:** This CONTRIBUTING.md file is formatted in [Markdown language](https://guides.github.com/features/mastering-markdown/) for ease of reading on _**open-ipcamera's**_ project's Github home.
Viewing it in a CLI editor such as _**vi**_ or _**nano**_ will obviously display all the underlying markups.


# Contributing to open-ipcamera Project:

## HOW to Contribute:
1. Fork the open-ipcamera repository.
2. Commit changes.
3. Push your commit.
4. Create a Pull Request.

## WHAT to Contribute:

### BUG FIXES/SECURITY VULNERABILITIES:
Although extensive unit testing has been performed as _**open-ipcamera**_ has been developed, the only real validation comes when putting code out into the wild.
If you identify a bug or security vulnerability:
1. Create an **ISSUE** for this project on Github, detailing:
- Version of open-ipcamera: 	/home/pi/open-ipcamera-scripts/version.txt
- Version of Raspbian:  		lsb\_release -a
- Filename where offending code lives
- How fault is reproducible
- Specific error messages generated
- Last time known to work correctly before breakage: ie, before an upgrade...
2. **OPTIONAL:** Create a **FIX** and send _**open-ipcamera**_ a PR (Pull Request)!


### FEATURES:
The organization of _**open-ipcamera**_ is *EXTREMELY* modular.  Adding features _**should be**_ reasonably straightforward.
Depending on both their merit and quality of coding, your feature may be pulled into the open-ipcamera repo.
Attribution will of course be given for your feature.


### HARDWARE DRIVERS:
If you have drivers you wish to be packaged with future _**open-ipcamera**_ releases, to be considered these *MUST* be:
- *Related to operation of an IP camera:* ie drivers for a barcode scanner wouldn't be accepted
- *Broad Interest:* Should be functionality useful to many users, not special-use fringe cases.
- *Opensource:* Please provide _Github_ or _Bitbucket_ URL where *UNCOMPILED* your uncompiled code can be downloaded
- *Loadable as a Kernel Module*
- *Specimen Hardware Supplied for Testing:*
- *RIGOROUSLY TESTED:*  Should work in the intended way and not crash the OS :wink:

*Policy on Failures:*  Min. 3 months before reconsideration; very avoidable if tested rigorously with latest version of _**open-ipcamera**_



### TRANSLATIONS:
You don't have to be a programmer or Linux-head to be involved with the _**open-ipcamera Project**_:
_**open-ipcamera**_ requires translations of the _**README.md**_ & _**CONTRIBUTING.md**_ files for multi-language support.
As the `.md` file extensions indicate, these files make use of _**Markdown Language**_. which is simple and easy to learn.\
Please maintain the Markdown formatting when translatting the documents.


**Submitting Translations:**
- *UTF-8 Encoding:* Documents should be UTF-8 encoded files as they use special non-English Character sets (_Linux_ & _OSX_ use *UTF-8* by default; nothing need be changed)
- *File Naming Conventions: `filename.2Letter-CountryCode.md`  [List of ISO Country Codes](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes)
- *Check Markdown Formatting:* [Online Markdown Checker](https://dillinger.io/)

Send Documents TO:
- `terrence.houlahan@open-ipcamera.net`

*Markdown Language Guides & References:*
- [Github Markdown Guide](https://guides.github.com/features/mastering-markdown/)
- [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

*UTF Encoding:* Setting to *UTF-8* on Windows\
- Check default encoding with **PowerShell**:  `[System.Text.Encoding]::Default`

_**Terrence Houlahan, open-ipcamera Project Developer**_

How to Change Default Encoding on Windows 10:\
[Screenshot of path to change Windows default Encoding to UTF-8](https://www.dropbox.com/sh/y61netrhtlpa5i9/AAAfobvf7PPMCUOUhH7mn-gMa?dl=0)

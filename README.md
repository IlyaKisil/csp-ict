# CSP ICT support
This repository contains various configuration file and scripts that make like CSP ICT administrator easier.

## Table of contents

<!--ts-->
   * [CSP ICT support](#csp-ict-support)
      * [Table of contents](#table-of-contents)
      * [General overview](#general-overview)
         * [admin](#admin)
         * [dotfiles](#dotfiles)
         * [ee-ik1614-lx](#ee-ik1614-lx)
         * [scripts](#scripts)
         * [software](#software)

<!-- Added by: Ilya Kisil, at: 2018-12-03T19:50+00:00 -->

<!--te-->


## General overview

### `admin`
Directory that contains scripts for overall management such as adding/removing users etc. All files should be executable only by CSP ICT administrator.

### `dotfiles`
Directory that contains various dotfiles which can be used as a templates for users.

### `ee-ik1614-lx`
Directory that contains all scripts and supplementary files regarding `ee-ik1614lx.ee.ic.ac.uk` machine. This includes scripts used for setting up or updating user's working environment. For more information see `README.md` therein.

### `scripts`
Directory that contains various utility scripts that can be added to user's `$HOME/bin/`. For more information see `README.md` therein.

### `software`
Directory that contains installation files for the software provided by third party, e.g. miniconda, nvidia drivers etc.
> **NOTE:** this directory is ignored by git !!! 

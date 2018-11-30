# Table of contents

<!--ts-->
   * [Table of contents](#table-of-contents)
   * [General overview](#general-overview)
   * [CSP ICT scripts](#csp-ict-scripts)
      * [Apply updates](#apply-updates)
      * [Start Jupyter Lab](#start-jupyter-lab)
      * [Create virtual environment](#create-virtual-environment)
      * [Add table of contents](#add-table-of-contents)
   * [External scripts](#external-scripts)

<!-- Added by: Ilya Kisil, at: 2018-11-30T15:39+00:00 -->

<!--te-->



# General overview
This directory contains various utility scripts. At the initial setup, all or some of these scripts are copied to users `$HOME/bin/` which is appended to to `$PATH`, so that they could be called from anywhere.

> **Note:** If you cannot see some of these scripts in `$HOME/bin/` then contact CSP ICT administrator. 



# CSP ICT scripts
The following is the list of scripts provided to you by your CSP ICT administrator. In most cases, they should be executed by typing their name in command line. Running `some_script -h` or `some_script --help` displays help message of this script.      

## Apply updates
Use script `csp_ict_update.sh`. This script can be used for applying future updates to the overall configuration.

## Start Jupyter Lab
Use script `start_jupyter.sh`. It will start jupyter lab to which you would be able to connect remotely.

## Create virtual environment
Use script `create_venv.sh`. It will create a virtual environment (venv) and associated ipykernel so this venv could be used no matter you start jupyter lab. You are not obliged to use it, but it is a good practice to create different venv for different projects.

## Add table of contents
Use `add_toc.sh`. It will generate TOC for Markdown files and prepend it to this file. Put these lines at the top of markdown file, prior calling this script.
```
<!--TS-->   # make letters of lowercase
<!--TE-->   # make letters of lowercase
```
> **Note:** Implementation is based on [`gh-md-toc`](https://github.com/ekalinin/github-markdown-toc).



# External scripts
The following is the list of useful scripts written by 3rd parties. In order to not depend on their updates, the source code was just copied.

-   `gh-md-toc`: Easy TOC creation for Markdown files. For more details see [home page](https://github.com/ekalinin/github-markdown-toc) of this project.

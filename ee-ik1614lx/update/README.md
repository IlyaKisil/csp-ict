# Updates for `ee-ik1614lx.ee.ic.ac.uk`
All update scripts support `-h|--help` option and adhere the following naming convention:
```
update_YEAR_MONTH_DAY.sh
```
where `YEAR_MONTH_DAY` specifies the release date of the update.
> **NOTE:** `dummy_update.sh` is reserved for testing purposes.


## List of all updates with short description
* [Update 2018-12-04](#update-2018-12-04)


## Update 2018-12-04
```
# Execution on client side
csp_ict_update.sh --file=update_2018_12_04
```
### Modified files:
-   `.zshrc`: Minor clean up for better generalisation in a future.
-   `.zshrc-local`: Added designated variable for selecting port on which Jupyter Lab should be running. Generalisation of `$CUDA_HOME`. Also changed names for `LOG_DIR` -> `USER_LOG_DIR` and `TEMP_DIR` -> `USER_TMP_DIR`.
-   `start_jupyter.sh`: Uses designated env variable in order to avoid possible clashes among ports that are being used by different users 
-   `.tmux-local.conf`: Allows to launch `start_jupyter.sh` when `tmux` session is restored.
-   `csp_ict_update.sh`: Passes paths for user's 'home', 'bak' and 'log' directories to the actual update script that is being sourced.  
    
rem This script performs an rclone sync from the local Box folder to a GCS bucket.
rem This version also copies the sync log file to GCS for auditing.

rem --- Configuration Variables ---
set "RCLONE_EXE_PATH=C:\Users\nikhi\tools\rclone\rclone.exe"
set "LOCAL_BOX_PATH=C:\Users\nikhi\Box"
set "GCS_REMOTE_DEST=iiba-box-folder-gcs-bucket:dev-ai-rclone-data-bucket"
set "RCLONE_CONFIG_PATH=C:\Users\nikhi\AppData\Roaming\rclone\rclone.conf"

rem Define the base log file path
set "RCLONE_LOG_FILE_BASE=C:\Users\nikhi\tools\rclone\logs\rclone_sync_log"
rem Define the base log file path
rem
rem rem Get the computer name (Windows built-in variable)
set "COMPUTER_NAME=%COMPUTERNAME%"
rem
rem Create a unique timestamped log file name including computer name
set "TIMESTAMP=%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "RCLONE_LOG_FILE_PATH=%RCLONE_LOG_FILE_BASE%_%COMPUTER_NAME%_%TIMESTAMP%.log"
rem
rem Ensure the log directory exists
if not exist "%RCLONE_LOG_FILE_PATH%\.." mkdir "%RCLONE_LOG_FILE_PATH%\.."

rem --- Logging Start Time ---
echo [%DATE% %TIME%] Starting rclone sync from Box to GCS... >> "%RCLONE_LOG_FILE_PATH%"

rem --- Change Working Directory ---
cd "%LOCAL_BOX_PATH%"
if %ERRORLEVEL% NEQ 0 (
    echo [%DATE% %TIME%] ERROR: Failed to change directory to "%LOCAL_BOX_PATH%". Exiting. >> "%RCLONE_LOG_FILE_PATH%"
   
    exit 1
)

rem --- Execute Rclone Sync Command ---
rem Store the rclone sync result in a variable
"%RCLONE_EXE_PATH%" sync "%LOCAL_BOX_PATH%" "%GCS_REMOTE_DEST%" --config "%RCLONE_CONFIG_PATH%" --log-file "%RCLONE_LOG_FILE_PATH%" --log-level DEBUG --fast-list
set SYNC_ERRORLEVEL=%ERRORLEVEL%

rem --- Log Rclone Sync Result ---
if %SYNC_ERRORLEVEL% NEQ 0 (
    echo [%DATE% %TIME%] Rclone sync FAILED with error code %SYNC_ERRORLEVEL%. >> "%RCLONE_LOG_FILE_PATH%"
) else (
    echo [%DATE% %TIME%] Rclone sync completed successfully. >> "%RCLONE_LOG_FILE_PATH%" 
)


rem --- Final Exit ---

rem Exit with the original sync command's error level, so Task Scheduler knows if the sync itself failed.
exit %SYNC_ERRORLEVEL%

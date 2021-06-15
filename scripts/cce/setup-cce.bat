@echo off
setlocal

rem #############################################
rem #
rem # Batch Script to Install Command Central
rem # 
rem #############################################

rem Read CCE and CICD setup related values from a properties file 
FOR /F "eol=# tokens=1,2 delims==" %%G IN (..\config\cce-setup.properties) DO (set %%G=%%H)  

SET EMPOWER_USR=%EMPOWER_USR%
SET EMPOWER_PSW=%EMPOWER_PSW%
SET product_version=%product_version%
SET repo_product_name=%repo_product_name%
SET repo_fix_name=%repo_fix_name%
SET mirror_repo_product_name=%mirror_repo_product_name%
SET mirror_repo_fix_name=%mirror_repo_fix_name%
SET license_key_archive_location=%license_key_archive_location%
SET cc_cli_home=%sagcce_installdir%/CommandCentral/client
SET log_file=%cicdhome_dir%\setupLogFile.log
SET start_datetime=%date%%time%

IF NOT EXIST %cicdhome_dir% MKDIR %cicdhome_dir%
cd %cicdhome_dir%
echo "============== Start at %start_datetime% ==================" >> %log_file%
echo.
echo Setup CCE with Repo and Licenses

cd %cc_cli_home%

echo -- Importing License Zip file
sagcc get license-tools keys -o "%license_key_archive_location%"
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)
echo -- Licens Files imported successfully.
echo.
echo ======================================


echo -- Creating credentials to connect to SAG EmPower SDC.
sagcc exec   templates composite import -i "%cc_cli_home%/sag-cc-creds.yaml"
sagcc exec templates composite apply sag-cc-creds credentials.username=%EMPOWER_USR% credentials.password=%EMPOWER_PSW% credentials.key=EmPower_Credentials --sync-job --wait 360
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)
echo -- Credentials created successfully.
echo.
echo ======================================
echo.
echo Creating Product and Fix Master Repo. Please wait till process completes...
sagcc exec   templates composite import -i "%cc_cli_home%/sag-cc-builder-repos.yaml"
sagcc exec templates composite apply sag-cc-builder-repos repo.product.url=https://sdc.softwareag.com/dataservewebM%product_version%/repository repo.product.credentials.key=EmPower_Credentials repo.product.name=%repo_product_name% repo.fix.url=https://sdc.softwareag.com/updates/prodRepo repo.fix.credentials.key=EmPower_Credentials repo.fix.name=%repo_fix_name% --sync-job --wait 360
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)
echo -- Product and Fix Master Repo created successfully.
echo.
echo ======================================
echo.
echo -- Creating Product Mirror Repo. Please wait till process completes...
sagcc add    repository products mirror name=%mirror_repo_product_name% sourceRepos=%repo_product_name% nodeAlias=local platforms=W64 description=mirror_repo
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)
echo -- Product Mirror Repo created successfully.
echo.
echo ======================================
echo.
echo Creating Fixes Mirror Repo. Please wait till process completes...
sagcc add    repository fixes mirror name=fixRepo107_mirror sourceRepos=fixRepo107 nodeAlias=local description=mirror_repo
echo.
echo ======================================
echo.
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)
echo -- Fix Mirror Repo created successfully.
echo.
echo ======================================



IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	rem endlocal	
	EXIT /B %errorlevel%
)

rem Exit from main script
EXIT /B %errorlevel%
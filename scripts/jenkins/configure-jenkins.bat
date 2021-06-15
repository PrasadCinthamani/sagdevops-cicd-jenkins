@echo off
setlocal

rem #################################################################
rem #
rem # Batch Script for Post-Installation Jenkins Configuration
rem # 
rem #################################################################

echo.
echo ============== Start at %date% %time% ==================
echo.

rem Read JENKINS configuration related values from a properties file 
FOR /F "eol=# tokens=1,2 delims==" %%G IN (..\config\jenkins-setup.properties) DO (set %%G=%%H)  

SET admin_passfile=%jenkins_home%\secrets\initialAdminPassword

rem Get the Admin's secret password
for /f "tokens=1" %%i in (%admin_passfile%) do set admin_pass=%%i

rem Jenkins CLI JAR file url
SET jenkinscli_jarfile_url="%jenkins_trans_protocol%://%jenkins_hostname%:%jenkins_http_port%/jnlpJars/jenkins-cli.jar"
echo.
echo Download Jenkins CLI jar fle from local Jenkins installation
curl -L %jenkinscli_jarfile_url% --output "%jenkins_home%\%jenkinscli_jarfilename%"
IF %errorlevel% NEQ 0 (
	echo Non-zero exit code %errorlevel% was returned. Exit the process.
	GOTO :exit-script	
)

echo.
SET java_cli_cmd=java -jar %jenkins_home%\%jenkinscli_jarfilename% -s %jenkins_trans_protocol%://%jenkins_hostname%:%jenkins_http_port%/ -auth %jenkins_admin_username%:%admin_pass%

SET /A no_of_retry=1

:install-def-plugins
echo.
echo Install Default Plugins
%java_cli_cmd% install-plugin @%default_plugins_filepath% -deploy
IF %errorlevel% NEQ 0 (	
	rem Increment the retry count
	SET /A no_of_retry+=1
	rem check if max retry limit reached
	IF %no_of_retry% LSS %max_tries% (	
		echo.	
		echo Retry in %retry_interval% seconds
		timeout %retry_interval%
		rem retry to install plugins
		GOTO :install-def-plugins
	) ELSE (
		echo.
		echo Non-zero exit code %errorlevel% was returned. Exit the process.
		GOTO :exit-script
	)
)

echo.
echo List Installed Jenkins Plugins
%java_cli_cmd% list-plugins
echo.
echo Import Jenkins JOB %pipeline_name%
echo.
%java_cli_cmd% create-job %pipeline_name% < "%pipeline_to_import_filepath%"
IF %errorlevel% NEQ 0 (
	echo.
	echo Non-zero exit code %errorlevel% was returned. Exit the process.	
	GOTO :exit-script	
)

echo Jenkins Version
%java_cli_cmd% version
echo.

echo Please login to Jenkins at %jenkins_trans_protocol%://%jenkins_hostname%:%jenkins_http_port% with Initial Password:%admin_pass%
echo.
echo "============== End at %date% %time% =================="
echo.

:exit-script
echo.
endlocal
rem Exit from main script
EXIT /B %errorlevel%


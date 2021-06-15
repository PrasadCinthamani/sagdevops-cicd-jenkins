@echo off
setlocal

rem #####################################
rem #
rem #Batch Script to Install Jenkins
rem # 
rem #####################################
echo.
echo ============== Installation started at %date% %time% ==================
echo.
rem Read JENKINS installation related values from a properties file 
FOR /F "eol=# tokens=1,2 delims==" %%G IN (..\config\jenkins-setup.properties) DO (set %%G=%%H)  

IF NOT EXIST %jenkins_home% MKDIR %jenkins_home%

rem Path to copy the Jenkins war file
SET jenkins_war_filepath=%jenkins_home%\%jenkins_warfile_filename%

SET /A no_of_retry=1

:downoad-jenkins-war
echo Download Jenkins war fle
curl -L %jenkins_warfile_url% --output %jenkins_war_filepath%
IF %errorlevel% NEQ 0 (	
	rem Increment the retry count
	SET /A no_of_retry+=1
	rem check if max retry limit reached
	IF %no_of_retry% LSS %max_tries% (		
		echo.
		echo Retry in %retry_interval% seconds
		timeout %retry_interval%
		rem retry to download war file
		GOTO :downoad-jenkins-war
	) ELSE (
		echo.
		echo Non-zero exit code %errorlevel% was returned. Exit the process.
		GOTO :exit-script
	)
)

echo.
echo Install Jenkins
echo Jenkins installation will be Completed in Background. Please wait for a minute...
START javaw -Djenkins_home=%jenkins_home% -jar %jenkins_war_filepath% --httpPort=%jenkins_http_port%

timeout 30 > tmp.txt
del tmp.txt
echo.
echo "============== Installation completed at %date% %time% =================="

:exit-script
echo.
endlocal
rem Exit from main script
EXIT /B %errorlevel%
echo "------------------------------------" >> C:\CICD\logFile.txt
git clone --recursive -b release/105oct2019 https://github.com/SoftwareAG/sagdevops-cc-server >> C:\CICD\logFile.txt
cd C:\CICD\sagdevops-cc-server
set EMPOWER_USR=KartikaSatyanarayanaMurthy.Medavarapu@softwareag.com
set EMPOWER_PSW=xxxxxx	
ant boot -Daccept.license=true >> C:\CICD\logFile.txt
ant up test >> C:\CICD\logFile.txt

@echo off
setlocal

set "SAMPLE_DIR=%~dp0"
set "SDK_DIR=%SAMPLE_DIR%..\..\..\sdk\java\lib"
set "MAIN_SOURCE=%SAMPLE_DIR%source\src\main\java\com\zoho\flow\samples\hello"
set "TEST_SOURCE=%SAMPLE_DIR%source\src\test\java\com\zoho\flow\samples\hello"
set "BUILD_DIR=%SAMPLE_DIR%build"
set "MAIN_CLASSES=%BUILD_DIR%\classes"
set "TEST_CLASSES=%BUILD_DIR%\test-classes"
set "PACKAGE_DIR=%BUILD_DIR%\package"
set "OUTPUT_ZIP=%SAMPLE_DIR%hello-static.zip"

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%OUTPUT_ZIP%" del /q "%OUTPUT_ZIP%"
mkdir "%MAIN_CLASSES%" "%TEST_CLASSES%" "%PACKAGE_DIR%\hello-static"

javac --release 11 -cp "%SDK_DIR%\ZFAgentCustom.jar;%SDK_DIR%\json.jar" -d "%MAIN_CLASSES%" "%MAIN_SOURCE%\HelloConnector.java" "%MAIN_SOURCE%\HelloInput.java" "%MAIN_SOURCE%\HelloOutput.java"
if errorlevel 1 exit /b 1

javac --release 11 -cp "%MAIN_CLASSES%;%SDK_DIR%\ZFAgentCustom.jar;%SDK_DIR%\json.jar" -d "%TEST_CLASSES%" "%TEST_SOURCE%\HelloConnectorSmokeTest.java"
if errorlevel 1 exit /b 1

java -ea -cp "%TEST_CLASSES%;%MAIN_CLASSES%;%SDK_DIR%\ZFAgentCustom.jar;%SDK_DIR%\json.jar" com.zoho.flow.samples.hello.HelloConnectorSmokeTest
if errorlevel 1 exit /b 1

jar --create --file "%PACKAGE_DIR%\hello-static\hello-static.jar" --manifest "%SAMPLE_DIR%MANIFEST.MF" -C "%MAIN_CLASSES%" .
if errorlevel 1 exit /b 1

powershell -NoProfile -Command "Compress-Archive -Path '%PACKAGE_DIR%\hello-static' -DestinationPath '%OUTPUT_ZIP%' -Force"
if errorlevel 1 exit /b 1

echo Created %OUTPUT_ZIP%

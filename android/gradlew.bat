@ECHO OFF
SETLOCAL

SET APP_HOME=%~dp0
SET WRAPPER_DIR=%APP_HOME%gradle\wrapper
SET WRAPPER_JAR=%WRAPPER_DIR%\gradle-wrapper.jar
SET WRAPPER_VERSION=8.9
SET WRAPPER_COORD=https://repo.maven.apache.org/maven2/org/gradle/gradle-wrapper/%WRAPPER_VERSION%/gradle-wrapper-%WRAPPER_VERSION%.jar

IF NOT EXIST "%WRAPPER_DIR%" (
  MKDIR "%WRAPPER_DIR%"
)

IF NOT EXIST "%WRAPPER_JAR%" (
  ECHO Downloading Gradle wrapper %WRAPPER_VERSION%...
  IF EXIST "%SystemRoot%\System32\curl.exe" (
    "%SystemRoot%\System32\curl.exe" -fL "%WRAPPER_COORD%" -o "%WRAPPER_JAR%"
  ) ELSE (
    POWERSHELL -Command "& {\$ErrorActionPreference='Stop'; Invoke-WebRequest '%WRAPPER_COORD%' -OutFile '%WRAPPER_JAR%'}"
  )
)

SET DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

SET CMD_LINE_ARGS=
:parseArgs
IF "%1"=="" GOTO doneParse
  SET CMD_LINE_ARGS=%CMD_LINE_ARGS% "%1"
  SHIFT
  GOTO parseArgs
:doneParse

IF EXIST "%JAVA_HOME%\bin\java.exe" (
  SET JAVA_EXE="%JAVA_HOME%\bin\java.exe"
) ELSE (
  SET JAVA_EXE=java
)

"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% -classpath "%WRAPPER_JAR%" org.gradle.wrapper.GradleWrapperMain %CMD_LINE_ARGS%

ENDLOCAL

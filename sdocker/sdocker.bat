@rem
@rem Copyright 2024 seung.
@rem
@rem ################################################################
@rem
@rem  Gradle project management script with Docker for Windows
@rem
@rem ################################################################

@echo off

setlocal enabledelayedexpansion

set "DEFAULT_WORKSPACE=%SEUNG_GIT%"
set "DEFAULT_REMOTE_REGISTRY=127.0.0.1:18579"
set "DEFAULT_COMPOSE_YAML=docker-compose.yaml"

set "CHARSET=65001"
set "EXIT_CODE="

call :color

if "%~1"=="" (
    goto try
)

:parse
    set "OPTION_KEY=%~1"
    set "OPTION_VALUE=%~2"
    if "!OPTION_KEY!"=="" goto charset
    if "-h"=="!OPTION_KEY!" (
        goto usage
    )
    if "-w"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "WORKSPACE=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-n"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "APPLICATION_NAME=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-v"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "APPLICATION_VERSION=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-f"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "COMPOSE_YAML=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-r"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "REMOTE_REGISTRY=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-c"=="!OPTION_KEY!" (
        if not "-"=="!OPTION_VALUE:~0,1!" (
            set "CHARSET=%~2"
            shift
        )
        shift
        goto parse
    )
    if "-"=="!OPTION_KEY:~0,1!" (
        if not "!OPTION_KEY!"=="!OPTION_KEY:D=!" (
            set "OPTION_D=1"
            set "OPTION_KEY=!OPTION_KEY:D=!"
        )
        if not "!OPTION_KEY!"=="!OPTION_KEY:G=!" (
            set "OPTION_G=1"
            set "OPTION_KEY=!OPTION_KEY:G=!"
        )
        if not "!OPTION_KEY!"=="!OPTION_KEY:B=!" (
            set "OPTION_B=1"
            set "OPTION_KEY=!OPTION_KEY:B=!"
        )
        if not "!OPTION_KEY!"=="!OPTION_KEY:R=!" (
            set "OPTION_R=1"
            set "OPTION_KEY=!OPTION_KEY:R=!"
        )
        if not "!OPTION_KEY!"=="!OPTION_KEY:P=!" (
            set "OPTION_P=1"
            set "OPTION_KEY=!OPTION_KEY:P=!"
        )
        if not "-"=="!OPTION_KEY!" (
            echo dockerw: option !OPTION_KEY! is not available
            goto try
        )
        shift
        goto parse
    )
    echo dockerw: option !OPTION_KEY! is not available
    goto try

:charset
    call chcp !CHARSET! >nul 2>&1
    if errorlevel 1 (
        echo dockerw: Invalid code page
        goto try
    )

:input

::Workspace
:input_workspace
    echo Workspace
    ::Path
    if 1==!OPTION_D! (
        set "WORKSPACE=%DEFAULT_WORKSPACE%"
        echo - Path [%DEFAULT_WORKSPACE%]: !WORKSPACE!
        goto input_application
    )
    if not ""=="!WORKSPACE!" (
        echo - Path [%DEFAULT_WORKSPACE%]: !WORKSPACE!
        goto input_application
    )
    set /p WORKSPACE="- Path [%DEFAULT_WORKSPACE%]: "
    if not ""=="!WORKSPACE!" (
        goto input_application
    )
    set /p CONTINUE="Continue using the default value [y/n]: "
    if /i not "y"=="!CONTINUE!" goto end
    set "WORKSPACE=%DEFAULT_WORKSPACE%"

::Application
:input_application
    echo Application
    ::Name
    :input_application_name
        if not ""=="!APPLICATION_NAME!" (
            echo - Name []: !APPLICATION_NAME!
            goto input_application_path
        )
        set /p APPLICATION_NAME="- Name []: "
        if ""=="!APPLICATION_NAME!" (
            echo.
            echo dockerw: Name can not be empty
            goto try
        )
    ::Application Path
    :input_application_path
        set "APPLICATION_PATH=!WORKSPACE!\!APPLICATION_NAME!"
        echo - Path []: !APPLICATION_PATH!
        cd /d "!APPLICATION_PATH!" >nul 2>&1
        if errorlevel 1 (
            echo.
            echo dockerw: Failed to move to !APPLICATION_PATH!
            goto fail
        )
        goto input_application_version
    ::Version
    :input_application_version
        if not ""=="!APPLICATION_VERSION!" (
            echo - Version []: !APPLICATION_VERSION!
            goto input_docker
        )
        set /p APPLICATION_VERSION="- Version []: "
        if ""=="!APPLICATION_VERSION!" (
            echo.
            echo dockerw: Version can not be empty
            goto try
        )
        goto input_docker

::Docker
:input_docker
    if not 1==!OPTION_B! if not 1==!OPTION_P! if not 1==!OPTION_R! goto begin
    echo Image
    if not 1==!OPTION_B! if not 1==!OPTION_P! if 1==!OPTION_R! goto input_compose
    ::Remote Registry
    :input_remote_registry
        if 1==!OPTION_D! (
            set "REMOTE_REGISTRY=%DEFAULT_REMOTE_REGISTRY%"
            echo - Remote Registry [%DEFAULT_REMOTE_REGISTRY%]: !REMOTE_REGISTRY!
            goto input_image
        )
        if not ""=="!REMOTE_REGISTRY!" (
            echo - Remote Registry [%DEFAULT_REMOTE_REGISTRY%]: !REMOTE_REGISTRY!
            goto input_image
        )
        set /p REMOTE_REGISTRY="- Remote Registry [%DEFAULT_REMOTE_REGISTRY%]: "
        if not ""=="!REMOTE_REGISTRY!" (
            goto input_image
        )
        set /p CONTINUE="Continue using the default value [y/n]: "
        if /i not "y"=="!CONTINUE!" goto end
        set "REMOTE_REGISTRY=%DEFAULT_REMOTE_REGISTRY%"
    ::Image
    :input_image
        set "IMAGE=!REMOTE_REGISTRY!/!APPLICATION_NAME!:!APPLICATION_VERSION!"
        echo - Image []: !IMAGE!
        goto input_compose
    ::Compose
    :input_compose
        if 1==!OPTION_D! (
            set "COMPOSE_YAML=%DEFAULT_COMPOSE_YAML%"
            echo - Compose [%DEFAULT_COMPOSE_YAML%]: !COMPOSE_YAML!
            goto begin
        )
        if not ""=="!COMPOSE_YAML!" (
            echo - Compose [%DEFAULT_COMPOSE_YAML%]: !COMPOSE_YAML!
            goto begin
        )
        set /p COMPOSE_YAML="- Compose File [%DEFAULT_COMPOSE_YAML%]: "
        if not ""=="!COMPOSE_YAML!" (
            goto begin
        )
        set /p CONTINUE="Continue using the default value [y/n]: "
        if /i not "y"=="!CONTINUE!" goto end
        set "COMPOSE_YAML=%DEFAULT_COMPOSE_YAML%"

:begin
    for /f "tokens=1,2 delims=.," %%a in ('powershell Get-Date -UFormat %%s') do (set "BEGIN_AT_SS=%%a" & set "BEGIN_AT_MS=1%%b")
    if !BEGIN_AT_MS! lss 100000 set "BEGIN_AT_MS=!BEGIN_AT_MS!0"

:variables
    call :info "Input:"
    call :info "  Application:"
    call :info "    Name: !APPLICATION_NAME!"
    call :info "    Version: !APPLICATION_VERSION!"
    call :info "    Path: !APPLICATION_PATH!"
    call :info "  Docker:"
    call :info "    Image: !IMAGE!"
    call :info "    Compose: !COMPOSE_YAML!"
    call :info "  Active code page: !CHARSET!"

:gradle
    if not 1==!OPTION_G! (
        call :warn "Build Gradle: skip"
        goto build
    )
    call :info "Build Gradle:"
    call gradlew.bat clean build --refresh-dependencies -Pver=!APPLICATION_VERSION!
    if errorlevel 1 (
        call :error "  Failed to build gradle"
        goto done
    )

:build
    if not 1==!OPTION_B! (
        call :warn "Build Docker Image: skip"
        goto compose
    )
    call :info "Build Docker Image:"
    ::Clean Container
    for /f "tokens=*" %%a in ('docker ps -aqf "name=!APPLICATION_NAME!"') do (set "CONTAINER_ID=%%a")
    if not ""=="!CONTAINER_ID!" (
        call :warn "  Remove container '!CONTAINER_ID!'"
        call docker container rm -f !CONTAINER_ID!
    )
    ::Clean Image
    call docker images --format "{{.Repository}}:{{.Tag}}" | findstr /i !IMAGE! >nul 2>&1
    if errorlevel 0 (
        call :warn "  Remove '!IMAGE!'"
        call docker image rm -f !IMAGE!
    )
    ::Build Image
    call docker image build --no-cache --tag !IMAGE! .
    if errorlevel 1 (
        call :error "  Failed to build docker image"
        goto done
    )

:compose
    if not 1==!OPTION_R! (
        call :warn "Run Docker Container: skip"
        goto push
    )
    call :info "Run Docker Container:"
    call docker compose -f !COMPOSE_YAML! up -d
    call docker compose ps -a

:push
    if not 1==!OPTION_P! (
        call :warn "Push Docker Image: skip"
        goto done
    )
    call :info "Push Docker Image:"
    call docker push !IMAGE!
    if errorlevel 1 (
        call :error "  Failed to push image"
        goto done
    )

:done
    for /f "tokens=1,2 delims=.," %%a in ('powershell Get-Date -UFormat %%s') do set "END_AT_SS=%%a" & set "END_AT_MS=1%%b"
    if !END_AT_MS! lss 100000 set "END_AT_MS=!END_AT_MS!0"
    if !BEGIN_AT_MS! gtr !END_AT_MS! set /a "END_AT_MS=!END_AT_MS!+100000" & set /a "END_AT_SS=!END_AT_SS!-1"
    set /a "ELAPSED_SS=!END_AT_SS!-!BEGIN_AT_SS!"
    set /a "DIFF_HH=!ELAPSED_SS!/3600"
    if !DIFF_HH! lss 10 set "DIFF_HH=0!DIFF_HH!"
    set /a "DIFF_MM=(!ELAPSED_SS!%%3600)/60"
    if !DIFF_MM! lss 10 set "DIFF_MM=0!DIFF_MM!"
    set /a "DIFF_SS=!ELAPSED_SS!%%60"
    if !DIFF_SS! lss 10 set "DIFF_SS=0!DIFF_SS!"
    set /a "DIFF_MS=!END_AT_MS!-!BEGIN_AT_MS!"
    if ""=="!EXIT_CODE!" set "EXIT_CODE=!ERRORLEVEL!"
    if 0==!EXIT_CODE! (
        call :info "%GREEN%Success%NOCOLOR% in %YELLOW%!DIFF_HH!:!DIFF_MM!:!DIFF_SS!.!DIFF_MS:~0,3!%NOCOLOR%"
    ) else (
        call :info "%RED%Error%NOCOLOR% in %YELLOW%!DIFF_HH!:!DIFF_MM!:!DIFF_SS!.!DIFF_MS:~0,3!%NOCOLOR%"
    )

goto end

:color
    set "ESC="
    for /f %%a in ('echo prompt $E ^| cmd') do (set "ESC=%%a")
    set "NOCOLOR=%ESC%[0m"
    set "RED=%ESC%[31m"
    set "GREEN=%ESC%[32m"
    set "YELLOW=%ESC%[33m"
    set "BLUE=%ESC%[34m"
    set "PURPLE=%ESC%[35m"
    set "SKY=%ESC%[36m"
    set "WHITE=%ESC%[37m"
    exit /b

:log
    if "INFO"=="%~1" echo [%date% %time%] [%GREEN% INFO%NOCOLOR%] %~2
    if "ERROR"=="%~1" echo [%date% %time%] [%RED%ERROR%NOCOLOR%] %~2
    exit /b

:info
    echo [%date% %time%] [%GREEN% INFO%NOCOLOR%] %~1
    exit /b

:warn
    echo [%date% %time%] [%YELLOW% WARN%NOCOLOR%] %~1
    exit /b

:error
    echo [%date% %time%] [%RED%ERROR%NOCOLOR%] %~1
    exit /b

:usage
    echo Usage: dockerw [options...]
    echo   -h  Get help for commands
    echo   -w  Workspace Path (DEFAULT: %SKY%!DEFAULT_WORKSPACE!%NOCOLOR%)
    echo   -n  Application Name
    echo   -v  Application Version
    echo   -r  Remote Registry Endpoint (DEFAULT: %SKY%!DEFAULT_REMOTE_REGISTRY!%NOCOLOR%)
    echo   -f  Docker compose file (DEFAULT: %SKY%!DEFAULT_COMPOSE_YAML!%NOCOLOR%)
    echo   -c  Active code page (DEFAULT: %SKY%!CHARSET!%NOCOLOR%)
    echo       65001 utf-8
    echo       51949 euc-kr
    echo       28591 iso-8859-1
    echo       For more code, head to https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
    echo   -D  Use Default Values
    echo   -G  Clean and Build Gradle
    echo   -B  Build Docker Image
    echo   -R  Run Docker Image
    echo   -P  Push Docker Image
    echo.
    echo Examples:
    echo   dockerw -DGBRP -n project-name -v 1.0.0
    echo     Use default values
    echo     Build gradle
    echo     Build docker image
    echo     Run docker image
    echo     Push docker image
    echo   dockerw -DGBRP
    echo     Input values
    echo     Build gradle
    echo     Build docker image
    echo     Run docker image
    echo     Push docker image
    echo   dockerw -DG -n project-name -v 1.0.0
    echo     Use default values
    echo     Build gradle
    echo   dockerw -DR -n project-name -v 1.0.0
    echo     Use default values
    echo     Run docker image
    echo   dockerw -GBRP -w %DEFAULT_WORKSPACE% -n project-name -v 1.0.0 -r %DEFAULT_REMOTE_REGISTRY% -f %DEFAULT_COMPOSE_YAML% -c %CHARSET%
    echo     Command all options
    goto success

:try
    echo dockerw: try 'dockerw -h' for more information
    goto fail

:success
    set "EXIT_CODE=0"
    goto end

:fail
    set "EXIT_CODE=1"
    goto end

:end
    endlocal
    exit /b !EXIT_CODE!

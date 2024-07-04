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

::Defaults
set "DEFAULT_ROOT=W:\seung-git"
set "DEFAULT_DOCKER_COMPOSE=docker-compose.yaml"
set "DEFAULT_ORIGIN_REGISTRY=docker.io"
set "DEFAULT_TARGET_REGISTRY=127.0.0.1:18579"
set "DEFAULT_NCR_PUBLIC_SUFFIX=ncr.ntruss.com"
set "DEFAULT_NCR_PRIVATE_SUFFIX=private-ncr.ntruss.com"
set "DEFAULT_KUBE_CONFIG=kubeconfig.yaml"
set "DEFAULT_KUBE_APPLY=apply.yaml"
set "DEFAULT_CHARSET=65001"

::Options
set "OPTION_B=0"
set "OPTION_D=0"
set "OPTION_U=0"
set "OPTION_P=0"
set "OPTION_L=0"
set "OPTION_S=0"
set "OPTION_A=0"

::Process
set "EXIT_CODE="

call :color

if "%~1"=="" (
    goto try
)

:parse
    set "ARG1=%~1"
    set "ARG2=%~2"
    if "!ARG1!"=="" goto valid
    if "-h"=="!ARG1!" (
        goto usage
    )
    if "-i"=="!ARG1!" (
        set "OPTION_INPUT=1"
        shift
        goto parse
    )
    if "-an"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "APP_NAME=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-av"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "APP_VERSION=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-ab"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "APP_BUILD=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-ap"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "APP_PATH=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-dc"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "DOCKER_COMPOSE=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-do"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "ORIGIN_REGISTRY=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-dt"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "TARGET_REGISTRY=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-np"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "NCR_PUBLIC_NAME=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-ns"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "NCR_PRIVATE_NAME=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-kn"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "CLUTER_NAME=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-kp"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "CLUSTER_PATH=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-kc"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "KUBE_CONFIG=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-ka"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "KUBE_APPLY=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if "-wc"=="!ARG1!" (
        if not "-"=="!ARG2:~0,1!" (
            set "CHARSET=!ARG2!"
            shift
        )
        shift
        goto parse
    )
    if not "-"=="!ARG1:~0,1!" (
        echo sdocker: option !ARG1! is not supported
        goto try
    )
    set "OPTIONS=!ARG1:~1!"
    :split
        if ""=="!OPTIONS!" (
            shift
            goto parse
        )
        set "OPTION=!OPTIONS:~0,1!"
        if "B"=="!OPTION!" (
            set "OPTION_B=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "D"=="!OPTION!" (
            set "OPTION_D=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "U"=="!OPTION!" (
            set "OPTION_U=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "P"=="!OPTION!" (
            set "OPTION_P=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "L"=="!OPTION!" (
            set "OPTION_L=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "S"=="!OPTION!" (
            set "OPTION_S=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        if "A"=="!OPTION!" (
            set "OPTION_A=1"
            set "OPTIONS=!OPTIONS:~1!"
            goto split
        )
        echo sdocker: option -!OPTION! is not supported
        goto try

:valid
    if "1"=="!OPTION_B!" if ""=="!APP_BUILD!" goto invalid
    set /a "SUMM=!OPTION_U!+!OPTION_P!"
    if !SUMM! gtr 1 goto invalid
    set /a "SUMM=!OPTION_B!+!OPTION_D!+!OPTION_U!+!OPTION_P!"
    if !SUMM! gtr 0 (
        set /a "SUMM=!OPTION_S!+!OPTION_A!"
        if !SUMM! gtr 0 goto invalid
    )
    goto init
    :invalid
        echo sdocker: options are invalid
        goto try

:init
    if ""=="!CHARSET!" (
        set "CHARSET=%DEFAULT_CHARSET%"
    )
    call chcp !CHARSET! >nul 2>&1
    if errorlevel 1 (
        echo sdocker: Invalid code page
        goto try
    )

::Application
:input_app
    echo Application
    ::Name
    :input_app_name
        if not ""=="!APP_NAME!" (
            echo - Name []: !APP_NAME!
            goto input_app_version
        )
        set /p APP_NAME="- Name []: "
        if ""=="!APP_NAME!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )
    ::Version
    :input_app_version
        if not ""=="!APP_VERSION!" (
            echo - Version []: !APP_VERSION!
            goto input_app_build
        )
        set /p APP_VERSION="- Version []: "
        if ""=="!APP_VERSION!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )
    ::Build
    :input_app_build
        if not "1"=="!OPTION_B!" goto input_app_path
        if not ""=="!APP_BUILD!" (
            echo - Build []: !APP_BUILD!
            goto input_app_path
        )
        set /p APP_BUILD="- Build [gradle|npm]: "
        if ""=="!APP_BUILD!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )
    ::Path
    :input_app_path
        if not "1"=="!OPTION_B!" if not "1"=="!OPTION_D!" if not "1"=="!OPTION_U!" goto input_registry
        if not ""=="!APP_PATH!" (
            echo - Path [%DEFAULT_ROOT%\!APP_NAME!]: !APP_PATH!
            goto move_app_path
        )
        if not "1"=="!OPTION_INPUT!" (
            set "APP_PATH=%DEFAULT_ROOT%\!APP_NAME!"
            echo - Path [%DEFAULT_ROOT%\!APP_NAME!]: !APP_PATH!
            goto move_app_path
        )
        set /p APP_PATH="- Path [%DEFAULT_ROOT%\!APP_NAME!]: "
        if ""=="!APP_PATH!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "APP_PATH=%DEFAULT_ROOT%\!APP_NAME!"
        )
    :move_app_path
        cd /d "!APP_PATH!" >nul 2>&1
        if errorlevel 1 (
            echo.
            echo sdocker: Failed to move to !APP_PATH!
            goto fail
        )
    ::Docker Compose
    :input_docker_compose
        if not "1"=="!OPTION_D!" if not "1"=="!OPTION_U!" goto input_registry
        if not ""=="!DOCKER_COMPOSE!" (
            echo - Compose File [%DEFAULT_DOCKER_COMPOSE%]: !DOCKER_COMPOSE!
            goto input_registry
        )
        if not "1"=="!OPTION_INPUT!" (
            set "DOCKER_COMPOSE=%DEFAULT_DOCKER_COMPOSE%"
            echo - Compose File [%DEFAULT_DOCKER_COMPOSE%]: !DOCKER_COMPOSE!
            goto input_registry
        )
        set /p DOCKER_COMPOSE="- Compose File [%DEFAULT_DOCKER_COMPOSE%]: "
        if ""=="!DOCKER_COMPOSE!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "DOCKER_COMPOSE=%DEFAULT_DOCKER_COMPOSE%"
        )

::Registry
:input_registry
    if not "1"=="!OPTION_D!" if not "1"=="!OPTION_U!" if not "1"=="!OPTION_P!" if not "1"=="!OPTION_L!" if not "1"=="!OPTION_S!" if not "1"=="!OPTION_A!" goto input_kubernetes
    echo Registry
    ::Origin Registry
    :input_origin
        if not "1"=="!OPTION_L!" goto input_target
        if not ""=="!ORIGIN_REGISTRY!" (
            echo - Origin Registry Endpoint [%DEFAULT_ORIGIN_REGISTRY%]: !ORIGIN_REGISTRY!
            goto input_target
        )
        if not "1"=="!OPTION_INPUT!" (
            set "ORIGIN_REGISTRY=%DEFAULT_ORIGIN_REGISTRY%"
            echo - Origin Registry Endpoint [%DEFAULT_ORIGIN_REGISTRY%]: !ORIGIN_REGISTRY!
            goto input_target
        )
        set /p ORIGIN_REGISTRY="- Origin Registry Endpoint [%DEFAULT_ORIGIN_REGISTRY%]: "
        if ""=="!ORIGIN_REGISTRY!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "ORIGIN_REGISTRY=%DEFAULT_ORIGIN_REGISTRY%"
        )
    ::Target Registry
    :input_target
        if not "1"=="!OPTION_D!" if not "1"=="!OPTION_U!" if not "1"=="!OPTION_P!" goto input_ncr_public
        if not ""=="!TARGET_REGISTRY!" (
            echo - Target Registry Endpoint [%DEFAULT_TARGET_REGISTRY%]: !TARGET_REGISTRY!
            goto input_ncr_public
        )
        if not "1"=="!OPTION_INPUT!" (
            set "TARGET_REGISTRY=%DEFAULT_TARGET_REGISTRY%"
            echo - Target Registry Endpoint [%DEFAULT_TARGET_REGISTRY%]: !TARGET_REGISTRY!
            goto input_ncr_public
        )
        set /p TARGET_REGISTRY="- Target Registry Endpoint [%DEFAULT_TARGET_REGISTRY%]: "
        if ""=="!TARGET_REGISTRY!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "TARGET_REGISTRY=%DEFAULT_TARGET_REGISTRY%"
        )
    ::NCR Public
    :input_ncr_public
        if not "1"=="!OPTION_S!" goto input_ncr_private
        if not ""=="!NCR_PUBLIC_NAME!" (
            echo - NCR Public Name []: !NCR_PUBLIC_NAME!
            goto input_ncr_private
        )
        set /p NCR_PUBLIC_NAME="- NCR Public Name []: "
        if ""=="!NCR_PUBLIC_NAME!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )
    ::NCR Private
    :input_ncr_private
        if not "1"=="!OPTION_S!" if not "1"=="!OPTION_A!" goto input_kubernetes
        if not ""=="!NCR_PRIVATE_NAME!" (
            echo - NCR Private Name []: !NCR_PRIVATE_NAME!
            goto input_kubernetes
        )
        set /p NCR_PRIVATE_NAME="- NCR Private Name []: "
        if ""=="!NCR_PRIVATE_NAME!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )

::Kubernetes
:input_kubernetes
    if not "1"=="!OPTION_S!" if not "1"=="!OPTION_A!" goto begin
    echo Kubernetes
    ::Cluster
    :input_cluster_name
        if not ""=="!CLUTER_NAME!" (
            echo - Cluster Name []: !CLUTER_NAME!
            goto input_kube_config
        )
        set /p CLUTER_NAME="- Cluster Name []: "
        if ""=="!CLUTER_NAME!" (
            echo.
            echo sdocker: This field can not be empty
            goto try
        )
    :input_cluster_path
        if not ""=="!CLUTER_PATH!" (
            echo - Cluster Path [%DEFAULT_ROOT%\!CLUTER_NAME!]: !CLUTER_PATH!
            goto move_cluster_path
        )
        if not "1"=="!OPTION_INPUT!" (
            set "CLUTER_PATH=%DEFAULT_ROOT%\!CLUTER_NAME!"
            echo - Cluster Path [%DEFAULT_ROOT%\!CLUTER_NAME!]: !CLUTER_PATH!
            goto move_cluster_path
        )
        set /p CLUTER_PATH="- Cluster Path [%DEFAULT_ROOT%\!CLUTER_NAME!]: "
        if ""=="!CLUTER_PATH!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "CLUTER_PATH=%DEFAULT_ROOT%\!CLUTER_NAME!"
        )
    :move_cluster_path
        cd /d "!CLUTER_PATH!" >nul 2>&1
        if errorlevel 1 (
            echo.
            echo sdocker: Failed to move to !CLUTER_PATH!
            goto fail
        )
    ::Config
    :input_kube_config
        if not ""=="!KUBE_CONFIG!" (
            echo - Cluster Config File [%DEFAULT_KUBE_CONFIG%]: !KUBE_CONFIG!
            goto input_kube_apply
        )
        if not "1"=="!OPTION_INPUT!" (
            set "KUBE_CONFIG=%DEFAULT_KUBE_CONFIG%"
            echo - Cluster Config File [%DEFAULT_KUBE_CONFIG%]: !KUBE_CONFIG!
            goto input_kube_apply
        )
        set /p KUBE_CONFIG="- Cluster Config File [%DEFAULT_KUBE_CONFIG%]: "
        if ""=="!KUBE_CONFIG!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "KUBE_CONFIG=%DEFAULT_KUBE_CONFIG%"
        )
    ::Apply
    :input_kube_apply
        if not ""=="!KUBE_APPLY!" (
            echo - Cluster Apply File [%DEFAULT_KUBE_APPLY%]: !KUBE_APPLY!
            goto input_kube_apply
        )
        if not "1"=="!OPTION_INPUT!" (
            set "KUBE_APPLY=%DEFAULT_KUBE_APPLY%"
            echo - Cluster Apply File [%DEFAULT_KUBE_APPLY%]: !KUBE_APPLY!
            goto input_kube_apply
        )
        set /p KUBE_APPLY="- Cluster Apply File [%DEFAULT_KUBE_APPLY%]: "
        if ""=="!KUBE_APPLY!" (
            set /p CONTINUE="Continue using the default value [y/n]: "
            if /i not "y"=="!CONTINUE!" goto end
            set "KUBE_APPLY=%DEFAULT_KUBE_APPY%"
        )

:begin
    for /f "tokens=1,2 delims=.," %%a in ('powershell Get-Date -UFormat %%s') do (set "BEGIN_AT_SS=%%a" & set "BEGIN_AT_MS=1%%b")
    if %BEGIN_AT_MS% lss 100000 set "BEGIN_AT_MS=%BEGIN_AT_MS%0"

:env
    if not ""=="!ORIGIN_REGISTRY!" set "ORIGIN_IMAGE=!ORIGIN_REGISTRY!/!APP_NAME!:!APP_VERSION!"
    if not ""=="!TARGET_REGISTRY!" set "TARGET_IMAGE=!TARGET_REGISTRY!/!APP_NAME!:!APP_VERSION!"
    if not ""=="!NCR_PUBLIC_NAME!" set "NCR_PUBLIC=!NCR_PUBLIC_NAME!.%DEFAULT_NCR_PUBLIC_SUFFIX%"
    if not ""=="!NCR_PUBLIC!" set "NCR_PUBLIC_IMAGE=!NCR_PUBLIC!/!APP_NAME!:!APP_VERSION!"
    if not ""=="!NCR_PRIVATE_NAME!" set "NCR_PRIVATE=!NCR_PRIVATE_NAME!.%DEFAULT_NCR_PRIVATE_SUFFIX%"
    if not ""=="!NCR_PRIVATE!" set "NCR_PRIVATE_IMAGE=!NCR_PRIVATE!/!APP_NAME!:!APP_VERSION!"
    call :info "Input:"
    call :info "  Application:"
    call :info "    Name: !APP_NAME!"
    call :info "    Version: !APP_VERSION!"
    call :info "    Build: !APP_Build!"
    call :info "    Path: !APP_PATH!"
    call :info "    Compose: !DOCKER_COMPOSE!"
    call :info "  Registry:"
    call :info "    Origin:"
    call :info "      Endpoint: !ORIGIN_REGISTRY!"
    call :info "      Image: !ORIGIN_IMAGE!"
    call :info "    Target:"
    call :info "      Endpoint: !TARGET_REGISTRY!"
    call :info "      Image: !TARGET_IMAGE!"
    call :info "    NCR:"
    call :info "      Public:"
    call :info "        Name: !NCR_PUBLIC_NAME!"
    call :info "        Endpoint: !NCR_PUBLIC!"
    call :info "        Image: !NCR_PUBLIC_IMAGE!"
    call :info "      Private:"
    call :info "        Name: !NCR_PRIVATE_NAME!"
    call :info "        Endpoint: !NCR_PRIVATE!"
    call :info "        Image: !NCR_PRIVATE_IMAGE!"
    call :info "  Kubernetes:"
    call :info "    Cluster:"
    call :info "      Name: !CLUSTER_NAME!"
    call :info "      Path: !CLUSTER_PATH!"
    call :info "      Config: !KUBE_CONFIG!"
    call :info "      Apply: !KUBE_APPLY!"
    call :info "  Active code page: !CHARSET!"

:gradle
    if not "1"=="!OPTION_B!" (
        call :warn "Build Gradle: skip"
        goto npm
    )
    if not "gradle"=="!APP_BUILD!" (
        call :warn "Build Gradle: skip"
        goto npm
    )
    call :info "Build Gradle:"
    call gradlew.bat clean build --refresh-dependencies -Pver=!APP_VERSION!
    if errorlevel 1 (
        call :error "  Failed to build gradle"
        goto done
    )

:npm
    if not "1"=="!OPTION_B!" (
        call :warn "Build NPM: skip"
        goto compose_build
    )
    if not "npm"=="!APP_BUILD!" (
        call :warn "Build NPM: skip"
        goto compose_build
    )
    call :info "Build NPM:"
    call npm run build
    if errorlevel 1 (
        call :error "  Failed to build npm"
        goto done
    )

:compose_build
    if not "1"=="!OPTION_D!" (
        call :warn "Compose Build Docker Image: skip"
        goto compose_up
    )
    call :info "Compose Build Docker Image:"
    call docker compose -f !DOCKER_COMPOSE! build --no-cache
    if errorlevel 1 (
        call :error "  Failed to build docker image"
        goto done
    )

:compose_up
    if not "1"=="!OPTION_U!" (
        call :warn "Compose Up Docker Container: skip"
        goto clean
    )
    call :info "Compose Up Docker Container:"
    call docker compose -f !DOCKER_COMPOSE! up -d
    if errorlevel 1 (
        call :error "  Failed to run docker image"
        goto done
    )
    call docker compose ps -a

:clean
    if not "1"=="!OPTION_D!" if not "1"=="!OPTION_U!" (
        call :warn "Prune Docker Image: skip"
        goto push
    )
    call :info "Prune Docker Images:"
    call docker image prune -f

:push
    if not "1"=="!OPTION_P!" (
        call :warn "Push Docker Image: skip"
        goto pull
    )
    call :info "Push Docker Image:"
    call docker image push !TARGET_IMAGE!
    if errorlevel 1 (
        call :error "  Failed to push image"
        goto done
    )

:pull
    if not "1"=="!OPTION_L!" (
        call :warn "Pull Docker Image: skip"
        goto done
    )
    call :info "Pull Docker Image: !ORIGIN_IMAGE!"
    call docker image pull !ORIGIN_IMAGE!
    if errorlevel 1 (
        call :error "  Failed to push image"
        goto done
    )

:done
    for /f "tokens=1,2 delims=.," %%a in ('powershell Get-Date -UFormat %%s') do set "END_AT_SS=%%a" & set "END_AT_MS=1%%b"
    if %END_AT_MS% lss 100000 set "END_AT_MS=%END_AT_MS%0"
    if %BEGIN_AT_MS% gtr %END_AT_MS% set /a "END_AT_MS=%END_AT_MS%+100000" & set /a "END_AT_SS=%END_AT_SS%-1"
    set /a "ELAPSED_SS=%END_AT_SS%-%BEGIN_AT_SS%"
    set /a "DIFF_HH=%ELAPSED_SS%/3600"
    if %DIFF_HH% lss 10 set "DIFF_HH=0%DIFF_HH%"
    set /a "DIFF_MM=(%ELAPSED_SS%%%3600)/60"
    if %DIFF_MM% lss 10 set "DIFF_MM=0%DIFF_MM%"
    set /a "DIFF_SS=%ELAPSED_SS%%%60"
    if %DIFF_SS% lss 10 set "DIFF_SS=0%DIFF_SS%"
    set /a "DIFF_MS=%END_AT_MS%-%BEGIN_AT_MS%"
    if ""=="%EXIT_CODE%" set "EXIT_CODE=%ERRORLEVEL%"
    if 0==%EXIT_CODE% (
        call :info "%GREEN%Success%NOCOLOR% in %YELLOW%%DIFF_HH%:%DIFF_MM%:%DIFF_SS%.%DIFF_MS:~0,3%%NOCOLOR%"
    ) else (
        call :error "%RED%Fail%NOCOLOR% in %YELLOW%%DIFF_HH%:%DIFF_MM%:%DIFF_SS%.%DIFF_MS:~0,3%%NOCOLOR%"
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
    echo Usage: sdocker [options...]
    echo   -h              Get help for commands
    echo   -i              Choose or Input Field Values
    echo   -an [name]      Application Name
    echo   -av [version]   Application Version
    echo   -ab [tool]      Application Build
    echo                   Tools:
    echo                     gradle
    echo                     npm
    echo   -ap [path]      Application Path (DEFAULT: %SKY%%DEFAULT_ROOT%%NOCOLOR%\[Application Name])
    echo   -do [endpoint]  Origin Registry Endpoint (DEFAULT: %SKY%%DEFAULT_ORIGIN_REGISTRY%%NOCOLOR%)
    echo   -dt [endpoint]  Target Registry Endpoint (DEFAULT: %SKY%%DEFAULT_TARGET_REGISTRY%%NOCOLOR%)
    echo   -dc [file]      Docker Compose File (DEFAULT: %SKY%%DEFAULT_DOCKER_COMPOSE%%NOCOLOR%)
    echo   -np [name]      NCloud Public Conatiner Registry Name
    echo                   End Point Suffix (DEFAULT: [Public Registry Name].%SKY%%DEFAULT_NCR_PUBLIC_SUFFIX%%NOCOLOR%)
    echo   -ns [name]      NCloud Private Conatiner Registry Name
    echo                   End Point Suffix (DEFAULT: [Private Registry Name].%SKY%%DEFAULT_NCR_PRIVATE_SUFFIX%%NOCOLOR%)
    echo   -kn [name]      Kubernetes Cluster Name
    echo   -kc [file]      Kubernetes Cluster Config File
    echo   -ka [file]      Kubernetes Apply File
    echo   -wc [code]      Windows Active code page (DEFAULT: %SKY%!CHARSET!%NOCOLOR%)
    echo                   Codes:
    echo                     65001 utf-8
    echo                     51949 euc-kr
    echo                     28591 iso-8859-1
    echo                     For more code, head to https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
    echo   -B              Build
    echo                   Compatible Options:
    echo                      -BD
    echo                      -BDU
    echo                      -BDP
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -ab [Application Build]
    echo                     -ap [Application Path]
    echo   -D              Compose Build Docker Image
    echo                   Compatible Options:
    echo                      -BD
    echo                      -BDU
    echo                      -BDP
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -ap [Application Path]
    echo                     -dt [Target Registry Endpoint]
    echo                     -dc [Docker Compose File]
    echo   -U              Compose Up Docker Image
    echo                   Compatible Options:
    echo                      -BDU
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -ap [Application Path]
    echo                     -dt [Target Registry Endpoint]
    echo                     -dc [Docker Compose File]
    echo   -P              Push Docker Image
    echo                   Compatible Options:
    echo                      -BDP
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -dt [Target Registry Endpoint]
    echo   -L              Pull Docker Image
    echo                   Compatible Options:
    echo                      -LU
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -do [Origin Registry Endpoint]
    echo                     -dt [Target Registry Endpoint]
    echo   -S              Synchronize Docker Image
    echo                   Compatible Options:
    echo                      -SA
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -do [Origin Registry Endpoint]
    echo                     -np [NCloud Public Conatiner Registry Name]
    echo   -A              Apply Container
    echo                   Compatible Options:
    echo                      -SA
    echo                   Required Fields:
    echo                     -an [Application Name]
    echo                     -av [Application Version]
    echo                     -ns [NCloud Private Conatiner Registry Name]
    echo                     -kn [Kubernetes Cluster Name]
    echo                     -kc [Kubernetes Cluster Config File]
    echo                     -ka [Kubernetes Apply File]
    echo.
    echo Examples:
    echo   -GBU: sdocker -BDU ^^
    echo         -an app-name ^^
    echo         -av 1.0.0 ^^
    echo         -ab gradle ^^
    echo         -ap %DEFAULT_ROOT%\app-name ^^
    echo         -dt %DEFAULT_TARGET_REGISTRY% ^^
    echo         -dc %DEFAULT_DOCKER_COMPOSE%
    echo   -GBP: sdocker -GBP ^^
    echo         -an app-name ^^
    echo         -av 1.0.0 ^^
    echo         -ab gradle ^^
    echo         -ap %DEFAULT_ROOT%\app-name ^^
    echo         -dt %DEFAULT_TARGET_REGISTRY% ^^
    echo         -dc %DEFAULT_DOCKER_COMPOSE%
    echo   -SA: sdocker -SA ^^
    echo         -an app-name ^^
    echo         -av 1.0.0 ^^
    echo         -do %DEFAULT_ORIGIN_REGISTRY% ^^
    echo         -np ncr-public-name.%DEFAULT_NCR_PUBLIC_SUFFIX% ^^
    echo         -ns ncr-private-name.%DEFAULT_NCR_PRIVATE_SUFFIX% ^^
    echo         -kn cluster-name ^^
    echo         -kc %DEFAULT_ROOT%\cluster-name\%DEFAULT_KUBE_CONFIG% ^^
    echo         -ka %DEFAULT_ROOT%\cluster-name\app-name\%DEFAULT_KUBE_APPLY%
    goto success

:try
    echo sdocker: try 'sdocker -h' for more information
    goto fail

:success
    set "EXIT_CODE=0"
    goto end

:fail
    set "EXIT_CODE=1"
    goto end

:end
    endlocal
    exit /b %EXIT_CODE%

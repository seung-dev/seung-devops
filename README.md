# seung-devops

## sdocker

Clean & Build Gradle + Clean & Build Docker Image + Run Docker Container + Push Docker Image

### Usage

Help

```cmd
sdocker -h
```

Options

```
Usage: sdocker [options...]
  -h  Get help for commands
  -w  Workspace Path (DEFAULT: W:\seung-git)
  -n  Application Name
  -v  Application Version
  -r  Remote Registry Endpoint (DEFAULT: 127.0.0.1:18579)
  -f  Docker compose file (DEFAULT: docker-compose.yaml)
  -c  Active code page (DEFAULT: 65001)
      65001 utf-8
      51949 euc-kr
      28591 iso-8859-1
      For more code, head to https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
  -D  Use Default Values
  -G  Clean and Build Gradle
  -B  Build Docker Image
  -R  Run Docker Image
  -P  Push Docker Image

Examples:
  sdocker -DGBRP -n {name} -v {version}
    Use default values
    Build gradle
    Build docker image
    Run docker image
    Push docker image
  sdocker -DGBRP
    Input values
    Build gradle
    Build docker image
    Run docker image
    Push docker image
  sdocker -DG -n {name} -v {version}
    Use default values
    Build gradle
  sdocker -DR -n {name} -v {version}
    Use default values
    Run docker image
  sdocker -GBRP -w W:\seung-git -n {name} -v {version} -r 127.0.0.1:18579 -f docker-compose.yaml -c 65001
    Command all options
```

Build

```cmd
sdocker -DGB -n {name} -v {version}
```

Run

```cmd
sdocker -DR -n {name} -v {version}
```

Push

```cmd
sdocker -DP -n {name} -v {version}
```

### Configuration

Add Workspace System Path

> Administrator: Command Prompt

```cmd
setx SEUNG_GIT W:\seung-git
```

Add Bin System Path

> Administrator: Command Prompt

```cmd
setx path "%PATH%;%SEUNG_GIT%\bin"
```

Move sdocker

```cmd
copy sdocker.bat %SEUNG_GIT%\bin\sdocker.bat
```

Add Files to the Project

- gradlew.bat
- settings.gradle
- build.gradle
- Dockerfile
- docker-compose.yaml

[goto templates](https://github.com/seung-dev/seung-devops/tree/main/sdocker/spring)

Edit Files

- Dockerfile
  - Base Image
  - User
  - Path
  - Command
  - Etc
- Compose
  - Remote Registry Endpoint
  - Project Name
  - Version
  - Timezone
  - Database Information
  - Command
  - Etc
- sdocker
  - Default Workspace Path
  - Default Remote Registry Endpoint
  - Default Compose Yaml File Path
  - Charset
  - Etc

## Self Signed Certification

Generate Certification

```cmd
cd %UserProfile%
```

```cmd
mkdir .ssl & cd .ssl
```

```cmd
openssl genrsa -out 127.0.0.1.key 4096
```

```cmd
openssl req -new -x509 -key 127.0.0.1.key -out 127.0.0.1.crt -days 3650 -subj "/C=KR/ST=Seoul/O=seung/CN=127.0.0.1/emailAddress=seung.dev@gmail.com" -addext "subjectAltName=IP:127.0.0.1" -text
```

```cmd
type 127.0.0.1.crt
```

Add Certificate

> Administrator: Command Prompt

```cmd
certutil -addstore Root %UserProfile%\.ssl\127.0.0.1.crt
```

## docker-registry

[goto docker-registry](https://github.com/seung-dev/seung-devops/tree/main/docker-registry)

## References

[OpenJDK 17](https://jdk.java.net/java-se-ri/17)

[Spring Tool Suite 4](https://spring.io/tools)

[Maven Repository](https://mvnrepository.com/)

[Writing Gradle Settings Files](https://docs.gradle.org/current/userguide/writing_settings_files.html)

[Writing Gradle Build Scripts](https://docs.gradle.org/current/userguide/writing_build_scripts.html)

[Spring Boot Application Properties](https://docs.spring.io/spring-boot/appendix/application-properties/index.html)

[Lombok Installation](https://projectlombok.org/setup/eclipse)

[MyBatis Getting started](https://mybatis.org/mybatis-3/getting-started.html)

[Docker Hub](https://hub.docker.com/)

[Writing a Dockerfile](https://docs.docker.com/guides/docker-concepts/building-images/writing-a-dockerfile/)

[Docker Compose Quickstart](https://docs.docker.com/compose/gettingstarted/)

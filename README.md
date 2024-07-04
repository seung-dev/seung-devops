# seung-devops

## sdocker

- Build
  - Gradle
  - NPM
- Docker
  - Compose
    - Build
    - Up
  - Push
  - Pull
- Kubernetes
  - Apply

### Usage

Help

```cmd
sdocker -h
```

Options

```
Usage: sdocker [options...]
  -h              Get help for commands
  -i              Choose or Input Field Values
  -an [name]      Application Name
  -av [version]   Application Version
  -ab [tool]      Application Build
                  Tools:
                    gradle
                    npm
  -ap [path]      Application Path (DEFAULT: W:\kesg-git\[Application Name])
  -do [endpoint]  Origin Registry Endpoint (DEFAULT: 192.168.100.199:18579)
  -dt [endpoint]  Target Registry Endpoint (DEFAULT: 192.168.100.199:18579)
  -dc [file]      Docker Compose File (DEFAULT: docker-compose.yaml)
  -np [name]      NCloud Public Conatiner Registry Name
                  End Point Suffix (DEFAULT: [Public Registry Name].ncr.ntruss.com)
  -ns [name]      NCloud Private Conatiner Registry Name
                  End Point Suffix (DEFAULT: [Private Registry Name].private-ncr.ntruss.com)
  -kn [name]      Kubernetes Cluster Name
  -kc [file]      Kubernetes Cluster Config File
  -ka [file]      Kubernetes Apply File
  -wc [code]      Windows Active code page (DEFAULT: )
                  Codes:
                    65001 utf-8
                    51949 euc-kr
                    28591 iso-8859-1
                    For more code, head to https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
  -B              Build
                  Compatible Options:
                     -BD
                     -BDU
                     -BDP
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -ab [Application Build]
                    -ap [Application Path]
  -D              Compose Build Docker Image
                  Compatible Options:
                     -BD
                     -BDU
                     -BDP
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -ap [Application Path]
                    -dt [Target Registry Endpoint]
                    -dc [Docker Compose File]
  -U              Compose Up Docker Image
                  Compatible Options:
                     -BDU
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -ap [Application Path]
                    -dt [Target Registry Endpoint]
                    -dc [Docker Compose File]
  -P              Push Docker Image
                  Compatible Options:
                     -BDP
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -dt [Target Registry Endpoint]
  -L              Pull Docker Image
                  Compatible Options:
                     -LU
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -do [Origin Registry Endpoint]
                    -dt [Target Registry Endpoint]
  -S              Synchronize Docker Image
                  Compatible Options:
                     -SA
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -do [Origin Registry Endpoint]
                    -np [NCloud Public Conatiner Registry Name]
  -A              Apply Container
                  Compatible Options:
                     -SA
                  Required Fields:
                    -an [Application Name]
                    -av [Application Version]
                    -ns [NCloud Private Conatiner Registry Name]
                    -kn [Kubernetes Cluster Name]
                    -kc [Kubernetes Cluster Config File]
                    -ka [Kubernetes Apply File]

Examples:
  -GBU: sdocker -BDU ^
        -an app-name ^
        -av 1.0.0 ^
        -ab gradle ^
        -ap W:\kesg-git\app-name ^
        -dt 192.168.100.199:18579 ^
        -dc docker-compose.yaml
  -GBP: sdocker -GBP ^
        -an app-name ^
        -av 1.0.0 ^
        -ab gradle ^
        -ap W:\kesg-git\app-name ^
        -dt 192.168.100.199:18579 ^
        -dc docker-compose.yaml
  -SA: sdocker -SA ^
        -an app-name ^
        -av 1.0.0 ^
        -do 192.168.100.199:18579 ^
        -np ncr-public-name.ncr.ntruss.com ^
        -ns ncr-private-name.private-ncr.ntruss.com ^
        -kn cluster-name ^
        -kc W:\kesg-git\cluster-name\kubeconfig.yaml ^
        -ka W:\kesg-git\cluster-name\app-name\kubeapply.yaml
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
  - Default Variables

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

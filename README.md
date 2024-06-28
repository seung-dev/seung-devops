# seung-devops

## dockerw

Clean & Build Gradle + Clean & Build Docker Image + Run Docker Container + Push Docker Image

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

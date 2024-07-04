FROM eclipse-temurin:17-jre-alpine

ARG APP_PATH=/seung
ARG JAR_PATH=${APP_PATH}/app.jar

RUN apk update && apk upgrade

RUN mkdir -p ${APP_PATH}

RUN addgroup -S seung && adduser -S seung -G seung
RUN chown -R seung:root ${APP_PATH}
USER seung

COPY build/libs/*.jar ${JAR_PATH}

ENV RUN_COMMAND="java -jar ${JAR_PATH}"

CMD $RUN_COMMAND

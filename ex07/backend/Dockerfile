FROM eclipse-temurin:21-jdk

RUN apt update && apt install -y git

WORKDIR /var/current/app

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

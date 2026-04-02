# Dockerfile은 원래 이미지를 기반으로 새로운 이미지를 만들어 내는 파일
# FROM 이미지명:버전
FROM ubuntu

# RUN -> 리눅스 내부에서 사용되는 쉘 명령어(여러번 작성 가능)
# && -> and
# \ -> 엔터(줄바꿈)
RUN apt-get update && \
    apt-get install -y cron

# COPY -> Host 시스템과 Docker 내부 시스템을 연결하는 명령어
# Host의 scripts폴더를 Docker 이미지 안에 복사
COPY scripts/ /scripts/
# root폴더의 scripts폴더 안에 있는 모든 .sh파일에 x 권한을 부여
RUN chmod +x /scripts/*.sh

CMD ["cron", "-f"]
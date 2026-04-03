# ex01 Docker + NGINX

- Dockerfile로 환경 자동화 (프로비저닝)
- NGINX로 요청 분산 (로드밸런싱)
- 여러 컨테이너를 연결해서 **웹 서비스 구조 만들기**

---

# 1. 프로비저닝 (Provisioning)

## 📌 개념

👉 컨테이너가 실행될 때 필요한 환경을 **자동으로 준비하는 과정**

### ❗ 문제 상황

- 컨테이너 실행할 때마다
  - vim 설치
  - 패키지 설치
  - 파일 복사
    👉 반복 작업 발생

### ✅ 해결

👉 Dockerfile로 자동화

---

## 📌 Dockerfile 역할

👉 컨테이너 생성 시 필요한 환경을 정의하는 **설계서**

---

## 📌 주요 명령어

```docker
FROM # 베이스 이미지
RUN # 설치/명령 실행
WORKDIR # 작업 경로 설정
COPY # 파일 복사
CMD # 기본 실행 명령
ENTRYPOINT # 무조건 실행되는 명령
```

---

## 📌 기본 예시

```docker
FROM ubuntu

RUN apt update && apt install -y nano

CMD ["/bin/bash"]
```

---

## 📌 실행

```docker
docker build -t ubuntu-nano .
docker run -it ubuntu-nano
```

👉 실행하면 vim이 이미 설치된 상태

---

# 2. WORKDIR & COPY

## 📌 WORKDIR

👉 기본 작업 디렉토리 설정

```
WORKDIR /app
```

---

## 📌 COPY

👉 Host → Container 파일 복사

```
COPY ./images/image.png ./image.png
```

---

## 📌 예시

```docker
FROM ubuntu

RUN apt update && apt install -y nano

WORKDIR /app

COPY ./images/image.png ./image.png

CMD ["/bin/bash"]
```

---

## 📌 실행

```
docker build-t ubuntu-image .
docker run-it ubuntu-image
ls
```

👉 `/app/image.png` 확인 가능

---

# 3. ENTRYPOINT vs CMD (핵심)

## 📌 차이

| 구분       | 특징          |
| ---------- | ------------- |
| CMD        | 덮어쓰기 가능 |
| ENTRYPOINT | 무조건 실행   |

---

## 📌 예제

```
ENTRYPOINT ["echo","컨테이너 실행"]
CMD ["/bin/bash"]
```

---

## 📌 실제 실행 결과

```
echo"컨테이너 실행""/bin/bash"
```

👉 echo 실행 후 종료

👉 컨테이너도 바로 종료됨 ⚠️

---

## 🔥 핵심 포인트

👉 **컨테이너는 메인 프로세스가 끝나면 종료된다**

---

# 4. NGINX 개념

## 📌 NGINX란?

👉 웹 서버 + 프록시 + 로드밸런서

---

## 📌 역할

- 정적 파일 제공
- 요청 전달 (프록시)
- 로드밸런싱
- 캐싱

---

## 📌 리버스 프록시

👉 클라이언트 요청을 대신 받아서 서버로 전달

```
Client → NGINX → Backend 서버
```

---

# 5. ex01 구조 (중요 ⭐)

![image.png](attachment:b7487f67-91d0-430f-9cd7-d7cdaf34bedc:image.png)

```
ex01/
├── app1/
├── app2/
└── lb/
```

---

## 📌 구성 설명

| 구성 | 역할               |
| ---- | ------------------ |
| app1 | 서버 1             |
| app2 | 서버 2             |
| lb   | NGINX (로드밸런서) |

---

# 6. app 서버 구조

## 📌 Dockerfile

```docker
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

👉 nginx + HTML 페이지

---

## 📌 역할

- app1 → "Server1"
- app2 → "Server2"

👉 응답 구분용

---

# 7. Load Balancer (NGINX)

## 📌 Dockerfile

```docker
FROM nginx

COPY nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["nginx","-g","daemon off;"]
```

---

## 📌 핵심

👉 `daemon off;`

→ foreground 실행 (컨테이너 유지 필수)

---

# 8. nginx.conf (핵심 ⭐⭐⭐)

```
upstream app1 {
    server host.docker.internal:8000;
}

upstream app2 {
    server host.docker.internal:9000;
}

server {
    listen 80;

    location /app1 {
        proxy_pass http://app1/;
    }

    location /app2 {
        proxy_pass http://app2/;
    }
}
```

---

## 📌 동작 구조

```
/app1 요청 → app1 서버
/app2 요청 → app2 서버
```

---

## 📌 host.docker.internal

👉 컨테이너에서 **내 PC(호스트)** 접근할 때 사용하는 주소

---

## 9. 실행 명령어

### 서버 1 실행

- docker build -t app1 ./app1
- docker run -dit -p 8000:80 app1

### 서버 2 실행

- docker build -t app2 ./app2
- docker run -dit -p 9000:80 app2

### nginx 실행

- docker build -t lb ./lb
- docker run -dit -p 80:80 lb

### 실행

- http://localhost:80/app1
- http://localhost:80/app2

# 10. 결과 확인

---

## 📌 접속

```
http://localhost/app1
→ Server1

http://localhost/app2
→ Server2
```

---

## 📌 흐름

```
브라우저 → NGINX(lb)
           ↓
   경로에 따라 서버 선택
           ↓
      app1 or app2
```

---

# ex04

## 이번 내용 핵심

- 로드밸런싱 환경에서 발생하는
  👉 **세션 불일치 문제 해결**
- Redis를 이용한
  👉 **세션 공유 구조 구현**

---

# 1. 문제 상황 (로드밸런싱의 함정)

## 📌 상황

```
Client → NGINX → 서버1 (로그인 성공)
Client → NGINX → 서버2 (다음 요청)
```

---

## ❗ 문제

👉 서버2는 로그인 정보를 모름

---

## 🔥 이유

- 세션이 서버마다 따로 저장됨
- 서버가 여러 대면 상태 공유 불가능

---

## 📌 결과

👉 로그인 풀림 / 인증 실패

---

# 2. 해결 방법 → Redis

## 📌 개념

👉 모든 서버가 공유하는 **공용 저장소**

---

## 🔥 비유

👉 공용 사물함

```
서버1 → 사물함 저장
서버2 → 사물함 조회
```

---

## 📌 Redis란?

👉 메모리 기반 Key-Value 데이터베이스

---

## 📌 특징

- 매우 빠름 (메모리 기반)
- 단순 구조 (Key-Value)
- 캐시 / 세션 저장에 최적

---

# 3. 구조

```
ex04/
├── api/
└── redis (컨테이너)
```

![image.png](attachment:9e7219f2-7ea9-4483-8312-80faba9add98:image.png)

---

## 📌 전체 구조

```
Client
   ↓
NGINX (생략 가능)
   ↓
API 서버1   API 서버2
     \      /
       Redis
```

---

## 🔥 핵심

👉 여러 서버가 하나의 Redis를 공유

---

# 4. API 서버 코드

## 📌 Redis 연결

```
r=redis.Redis(host='redis',port=6379,db=0)
```

👉 컨테이너 이름으로 접근

---

## 📌 저장

```
@app.route("/save")
defsave_name():
r.set("name","metacoding")
```

---

## 📌 조회

```
@app.route("/read")
defread_name():
value=r.get("name")
```

---

# 5. Docker 네트워크 (핵심 ⭐⭐⭐)

## 📌 왜 필요?

👉 컨테이너는 기본적으로 서로 통신 불가

---

## 📌 해결

```
docker network create myNetwork
```

---

## 📌 핵심 효과

👉 같은 네트워크에 있으면

```
컨테이너 이름 = 호스트명
```

👉 `redis`로 접근 가능

---

# 6. 실행 과정

---

## 1️⃣ 네트워크 생성

```
docker network create myNetwork
```

![image.png](attachment:6600d78a-5027-4d11-9b77-7aedd05a73b1:image.png)

---

## 2️⃣ Redis 실행

```docker
docker run -d --name redis \
--network myNetwork \
-p6379:6379 redis
```

---

## 3️⃣ API 서버 2개 실행

```
docker build-t api ./api

docker run-d--name api1 \
--network myNetwork \
-p5001:5000 api

docker run-d--name api2 \
--network myNetwork \
-p5002:5000 api
```

---

# 7. 테스트

---

## 📌 1. api1에서 저장

```
http://localhost:5001/save
```

![image.png](attachment:d5471530-7c7d-4335-ad21-b98250f8f858:image.png)

👉 Redis에 저장됨

---

## 📌 2. api2에서 조회

```
http://localhost:5002/read
```

👉 api1에서 저장한 값 조회 가능

---

## 🔥 결과 의미

👉 서버가 달라도 데이터 공유됨

---

# 8. 전체 흐름

```
Client → API1 → Redis 저장
Client → API2 → Redis 조회
```

---

# 9. 핵심 정리

## 🔥 가장 중요한 포인트

- 세션을 서버에 저장하면 문제 발생
- Redis에 저장하면 모든 서버 공유 가능
- Docker 네트워크로 컨테이너 연결
- 컨테이너 이름으로 통신 가능

---

# 🚀 한줄 요약

👉 **Redis는 여러 서버가 공통으로 사용하는 세션 저장소다**

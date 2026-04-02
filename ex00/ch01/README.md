## Crontab 튜토리얼 (Docker Ubuntu)

### Crontab이란?

리눅스에서 **정해진 시간에 자동으로 명령어를 실행**하는 스케줄러

### Crontab 문법

```
*    *    *    *    *    실행할 명령어
분   시   일   월   요일
```

| 필드 | 범위 | 설명                 |
| ---- | ---- | -------------------- |
| 분   | 0-59 | 몇 분에 실행         |
| 시   | 0-23 | 몇 시에 실행         |
| 일   | 1-31 | 몇 일에 실행         |
| 월   | 1-12 | 몇 월에 실행         |
| 요일 | 0-6  | 무슨 요일 (0=일요일) |

### 주요 표현식 예시

| 표현식         | 의미                 |
| -------------- | -------------------- |
| `* * * * *`    | 매분                 |
| `*/5 * * * *`  | 5분마다              |
| `0 * * * *`    | 매시 정각            |
| `0 9 * * *`    | 매일 오전 9시        |
| `0 9 * * 1`    | 매주 월요일 오전 9시 |
| `0 0 1 * *`    | 매월 1일 자정        |
| `30 2 * * 1-5` | 평일 새벽 2시 30분   |

### 표준 리다이렉션 (Redirection)

crontab에서 `>> /var/log/cron.log` 같은 표현이 나온다. 이것을 이해하려면 리다이렉션을 알아야 한다.

#### 3가지 표준 스트림

| 번호 | 이름   | 설명      | 기본 방향 |
| ---- | ------ | --------- | --------- |
| 0    | stdin  | 표준 입력 | 키보드    |
| 1    | stdout | 표준 출력 | 화면      |
| 2    | stderr | 표준 에러 | 화면      |

#### 리다이렉션 기호

| 기호   | 의미                      | 예시                     |
| ------ | ------------------------- | ------------------------ |
| `>`    | 출력을 파일로 (덮어쓰기)  | `echo hello > file.txt`  |
| `>>`   | 출력을 파일로 (이어쓰기)  | `echo hello >> file.txt` |
| `2>`   | 에러를 파일로             | `cmd 2> error.log`       |
| `2>&1` | 에러를 출력과 같은 곳으로 | `cmd > all.log 2>&1`     |
| `&>`   | 출력+에러 모두 파일로     | `cmd &> all.log`         |
| `<`    | 파일을 입력으로           | `sort < names.txt`       |

#### 실습 예시 (컨테이너 안에서)

```bash
# 1) stdout만 파일로
echo "hello" > /tmp/test.txt
cat /tmp/test.txt
# 결과: hello

# 2) 이어쓰기
echo "world" >> /tmp/test.txt
cat /tmp/test.txt
# 결과: hello
#       world

# 3) 덮어쓰기 vs 이어쓰기 차이
echo "new" > /tmp/test.txt
cat /tmp/test.txt
# 결과: new  (이전 내용 사라짐)

# 4) stderr 리다이렉션
ls /없는경로 2> /tmp/error.log
cat /tmp/error.log
# 결과: ls: cannot access '/없는경로': No such file or directory

# 5) stdout + stderr 모두 한 파일로
ls / /없는경로 > /tmp/all.log 2>&1
cat /tmp/all.log
# 결과: 정상 출력 + 에러 메시지 모두 포함

# 6) /dev/null - 출력 버리기 (쓰레기통)
ls / > /dev/null 2>&1
# 결과: 아무것도 안 나옴 (모두 버림)
```

#### crontab에서 리다이렉션이 중요한 이유

cron은 터미널이 없어서 출력을 볼 수 없다.
리다이렉션으로 로그 파일에 기록해야 결과를 확인할 수 있다.

```
# 로그를 남기는 경우
* * * * * /scripts/hello.sh >> /var/log/cron.log 2>&1

# 로그가 필요 없는 경우 (조용히 실행)
* * * * * /scripts/hello.sh > /dev/null 2>&1
```

### 실습 예제 구성

| 스크립트     | 주기     | 설명                        |
| ------------ | -------- | --------------------------- |
| `hello.sh`   | 매분     | "Hello Cron!" 출력          |
| `cleanup.sh` | 5분마다  | /tmp 파일 목록 확인 후 정리 |
| `health.sh`  | 10분마다 | 디스크 사용량 기록          |

### 실행 명령어

#### 빌드 (실습1)

```bash
docker build -t cron-tutorial .
```

#### 실행 (실습2)

```bash
docker run -d --name cron-test cron-tutorial
```

#### 컨테이너 진입 (실습3)

```bash
docker exec -it cron-test bash
```

### 컨테이너 안에서 crontab 다루기 (실습 아님)

```bash
# 현재 등록된 작업 확인
crontab -l

# 작업 수정 (vi 에디터)
crontab -e

# 작업 전체 삭제
crontab -r
```

### 크론 등록 (실습4)

```
crontab -e

*/1 * * * * /scripts/hello.sh >> /var/log/cron.log
```

### tail 해보기 (실습5)

```
tail -f /var/log/cron.log
```

### 새로운 윈도우 터미널 열기 (실습6)

git bash일때

```
docker exec cron-test tail -f //var/log/cron.log
```

cmd 일때

```
docker exec cron-test tail -f /var/log/cron.log
```

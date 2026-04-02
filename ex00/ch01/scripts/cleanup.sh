#!/bin/bash
# cleanup.sh - /tmp 디렉토리를 정리하는 스크립트

echo "========== CLEANUP =========="
# date 명령어로 현재 시간 출력 ('+포맷'으로 형식 지정)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] /tmp 정리 시작"

# ls 명령어로 /tmp 안의 파일 목록 출력
echo "현재 /tmp 파일 목록:"
ls /tmp

# rm -f : 파일 강제 삭제 (-f는 에러 무시)
# /tmp/* : /tmp 안의 모든 파일
rm -f /tmp/*
echo "정리 완료!"
echo "============================="

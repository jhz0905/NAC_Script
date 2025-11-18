@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ===============================================
rem  Security Policy Auto-Check & Apply Script
rem  (for Local Windows Accounts)
rem ===============================================

rem 관리자 권한 확인
net session >nul 2>&1 || (
  exit /b 1
)

rem ===== 목표 값 설정 =====
set "MAXPWAGE=90"                 rem 최대 암호 사용기간(일)
set "MINPWAGE=1"                  rem 최소 암호 사용기간(일)
set "PW_HISTORY=3"                rem 암호 기억 개수
set "LOCK_THRESH=5"               rem 잠금 임계값 (5회 실패시)
set "LOCK_DURATION_MIN=10"        rem 잠금 지속 시간(분)
set "LOCK_WINDOW_MIN=10"          rem 관찰 창(분)

rem ===== 실제 정책 적용 =====
net accounts /MAXPWAGE:!MAXPWAGE! /MINPWAGE:!MINPWAGE! /UNIQUEPW:!PW_HISTORY! >nul 2>&1

net accounts ^
  /LOCKOUTTHRESHOLD:!LOCK_THRESH! ^
  /LOCKOUTDURATION:!LOCK_DURATION_MIN! ^
  /LOCKOUTWINDOW:!LOCK_WINDOW_MIN! >nul 2>&1

endlocal
exit /b 0

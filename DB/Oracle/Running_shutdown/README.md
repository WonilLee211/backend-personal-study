# 오라의 기동과 정지

기동 시 어떤 파일을 어떻게 사용하는지, 의존 관계가 어떻게 되어 있는지 학습한다.

각종 파일이 손상되는 장애에 대응을 위해 내부 동작에 대한 지식을 학습한다.

멀티프로세스 구조의 유닉스용 오라클에 초점을 맞춘다.

## 오라클의 기동/정지의 개요

기동과 정지는 오라클의 시작과 끝을 의미한다.

### 오라클의 기동 상태

1. **OPEN**
    - 데이터 처리를 할 수 있는 상태
    - SQL을 처리할 수 있는 상태
2. **MOUNT**
    - 데이터 파일 등에 접근할 수 있는 상태
    - 컨트롤 파일을 읽은 상태
    - `데이터 파일`이나 `리두(redo) 파일`을 읽어서 오라클이 내부적으로 사용하는 정보와 비교하여 문제가 있는지 확인 후에 OPEN 상태로 전환된다.
        - `데이터 파일` : 데이터를 보관하고 있는 파일
        - `리두(redo) 파일` : 데이터 변경 이력을 보관하는 파일
3. **NOMOUNT**
    - 백그라운드 프로세스와 공유메모리가 존재하는 상태
    - `컨트롤 파일`을 읽은 후 MOUNT 상태로 전환된다.
        - `컨트롤 파일` : 데이터베이스 구성 정보가 적혀 있는 파일로서, 데이터베이스의 파일 경로를 알 수 있음
4. **SHUTDWN**
    - 정지 상태
    - 파라미터를 읽어와서 백그라운드 프로세스를 시동시키고 공유메모리를 할당한다. 이후 NOMOUNT 상태로 전환된다.

## 인스턴스, 데이터베이스, 그리고 주요 파일의 구성

### 인스턴스

백그라운드 프로세스 + 공유메모리로 구성되어 데이터 베이스를 관리하는 것

NOMOUNT 상태는 인스턴스가 기동한 상태를 의미한다.

> ### RAC(Real Application Cluster)
> 
> - 기존 구성은 인스턴스와 데이터베이스가 일대일 대응
> - RAC는 하나의 데이터베이스에 두 개의 인스턴스가 대응한다.
> - 고가용성을 위해 하나의 서버가 정지하더라도 failover를 통해 서비스가 멈추지않도록 하기 위한 구성


### 주요 파일의 구성

1. `$ORACLE_HOME/bin/`
    - sqlplus
        - 데이터베이스와 상호작용하고 sql 문을 실행하는 데 사용
    - sqlldr
        - sql*Loader 유틸리티로, 데이터베이스를 로드하는데 사용
    - exp
        - 데이터베이스를 내보내는 export 유틸리티로, 데이터베이스를 백업하거나 데이터를 이동하는 데 사용
    - imp
        - 데이터베이스를 가져오는 import유틸리티로, export로 내보낸 데이터를 다시 데이터베이스로 가져오는 데 사용
    - tnsping
        - TNS 서비스에 대한 응답 시간을 테스트하는 데 사용하는 유틸리티
    - lsnctl
        - 리스너를 제어하는 데 사용하는 유틸리티로, 리스너를 시작하고 중지하거나 상태를 확인하는 데 사용
    - dbca
        - 데이터베이스 구성 어시스턴스로, 데이터베이스 생성 및 구성을 도와주는 그래픽 도구
    - netca
        - 네트워크 구성 어시스턴스로, 데이터베이스 네트워크 설정을 도와주는 그래픽 도구
    - srvctl
        - 클러스터 데이터베이스와 서비스를 관리하는 데 사용하는 유틸리티
    - oerr
        - 오라클 에러 메세지를 조회하는 데 사용하는 유틸리티
    - 등등

2. `$ORACLE_HOME/dbs/`
    - datafile/
        - 실제 데이터가 저장되는 디렉토리
        - DB_NAME.dbf 형식
    - controlfile/
        - 데이터베이스 구조와 상태 정보를 포함하는 중요한 컨트롤 파일이 저장되는 디렉토리
        - control01.ctl 형식
    - redologfile/
        - 데이터베이스에서 발생하는 변경들을 기록한 파일이 저장되는 디렉토리
        - redo01.log 형식
    - temp directory
        - 임시 테이블 스페이스와 같이 임시적으로 사용하는 데이터 파일이 위치하는 디렉토리
        - temp01.dbf 형식
    - backupfile/
        - 데이터베이스 백업 파일들이 위치하는 디렉토리

## 기동처리의 흐름과 내부 동작

### SHUTDOWN에서 NOMOUNT로 전환

1. 환경 변수의 설정 수행
2. `sqlplus /nolog`
    - 데이터베이스를 기동하기 위해 SQL*Plus 시작
    - `/nolog` : 기동할 때 옵션 중 하나로, 로그인하지 않고도 SQL*Plus 사용 가능
3. `connect / as sysdba`
    - SQL*Plus를 기동할 수 있는 관리자 계정으로 전환
4. `startup nomount` 명령어 선언
    - 일반적으로 `startup` 명령어 선언
    - 내부적으로 환경 변수 `$ORACLE_HOME`과 `$ORACLE_SID`를 토대로 초기화 파라미터 파일을 찾아 읽음
    - 파라미터를 읽어와서 백그라운드 프로세스 기동시키고 공유 메모리 할당
    - SHUTDOWN 상태에서 NOMOUNT 상태로 전환
5. `ps` 
    - 백그라운드 프로세스 리스트 확인

### NOMOUNT로부터 MOUNT로 전환

1. `alter databse mount;`
    - 컨트롤 파일을 읽어와서 MOUNT 상태로 전환됨
    - 리두 로그 파일이나 데이터 파일 위치를 파악

### MOUNT에서 OPEN으로 전환

1. `alter database open;`
    - 데이터파일을 열어서 간단한 점검과 백그라운드 프로세스 기동

> 일반적으로 `startup` 명령어로 OPEN 상태가 됨

<br>

### 파일의 사용순서

초기 파라미터 파일 -> 컨트롤 파일 -> 데이터 파일

<br>

> ### 여러 버전의 오라클 설치
> 오라클 프로그램은 `$ORACLE_HOME/bin`에 설치되기 떄문에 `$ORACLE_HOME`을 분리할 필요가 있음
>
> ### ifile과 spfile
> 현업에서 초기 파라미터 파일 내부에 `ifile`이라는 파라미터를 이용하여 다른 곳에 파라미터 파일을 호출하도록 설정하는 경우가 있음
> 오라클 10g버전부터는 기존 초기화 파라미터 파일(init.ora)을 대체하는 서버 파라미터 파일(spfile)을 기본적으로 사용


## SHUTDOWN 옵션

`shutdown`
- 접속 종료를 기다린다.

`shutdown transactional`
- 트랜잭션이 끝나는 것을 기다린다.
- 트랜잭셔니 끝나면 접속을 끊어 버린다.

`shutdown immediate`
- 커밋하지 않은 데이터는 없어진다.

`shutdown abort`
- 커밋하지 않은 데이터는 없어지고, 변경 데이터를 데이터 파일에 기록하지 않는다.

## 인스턴스 복구

shutdown 이 후 다음 기동 시, 데이터를 복구한다.

데이터 파일에 작성되지 않는 파일은 리두 로그 파일을 이용하여 데이터를 사용해서 복구한다.

리두 로그 파일을 이용하여 오래된 데이터 파일을 최신의 것으로 변경할 수 있음

일반적인 재기동 상황이나 OS 장애 또는 하드웨어 장애로 인한 비정상적인 종료에도 인스턴스 복구는 오라클에서 자동으로 수행해준다.
- 위 상황에서는 캐시의 변경된 데이터만 손실된 것

데이터 파일이 존재하지 않는 등의 파일에 관한 장애는 본격적인 복구 작업을 진행해야 한다.

## 수작업으로 데이터베이스 생성하기

1. 초기화 파라미터 파일 작성
    - DB명, 인스턴스명, 컨트롤러 파일 경로 변경

```ora
<!-- init.ora -->
db_name=test

<!-- 컨트롤 파일 위치의 정보와 해당 데이터베이스가 최대로 열 수 있는 파일의 개수에 관한 정보 -->
control_files = (/home1/test_db/ora_control1.dbf, /home1/test_db/ora_control2.dbf)
db_file = 80

db_block_size = 8192
db_file_multiblock_read_count = 8
db_cache_size = 80M
shared_pool_size = 50000000
log_buffer = 1048576

undo_management = AUTO
Oundo_tablespace = TS_undo

<!-- 리두 로그의 아카이브 위치나 각종 에러 로그의 장소를 지정 -->
log_achive_dest = /home1/test_db/arch
user_dump_dest = /home1/test_db/log/udump
background_dump_dest = /home1/test_db/log/bdump
core_dump_dest = /home1/test_db/log/cdump
```

2. `startup numount`
    - 초기화 파라미터 파일만 있기 때문에 nomount만 가능하다
3. 컨트롤 파일, 데이터 파일, 리두 로그 파일 생성

```sql

create database test
-- 데이터베이스 관리 계정 생성
user sys identified by king825
user sys identified by queen549

-- 로그 파일 설정 시작
logfile 
-- 데이터 변경 사항 기록 함에 사용하는 3 개 로그 그룹 
group 1 ('%ORACLE_HOME%\database\redo01.log') SIZE 50M,
group 2 ('%ORACLE_HOME%\database\redo02.log') SIZE 50M,
group 3 ('%ORACLE_HOME%\database\redo03.log') SIZE 50M
-- 최대 로그 그룹 개수
maxlogfiles 6
-- 하나의 로그 그룹에 속할 수 있는 최대 맴버 수
maxlogmembers 2
-- 데이터 파일 최대 개수
maxdatafiles 80
-- 데이터베이스 문자 집합
character set JA16SJIS
-- 아카이브 로그 모드 활성화 : 데이터베이스의 모든 로그를 보관하고 백업에 사용. 데이터 손실 최소화에 도움을 줌
archivelog
-- 시스템 테이블스페이스의 데이터 파일 경로와 크기 설정
datafile '/home1/test_db/system.dbf' size 300M
-- 보조시스템 테이블스페이스의 데이터 파일 경로와 크기 설정
sysaux datafile '/home1/test_db/sysaux.dbf' 50M
-- 기본 임시 테이블스페이스 데이터파일 경로와 크기 설정
default temporary tablespace TS_temp tempfile '/home1/test_db/TS_temp01.dbf' size 20M
-- 롤백 테이블스페이스의 데이터 파일 경로와 크기 설정. 트랜잭션 롤백에 사용됨
undo tablespace TS_undo datafile '/home1/test_db/TS_undo01.dbf' size 20M;
```

# ubuntu cli

1. `cd` : 디렉토리를 변경합니다.
    - `cd /home/user/Desktop` : 사용자의 데스크탑 디렉토리로 이동합니다.

2. `ls` : 현재 디렉토리에 있는 파일과 폴더를 나열합니다.
    - ls -l # 상세 정보를 포함하여 파일 및 폴더를 나열합니다.

3. `mkdir` : 새로운 디렉토리를 생성합니다.
4. `rmdir` : 디렉토리를 삭제합니다.
5. `touch` : 빈 파일을 만듭니다.
    - `touch myfile.txt` : "myfile.txt"라는 이름의 빈 파일을 생성합니다.

6. `cp` : 파일 또는 디렉토리를 복사합니다.
    - `cp file1.txt file2.txt` : "file1.txt"를 "file2.txt"로 복사합니다.

7. `mv` : 파일 또는 디렉토리를 이동하거나 이름을 변경합니다.
    -` mv file1.txt myfolder/` : "file1.txt"를 "myfolder" 디렉토리로 이동합니다.

8. `rm` : 파일을 삭제합니다.

9. `sudo` : 관리자 권한으로 명령어를 실행합니다.
10. `apt-get` : 패키지를 설치, 업데이트, 삭제하는데 사용됩니다.

    <details>
    <summary>apt-get vs apt</summary>
    <div markdown="1">

    안녕
    사용자가 일반 리눅스 사용자라면 apt를 사용하는 것이 효과적이고, 패키지 관리의 세밀한 옵션을 주로 사용하는 스크립트 작업에서는 apt-get을 사용하는 것이 좋습니다.

    - `apt-get install firefox` : "firefox"라는 이름의 웹 브라우저를 설치합니다

    - `apt install` : `apt-get install` : 패키지 목록
    - `apt remove` : `apt-get remove` :	패키지 삭제
    - `apt purge` :	`apt-get purge` : 패키지와 관련 설정 제거
    - `apt update` : `apt-get update` : 레파지토리 인덱스 갱신
    - `apt upgrade` : `apt-get upgrade` : 업그레이드 가능한 모든 패키지 업그레이드
    - `apt autoremove`: `apt-get autoremove` : 불필요한 패키지 제거
    - `apt full-upgrade` : `apt-get dist-upgrade` : 의존성 고려한 패키지 업그레이드
    - `apt search` : `apt-cache search` : 프로그램 검색
    - `apt show` : `apt-cache show` : 패키지 상세 정보 출력

    </div>
    </details>

11. `git clone` : Git 저장소에서 코드를 다운로드합니다.
12. `chmod` : 파일 또는 디렉토리의 권한을 변경합니다.
13. `scp` : 로컬 머신과 원격 서버 사이에서 파일을 전송합니다.
14. `ssh` : 원격 서버에 로그인합니다.
15. `rsync` : 로컬 머신과 원격 서버 사이에서 파일을 동기화합니다.
16. `systemctl` : 시스템 서비스를 관리합니다.
17. `nginx` : 웹 서버를 설정하고 관리합니다.

    <details>
    <summary>nginx 예시</summary>
    <div markdown="1">

    안녕
    사용자가 일반 리눅스 사용자라면 apt를 사용하는 것이 효과적이고, 패키지 관리의 세밀한 옵션을 주로 사용하는 스크립트 작업에서는 apt-get을 사용하는 것이 좋습니다.

    - `apt-get install firefox` : "firefox"라는 이름의 웹 브라우저를 설치합니다

    - `apt install` : `apt-get install` : 패키지 목록
    - `apt remove` : `apt-get remove` :	패키지 삭제
    - `apt purge` :	`apt-get purge` : 패키지와 관련 설정 제거
    - `apt update` : `apt-get update` : 레파지토리 인덱스 갱신
    - `apt upgrade` : `apt-get upgrade` : 업그레이드 가능한 모든 패키지 업그레이드
    - `apt autoremove`: `apt-get autoremove` : 불필요한 패키지 제거
    - `apt full-upgrade` : `apt-get dist-upgrade` : 의존성 고려한 패키지 업그레이드
    - `apt search` : `apt-cache search` : 프로그램 검색
    - `apt show` : `apt-cache show` : 패키지 상세 정보 출력

    </div>
    </details>

18. `ufw` : 방화벽 규칙을 관리합니다.

    <details>
    <summary>ufw 예시</summary>
    <div markdown="1">
    
    - `ufw enable` : 방화벽을 활성화합니다.

        - `sudo ufw enable`

    - `ufw disable` : 방화벽을 비활성화합니다.

        - `sudo ufw disable`

    - `ufw status` : 방화벽 상태를 확인합니다.

        - `sudo ufw status`

    - `ufw allow` : 포트 및 프로토콜을 허용합니다.

        - `sudo ufw allow 80/tcp` : 80번 포트와 TCP 프로토콜을 허용합니다.

    - `ufw deny` : 포트 및 프로토콜을 차단합니다.

        - `sudo ufw deny 22/tcp` : 22번 포트와 TCP 프로토콜을 차단합니다.

    - `ufw delete` : ufw 규칙을 삭제합니다.

        - `sudo ufw delete allow 80/tcp` : 80번 포트와 TCP 프로토콜을 허용하는 ufw 규칙을 삭제합니다.

    - `ufw reset` : ufw 설정을 초기화합니다.

        - `sudo ufw reset`

    - `ufw limit` : 연결 제한을 설정합니다.

        - sudo ufw limit ssh # SSH 연결을 3회로 제한합니다.

    - `ufw logging` : 로그 기록을 설정합니다.

        - `sudo ufw logging on` # ufw 로그 기록을 활성화합니다.

    - `ufw app list` : ufw 애플리케이션 리스트를 확인합니다.
        - `sudo ufw app list` : ufw 애플리케이션 리스트를 출력합니다.

    </div>
    </details>

    
19. `docker` : 컨테이너를 생성, 실행, 관리합니다




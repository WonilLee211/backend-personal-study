# 2.1 Sequence

- 자동 순번을 반환하는 데이터베이스 객체
- MySQL은 지원하지 않음
- SEQ_USER, nextval, SEQ_USER.currval, SEQ_USER.setval 등으로 사용
- 현업에서 xxx-1과 같은 값을 넣어야 할 때 자주 사용함


```SQL

    CREATE SEQUENCE [스키마명.]시퀀스명
    INCREMENT BY 증감숫자
    START WITH 시작 숫자
    NOINVALUE | MINVALUE 최소값
    NOMAXVALUE | MAXVALUE 최대값
    NOCYCLE | CYCLE
    NOCACHE | CACHE;

```

# 2.2 FUNCTION

- 우리가 알고 있는 바로 그 함수
- RETURN값 필수
- RETURN값은 하나

```SQL
    CREATE FUNCTION '함수명' (
        파라미터
    ) RETURN 반환할 데이터타입
    BEGIN
        수행할 쿼리
        REUTRN 반환할 값
    END

```


## MySQL에서 Sequence를 어떻게 구현할까?

```SQL
    CREATE TABLE 'TBL_SEQUENCE' (
        'SQUENCE_NAME' VARCHAR(50) NOT NULL,
        'CURRENT_VALUE' BIGINT NOT NULL DEFAULT 0,
        'INCREMENT' BIGINT NOT NULL DEFAULT 1,
        PRIMARRY KEY ('SEQUENCE_NAME')
    );
    -- 초기값 주입
    INSERT INTO 'TBL_SEQUENCE' VALUES('userSeq', 0, 1);
```

- userSeq를 생성하는데 초기값 0, 1씩 증가하도록 설정


<br>

## 함수 1 현재값 조회 함수

- DELIMITER
    - 구분자. 
    - 함수의 끝을 표현해주는 역할.
    - 어디서 어디까지 함수인지 표현함

- 입력받은 `_seqName`과 일치하는 튜플에 대해 `CURRENT_VALUE`를 `rtnVal`에 저장

```sql
    -- 조회 함수
    DROP FUNCTION IF EXISTS 'CURRVAL';
    DELIMITER;; 

    CREATE FUNCTION 'CURRVAL' (_seqName VARCHAR(50)) RETURNS BIGINT
    BEGIN
        DECLARE rtnVal BIGINT; -- 변수 생성
        SET rtnVal = 0; -- 기존에 있는 변수 사용 시 SET
        -- TABLE에서 가져올 경우 SELECT
        SELECT CURRENT_VALUE INTO rtnVal 
        FROM TBL_SEQUENCE
        WHERE SEQUENCE_NAME = _seqName;

        RETURN rtnVal;
    END
    ;;
    DELIMITER; -- 함수의 끝
```

## 함수 2 특정 값 수정 함수

- `SET CURRENT_VALUE = CURRENT_VALUE + INCREMENT`
    - 입력받은 `_seqName`과 일치하는 튜플에 대해서 현재값을 증가시킴

```sql
    -- UPDATE 함수
    DROP FUNCTION IF EXISTS 'NEXTVAL';
    DELIMITER;;
    CREATE FUNCTION 'NEXTVAL'(_seqName VARCHAR(50)) RETURN BIGINT
    BEGIN
        UPDATE TBL_SEQUENCE
        SET CURRENT_VALUE = CURRENT_VALUE + INCREMENT
        WHERE SEQUENCE_NAME = _seqName;

        RETURN CURRVAL(_seqName);
    END
    ;;
    DELIMITER;
```

## 함수 3 초기화 함수

- _seqName에 해당하는 튜플의 `CURRENT_VALUE`를 `_setVal`로 변경 후 해당 값 return


```sql
    --초기화 함수
    DROP FUNCTION IF EXISTS 'SETVAL';
    DELIMITER;;
    -- _seqName을 _setVal로 초기화 하겠다.
    CREATE FUNCTION 'SETVAL'(_seqName VARCHAR(50), _setVal BIGINT) RETURN BIGINT 
    BEGIN
        UPDATE TBL_SEQUENCE
        SET CURRENT_VALUE = _setVal
        WHERE SEQUENCE_NAME = _seqName;

        RETURN CURRVAL(_seqName); --function에서 function을 호출
    END
    ;;
    DELIMITER;

```

## 함수 실행해보기

```sql
SELECT CURRVAL('userSeq');
SELECT SETVAL('userSeq', 0);
SELECT CURRVAL('userSeq');
SELECT NEXTVAL('userSeq');

SELECT * FROM TBL_SEQUENCE;
```
---

# 4. 요구사항에 맞는 FUCNTION 만들기

- 테이블마다 데이터 생성
- 쿼리에서도 `sha2('1111', 256)`와 같이 string을 특정 알고리즘에 맞게 암호화 가능


```SQL
    INSERT INTO TBL_USER_KR(USER_SEQ, USER_ID, USER_PASS, USER_NAME, USER_EMAIL)
    VALUES (NEXTVAL('userSeq'), 'userKr1', sha2('1111', 256), '유저명1', 'userKr1@gmail.com');

    INSERT INTO TBL_USER_EN(USER_SEQ, USER_ID, USER_PASS, USER_NAME, USER_EMAIL)
    VALUES (NEXTVAL('userSeq'), 'userEn2', sha2('1111', 256), 'username2', 'userEn2@gmail.com');
    
    INSERT INTO TBL_BOARD(USER_SEQ, BOARD_TITLE, BOARD_CONTENTS)
    VALUES (1, '첫번째 글 제목', '첫번째 게시판 글 내용');
    INSERT INTO TBL_BOARD(USER_SEQ, BOARD_TITLE, BOARD_CONTENTS)
    VALUES (2, '두번째 글 제목', '두번째 게시판 글 내용');
    INSERT INTO TBL_BOARD(USER_SEQ, BOARD_TITLE, BOARD_CONTENTS)
    VALUES (3, '세번째 글 제목', '세번째 게시판 글 내용');
    
```


## 요구사항 1
- 작성한 글 조회시 항상 작성자 아이디, 이름 함께 보여줘야 함
- _userSeq를 입력받아 해당 사용자의 이름을 반환하는 MySQL 함수를 생성

```SQL
DROP FUNCTION IF EXISTS `FN_GET_USER_NAME`;
DELIMITER ;; -- 구분자를 변경하는 구문입니다. 이 구문을 통해 MySQL에서 세미콜론(;)을 문장의 끝이 아닌 다른 용도로 사용할 수 있게 됩니다.

--_userSeq라는 매개변수를 받고, VARCHAR(40) 타입의 사용자 이름을 반환
CREATE FUNCTION `FN_GET_USER_NAME`(_userSeq BIGINT) RETURNS VARCHAR(40)

-- 함수의 본문
BEGIN
-- 변수 krUserCnt와 _userName을 선언하고 초기화
DECLARE krUserCnt TINYINT;
DECLARE _userName VARCHAR(40);
    -- 한국어 사용자 테이블에서 _userSeq와 일치하는 레코드 수를 krUserCnt 변수에 저장
	SELECT COUNT(*) INTO krUserCnt
    FROM TBL_USER_KR 
    WHERE USER_SEQ = _userSeq;

	-- IF 구문을 사용하여 krUserCnt 값이 0보다 큰 경우
    IF krUserCnt > 0 THEN
        -- 한국어 사용자 테이블에서 해당 사용자의 이름을 _userName 변수에 저장
		SELECT USER_NAME INTO _userName
		FROM TBL_USER_KR
		WHERE USER_SEQ = _userSeq;
    -- 한국어 사용자 테이블에 일치하는 레코드가 없는 경우
	ELSE
        -- 영어 사용자 테이블에서 해당 사용자의 이름을 _userName 변수에 저장
		SELECT USER_NAME INTO _userName
		FROM TBL_USER_EN
		WHERE USER_SEQ = _userSeq;
	END IF;
RETURN _userName;

END
;;

DELIMITER ;

```

- test query날려보기

```sql
SELECT FN_GET_USER_NAME (1) as USER_NAME;

SELECT FN_GET_USER_NAME (2) as USER_NAME;

SELECT *, FN_GET_USER_NAME (USER_SEQ) as USER_NAME FROM TBL_BOARD;
```

### 주의

- 쿼리가 두번 날라가기 때문에 성능은 무시하고 기능만 본다고 생각하자!
- join을 통해 수정이 필요하다.

## 요구사항 2

- 회원정보 조회시 회원이 작성한 글 수를 항상 함께 보여줘야 함

```sql
-- 해당 사용자의 게시물 개수를 반환하는 MySQL 함수
DROP FUNCTION IF EXISTS `FN_GET_BOARD_CNT`;
DELIMITER ;;
CREATE FUNCTION `FN_GET_BOARD_CNT`(_userSeq BIGINT) RETURNS VARCHAR(40)

BEGIN
DECLARE _boardCnt INTEGER;
    SELECT COUNT(*) INTO _boardCnt
    FROM TBL_BOARD
    WHERE USER_SEQ = _userSeq;
RETURN _boardCnt;
END
;;
DELIMITER ;
```

- test query

```sql
SELECT FN_GET_BOARD_CNT(1) AS BOARD_CNT;

SELECT *, FN_GET_BOARD_CNT(USER_SEQ) AS BOARD_CNT FROM TBL_USER_KR;

SELECT *, FN_GET_BOARD_CNT(USER_SEQ) AS BOARD_CNT FROM TBL_USER_EN;
```


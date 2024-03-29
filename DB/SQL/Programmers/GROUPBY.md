# programmers group by 문제

## 목차

1. [자동차-대여-기록에서-대여중--대여-가능-여부-구분하기](#1-자동차-대여-기록에서-대여중--대여-가능-여부-구분하기)
2. [식품분류별 가장 비싼 식품의 정보 조회하기](#2-식품분류별-가장-비싼-식품의-정보-조회하기)
3. [대여 횟수가 많은 자동차들의 월별 대여 횟수 구하기](#3-대여-횟수가-많은-자동차들의-월별-대여-횟수-구하기)
4. [거래완료 총액이 70만원 이상인 회원 정보 구하기](#4-거래완료-총액이-70만원-이상인-회원-정보-구하기)
5. [년, 월, 성별 별 상품 구매 회원 수 구하기](#5-년-월-성별-별-상품-구매-회원-수-구하기)

---

# 1. 자동차 대여 기록에서 대여중 / 대여 가능 여부 구분하기

- CAR_RENTAL_COMPANY_RENTAL_HISTORY 테이블에서 2022년 10월 16일에 대여 중인 자동차인 경우 '대여중' 이라고 표시하고, 대여 중이지 않은 자동차인 경우 '대여 가능'을 표시하는 컬럼(컬럼명: AVAILABILITY)을 추가하여 자동차 ID와 AVAILABILITY 리스트를 출력하는 SQL문을 작성해주세요. 이때 반납 날짜가 2022년 10월 16일인 경우에도 '대여중'으로 표시해주시고 결과는 자동차 ID를 기준으로 내림차순 정렬해주세요.

```SQL
SELECT
    DISTINCT
    CAR_ID,
    CASE
        WHEN
            CAR_ID IN (
                SELECT CAR_ID FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
                WHERE START_DATE <= '2022-10-16' AND END_DATE >= '2022-10-16'
                GROUP BY CAR_ID
            )
        THEN '대여중'
        ELSE '대여 가능'
        
    END AVAILABILITY
FROM
    CAR_RENTAL_COMPANY_RENTAL_HISTORY AS C
ORDER BY CAR_ID DESC
;

```
<br>

### 코드 최적화

```sql
SELECT
    CR.CAR_ID,
    CASE
        WHEN RH.CAR_ID IS NOT NULL THEN '대여중'
        ELSE '대여 가능'
    END AS AVAILABILITY
FROM
    CAR_RENTAL_COMPANY AS CR
LEFT JOIN
    CAR_RENTAL_COMPANY_RENTAL_HISTORY AS RH
    ON CR.CAR_ID = RH.CAR_ID
    AND RH.START_DATE <= '2022-10-16'
    AND RH.END_DATE >= '2022-10-16'
ORDER BY
    CR.CAR_ID DESC;
```

# 2. 식품분류별 가장 비싼 식품의 정보 조회하기

- `FOOD_PRODUCT` 테이블에서 식품분류별로 가격이 제일 비싼 식품의 분류, 가격, 이름을 조회하는 SQL문을 작성해주세요. 이때 식품분류가 '과자', '국', '김치', '식용유'인 경우만 출력시켜 주시고 결과는 식품 가격을 기준으로 내림차순 정렬해주세요.

```sql
SELECT F2.CATEGORY, F2.MAX_PRICE, F1.PRODUCT_NAME
FROM FOOD_PRODUCT F1
LEFT JOIN
(
    SELECT CATEGORY, MAX(PRICE) AS MAX_PRICE
    FROM FOOD_PRODUCT
    GROUP BY CATEGORY
    HAVING CATEGORY IN ('과자', '국', '식용유', '김치')
) F2
ON F1.CATEGORY = F2. CATEGORY  AND F1.PRICE = F2.MAX_PRICE
WHERE F2.CATEGORY IS NOT NULL
ORDER BY F2.MAX_PRICE DESC;
```

# 3. 대여 횟수가 많은 자동차들의 월별 대여 횟수 구하기

- CAR_RENTAL_COMPANY_RENTAL_HISTORY 테이블에서 대여 시작일을 기준으로 2022년 8월부터 2022년 10월까지 총 대여 횟수가 5회 이상인 자동차들에 대해서 해당 기간 동안의 월별 자동차 ID 별 총 대여 횟수(컬럼명: RECORDS) 리스트를 출력하는 SQL문을 작성해주세요. 결과는 월을 기준으로 오름차순 정렬하고, 월이 같다면 자동차 ID를 기준으로 내림차순 정렬해주세요. 특정 월의 총 대여 횟수가 0인 경우에는 결과에서 제외해주세요.

```sql
SELECT
    MONTH(START_DATE) AS MONTH,
    CAR_ID,
    COUNT(HISTORY_ID) AS RECORDS
FROM 
    CAR_RENTAL_COMPANY_RENTAL_HISTORY

WHERE 
    START_DATE BETWEEN '2022-08-01' AND '2022-10-31' 
    AND CAR_ID IN (
        SELECT 
            CAR_ID
        FROM 
            CAR_RENTAL_COMPANY_RENTAL_HISTORY
        WHERE START_DATE BETWEEN '2022-08-01' AND '2022-10-31'
        GROUP BY
            CAR_ID
        HAVING COUNT(*) >= 5
   )
GROUP BY
    MONTH,
    CAR_ID
HAVING COUNT(*) > 0
ORDER BY
    MONTH, CAR_ID DESC
;
```
<br>

### 쿼리 최적화

1. 중첩된 서브쿼리를 사용하는 대신 WITH 절 (또는 CTE, Common Table Expressions)을 사용하여 더 명확하고 효율적인 쿼리를 작성

2. 중복된 'WHERE' 조건을 줄이기

```sql

WITH CAR_RENTAL_FILTER AS (
    SELECT 
        CAR_ID
    FROM 
        CAR_RENTAL_COMPANY_RENTAL_HISTORY
    WHERE 
        START_DATE BETWEEN '2022-08-01' AND '2022-10-31'
    GROUP BY
        CAR_ID
    HAVING COUNT(*) >= 5
)

SELECT
    MONTH(START_DATE) AS MONTH,
    CAR_ID,
    COUNT(HISTORY_ID) AS RECORDS
FROM 
    CAR_RENTAL_COMPANY_RENTAL_HISTORY
WHERE 
    START_DATE BETWEEN '2022-08-01' AND '2022-10-31' 
    AND CAR_ID IN (SELECT CAR_ID FROM CAR_RENTAL_FILTER)
GROUP BY
    MONTH,
    CAR_ID
HAVING COUNT(*) > 0
ORDER BY
    MONTH, CAR_ID DESC;

```

# 4. 거래완료 총액이 70만원 이상인 회원 정보 구하기

- USED_GOODS_BOARD와 USED_GOODS_USER 테이블에서 완료된 중고 거래의 총금액이 70만 원 이상인 사람의 회원 ID, 닉네임, 총거래금액을 조회하는 SQL문을 작성해주세요. 결과는 총거래금액을 기준으로 오름차순 정렬해주세요.

```sql
SELECT
    USER_ID,
    NICKNAME,
    U2.TOTAL_SALES
FROM
    USED_GOODS_USER U1
INNER JOIN
    (
        SELECT 
            WRITER_ID,
            SUM(PRICE) AS TOTAL_SALES
        FROM
            USED_GOODS_BOARD
        WHERE STATUS = 'DONE'
        GROUP BY 
            WRITER_ID
    ) U2
ON 
    U1.USER_ID = U2.WRITER_ID
WHERE TOTAL_SALES >= 700000
ORDER BY
    U2.TOTAL_SALES
;

```

### 배운 점

- WHERE 절과 HAVING 절의 차이

WHERE 절은 USED_GOODS_BOARD 테이블에서 STATUS = 'DONE'인 행만 그룹화 전에 먼저 필터링합니다. 따라서 SUM(PRICE)는 STATUS = 'DONE'인 행의 PRICE 합계만을 계산하게 됩니다.

<br>

```sql
SELECT
    USER_ID,
    NICKNAME,
    U2.TOTAL_SALES
FROM
    USED_GOODS_USER U1
INNER JOIN
    (
        SELECT 
            WRITER_ID,
            SUM(PRICE) AS TOTAL_SALES
        FROM
            USED_GOODS_BOARD
        GROUP BY 
            WRITER_ID
        HAVING
            STATUS = 'DONE'
    ) U2
ON 
    U1.USER_ID = U2.WRITER_ID
WHERE TOTAL_SALES >= 700000
ORDER BY
    U2.TOTAL_SALES
;

```
HAVING 절은 그룹화된 결과에 대한 필터링을 수행합니다. 이 쿼리에서는 STATUS = 'DONE' 조건을 만족하는 그룹만을 선택하려고 시도합니다. 그러나 STATUS가 그룹화 기준(GROUP BY)에 포함되지 않았으므로, 이 쿼리는 에러를 발생시킬 것입니다.

# 5. 년, 월, 성별 별 상품 구매 회원 수 구하기

- USER_INFO 테이블과 ONLINE_SALE 테이블에서 년, 월, 성별 별로 상품을 구매한 회원수를 집계하는 SQL문을 작성해주세요. 결과는 년, 월, 성별을 기준으로 오름차순 정렬해주세요. 이때, 성별 정보가 없는 경우 결과에서 제외해주세요.
- 동일한 날짜, 회원 ID, 상품 ID 조합에 대해서는 하나의 판매 데이터만 존재합니다.

<br>

### 풀이

- group by로 발생하는 중복 데이터 distinct로 처리하기

```sql
SELECT 
    YEAR(OS.SALES_DATE) AS YEAR,
    MONTH(OS.SALES_DATE) AS MONTH,
    SQ.GENDER, 
    COUNT(DISTINCT OS.USER_ID) AS USERS
FROM 
    ONLINE_SALE OS
INNER JOIN
    (        
        SELECT
            USER_ID,
            GENDER
        FROM
            USER_INFO
        WHERE
            GENDER IS NOT NULL
    ) SQ
ON OS.USER_ID = SQ.USER_ID
GROUP BY YEAR, MONTH, SQ.GENDER
ORDER BY YEAR, MONTH, SQ.GENDER
;

```

<br>

### 쿼리 최적화

- WHERE 조건문을 JOIN 조건으로 이동시켜 sub query를 없애라

```sql
SELECT 
    YEAR(OS.SALES_DATE) AS YEAR,
    MONTH(OS.SALES_DATE) AS MONTH,
    UI.GENDER, 
    COUNT(DISTINCT OS.USER_ID) AS USERS
FROM 
    ONLINE_SALE OS
INNER JOIN
    USER_INFO UI
ON OS.USER_ID = UI.USER_ID AND UI.GENDER IS NOT NULL
GROUP BY YEAR, MONTH, UI.GENDER
ORDER BY YEAR, MONTH, UI.GENDER;
```

---

# 6. 입양 시각 구하기(2)

- 보호소에서는 몇 시에 입양이 가장 활발하게 일어나는지 알아보려 합니다. 0시부터 23시까지, 각 시간대별로 입양이 몇 건이나 발생했는지 조회하는 SQL문을 작성해주세요. 이때 결과는 시간대 순으로 정렬해야 합니다.
- 0에서 23까지 시간이 모두 출력되어야 합니다. 정보가 없는 경우 count 값을 0으로 채웁니다.

```sql

SELECT
    NUM AS HOUR,
    COUNT(AO.ANIMAL_ID) AS COUNT
FROM
    (
        SELECT 0 AS NUM UNION ALL SELECT 1
        UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
        UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
        UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13
        UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
        UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19
        UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22
        UNION ALL SELECT 23
    ) H
LEFT JOIN
    ANIMAL_OUTS AO
ON H.NUM = HOUR(AO.DATETIME)
GROUP BY HOUR
ORDER BY HOUR
;

```

<br>

### 쿼리 최적화

1. 임시 테이블 생성

```sql
-- 임시 테이블 생성
WITH RECURSIVE HOUR AS (
    SELECT 0 AS HOUR
    UNION ALL
    SELECT HOUR + 1 FROM HOUR
    WHERE HOUR < 23
)

SELECT 
    H.HOUR,
    COUNT(AO.ANIMAL_ID) AS COUNT
FROM 
    HOUR H 
LEFT JOIN
(
    SELECT 
        HOUR(DATETIME) AS HOUR,
        ANIMAL_ID
    FROM
        ANIMAL_OUTS
) AO
ON H.HOUR = AO.HOUR
GROUP BY HOUR
ORDER BY HOUR
;

```

2. 변수 선언

```sql
SET @hour := -1; -- 변수 선언

SELECT (@hour := @hour + 1) as HOUR,
(SELECT COUNT(*) FROM ANIMAL_OUTS WHERE HOUR(DATETIME) = @hour) as COUNT
FROM ANIMAL_OUTS
WHERE @hour < 23

```

[출처](https://chanhuiseok.github.io/posts/db-6/)
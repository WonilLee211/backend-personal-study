# programmers group by 문제

## 목차

1. [자동차-대여-기록에서-대여중--대여-가능-여부-구분하기](#1-자동차-대여-기록에서-대여중--대여-가능-여부-구분하기)
2. 

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

# 4. 대여 횟수가 많은 자동차들의 월별 대여 횟수 구하기

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
# programmer SQL JOIN 문제 풀이

### 목차

1. [특정-기간동안-대여-가능한-자동차들의-대여비용-구하기](#특정-기간동안-대여-가능한-자동차들의-대여비용-구하기)
2. [5월-식품들의-총매출-조회하기](#2-5월-식품들의-총매출-조회하기)
3. [그룹별-조건에-맞는-식당-목록-출력하기](#3-그룹별-조건에-맞는-식당-목록-출력하기)
4. []()
---

## 특정 기간동안 대여 가능한 자동차들의 대여비용 구하기

- `CAR_RENTAL_COMPANY_CAR` 테이블과 `CAR_RENTAL_COMPANY_RENTAL_HISTORY` 테이블과 `CAR_RENTAL_COMPANY_DISCOUNT_PLAN` 테이블에서 자동차 종류가 '세단' 또는 'SUV' 인 자동차 중 2022년 11월 1일부터 2022년 11월 30일까지 대여 가능하고 30일간의 대여 금액이 50만원 이상 200만원 미만인 자동차에 대해서 자동차 ID, 자동차 종류, 대여 금액(컬럼명: FEE) 리스트를 출력하는 SQL문을 작성해주세요. 결과는 대여 금액을 기준으로 내림차순 정렬하고, 대여 금액이 같은 경우 자동차 종류를 기준으로 오름차순 정렬, 자동차 종류까지 같은 경우 자동차 ID를 기준으로 내림차순 정렬해주세요.

```sql
SELECT CRCC.CAR_ID, 
    CRCC.CAR_TYPE, 
    ROUND(CRCC.DAILY_FEE * (1 - CRCDP.DISCOUNT_RATE* 0.01) * 30) AS FEE
FROM CAR_RENTAL_COMPANY_CAR CRCC
INNER JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN CRCDP
    ON CRCDP.CAR_TYPE = CRCC.CAR_TYPE 
    AND CRCDP.DURATION_TYPE = '30일 이상' 
WHERE CRCC.CAR_ID NOT IN (
    SELECT CAR_ID
    FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY 
    WHERE END_DATE >= '2022-11-01' AND START_DATE <= '2022-11-30' 
    )
    AND CRCC.CAR_TYPE IN ('세단', 'SUV')
HAVING FEE >=500000 AND FEE < 2000000
ORDER BY FEE DESC, CRCC.CAR_TYPE, CRCC.CAR_ID DESC;
```
<br>

### 쿼리 최적화

- HAVING 절을 제외하기 위해 FROM 절의 서브쿼리를 사용하여 FEE를 미리 계산한 다음 WHERE 절에서 FEE를 기준으로 결과를 필터링하는 것

```SQL

SELECT T.CAR_ID, T.CAR_TYPE, T.FEE
FROM (
    SELECT CRCC.CAR_ID,
        CRCC.CAR_TYPE,
        ROUND(CRCC.DAILY_FEE * (1 - CRCDP.DISCOUNT_RATE * 0.01) * 30) AS FEE
    FROM CAR_RENTAL_COMPANY_CAR CRCC
    INNER JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN CRCDP
        ON CRCDP.CAR_TYPE = CRCC.CAR_TYPE
        AND CRCDP.DURATION_TYPE = '30일 이상'
    WHERE CRCC.CAR_TYPE IN ('세단', 'SUV')
) AS T
WHERE T.CAR_ID NOT IN (
    SELECT CAR_ID
    FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
    WHERE END_DATE >= '2022-11-01' AND START_DATE <= '2022-11-30'
)
AND T.FEE >= 500000 AND T.FEE < 2000000
ORDER BY T.FEE DESC, T.CAR_TYPE, T.CAR_ID DESC;
```



## 2. 5월 식품들의 총매출 조회하기

- `FOOD_PRODUCT`와 `FOOD_ORDER` 테이블에서 생산일자가 2022년 5월인 식품들의 식품 ID, 식품 이름, 총매출을 조회하는 SQL문을 작성해주세요. 이때 결과는 총매출을 기준으로 내림차순 정렬해주시고 총매출이 같다면 식품 ID를 기준으로 오름차순 정렬해주세요.

```sql
SELECT 
     FP.PRODUCT_ID,
     FP.PRODUCT_NAME, 
     (FP.PRICE * FO.TOTAL_AMOUNT) AS TOTAL_SALES
FROM FOOD_PRODUCT FP
INNER JOIN (
    SELECT 
        PRODUCT_ID,
        SUM(AMOUNT) AS TOTAL_AMOUNT
    FROM FOOD_ORDER
    WHERE PRODUCE_DATE BETWEEN '2022-05-01' AND '2022-05-31'
    GROUP BY PRODUCT_ID
) FO
ON FO.PRODUCT_ID = FP.PRODUCT_ID
ORDER BY TOTAL_SALES DESC, PRODUCT_ID;

```
<br>

### 쿼리 최적화

1. **인덱스 활용**: FOOD_ORDER 테이블의 PRODUCE_DATE와 PRODUCT_ID 열에 인덱스를 생성하여 WHERE 절과 JOIN 작업의 속도를 높일 수 있습니다. 또한, FOOD_PRODUCT 테이블의 PRODUCT_ID 열에 인덱스를 생성하여 JOIN 작업 속도를 향상시킬 수 있습니다.

2. **파티셔닝**: FOOD_ORDER 테이블에 대해 날짜 기반 파티셔닝을 적용하여, 쿼리가 필요한 데이터에만 접근하도록 할 수 있습니다. 이를 통해 쿼리 성능을 향상시킬 수 있습니다.

3. **머터리얼라이즈드 뷰(Materialized View) 사용**: 상품별 총 판매 금액을 미리 계산하고 저장하는 머터리얼라이즈드 뷰를 생성하여, 쿼리 성능을 높일 수 있습니다.

이를 적용하기 위해서는 데이터베이스 관리 시스템(DBMS)의 도구와 명령어를 사용해야 합니다.


## 3. 그룹별 조건에 맞는 식당 목록 출력하기

- `MEMBER_PROFILE와` `REST_REVIEW` 테이블에서 리뷰를 가장 많이 작성한 회원의 리뷰들을 조회하는 SQL문을 작성해주세요. 회원 이름, 리뷰 텍스트, 리뷰 작성일이 출력되도록 작성해주시고, 결과는 리뷰 작성일을 기준으로 오름차순, 리뷰 작성일이 같다면 리뷰 텍스트를 기준으로 오름차순 정렬해주세요.

<br>

```sql

SELECT
    MEMBER_NAME,
    REVIEW_TEXT RT,
    LEFT(REVIEW_DATE, 10) RD
FROM REST_REVIEW R1
LEFT JOIN MEMBER_PROFILE MP
ON R1.MEMBER_ID = MP.MEMBER_ID
WHERE R1.MEMBER_ID IN (
    -- 맥스값과 일치하는 유저 정보 조회
    SELECT 
        R2.MEMBER_ID
    FROM REST_REVIEW R2
    GROUP BY R2.MEMBER_ID
    HAVING COUNT(R2.REVIEW_ID) = 
    (
        -- 맥스값 구하는 방법
        SELECT
            MAX(SQ.COUNT_REVIEW)
        FROM (
            SELECT
                COUNT(REVIEW_ID) COUNT_REVIEW
            FROM REST_REVIEW
            GROUP BY MEMBER_ID
        ) SQ
    )
)
ORDER BY RD, RT
;
```
<br>

### 쿼리 최적화

- chat gpt가 "이 쿼리는 이미 상당히 효율적으로 작성되어 있습니다."라는 평가를 줬다. 기분이 좋다.
- 두 개의 CTE (Common Table Expression)를 사용하여 가독성과 유지 관리성을 개선할 수 있습니다.

```sql
WITH 
    REVIEW_COUNTS AS (
        SELECT
            MEMBER_ID,
            COUNT(REVIEW_ID) AS COUNT_REVIEW
        FROM REST_REVIEW
        GROUP BY MEMBER_ID
    ),
    MAX_REVIEW_COUNT AS (
        SELECT MAX(COUNT_REVIEW) AS MAX_COUNT_REVIEW
        FROM REVIEW_COUNTS
    )

SELECT
    MP.MEMBER_NAME,
    R1.REVIEW_TEXT AS RT,
    LEFT(R1.REVIEW_DATE, 10) AS RD
FROM REST_REVIEW R1
LEFT JOIN MEMBER_PROFILE MP
ON R1.MEMBER_ID = MP.MEMBER_ID
WHERE R1.MEMBER_ID IN (
    SELECT 
        RC.MEMBER_ID
    FROM REVIEW_COUNTS RC
    JOIN MAX_REVIEW_COUNT MRC
    ON RC.COUNT_REVIEW = MRC.MAX_COUNT_REVIEW
)
ORDER BY RD, RT; 
```

---

## 4. 주문량이 많은 아이스크림들 조회하기

- 7월 아이스크림 총 주문량과 상반기의 아이스크림 총 주문량을 더한 값이 큰 순서대로 상위 3개의 맛을 조회하는 SQL 문을 작성해주세요.

<br>

```sql
SELECT
    J.FLAVOR
FROM (
    SELECT
        FLAVOR,
        SUM(TOTAL_ORDER) SUM_ORDER
    FROM JULY
    GROUP BY FLAVOR
) J
LEFT JOIN (
    SELECT
        FLAVOR,
        SUM(TOTAL_ORDER) SUM_ORDER
    FROM FIRST_HALF
    GROUP BY FLAVOR
) FH
ON J.FLAVOR = FH.FLAVOR
ORDER BY J.SUM_ORDER + FH.SUM_ORDER DESC
LIMIT 3
;
```
<br>

### 쿼리 최적화

```sql
SELECT
    J.FLAVOR
FROM (
    SELECT
        FLAVOR,
        SUM(TOTAL_ORDER) AS SUM_ORDER
    FROM JULY
    GROUP BY FLAVOR
) J
LEFT JOIN (
    SELECT
        FLAVOR,
        SUM(TOTAL_ORDER) AS SUM_ORDER
    FROM FIRST_HALF
    GROUP BY FLAVOR
) FH
ON J.FLAVOR = FH.FLAVOR
ORDER BY (COALESCE(J.SUM_ORDER, 0) + COALESCE(FH.SUM_ORDER, 0)) DESC
LIMIT 3;

```

-  `ORDER BY` 절 `COALESCE` 함수를 사용하여 `J.SUM_ORDER`와 `FH.SUM_ORDER`가 `NULL`인 경우 0으로 대체하였습니다. 
- 이렇게 하면 `SUM_ORDER`가 `NULL`인 경우 정렬에 문제가 발생하지 않습니다.
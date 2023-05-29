집계 함수(Aggregate Functions) 사용 방법:

- COUNT: 행의 개수를 반환합니다.

```sql
SELECT COUNT(*) FROM 테이블명;
```
- SUM: 열의 합계를 반환합니다.

```sql
SELECT SUM(열) FROM 테이블명;
```
- AVG: 열의 평균값을 반환합니다.

```sql
SELECT AVG(열) FROM 테이블명;
```
- MIN: 열의 최소값을 반환합니다.

```sql
SELECT MIN(열) FROM 테이블명;
```
- MAX: 열의 최대값을 반환합니다.

```sql
SELECT MAX(열) FROM 테이블명;
```
문자열 함수(String Functions) 사용 방법:

- CONCAT: 문자열을 연결합니다.

```sql
SELECT CONCAT(문자열1, 문자열2) FROM 테이블명;
```
- SUBSTRING: 문자열의 일부를 추출합니다.

```sql
SELECT SUBSTRING(문자열, 시작위치, 길이) FROM 테이블명;
```
- REPLACE: 문자열에서 특정 문자열을 다른 문자열로 바꿉니다.

```sql
SELECT REPLACE(문자열, '찾을문자열', '바꿀문자열') FROM 
테이블명;
```

- TRIM: 문자열 앞뒤의 공백을 제거합니다.

```sql
SELECT TRIM(문자열) FROM 테이블명;
```

- LENGTH: 문자열의 길이를 반환합니다.

```sql
SELECT LENGTH(문자열) FROM 테이블명;
```

- UPPER: 문자열을 대문자로 변환합니다.

```sql
SELECT UPPER(문자열) FROM 테이블명;
```

- LOWER: 문자열을 소문자로 변환합니다.

```sql
SELECT LOWER(문자열) FROM 테이블명;
```

## 날짜 및 시간 함수(Date and Time Functions) 사용 방법:

- NOW: 현재 날짜와 시간을 반환합니다.

```sql
SELECT NOW();
```

- CURDATE: 현재 날짜를 반환합니다.

```sql
SELECT CURDATE();
```

- CURTIME: 현재 시간을 반환합니다.

```sql
SELECT CURTIME();
```

- DATE_ADD: 날짜에 특정 기간을 더합니다.

```sql
SELECT DATE_ADD(날짜, INTERVAL 값 단위) FROM 테이블명;
```

- DATE_SUB: 날짜에서 특정 기간을 뺍니다.

```sql
SELECT DATE_SUB(날짜, INTERVAL 값 단위) FROM 테이블명;
```

- DATEDIFF: 두 날짜 간의 차이를 반환합니다.

```sql
SELECT DATEDIFF(날짜1, 날짜2) FROM 테이블명;
```

- DAY, MONTH, YEAR: 날짜에서 일, 월, 년을 추출합니다.

```sql
SELECT DAY(날짜), MONTH(날짜), YEAR(날짜) FROM 테이블명;
```

## 형 변환 함수

- CAST: 데이터 형식을 변환합니다.

```sql
SELECT CAST(열 AS 데이터형) FROM 테이블명;
```
- CONVERT: 데이터 형식을 변환합니다.

```sql
SELECT CONVERT(데이터형, 열) FROM 테이블명;
```

## 조건 함수(Conditional Functions) 사용 방법:

- IF: 조건에 따라 값을 반환합니다.

```sql
SELECT IF(조건, '참일때 값', '거짓일때 값') FROM 테이블명;
```

- IFNULL: NULL 값을 다른 값으로 대체합니다.

```sql
SELECT IFNULL(열, '대체할 값') FROM 테이블명;
```

- NULLIF: 두 값이 같으면 NULL을 반환하고, 다르면 첫 번째 값을 반환합니다.

```sql
SELECT NULLIF(값1, 값2) FROM 테이블명;
```

- COALESCE: NULL이 아닌 첫 번째 값을 반환합니다.
```sql
SELECT COALESCE(값1, 값2, ...) FROM 테이블명;
```

- CASE: 다양한 조건에 따라 값을 반환합니다.

```sql
SELECT CASE
         WHEN 조건1 THEN 값1
         WHEN 조건2 THEN 값2
         ELSE 기본값
       END
FROM 테이블명;
```

## 수학 함수(Mathematical Functions) 사용 방법:

- ABS: 절대값을 반환합니다.

```sql
SELECT ABS(값) FROM 테이블명;
```

- CEIL: 크거나 같은 가장 작은 정수를 반환합니다.

```sql
SELECT CEIL(값) FROM 테이블명;
```

- FLOOR: 작거나 같은 가장 큰 정수를 반환합니다.

```sql
SELECT FLOOR(값) FROM 테이블명;
```

- ROUND: 반올림한 값을 반환합니다.

```sql
SELECT ROUND(값, 소수점자리수) FROM 테이블명;
```

- SQRT: 제곱근을 반환합니다.

```sql
SELECT SQRT(값) FROM 테이블명;
```

- RAND: 0부터 1 사이의 난수를 반환합니다.

```sql
SELECT RAND();
```


## 창 함수(Window Functions) 사용 방법:

- ROW_NUMBER(): 각 행에 고유한 일련 번호를 할당합니다.

```sql
SELECT ROW_NUMBER() OVER(ORDER BY 열) AS '번호', 열1, 열2, ... FROM 테이블명;
```
- RANK(): 순위를 할당하되 동일한 값이 있을 경우 동일 순위를 부여하고 다음 순위를 건너뜁니다.

```sql
SELECT RANK() OVER(ORDER BY 열) AS '순위', 열1, 열2, ... FROM 테이블명;
```
- DENSE_RANK(): 순위를 할당하되 동일한 값이 있을 경우 동일 순위를 부여하고 다음 순위를 건너뛰지 않습니다.

```sql
SELECT DENSE_RANK() OVER(ORDER BY 열) AS '순위', 열1, 열2, ... FROM 테이블명;
```

- NTILE(n): 결과를 n 개의 그룹으로 나눕니다.

```sql
SELECT NTILE(n) OVER(ORDER BY 열) AS '그룹', 열1, 열2, ... FROM 테이블
명;
```

## 텍스트 처리 함수(Text Processing Functions):

- CHAR_LENGTH(): 문자열의 길이를 반환합니다.

```sql
SELECT CHAR_LENGTH(열) FROM 테이블명;
```

- POSITION(): 문자열에서 부분 문자열의 위치를 찾
습니다.

```sql
SELECT POSITION('부분문자열' IN 열) FROM 테이블명;
```

- LEFT(): 문자열의 왼쪽 부분을 반환
합니다.

```sql
SELECT LEFT(열, n) FROM 테이블명;
```

- RIGHT(): 문자열의 오른쪽 부분을 반환
합니다.

```sql
SELECT RIGHT(열, n) FROM 테이블명;
```
- LTRIM(): 문자열의 왼쪽 공백을 제거합니다.
```sql
SELECT LTRIM(열) FROM 테이블명;
```

- RTRIM(): 문자열의 오른쪽 공백을 제거합니다.

```sql
SELECT RTRIM(열) FROM 테이블명;
```
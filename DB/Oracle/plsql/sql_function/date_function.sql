/* 날짜 함수 */
/* SYSDATE, SYSTIMESTAMP 
    현재일자와 시간을 각각 date, timestamp 타입으로 변환 후 반환
*/
SELECT SYSDATE, SYSTIMESTAMP
FROM DUAL;

/* ADD_MONTHS(date, integer) */
SELECT ADD_MONTHS(SYSDATE, 1), ADD_MONTHS(SYSDATE, -1)
FROM DUAL;
-- 2023/10/05	2023/08/05

/* MONTHS_BETWEEN(date1, date2) 
    date1 > date2
*/
SELECT MONTHS_BETWEEN(SYSDATE, ADD_MONTHS(SYSDATE, 1)) mon1, 
       MONTHS_BETWEEN(ADD_MONTHS(SYSDATE, 1), SYSDATE) mon2
FROM DUAL;    
-- -1	1

/* LAST_DAY(DATE) */
SELECT LAST_DAY(SYSDATE)
FROM DUAL;  
-- 2023/09/30

/* ROUND(date, format), TRUNC(date, format) 
    format에 따라 반올림/잘라낸 날짜를 반
*/
SELECT SYSDATE, ROUND(SYSDATE, 'month'), TRUNC(SYSDATE, 'month')
FROM DUAL;
--2023/09/05	2023/09/01	2023/09/01

/* NEXT_DAY(date, char) 
    char에 명시한 요일로 앞으로 가장 가까운 일자를 반환
    char는 일요일 ~ 토요일 또는 SUNDAY ~SATURDAY와 같이 NLS_LANG 변수값에 따라 맞게 입력해야 함
*/
SELECT SYSDATE, NEXT_DAY(SYSDATE, '금요일')
FROM DUAL;
--2023/09/05	2023/09/08
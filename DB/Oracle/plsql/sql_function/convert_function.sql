/* 변환 함수 */

/* TO_CHAR(숫자 혹은 날짜, format) */
SELECT TO_CHAR(123456789, '999,999,999')
FROM DUAL;
-- 123,456,789

/* 날짜 변환 형식
AM, A.M | 오전
PM, P.M | 오후
YYYY, YYY, YY, Y | 연도
MONTH, MON | 월
MM | 01 ~ 12 형태의 월
D | 주중의 일을 1 ~ 7로 표시(일요일 1)
DAY | 주중의 일을 요일로 표시
DD | 일을 01 ~ 31 형태로 표시
DDD | 일을 001 ~ 365 형태로 표시
DL | 현재 일을 요일까지 표시
HH, HH12 | 시간을 01 ~ 12시 형태로 표시
HH24 | 시간을 01 ~ 23시 형태로 표시
MI | 분을 00 ~ 59분 형태로 표시
SS | 초를 01 ~ 59초 형태로 표시
WW | 주를 01 ~ 53주 형태로 표시
*/
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD')
FROM DUAL;
-- 2023-09-06

/* 숫자 변환 형식
,(콤마) | 콤마로 표시
.(소수점) | 소수점 표시
9 | 한자리 숫자, 실제값보다 크거나 같게 명시
PR | 음수일 때 <>로 표시
RN, rn | 로마 숫자로 표시
S | 양수이면 +, 음수이면 -표시
*/
/* TO_NUMBER(expr, format) */
SELECT TO_NUMBER('123456')
FROM DUAL;
-- 123456

/* TO_DATE(char, format) TO_TIMESTAMP(char, format) */
SELECT TO_DATE('20140101', 'YYYY-MM-DD')
FROM DUAL;
-- 2014/01/01

SELECT TO_TIMESTAMP('20140101 13:44:50', 'YYYY-MM-DD HH24:MI:SS')
FROM DUAL;  
--2014/01/01 13:44:50.000000000











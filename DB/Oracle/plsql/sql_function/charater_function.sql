/* 문자 함수 */

/* INITCAP(CHAR)
    RETURN : 매개변수 문자열을 첫문자를 대문자, 나머지를 소문자로 반환하는 함수
    첫 문자를 인식하는 기준
    - 공백이나 앒파벳(숫자 포함)이 아닌 문자
*/
SELECT INITCAP('never say goodbye'), INITCAP('never6say*good가bye')
FROM DUAL;
-- Never Say Goodbye	Never6say*Good가Bye

/* LOWER / UPPER 함수 */
SELECT LOWER('NEVER SAY GOODBYE'), UPPER('never say goodbye')
FROM DUAL;
-- never say goodbye	NEVER SAY GOODBYE

/* CONCAT(CHAR1, CHAR2) */
SELECT CONCAT('I Have', ' A Dream'), 'I Have' || ' A Dream'
FROM DUAL;
-- I Have A Dream	I Have A Dream

/* SUBSTR(CAHR,POS, LEN)
    잘라올 문자열을 pos부터 len길이만큼 잘라냄
    pos
    - 0이면 default값으로 1을 의미
    - 음수면 끝에서부터 시작한 상대적 위치를 의미
*/
SELECT SUBSTR('ABCDEFG', 1, 4), SUBSTR('ABCDEFG', -1, 4)
FROM DUAL;
-- ABCD	G

/* SUBSTRB(CAHR,POS, LEN)
    잘라올 문자열을 pos부터 lenBYTE만큼 잘라냄
    한글은 한글자에 3byte를 차지하는 듯하다.
*/
SELECT SUBSTRB('ABCDEFG', 1, 4), SUBSTRB('가나다라마바사', 1, 3)
FROM DUAL;
--ABCD	가 

/* LTRIM(char, set), RTRIM(CHAR, SET)
    문장 가운데 있다면 trip 불가능
    공백 제거 시 많이 사용
*/
SELECT 
    LTRIM('ABCDEFGABC', 'ABC'), 
    LTRIM('가나다라', '가'),
    RTRIM('ABCDEFGABC', 'ABC'), 
    RTRIM('가나다라', '라')
FROM DUAL;
-- DEFGABC	나다라	ABCDEFG	가나다
  
SELECT LTRIM('가나다라', '나'), RTRIM('가나다라', '나')
FROM DUAL;
-- 가나다라	가나다라

/* LPAD(EXPR1, N, EXPR2), RPAD(EXPR1, N, EXPR2)
    expr2 문자열을 n자리 만큼 왼쪽부터 채워 expr1을 반환하는 함수 
    n : expr1 자릿수 + expr2 자릿수 
    예를 들어 서울 지역번호 02가 전화번호 컬럼에 없으면 자동으로 채움
*/
CREATE TABLE ex4_1 (
       phone_num VARCHAR2(30));
INSERT INTO ex4_1 VALUES ('111-1111');
INSERT INTO ex4_1 VALUES ('111-2222');
INSERT INTO ex4_1 VALUES ('111-3333');

SELECT * FROM EX4_1;
--111-1111
--111-2222
--111-3333

SELECT LPAD(PHONE_NUM, 12, '(02)')
FROM EX4_1;
--(02)111-1111
--(02)111-2222
--(02)111-3333
SELECT RPAD(phone_num, 12, '(02)')
FROM ex4_1;
--111-1111(02)
--111-2222(02)
--111-3333(02)

/* REPLACE(CHAR, SEARCH_STR, REPLACE_STR), TRANSLATE(EXPR, FROM_STR, TO_STR) 
    REPLACE : str자체를 변환
    translate : from에서 문자 하나 하나를 매핑되는 to 문자 하나 하나로 변환
*/
SELECT REPLACE('나는 너를 모르는데 너는 나를 알겠는가?', '나는', '너를') AS rep,
       TRANSLATE('나는 너를 모르는데 너는 나를 알겠는가?', '나는', '너를') AS trn
FROM DUAL;
-- 너를 너를 모르는데 너는 나를 알겠는가?	너를 너를 모르를데 너를 너를 알겠를가?


/* INSTR(str, substr, pos, occur), LENGTH(chr), LENGTHB(chr) 
    INSTR : str문자열에서 substr과 일치하는 위치를 반환
        pos 시작 위치부터 occur 번째 일치하는 위치
*/
SELECT INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약') AS INSTR1, 
       INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약', 5) AS INSTR2, 
       INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약', 5, 2) AS INSTR3 
FROM DUAL;   
--4	18	32

SELECT LENGTH('대한민국'),
       LENGTHB('대한민국')
FROM DUAL;
--4	12
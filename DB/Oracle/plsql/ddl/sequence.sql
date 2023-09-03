/*
SEQUENCE

CREATE SEQUENCE [SCHEMA.]NAME
INCREMENT BY [INT]
START WITH [INT]
NOMINVALUE | MINVALUE [INT]
NOCYCLE | CYCLE
NOCACHE | CACHE;

-- 
-- NOCACHE : 디폴트로, 메모리에 시퀀스 값을 미리 할당해 놓지 않으며 디폴트값은 20
-- 메모리에 시퀀스 값을 할당해 둠
*/


--CREATE SEQUENCE my_seq1
--INCREMENT BY 1
--START WITH 1
--MINVALUE 1
--MAXVALUE 1000
--NOCYCLE
--NOCACHE;


--CREATE TABLE ex2_8 (
--    col1 VARCHAR2(10) PRIMARY KEY,
--    col2 VARCHAR2(10)
--);
--Table EX2_8 created.

--INSERT INTO ex2_8 (col1) VALUES (my_seq1.nextval);
--1 row inserted.
--1 row inserted.

--SELECT my_seq1.CURRVAL FROM DUAL;
-- 2

--DROP SEQUENCE MY_SEQ1;

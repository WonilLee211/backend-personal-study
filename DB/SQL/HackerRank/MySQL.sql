-- Query all columns for all American cities in the CITY table with populations larger than 100000. The CountryCode for America is USA.
select * from CITY where POPULATION > 100000 and COUNTRYCODE = 'USA';

-- Query a list of CITY names from STATION for cities that have an even ID number. Print the results in any order, but exclude duplicates from the answer.
SELECT DISTINCT CITY FROM STATION WHERE MOD(ID, 2) = 0;

-- Find the difference between the total number of CITY entries in the table and the number of distinct CITY entries in the table.
SELECT COUNT(ID) - COUNT(DISTINCT CITY) FROM STATION S;

-- Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths 
--(i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
SELECT CITY, LENGTH(CITY) AS NAME_LENGTH 
FROM STATION
WHERE CITY = (SELECT CITY FROM STATION WHERE LENGTH(CITY) = (SELECT MIN(LENGTH(CITY)) FROM STATION) ORDER BY CITY ASC LIMIT 1)
   OR CITY = (SELECT CITY FROM STATION WHERE LENGTH(CITY) = (SELECT MAX(LENGTH(CITY)) FROM STATION) ORDER BY CITY ASC LIMIT 1)
ORDER BY NAME_LENGTH ASC, CITY ASC;

-- Query the list of CITY names starting with vowels (i.e., a, e, i, o, or u) from STATION. Your result cannot contain duplicates.
SELECT DISTINCT CITY FROM STATION WHERE CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%';
SELECT DISTINCT CITY FROM STATION WHERE CITY REGEXP '^[aeiouAEIOU].*';

-- Query the list of CITY names ending with vowels (a, e, i, o, u) from STATION. Your result cannot contain duplicates.
SELECT DISTINCT CITY FROM STATION WHERE CITY REGEXP '.*[aeiouAEIOU]$';

/*
정규표현식 정리
패턴 구성: 찾고자 하는 문자열 패턴을 구성합니다. 예를 들어, "a"로 시작하고 "b"로 끝나는 문자열을 찾으려면 "a.*b"와 같은 패턴을 구성할 수 있습니다.
특수 문자 이스케이프: 정규 표현식에서 사용되는 특수 문자(예: $, ^, *, . 등)를 찾고자 하는 문자열과 구분하기 위해 이스케이프 문자(예: )를 사용합니다.
문자 클래스: 특정 문자 클래스(예: 숫자, 알파벳 등)를 찾으려면 해당 문자 클래스를 나타내는 특수 문자를 사용합니다.
패턴 반복: 패턴을 반복해서 찾으려면 반복자(예: *, +, ?, {n,m})를 사용합니다.
대/소문자 구분: 일부 정규 표현식은 대/소문자를 구분합니다. 이 경우에는 대소문자를 일치시키는 옵션을 사용할 수 있습니다.
전방/후방 탐색: 일부 정규 표현식에서는 특정 패턴 앞/뒤에 있는 문자열만 찾기 위해 전방/후방 탐색을 사용할 수 있습니다.


이메일 검증 정규표현식
^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$

    "^" : 문자열의 시작
    "[a-zA-Z0-9]+" : 최소한 한 개 이상의 알파벳 대/소문자 또는 숫자
    "@" : @ 문자
    "[a-zA-Z0-9]+" : 최소한 한 개 이상의 알파벳 대/소문자 또는 숫자
    "." : 마침표 (점) 문자 (역슬래시()를 사용하여 이스케이프)
    "[a-zA-Z]{2,}" : 최소한 두 개 이상의 알파벳 대/소문자
*/

-- Query the list of CITY names from STATION which have vowels (i.e., a, e, i, o, and u) as both their first and last characters. Your result cannot contain duplicates.
SELECT CITY FROM STATION 
WHERE CITY REGEXP '^[aeiouAEIOU].*[aeiouAEIOU]$';

-- Query the list of CITY names from STATION that do not start with vowels. Your result cannot contain duplicates.
SELECT DISTINCT CITY FROM STATION 
WHERE NOT CITY REGEXP '^[AEIOUaeiou].*';

-- Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates.
SELECT DISTINCT CITY FROM STATION 
WHERE NOT CITY REGEXP '^[AEIOUaeiou].*[AEIOUaeiou]$';

-- Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by the last three characters of each name. 
-- If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
SELECT Name FROM Students WHERE Marks > 75 ORDER BY RIGHT(Name, 3), ID ASC;

/*
Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:

Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.
*/
select
    case
        when A + B > C and A + C > B and B + C > A then
            case 
                when A = B and A = C then 'Equilateral'
                when A = B or A = C or B = C then 'Isosceles'
                else 'Scalene'
            end 
        else 'Not A Triangle'
    end as TRIANGLE_TYPE
from TRIANGLES;

/*
Generate the following two result sets:

Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses). For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, and output them in the following format:

There are a total of [occupation_count] [occupation]s.
where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name. If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.
*/
SELECT concat(name, '(', left(Occupation, 1), ')') AS name_Profession 
FROM OCCUPATIONS 
ORDER BY name_Profession;

SELECT CONCAT('There are a total of ', COUNT(Occupation), ' ', LOWER(Occupation), 's.') AS occupation_count
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY occupation_count ASC, Occupation ASC;


/*
Pivot the Occupation column in OCCUPATIONS 
so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. 
The output column headers should be Doctor, Professor, Singer, and Actor, respectively.

Note: Print NULL when there are no more names corresponding to an occupation.

output example
Jenny    Ashley     Meera  Jane
Samantha Christeen  Priya  Julia
NULL     Ketty      NULL   Maria

풀이
1. partition by를 사용하여 전체 데이터에 대해서 Occupation으로 묶고 ROW_NUMBER()를 할당해준다.
2. 할당한 ROW_NUMBER로 묶어서 컬럼 아이템을 가로로 붙인다.
3. null인 아이템에 대해서 MAX()로 구분해서 NULL이 아닌 아이템부터 출력하도록 한다.
    여기서 String은 MAX 함수를 거쳐도 문제가 NULL만 구분된다.
*/

SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS 'Doctor',
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS 'Professor',
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS 'Singer',
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS 'Actor'
FROM
    (SELECT *, ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) rm FROM OCCUPATIONS) subquery
GROUP BY rm;


/*
Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:

Root: If node is root node.
Leaf: If node is leaf node.
Inner: If node is neither root nor leaf node.
*/
select
    distinct b1.N,
    case 
        when b1.P is null then 'Root'
        when b2.N is null then 'Leaf'
        else 'Inner'
    end as type
from BST b1 left join BST b2 on b1.N = b2.P
order by b1.N;

/*
write a query to print the 
    company_code, founder name, 
    total number of lead managers, 
    total number of senior managers, 
    total number of managers, 
    and total number of employees. 
Order your output by ascending company_code.
*/
-- first problem solve
select 
    c.company_code, c.founder, 
    (select count(distinct lm.lead_manager_code) from Lead_Manager lm where c.company_code = lm.company_code),
    (select count(distinct sm.senior_manager_code) from Senior_Manager sm where c.company_code = sm.company_code),
    (select count(distinct m.manager_code) from Manager m where c.company_code = m.company_code),
    (select count(distinct e.employee_code) from Employee e where c.company_code = e.company_code)
from Company c
order by c.company_code;

-- 중첩 서브 쿼리로 인한 성능 저하가 발생하기 떄문에 조인으로 수정하기
SELECT
    c.company_code,
    c.founder,
    COUNT(DISTINCT lm.lead_manager_code) as num_lead_manager,
    COUNT(DISTINCT sm.senior_manager_code) as num_senior_manager,
    COUNT(DISTINCT m.manager_code) as num_manager,
    COUNT(DISTINCT e.employee_code) as num_employee
FROM
Company c
    LEFT JOIN Lead_Manager lm ON c.company_code = lm.company_code
    LEFT JOIN Senior_Manager sm ON c.company_code = sm.company_code
    LEFT JOIN Manager m ON c.company_code = m.company_code
    LEFT JOIN Employee e ON c.company_code = e.company_code
GROUP BY
    c.company_code,
    c.founder
ORDER BY
    c.company_code; 


/* FLOOR(), AVG()
Query the average population for all cities in CITY, rounded down to the nearest integer.
*/
SELECT FLOOR(AVG(POPULATION)) FROM CITY;

/*
Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, 
but did not realize her keyboard's  key was broken until after completing the calculation.
 She wants your help finding the difference between her miscalculation (using salaries with any zeros removed), 
 and the actual average salary.

Write a query calculating the amount of error (i.e.:  average monthly salaries), and round it up to the next integer.
*/
SELECT CEIL(AVG(SALARY) - AVG(REPLACE(SALARY, '0', ''))) FROM EMPLOYEES;

/* AGGREGATION FUCTION
CEIL(숫자) : 올림
ROUND(숫자, (자리수)) : 반올림
TRUNCATE(숫자, 자릿수) : 내림
FLOOR(숫자) : 내림
ABS(TNTWK) : 절대값
POW(X, Y), POWER(X, Y) : X의 Y 제곱
MOD(X, Y) : X를 Y로 나눈 나머지
*/

---

/*
We define an employee's total earnings to be their monthly `salary * months` worked, 
and the maximum total earnings to be the maximum total earnings for any employee in the Employee table.
Write a query to find the maximum total earnings for all employees as well as the total number of employees who have maximum total earnings. 
Then print these values as  space-separated integers.
*/
SELECT MAX(E1.months * E1.salary), COUNT(E1.employee_id)
FROM Employee E1
INNER JOIN 
    (SELECT MAX(months * salary) AS MAX_EARNING FROM Employee) E2 
    ON (E1.months * E1.salary) = E2.MAX_EARNING;

/*
Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than 38.7880 and less than 137.2345. Truncate your answer to  decimal places.
*/
SELECT TRUNCATE(SUM(LAT_N), 4) FROM STATION WHERE LAT_N > 38.7880 AND LAT_N < 137.2345;

/* INNER JOIN
Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than 137.2345.
 Round your answer to  decimal places.
*/
SELECT ROUND(LONG_W, 4)
FROM STATION S1
INNER JOIN
    (SELECT MAX(LAT_N) AS MAX_LAT FROM STATION WHERE LAT_N < 137.2345) S2
ON S1.LAT_N = S2.MAX_LAT;

/* SUBQUERY 
A median is defined as a number separating the higher half of a data set from the lower half. 
Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to  decimal places.
*/
SELECT ROUND(LAT_N, 4)
FROM STATION S1
WHERE (SELECT COUNT(*) FROM STATION S2 WHERE LAT_N > S1.LAT_N) = (SELECT COUNT(*) FROM STATION S3 WHERE LAT_N < S1.LAT_N);

/* PERCENT_RANK
PERCENT_RANK() 함수는 분위수를 계산하는 윈도우 함수입니다
OVER(ORDER BY LAT_N ASC) 절은 PERCENT_RANK() 함수에게 LAT_N 열을 기준으로 오름차순으로 정렬하고 순위를 계산하도록 지시합니다.
*/
SELECT ROUND(LAT_N, 4)
FROM 
    (SELECT LAT_N, PERCENT_RANK() OVER(ORDER BY LAT_N ASC) PR FROM STATION) S1
WHERE PR = 0.5;
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
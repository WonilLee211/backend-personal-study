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

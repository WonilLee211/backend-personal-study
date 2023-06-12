DELIMITER $$
DROP PROCEDURE IF EXISTS INSERT_TRAVEL_SAMPLE_DATA;
CREATE PROCEDURE INSERT_TRAVEL_SAMPLE_DATA(IN NUM_ROWS INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE CITY_NATION_JSON TEXT;
    DECLARE ACTIVITY_LIST TEXT;
    DECLARE SELECTED_CITY TEXT;
    DECLARE SELECTED_NATION TEXT;
    DECLARE SELECTED_ACTIVITY TEXT;
    DECLARE INDEX1 INT;
    DECLARE INDEX2 INT;
    DECLARE START_DATE DATETIME;
    
    SET CITY_NATION_JSON = '[{"city": "서울", "nation": "대한민국"}, {"city": "도쿄", "nation": "일본"}, {"city": "오사카", "nation": "일본"}, {"city": "뉴욕", "nation": "미국"}, {"city": "런던", "nation": "영국"}, {"city": "파리", "nation": "프랑스"}, {"city": "베를린", "nation": "독일"}]';
    SET ACTIVITY_LIST = '문화체험,자연탐방,미식,역사,레저스포츠,쇼핑';
    
    WHILE i < NUM_ROWS DO
        SET INDEX1 =  FLOOR(RAND(UUID_SHORT()) * JSON_LENGTH(CITY_NATION_JSON));
		SET INDEX2 =  i % 6; -- FLOOR(RAND() * LENGTH(ACTIVITY_LIST) - LENGTH(REPLACE(ACTIVITY_LIST, ',', '')));
        SET START_DATE = DATE_ADD(NOW(), INTERVAL i % 30 + 1 DAY);
        SET SELECTED_CITY = JSON_UNQUOTE(JSON_EXTRACT(CITY_NATION_JSON, CONCAT('$[', INDEX1, '].city')));
        SET SELECTED_NATION = JSON_UNQUOTE(JSON_EXTRACT(CITY_NATION_JSON, CONCAT('$[', INDEX1, '].nation')));
        SET SELECTED_ACTIVITY = SUBSTRING_INDEX(SUBSTRING_INDEX(ACTIVITY_LIST, ',', 1 + INDEX2), ',', -1);
        
        INSERT INTO article (
          created_at,
          updated_at,
          city,
          content,
          end_date,
          nation,
          start_date,
          status,
          title,
          author_id
        ) VALUES (
            NOW(),
            NOW(),
            SELECTED_CITY,
            CONCAT('안녕하세요! ', SELECTED_CITY, '에서 ', SELECTED_ACTIVITY, ' 여행을 계획 중입니다. 함께 여행할 동행을 찾습니다.', i),
            DATE_ADD(START_DATE, INTERVAL FLOOR(RAND() * 30) DAY),
            SELECTED_NATION,
            START_DATE,
            'T',
            CONCAT(SELECTED_CITY, '에서 ', SELECTED_ACTIVITY, ' 여행 동행 구합니다!'),
            2
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL INSERT_TRAVEL_SAMPLE_DATA(10000);
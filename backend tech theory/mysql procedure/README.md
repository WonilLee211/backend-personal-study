# 프로시저

- 더미데이터 삽입

```sql
USE coredb;

DELIMITER $$

DROP PROCEDURE IF EXISTS insertDummyData$$

CREATE PROCEDURE insertDummyData()
BEGIN
    DECLARE i INT DEFAULT 1;
        
	WHILE i <= 30000000 DO
		IF i % 2 = 1 THEN
			INSERT INTO coredb.auction(id, bid_start_price, creator_name, expired_date, highest_bid_price, is_close, nft_id, nft_image_path, song_title, seller_id, created_at, updated_at)
			  VALUES(i, 100.0 + i, CONCAT('creator_name_', i), DATE_SUB(now(), INTERVAL i DAY), NULL, true, CONCAT('nft_id_', i), CONCAT('nft_image_path_', i), CONCAT('song_title_', i), 1, DATE_SUB(now(), INTERVAL i DAY), DATE_SUB(now(), INTERVAL i DAY));
		ELSE
			INSERT INTO coredb.auction(id, bid_start_price, creator_name, expired_date, highest_bid_price, is_close, nft_id, nft_image_path, song_title, seller_id, created_at, updated_at)
			  VALUES(i, 100.0 + i, CONCAT('creator_name_', i), DATE_SUB(now(), INTERVAL i DAY), NULL, false, CONCAT('nft_id_', i), CONCAT('nft_image_path_', i), CONCAT('song_title_', i), 1, DATE_SUB(now(), INTERVAL i DAY), DATE_SUB(now(), INTERVAL i DAY));
		END IF;
		SET i = i + 1;
	END WHILE;
END$$
DELIMITER $$


CALL insertDummyData;
```
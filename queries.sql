use at;
/*2 самые читаемые книги */
select l.book_id, b.title, count(*) from lib as l 
left join books as b on l.book_id = b.id 
where l.status_id !=4  group by l.book_id order by count(*) desc limit 2;


/* тоже самое через временную таблицу */ 
CREATE TEMPORARY TABLE tbl select book_id, count(*) as cht from lib where status_id !=4  
group by book_id order by count(*) desc limit 2;
select book_id, cht, title  from tbl 
join books on book_id = id;
drop TEMPORARY TABLE tbl;

/* исправим время заведения 2 пользователя */
UPDATE users
SET created_at = CURDATE()
LIMIT 2;

/* добавим индекс в таблицу lib на статус
 if exists не применим в mysql в подобной конструкции
 **/
#CREATE INDEX status_id ON lib(status_id);
#ALTER TABLE lib ADD INDEX (status_id);

/* новые пользователи за последние 10 недель */
select firstname, lastname, created_at from users 
where  ( created_at > CURDATE()  - INTERVAL 10 week);

/* Представление */
/* 1. Пользователи */ 
CREATE or REPLACE VIEW list_users AS SELECT concat(firstname," ", lastname) as 'user', email, phone FROM users;
select * from list_users;
/* 2. Книги */ 
CREATE or REPLACE VIEW list_books AS SELECT b.title, CONCAT(u.firstname," ",u.lastname) as author from books b 
left join users u on b.author_id = u.id ;
select * from list_books;

/* хранимые процедуры */
/* 1. добавление текста в книгу */
START TRANSACTION 
delimiter //
DROP PROCEDURE IF EXISTS update_book //
CREATE PROCEDURE if not exists update_book (bk_id mediumint(8), bk_text TEXT)
BEGIN 
	DECLARE oldText TEXT ;	
	SET @oldText = (SELECT text from books WHERE id = bk_id);
	update books 
	set text = CONCAT(@oldText,"\r ", bk_text)
	WHERE id = bk_id; 
END//
COMMIT;
call update_book(1, "UPDATE 1");
SELECT TEXT FROM books  WHERE id = 1; 

/* 2. добавление пользователя */
/* адаптировал процедуру из лекции*/

DELIMITER //
DROP PROCEDURE IF EXISTS sp_add_user//
CREATE PROCEDURE sp_add_user(firstname VARCHAR(150), lastname VARCHAR(150), email VARCHAR(150), phone CHAR(11),
							gender CHAR(1), birthday DATE, city VARCHAR(130), country VARCHAR(130), OUT tran_result VARCHAR(200))
BEGIN
	DECLARE tran_rollback BOOL DEFAULT 0;
	DECLARE code VARCHAR(100);
	DECLARE error_string VARCHAR(100);
	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
	-- если пойман exception ставим флажок
		SET tran_rollback = 1;
	
		GET STACKED DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result = CONCAT(code, ': ', error_string);
	END;

	-- начало транзакции
	START TRANSACTION;

	INSERT users (firstname, lastname, email, phone)
	VALUES (firstname, lastname, email, phone);
	
	INSERT profiles (user_id, gender, birthday, city, country)
	VALUES (LAST_INSERT_ID(), gender, birthday, city, country);
	
	IF tran_rollback
	THEN
		ROLLBACK;
	ELSE
		SET tran_result = 'ok';
		COMMIT;
	END IF;
END//

DELIMITER ;

CALL sp_add_user('Transaction2', 'User2', 'new2@mail.com', 89303099090,
								'm', '1990-11-11',  'Moscow', 'Russia', @tran_result);
SELECT @tran_result;							
CALL sp_add_user('Transaction3', 'User3', 'new3@mail.com', 83303099090,
				'm', '1990-11-11',  'Moscow', 'Russia', @tran_result);
SELECT @tran_result;	

/* 3. включение/отключение логирования */
delimiter //
DROP PROCEDURE IF EXISTS set_log //
CREATE PROCEDURE if not exists set_log (flag boolean)
BEGIN 
	update settings  
	set value = flag
	WHERE id = 1 and value != flag; 
	END//
delimiter ;
call set_log(1);

SELECT value FROM settings WHERE id = 1; 

/* 4. тригер логирования изменения текста */
DELIMITER //
DROP TRIGGER IF EXISTS log_book_update //
CREATE TRIGGER log_book_update BEFORE UPDATE ON books
FOR EACH ROW 
BEGIN 	
	IF @flag=(select value from settings where id = 1) and  OLD.text <> NEW.text THEN 
		INSERT INTO logs Set book_id = OLD.id, old_text = OLD.text;
	END IF;
END//

DELIMITER ;

call update_book(1, "UPDATE 4");
call update_book(1, "UPDATE 5");







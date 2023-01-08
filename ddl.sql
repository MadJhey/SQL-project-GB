DROP database if exists at;
create database at default charset utf8;

USE at;
UNLOCK TABLES; -- на всякий случай

DROP TABLE IF EXISTS typeofusers;
CREATE TABLE `typeofusers` (
id int unsigned not null,
name varchar(50) not null, 
PRIMARY KEY (id));
insert into typeofusers values (1, 'admin'), (2, 'user'); 

-- `at`.users definition
DROP TABLE IF EXISTS users;
CREATE TABLE `users` (
  id bigint unsigned NOT NULL AUTO_INCREMENT,
  firstname varchar(145) NOT NULL,
  lastname varchar(145) NOT NULL,
  email varchar(145) NOT NULL,
  phone char(11) NOT NULL,
  password_hash char(65) DEFAULT NULL,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, 
  type_users_id INT not NULL, 
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_idx` (`email`),
  UNIQUE KEY `phone_idx` (`phone`),
  CONSTRAINT `phone_check` CHECK (regexp_like(`phone`,_utf8mb4'^[0-9]{11}$'))
  #CONSTRAINT fk_users_type FOREIGN KEY (type_users_id) REFERENCES typeofusers (id)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- `at`.profiles definition
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id bigint unsigned NOT NULL,
  gender enum('f','m','x') NOT NULL,
  birthday date NOT NULL,  
  city varchar(130) DEFAULT NULL,
  country varchar(130) DEFAULT NULL,
  PRIMARY KEY (user_id),    
  CONSTRAINT fk_profiles_users FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOCK TABLES `users` WRITE;
INSERT INTO `users` VALUES (1,'Guadalupe','Nitzsche','greenfelder.antwan@example.org','89213456678','d6f684fe75bdff654841d18f34c9acd6d3b05233','2011-12-04 16:57:02', 1),
(2,'Elmira','Bayer','xjacobs@example.org','89214507878','501a9b34edb153894128f6255ff3ef6bf0d3f4db','1990-01-20 18:48:26',1),
(3,'D\'angelo','Cruickshank','linwood.medhurst@example.org','89214567878','3273c607f8dfbc808adaa5493b7439ba08c3f43e','1994-09-04 15:21:06',2),
(4,'Princess','Runolfsson','huel.nash@example.org','89213455643','21444980cef626302f7ae9a507971889c9daac1d','1987-08-27 19:05:04',2),
(5,'Ethan','Legros','mhickle@example.org','89219567878','4dd91825495d2233602c0b0af6ff8b113b1844d9','1993-01-08 23:58:41',2),
(6,'Freda','Sporer','devyn70@example.net','89213457870','3df01bfd0a99988ca0383a49481e523226d4adca','1997-11-10 19:45:09',2),
(7,'Bonnie','Prosacco','hester.marvin@example.com','89213332222','10db70a3dcce2a22dd8eabdc7342260c91ff1749','1982-09-30 14:12:03',2),
(8,'Sierra','Bruen','aprosacco@example.net','89212222334','99fbaa12eecf0e10bf372dbf9cf7f98267b6636e','2004-01-28 04:41:46',2),
(9,'Trudie','Heller','hjohnston@example.net','89213336675','33b1681186add7816a701f570615c9d0aae215ab','1999-06-10 12:49:14',2),
(10,'Shaylee','Sawayn','pagac.clarissa@example.org','89212233456','b1771cc64742c38ec18ac67a4e61597b05cc9e20','1973-12-14 01:24:44',2),
(11,'Demarco','Eichmann','lakin.ethel@example.org','89233388787','f7f50eddf4d112d2d858510211128b8e0de60f84','2006-02-22 14:32:06',2);
UNLOCK TABLES;

LOCK TABLES `profiles` WRITE;
INSERT INTO `profiles` VALUES (1,'m','1989-04-09','Hamillfurt','Austria'),
(2,'x','1991-11-11','Westburgh','Austria'),
(3,'f','2000-10-01','Camilahaven','Russia'),
(4,'f','1977-12-18','Osinskibury','USA'),
(5,'f','1985-10-14','Raphaellestad','USA'),
(6,'x','2006-12-02','Hansenburgh','USA'),
(7,'x','2014-12-27','Jessycamouth','Russia'),
(8,'x','1970-04-06','East Carrieborough','Canada'),
(9,'x','2020-02-28','Anabellestad','Canada'),
(10,'m','1992-01-27','Port Charity','Germany'),
(11,'x','2002-04-29','West Lenniemouth','France');
UNLOCK TABLES;

/* различные настройки базы. Храню признак логирования. id = 1 поле value 1 - база логируется, 0 - нет. */
DROP TABLE IF EXISTS settings;
CREATE TABLE settings (
id int unsigned not null,
value varchar(100),
primary key (id)
);
insert into settings values (1, 1); 


DROP TABLE IF EXISTS books;
CREATE TABLE books (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `author_id` bigint unsigned NOT NULL,
  `title` TEXT default NULL,
  `text` TEXT default NULL,
  `price` mediumint default NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_books_author FOREIGN KEY (author_id) REFERENCES users (id)
) AUTO_INCREMENT=1 ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `books` (`author_id`,`title`,`text`,`price`)
VALUES
  (2,"ultrices. Duis","Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu iaculis enim, sit amet ornare lectus justo eu arcu. Morbi sit amet massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum",155),
  (6,"augue","fringilla ornare placerat, orci lacus vestibulum lorem, sit amet ultricies",148),
  (4,"ut lacus.","nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat dolor vitae dolor. Donec fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh.",136),
  (2,"facilisis facilisis,","luctus et ultrices posuere cubilia Curae Phasellus ornare. Fusce mollis. Duis sit amet diam eu dolor egestas rhoncus. Proin nisl sem, consequat nec, mollis vitae, posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per",115),
  (5,"faucibus.","faucibus lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula",103);
 
 



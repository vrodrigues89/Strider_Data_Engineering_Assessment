select * from `data`.authors
order by 1

drop table `data`.authors

select nvl(max(id),0) from authors

------------------------------------

drop table `data`.books

select * from `data`.books
order by 1

SHOW TABLES LIKE books


SELECT count(*) FROM INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'books'

SELECT 
  `authors`.`id`, 
  `authors`.`name`, 
  DATE_FORMAT(`authors`.`birth_date`, '%Y-%m-%d' ) AS birth_date, 
  DATE_FORMAT(`authors`.`died_at`, '%Y-%m-%d' ) AS died_at, 
  `authors`.`nationality`
FROM `authors`

SELECT ;

---------------------------

drop table `data`.reviews

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `review` varchar(500) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `book` varchar(200)  NOT NULL,
  `pages` int(11) NULL,
  `movie` varchar(200) NOT NULL,
  `updated` datetime DEFAULT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

select * from reviews
order by 1

SELECT 
id, 
review, 
rate, 
book, 
pages, 
movie, 
DATE_FORMAT(updated, '%Y-%m-%d %T') AS updated,
DATE_FORMAT(created, '%Y-%m-%d %T') AS created
FROM `data`.reviews;


---------------

SELECT count(*) FROM INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'movies'

drop table movies

select * from movies
order by 1

------------


drop table streams

select * from streams 
where user_email = 'courtney@tromp.net'
order by 1

select movie_title, user_email, count(*)  qty from streams 
group by movie_title, user_email
having count(*) > 1
order by 1

start_at	end_at

SELECT 
  `streams`.`id`, 
  `streams`.`movie_title`, 
  `streams`.`user_email`,
  `streams`.`size_mb`,
DATE_FORMAT(start_at, '%Y-%m-%d %T') AS start_at,
DATE_FORMAT(end_at, '%Y-%m-%d %T') AS end_at
FROM `streams`
order by 1

-----
drop table users

select * from users 
order by 1

select nvl(max(id),0)+1 as MaxID from data.users

SELECT count(*) FROM INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'users'
and TABLE_SCHEMA = 'data'

SELECT * FROM INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'users'
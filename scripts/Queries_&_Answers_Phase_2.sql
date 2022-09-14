/* Question 1 - What percentage of the streamed movies are based on books? */
/* Resp. 89.01% */

SELECT CONCAT(round(((QTY_MOVIES_BASED_BOOKS / QTY_TOTAL_MOVIES)*100),2),'%') PERC
FROM
(
SELECT DISTINCT COUNT(DISTINCT s.movie_title) QTY_TOTAL_MOVIES, COUNT(DISTINCT r.movie) QTY_MOVIES_BASED_BOOKS  FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 
LEFT JOIN reviews r
ON s.movie_title = r.movie
) AUX

/* Question 2 - During Christmas morning (7 am and 12 noon on December 25), a partial system outage was caused by a corrupted file. Knowing the file was part of the movie "Unforgiven" thus could affect any in-progress streaming session of that movie, how many users were potentially affected? */
/* Resp. 4 users */

SELECT COUNT(DISTINCT u.id) QTY
FROM streams s 
INNER JOIN users u /*checking if user is registered in users table*/
ON u.email = s.user_email
WHERE movie_title = 'Unforgiven'
AND (end_at > '2021-12-25 07:00:00' and start_at < '2021-12-25 12:00:00')

/* Question 3 - How many movies based on books written by Singaporeans authors were streamed that month? */
/* Resp. 3 movies */

SELECT count(distinct s.movie_title) QTY FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 
INNER JOIN reviews r
ON s.movie_title = r.movie
INNER JOIN books b 
on b.name = r.book 
INNER JOIN authors a 
on a.name = b.author 
and a.nationality like '%Singapor%'
WHERE DATE_FORMAT(start_at, "%Y-%m") = '2021-12'

/* Question 4 - What's the average streaming duration? */
/* Resp.  
 * Average in Seconds : 43.336
 * Average in Minutes: 722
 * Average in Hours: 12
 */

SELECT 
ROUND(AVG(TIMESTAMPDIFF(SECOND, s.start_at, s.end_at)),0) AVG_IN_SECONDS,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.start_at, s.end_at)),0) AVG_IN_MINUTES,
ROUND(AVG(TIMESTAMPDIFF(HOUR, s.start_at, s.end_at)),0)  AVG_IN_HOURS
FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 


/* Question 5 - What's the median streaming size in gigabytes? */
/* Resp. 1.1gb */

SELECT 
ROUND(AVG(s.size_mb)/1024,2) AVG_IN_GB
FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 


/* Question 6 - Given the stream duration (start and end time) and the movie duration, how many users watched at least 50% of any movie in the last week of the month (7 days)? */
/* Resp. 739 users */

SELECT COUNT(DISTINCT user_email) QTY
FROM
(
SELECT s.movie_title, s.user_email, TIMESTAMPDIFF(MINUTE, s.start_at, s.end_at) duration_stream_minutes, m.duration_mins as duration_movie_minutes, (m.duration_mins * 0.5) duration_stream_minutes_50, DATE_FORMAT(s.start_at,"%Y-%m-%d") start_at
FROM streams s 
INNER JOIN movies m 
ON m.title = s.movie_title 
INNER JOIN users u /*checking if user is registered in users table*/
ON u.email = s.user_email
WHERE DATE_FORMAT(s.start_at,"%Y-%m-%d") >= DATE_ADD('2021-12-31', interval -7 day)
order by DATE_FORMAT(s.start_at,"%Y-%m-%d")
) AUX
WHERE duration_stream_minutes >= duration_stream_minutes_50



# Dev Name: Vinicius de Almeida Rodrigues
# Project: Strider Data Engineering Assessment 3.0

### This set of code and instructions has the purpouse to instanciate a compiled environment with set of docker images such as Linux + JVM + Java Application Crontab, MariaDB and Pureftp.

## Overview
It’s Tuesday morning and the product manager you work with comes to you with several files asking for help. The dataset contains information about a small startup streaming app in the month of December 2021. The company keeps data about its users, movies, and streaming activity. In order to answer some important questions about the product, external data was also acquired with information about books, authors, and reviews that can be linked to internal movies data.

## Languages and Applications used:
* Java (For some developing components);
* Talend Open Studio 8 (For developing the data pipeline);
* Docker Desktop (For container virtualization);
* Crontab (For scheduling the jobs to run automatically);
* WinSCP (For accessing vendor FTP);
* Dbeaver (For accessing created tables and SQL queries).

## Current Architecture Diagram

![Screenshot](\images\current_architecture.drawio)

## Requirements for replicating the enviroment:
* Windows 10+
* Docker Desktop
* WinSCP
* Dbeaver

## Instructions
  
* Save "Vinicius-Rodrigues-3-0-data-engineering.zip" to root path in drive C.

* Open a Powershell terminal, run the following command to go to root in drive c:
cd c:

* Unzip "Vinicius-Rodrigues-3-0-data-engineering.zip" to drive C:
Expand-Archive -Force $pwd\Vinicius-Rodrigues-3-0-data-engineering.zip $pwd\

* Go to the new created folder
cd talendinfra

* Unzip original source files to the respective source folders:
Expand-Archive -Force $pwd\data\original\data.zip $pwd\data\source\internal\
Expand-Archive -Force $pwd\data\original\vendor.zip $pwd\ftp\vendor\

* Create database in network (It might be already created. Desconsider if any error)
docker network create database

* Run docker compose
docker-compose up -d

## Access

* WinScp for vendor FTP access
Host: localhost (127.0.0.1)
Port: 21
User: user
Password: user
Paths: 
/vendor -> Path where new files will be landed from vendor to be processed
/vendor/processed -> Path where files will be stored after being processed

* Dbeaver for MariaDb access
Host: localhost (127.0.0.1)
Port: 3306
Database: data
User: root
Password: root
Tables: authors,books,movies,reviews,streams,users

## Data Pipeline Run

Whenever the enviroment is started and all containers are up and running, the data pipeline is automatically scheduled to run the following way:

Vendor Loading Tables: At every 3 minutes
Internal Loading Tables: At every 7 minutes

cronjobs file are resposible for setting up the command in Crontab for automatically running.

IMPORTANT: Althought the vendor source files are coming once a day at 2am, the jobs are scheduled to run in a higher frequency to give the chance to see it running anytime is needed.

For a whole simulation process, follow the steps:

* Go to Dbeaver, connect to the database and run the commands below:
drop table `data`.books
drop table `data`.authors
drop table `data`.reviews
drop table `data`.movies
drop table `data`.streams
drop table `data`.users

* Allocate the source files in the respective source paths using the command below in Powershell terminal:
Expand-Archive -Force $pwd\data\original\data.zip $pwd\data\source\internal\
Expand-Archive -Force $pwd\data\original\vendor.zip $pwd\ftp\vendor\

* Check if the internal source files are correctly allocated to: \talendinfra\data\source\internal

* Check if the vendor source files are correctly allocated in FTP to: /vendor

* After some minutes, check if the tables are created and propely populated:
select * from `data`.authors
order by 1
select * from `data`.books
order by 1
select * from `data`.reviews
order by 1
select * from `data`.movies
order by 1
select * from `data`.streams 
order by 1
select * from `data`.users 
order by 1

* Check if the internal source files are correctly sent with datetime to: \talendinfra\data\source\internal\processed

* Check if the vendor source files are correctly sent with datetime in FTP to: /vendor/processed 

* Check if the vendor source files are correctly sent with datetime in FTP to: \talendinfra\data\source\vendor\processed

* For tracking the executions, run the following commands in Powershell terminal to check the log:

* Go to the root project directory
cd talendinfra

* Show running Containers
docker ps

* Get the CONTAINER ID from talendinfra-crontab IMAGE and run the command below for showing container logs
docker logs <CONTAINER ID>

### Accessment Details:

## Phase 1

## Overview
Due to unknown reasons, the vendor can delete and/or update existing records content (authors, books, and reviews data). Since we want to extract the best of the data we should retain historical records even if they got deleted on newly received dumps and avoid duplications in case of existing records updates.
Keeping that in mind, build an Extract, Transform, Load (ETL) pipeline that will take this data (and any newly received data) and move it into a **production-ready database** that can be easily and performant queried to answer questions for the business.

* It was created the following ETL jobs for loading vendor files:

![Screenshot](\images\vendor_jobs.jpg)

* j_00_vend_load_tab_main: Job responsible for orchestrating all vendor jobs
* j_01_vend_get_files_ftp: Job to get vendor files by FTP
* j_02_vend_load_authors: Load data into authors table
* j_03_vend_load_books: Load data into books table
* j_04_vend_load_reviews: Load data into reviews table
* j_05_vend_move_proc_files_ftp: Job to move processed vendor files in FTP

* It was created the following ETL jobs for loading internal files:

![Screenshot](\images\internal_jobs.jpg)

* j_00_int_load_tab_main: Job responsible for orchestrating all internal jobs
* j_01_int_load_movies: Load data into movies table 
* j_02_int_load_streams: Load data into streams table
* j_03_int_load_users: Load data into users table
* j_04_int_move_processed_files: Job to move processed internal files

* For each loading job, it was created a data pipeline to CDC data to check if the record is new or not. If it's new, INSERT. If it's not new and there is any change, UPDATE.

![Screenshot](\images\Data_Pipeline_Standard.jpg)

Details of Data Pipeline Standard:

* Pre-Job:
1 - Open Connection to MariaDB;
2 - Check if target table already exists:
    2.1 - If NOT: CREATE TABLE and set MaxID variable to 1
    2.2 - If YES: Query target table to get MAX ID sequence and set MaxID variable according to MAXID sequence.

* Main Job:

1 - Log start datetime;
2 - List source files to be processed;
3 - For each file, Read, Transform and append to a Staging File (\talendinfra\data\staging);
4 - Read Staging File;
5 - Treat nulls;
6 - Generate a Hash for each record. This does not consider primary key columns;
7 - Read target table as Lookup;
8 - Generate a Hash for each record. This does not consider primary key columns;
9 - Join source x lookup and check the differences;
10 - If the record is new then INSERT to target table
11 - If the record is not new and there's any change in the non-primary key columns then UPDATE to target table.

* Post-Job:

1 - Close connection with MariaDb
2 - Log end datetime.

IMPORTANT: The jobs never do DELETE in order to keep the historical records.

## Phase 2

## Overview
Answer the following questions, and show the SQL queries you used to extract the data.

* Question 1 - What percentage of the streamed movies are based on books? 
* Resp. 89.01% 

SELECT CONCAT(round(((QTY_MOVIES_BASED_BOOKS / QTY_TOTAL_MOVIES)*100),2),'%') PERC
FROM
(
SELECT DISTINCT COUNT(DISTINCT s.movie_title) QTY_TOTAL_MOVIES, COUNT(DISTINCT r.movie) QTY_MOVIES_BASED_BOOKS  FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 
LEFT JOIN reviews r
ON s.movie_title = r.movie
) AUX

* Question 2 - During Christmas morning (7 am and 12 noon on December 25), a partial system outage was caused by a corrupted file. Knowing the file was part of the movie "Unforgiven" thus could affect any in-progress streaming session of that movie, how many users were potentially affected?
* Resp. 4 users 

SELECT COUNT(DISTINCT u.id) QTY
FROM streams s 
INNER JOIN users u /*checking if user is registered in users table*/
ON u.email = s.user_email
WHERE movie_title = 'Unforgiven'
AND (end_at > '2021-12-25 07:00:00' and start_at < '2021-12-25 12:00:00')

* Question 3 - How many movies based on books written by Singaporeans authors were streamed that month? 
* Resp. 3 movies 

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

* Question 4 - What's the average streaming duration?
* Resp.  
 * Average in Seconds : 43.336
 * Average in Minutes: 722
 * Average in Hours: 12

SELECT 
ROUND(AVG(TIMESTAMPDIFF(SECOND, s.start_at, s.end_at)),0) AVG_IN_SECONDS,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.start_at, s.end_at)),0) AVG_IN_MINUTES,
ROUND(AVG(TIMESTAMPDIFF(HOUR, s.start_at, s.end_at)),0)  AVG_IN_HOURS
FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 

* Question 5 - What's the median streaming size in gigabytes? 
* Resp. 1.1gb

SELECT 
ROUND(AVG(s.size_mb)/1024,2) AVG_IN_GB
FROM streams s 
INNER JOIN movies m /*checking if movie is registered in movies table*/
ON m.title = s.movie_title 

* Question 6 - Given the stream duration (start and end time) and the movie duration, how many users watched at least 50% of any movie in the last week of the month (7 days)?
* Resp. 739 users

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

## Phase 3

## Overview
In **as much detail as time provides**, describe how you would build this pipeline if you had more time for the test and planned to ship it in a production environment.
You should:
- Explain which technologies you would use (programming languages, frameworks, database, and pipeline) and **why** for each one
- Share a detailed architecture diagram
- Write down your reasoning process for the designed architecture, making sure you cover in detail the components and how they interact with each other.
- **Please provide as much detail as possible!**

* Resp.
Regarding the current developed pipeline, If I had more time, I would:
create context variables to all parameter fields. This context would be in a context table in database.
create tables for controlling the processes such as start and end datetime, status and historical to track all executions.
work with a git repository in Talend to versioning the jobs snapshots and releases.
create 3 environments: Local, UAT and PROD and each one would have it's own contexts variables.
create 3 different databases for simulating the 3 environments.
create stage database and the staging would be tables instead of files.
create error handling as well as an email to support with the log and error cause.
create reports and dashboards for data visualization in PowerBI.
create better logs for visualization.
create an entity-relationship model for applying PK, Indexes and FK.
create standardized column and table names.

I would use the following technologies:
- Talend Cloud Data Fabric for Data Integration - Talend provides a single, unified platform for data integration, data integrity, data governance, and real-time data delivery.
- Azure Data Lake Analytics for repository - Easily Develop And Run Massively Parallel Data Processing jobs. 
- Power BI for dataviz - We can collect your company data, whether it's located in the cloud or locally, and provides quick and easy access to this data.

Detailed architecture diagram:

![Screenshot](\images\architecture.drawio)





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

## Requirements for implementing the enviroment:
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

* Check if the internal source files are correctly allocated to: C:\talendinfra\data\source\internal

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

* For tracking the executions, run the following commands in Powershell terminal to check the log:

* Go to the root project directory
cd talendinfra

* Show running Containers
docker ps

* Get the CONTAINER ID from talendinfra-crontab IMAGE and run the command below for showing container logs
docker logs <CONTAINER ID>



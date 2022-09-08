FROM openjdk:11

# Update and install dependencies

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install cron

# Setting up working directory

RUN mkdir /talendinfra/
RUN mkdir /talendinfra/data/
WORKDIR /talendinfra/

# Folders and permissions Setup

COPY config/cronjobs /etc/cron.d/cjob
RUN chmod 0644 /etc/cron.d/cjob
RUN crontab /etc/cron.d/cjob
RUN chmod 755 /talendinfra/
RUN chmod 755 /talendinfra/data/
RUN touch /talendinfra/cron.log

# Entrypoint

CMD cron && tail -f /talendinfra/cron.log
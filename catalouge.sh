#!/bin/bash
DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    #$1 is argument you give
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... .$R FAILURE $N"
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
yum install nodejs -y &>>$LOGFILE
VALIDATE $? "NODEJS INSTALLED"
useradd roboshop &>>$LOGFILE
mkdir /app &>>$LOGFILE
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
cd /app &>>$LOGFILE
unzip /tmp/catalogue.zip&>>$LOGFILE
cd /app &>>$LOGFILE
npm install  &>>$LOGFILE
VALIDATE $? "NPM INSTALLED"
cp catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload &>>$LOGFILE
systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "CATALOUGE ENABLED"
systemctl start catalogue &>>$LOGFILE
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "MONGO RPO COPIED"
yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "MONOGODB-SHELL INSTALLED"
mongo --host 172.31.4.169 </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "MONGODB ENABLED"

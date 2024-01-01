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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "COPYING TO MONGO"
yum install mongodb-org -y &>>$LOGFILE
VALIDATE $? "INSTALLING MONGODB"
systemctl enable mongod &>>$LOGFILE
VALIDATE $? "MONGODB ENABLED"
systemctl start mongod &>>$LOGFILE
VALIDATE $? "STARTING MONGODB"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGFILE
systemctl restart mongod &>>$LOGFILE
VALIDATE $? "RESTARTING MONGODB"
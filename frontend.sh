#!/bin/bash

LOG_FOLDER=/var/log/expense-backend
mkdir -p $LOG_FOLDER
SCRIPT_NAME=$(echo "$0" | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)
CHECK_ROOT()
{
    if [ $USER_ID -ne 0 ]
    then
        echo "Please run the script through root access i.e SUDO :"
        exit 1
    fi
}

VALIDATE()
{
    if [ $1 -eq 0 ]
    then 
        echo -e "$2.... is $G SUCCESS $N"
    else
        echo -e "$2 .... is $R FAILED $N"
        exit 1
    fi
}
CHECK_ROOT


dnf install nginx -y 
VALIDATE $? "Installing Nginx "

systemctl enable nginx
VALIDATE $? "Enabling Nginx"


systemctl start nginx
VALIDATE $? "Starting Nginx"


rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing Default site "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading the content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "Extracting the front end zipped content"

cp /home/ec2-user/expense-shell-project/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "creating conf file "

systemctl restart frontend
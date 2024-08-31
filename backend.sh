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

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disabling Nodejs "| tee -a $LOG_FILE

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enabling Nodejs"| tee -a $LOG_FILE

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installing Nodejs "| tee -a $LOG_FILE


id expense
if [ $? -ne 0 ]
then 
    echo "user is not added .Adding now"
    useradd expense
else
    echo "User expense is already added.. so skipping"
fi
mkdir -p /app &>>LOG_FILE
VALIDATE $? "Making the directory"| tee -a $LOG_FILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"




mkdir -p /app &>>LOG_FILE
VALIDATE $? "Making the directory"| tee -a $LOG_FILE

npm install&>>LOG_FILE 
cp /home/ec2-user/expense-shell-project/backend.service /etc/systemd/system/backend.service


systemctl daemon-reload&>>$LOG_FILE
VALIDATE $? "Reloading the application"

systemctl start backend&>>$LOG_FILE
VALIDATE $? "Starting the backend application"

systemctl enable backend&>>$LOG_FILE
VALIDATE $? "Enabling the backend application"

dnf install mysql -y&>>$LOG_FILE
VALIDATE $? "Installing Mysql service"


mysql -h <daws81s-mysql.reyanshsai.online> -uroot -pExpenseApp@1 < /app/schema/backend.sql

systemctl restart backend>>$LOG_FILE
VALIDATE $? "Restaring the backend"





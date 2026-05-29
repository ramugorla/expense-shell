#!/bin/bash 

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/script-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


if [ $USERID -ne 0 ]
then 
    echo "Error:: You should have root access to run this script"
fi 

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

dnf install nginx -y &>>$LOG_FILE_NAME
validate $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
validate$? "Enabling nginx"

systemctl start nginx &>>$LOG_FILE_NAME
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/*
validate $? "Removing existing nginx config"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate $? "Dowloading code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
validate $? "Unzip the code"

cp  /home/ec2-user/expense-shell/expense.conf /etc/systemd/system/expense.conf


systemctl restart nginx


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

mkdir -p $LOGS_FOLDER
dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validate $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
validate "Installing Nodejs is"

id expense 

if [ $? -ne 0 ]
then
    echo "Adding Expense user"
    useradd expense &>>$LOG_FILE_NAME
    validate $? "Adding user"
else
    echo "Expense User already added"
fi

mkdir -p /app &>>$LOG_FILE_NAME
validate $?  "App directory Already create"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

unzip /tmp/backend.zip
validate $? "Unzip the file"

cd /app

npm install
validate $? "Installing Dependencies"

cp -r /home/ec2-user/expense-shell /etc/systemd/system/backend.service


systemctl daemon-reload
validate $? "Systemctl service reloading"

systemctl start backend
validate $? "backsend restart"

systemctl enable backend
validate $? "enabling backend"

dnf install mysql -y
validate $? "Installing mysql client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "Creating mysql schema"

systemctl restart backend

systemctl status backend 




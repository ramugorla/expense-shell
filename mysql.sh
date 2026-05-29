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
    echo "Error:: You should have root access to execute this script"
    exit 1
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
dnf install mysql-server -y &>>$LOG_FILE_NAME
validate $? "Mysql Server installation"

systemctl enable mysqld &>>$LOG_FILE_NAME
validate $? "Enabling Mysqld"

systemctl restart mysqld &>>$LOG_FILE_NAME
validate $? "Starting Mysqld"

systemctl status mysqld &>>$LOG_FILE_NAME
netstat -lntp &>>$LOG_FILE_NAME
ps -ef | grep mysqld &>>$LOG_FILE_NAME

mysql -h 172.31.8.210 -u root -pExpenseApp@1 -e "show databases;"

if [ $? -ne 0 ]
then
    echo "Mysql password not set up"
    mysql_secure_installation --set-root-pass ExpenseApp@1 
    validate $? "Setting root password to Mysql"
else
    echo "Mysql Root password already set up"
fi


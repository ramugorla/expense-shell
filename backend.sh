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


dnf module disable nodjs -y 
validate $? "Disabling nodejs"

dnf module enable nodejs:20 -y 
validate $? "enabling nodejs 20"

dnf install nodejs -y
validate "Installing Nodejs is"

useradd expense 
validate $? "Adding user"

mkdir /app
validate $? "Creating App directory"




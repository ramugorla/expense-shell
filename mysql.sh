#!/bin/bash


USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Error:: You should have root access to execute this script"
    exit 1
fi

dnf install mysql-server -y 

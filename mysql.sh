LOG_FOLDER=/var/log/expense
mkdir -p LOG_FOLDER
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
    if[ $1 -eq 0 ]
    then 
        echo -e "$2.... is $G SUCCESS $N"
    else
        echo "$2 .... is $R FAILED $N"
        exit 1
    fi
}

dnf install mysql-server -y&>>$LOG_FILE
VALIDATE $? "Installing Mysql server"

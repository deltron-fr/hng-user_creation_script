
# Check if the User has elevated privileges
if [[ $EUID -ne 0 ]]
then
    echo "Execute this script as the root user"
    exit 1
fi

# Check if the text file was passed as an argument
if [[ $# -eq 0]]
then
    echo "Pass in a text file as argument"
    exit 2
fi

filename="$1"
if [[ -f $filename ]]
then
    echo "The file exists"
fi

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Creating files and assigning permissions

touch $LOG_FILE
mkdir -p /var/secure
chmod 700 /ar/secure
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Function to generate a random password

generate_password(){
    openssl rand -base64 12
}

#users=$(cut -d ";" -f1 $filename)
while IFS=";" read -r username groups;do

    # Trimming whitespace
    username=$(echo "username" | tr -d '[:space:]')
    groups=$(echo "group" | tr -d '[:space:]')

    # Check if the User already exists
    if id $username &>/dev/null ;then
        echo "The User $username already exists!"
    else
        if ! getent group "$username" &>/dev/null;then
            echo "The group $username does not exist, creating group..." 
            sudo groupadd "$username"
        fi        

        useradd -m -g $username -s /bin/bash/ "$username"

        password=$(generate_password)
        echo "$username:$password" | chpasswd

    # Check if the group exists
        IFS=',' read -ra group_array <<< "$groups"
            for group in "${group_array[@]}"; do
                if ! getent group "$group" &>/dev/null; then
                    groupadd "$group"

                fi
                usermod -aG "$group" "$username"
 
            done
    fi
done < "$1"
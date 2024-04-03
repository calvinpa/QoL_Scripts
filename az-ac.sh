while getopts rl flag
do 
    case "$flag" in
    r) revoke=true;;
    l) login=true;;
    esac
done

function az_login {
    output=$(az login --output json --query "statusCode")
    login_pid=$!

    # Check if the login was successful
    wait $login_pid
    
    if [ $? -eq 0 ]; then
        echo "Successfully logged in"
    else
        echo "Failed to login"
        exit 1
    fi
}

user=$(az account show --query user.name)
echo "Current user: $user"

if [ -n "$user" ]; then
    echo "Current user: $user already logged in"
    if [ "$revoke" = true ]; then
        echo "Revoking current user: $user from the session"
        az logout

        if [ "$login" = true ]; then
        echo "ask user to login..."
        az_login
        fi
    fi
else
    echo "No user is currently logged in"
    if [ "$revoke" = true ]; then
        echo "Cannot revoke as there is no user that is logged in"
    fi

    az_login
fi

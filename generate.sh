#!/bin/bash

# credit to Alexander Klimetschek answer at https://unix.stackexchange.com/a/415155
function select_option {
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    for opt; do printf "\n"; done

    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}

echo "Welcome to the NGINX config generator"
echo "Created By Zainokta"
echo "zainokta@gmail.com"
echo ""
echo "This generator only generate simple NGINX config, you need to configure manually for another config if necessary"
echo "There are two options for this generator"
echo "1. For service config generator"
echo "ex. web service that using ip:port to run"
echo "2. For index file config generator"
echo "ex. HTML CSS or PHP Website"
echo ""
echo "Choose your option:"

option_generator_type=("Service" "Index")
generator_type=""
case `select_opt ${option_generator_type[@]}` in
    0) generator_type="service";;
    1) generator_type="index";;
esac

echo -e "\nEnter your domain name (example.com): "
read server_name
if [[ $server_name == "" ]]; then
    echo "Domain name cannot be empty."
    exit;
fi

echo -e "\nEnter your project name (my-awesome-project): "
read project_name
if [[ $project_name == "" ]]; then
    echo "Project name cannot be empty."
    exit;
fi

directory_paths=$(locate $project_name | grep /$project_name$)

echo -e "\nSelect your project directory path: "
directory_path=${directory_paths[$(select_opt ${directory_paths[@]})]}
echo $directory_path

echo -e "\nEnter your directory root (/public): "
read directory_root
if [[ $directory_root == "" ]]; then
    directory_root='/'
fi
echo $directory_path$directory_root

filename=""
case $generator_type in
    service)
        filename=${server_name}.conf
        cp ./stub/nginx.api.stub $filename

        echo -e "\nEnter your service endpoint (localhost:3000): "
        read proxy_pass
        sed -i "s|proxy_pass_placeholder|$proxy_pass|gi" "$filename"
        ;;
    index)
        filename=${server_name}.conf
        cp ./stub/nginx.html.stub $filename
        ;;
esac

sed -i "s|server_name_placeholder|$server_name|gi" "$filename"
sed -i "s|directory_path_placeholder|$directory_path|gi" "$filename"
sed -i "s|directory_root_placeholder|$directory_root|gi" "$filename"

# move generated file to nginx sites available
mv $filename /etc/nginx/sites-available/

# create symlink to sites enabled
ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled/

# reload nginx service
service nginx reload

# TODO : CERTBOT
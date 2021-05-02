# Zenginx
This is a generator to generate simple NGINX configuration file. Edit the generated file as you need on `/etc/nginx/sites-available` and don't forget to reload the NGINX service by using `sudo service nginx reload` or ```sudo systemctl reload nginx``` after you finished editing the generated file. 

# How To Run

```
sudo ./generate.sh
````

# Connection upgrade issue 
add these line on your `nginx.conf` file
```
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```

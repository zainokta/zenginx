# Zenginx
Simple NGINX config file generator

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


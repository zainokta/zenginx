# Zenginx
Simple NGINX config file generator

# How To Run

```
sudo chmod +x ./generate.sh
./generate.sh
````

# Connection upgrade issue 
add these line on your `nginx.conf` file
```
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```

I will update README later
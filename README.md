# Bedrock WordPress Local Development Environment with Docker & Docker Compose

Install docker https://docs.docker.com/get-docker/

Instructions on how to set up a Bedrocl WordPress local dev enviroment using this repository files:

1. Create your project folder
2. Download the files or clone the repo to your project folder
3. Replace the 'env-files/.env.localdev' database credentials and the 'WP_HOME'
4. Replace the 'server-conf/nginx/nginx.conf' server_name with the same name you used on WP_HOME (without 'http://')
5. Replace all the containers' names, and database credentials in the docker-compose.yml file
6. Use your terminal to `cd` into your project folder and run the command `docker-compose --project-name your-project-name up -d --build`
7. Open the Docker Desktop UI to check all 4 containers are mounted and running
8. On docker desktop open the php container cli and run: 'composer create-project roots/bedrock' to create the Bedrock WordPress. Wait until the installation finishes.
9. Edit your computer hosts file to add your new project server name so it will map to your application. The hosts file is a simple text file that contains any hostnames or domain names used in your local system. At the bottom of this file you should add the following lines:

   ```
   127.0.0.1 projectname.local 
   127.0.0.1 www.projectname.local 
   ```

   In Linux systems you will find it under '/etc/hosts'. In a Windows 10 machine you will probably find it under 'C:\Windows\System32\drivers\etc' and you can open/edit it with the Notepad. If you cannot save the file, try opening the Notepad as Administrator. For other systems, you will need to ask google to give you the hint where the hosts file is located. :)

10. Now you can use any browser to access your application using http://projectname.local/. As the hostname is set up in your system and hosted in your system (inside a docker container) it is not published on the internet. Only your machine/system will be able to access this url.
11. Now you are good to go. To access the website go to: http://projectname.local
12. To access the WordPress admin got to: http://projectname.local/wp/wp-admin
13. To access the PHPMyAdmin go to: http://projectname.local:8080

## Containers/Services

The docker-compose.yml file will mount 4 containers/services:

- DB (the database)
- PHP (PHP 7.3)
- NGinx (the server)
- PHPMyAdmin (free software to manage the database)

### DB Container

* Uses the `mariadb` docker image to install MySQL in the container.
* Set up MySQL database name, root password, and user. 
* Uses port 3306 in both docker host (your physical computer system) and inside the container. 
* Uses shared volume: 
  - `/wp-data` in the docker host (inside your project folder structure) shares files with `/var/lib/mysql` inside the container. That means that all mysql files created inside the container can be found in your project `wp-data` folder.

### PHP Container

* Uses the `php:php7.3-fpm-alpine` docker image to install php inside the container.
* As Bedrock uses env files for setting up environments, we will use the .env file we have in the 'env-files' folder. The database credentials in the env file and the DB container environment should match. 
* Build will run the Dockerfile. The Dockerfile will basically install the MySQLi extension to the PHP (apparently it is not included in the docker PHP image I am using) and download Composer to the container as we will need it to install Bedrock and to manage the WP themes and plugins.
* Uses shared volume: 
  - `/wp-app` in the docker host shares files with `/var/www/html` inside the container. All the WordPress files created inside the container can be found in your project `wp-app` folder. And you will use this folder to create/update WP themes, plugins and templates.
  - `/server-conf/php` in the docker host shares files with `/usr/local/etc/php/conf.d/` inside the container. When you donwload/clone this repo it already comes with `/server-conf/php/my.ini` and we are now telling docker-compose to use this existing file as an extra config for php inside the container. It will mostly raise the php max_upload_size limits.

### NGinx Container

* Uses the `nginx` docker image to install nginx into the container.
* Depends on the DB container. It will only be mounted when the DB container is ready
* Links to the PHP container.
* Uses port 80 in both the docker host and inside the container. 
* Uses shared volume: 
  - `/wp-app` in the docker host shares files with `/var/www/html` inside the container. 
  - `/wp-app/logs/nginx` in the docker host shares files with `/var/log/nginx` inside the container. Then, the server logs generated at `/var/log/nginx` can automatically be found in your project `/wp-app/logs/nginx`.
  - `/server-conf/nginx` in the docker host shares files with `/etc/nginx/conf.d` inside the container. When you donwload/clone this repo it already comes with `/server-conf/nginx/nginx.conf` and we are now telling docker-compose to use this existing file as an extra config for the nginx server inside the container. It tells the server to listen to port 80, it sets up the server name as `projectname.local` and the default website files as index.php, index.html or index.html. It determines the root path where the website/application files should be found inside the container. It determines the path for the server access and error logs inside the container.


### PHPMyAdmin Container

* Uses the `phpmyadmin/phpmyadmin` docker image to install PHPMyAdmin into the container.
* Links to the DB container.
* Uses port 8080 in the docker host and port 80 inside the container. That means that from your computer/browser you have to access http://projectname.local:8080 to access the PHPMyAdmin.

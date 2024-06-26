*Clone this repository anywhere on your machine:
git clone https://git.softrobotics.com.tr/Softrobotics-IT/Laravel-Docarize.git

*Your folder structure should look like this:
Laravel-Docarize
project-z

*Edit your web server sites configuration.
We’ll need to do step 1 of the Usage section now to make this happen.

*cp .env.sr.example .env At the top, change the APP_CODE_PATH_HOST variable to your project path.

*APP_CODE_PATH_HOST=path to /project-z/ Make sure to replace project-z with your project folder name.

*change env db_host, redis_host, queue_host value to "dockerhost" 

*docker-compose up -d apache2 workspace php-worker



#!/bin/sh

# Start php-fpm
php-fpm
tail -f /dev/null
# If php-fpm fails, print an error message and keep the container running
if [ $? -ne 0 ]; then
  echo "php-fpm failed to start. Keeping the container alive."
  tail -f /dev/null
fi

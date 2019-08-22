#!/bin/bash

echo -e "Pull aditional images ...\n"
docker pull unjudge/opt-cpp-backend
docker pull unjudge/inginious-c-base
docker pull unjudge/inginious-c-default
docker pull unjudge/uncode-c-base
docker pull unjudge/inginious-c-multilang

echo -e "Tag new images ...\n"
docker tag unjudge/opt-cpp-backend:latest pgbovine/opt-cpp-backend:v1
docker tag unjudge/inginious-c-base ingi/inginious-c-base
docker tag unjudge/inginious-c-default ingi/inginious-c-default
docker tag unjudge/inginious-c-multilang ingi/inginious-c-multilang

echo -e "Restar ssh service ...\n"
service ssh restart 1>/dev/null 2>/tmp/ssh.log

if [[ -e /tmp/.firstrun ]]; then
    echo "First init for mongo ..."
    /usr/bin/mongod --port 27017 --dbpath /data/db --nojournal &
    while ! nc -vz localhost 27017; do sleep 1; done
    # Create User
    echo "Creating user: ..."
    mongo --quiet --eval "db.users.insert({
    'username' : 'superadmin',
    'realname' : 'superadmin',
    'language' : 'en',
    'password' : '964a5502faec7a27f63ab5f7bddbe1bd8a685616a90ffcba633b5ad404569bd8fed4693cc00474a4881f636f3831a3e5a36bda049c568a89cfe54b1285b0c13e',
    'email' : 'superadmin@inginous.org',
    'bindings' : {}})"

    # Stop MongoDB service
    /usr/bin/mongod --dbpath /data --shutdown
    rm -rf /tmp/.firstrun

#/usr/bin/mongod --port 27017 --dbpath /data/db --smallfiles --oplogSize 128 1>/dev/null 2>/tmp/mongo.log
fi

echo -e "Starting MongoDB...\n"
/usr/bin/mongod --port 27017 --dbpath /data/db --auth $@ --smallfiles --oplogSize 128 1>/dev/null 2>/tmp/mongo.log

echo -e "Restart nginx service ...\n"
service nginx restart 1>/dev/null 2>/tmp/nginx.log

echo -e "Restart lighttpd service  ...\n"
service lighttpd restart 1>/dev/null 2>/tmp/ligthttpd.log

echo -e "Restart nodejs app ...\n"
node cokapi.js 1>/dev/null 2>/tmp/node.log
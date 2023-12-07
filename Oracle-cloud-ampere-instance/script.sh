#!/bin/bash

while [ True ];
do
    terraform apply -auto-approve > /dev/null 2>&1 && echo "Success!" && break
    echo "Failed!"
    sleep 10
done
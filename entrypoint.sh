#!/bin/bash

sed -i 's/fr24key=".\+"/fr24key="'"${FR24_KEY}"'"/g' /etc/fr24feed.ini

/fr24/fr24feed
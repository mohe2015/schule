#!/bin/bash

update_hash () {
	hash=($(sha512sum www/$1))
	sed -r 's/'$1'\?v=[a-f0-9]+/'$1'\?v='$hash'/g' www/index.html
}

update_hashes () {
	update_hash 'index.js'
}

update_hashes

while true; do

inotifywait --event modify -r www/ --exclude '.*kate-swp'
update_hashes

done

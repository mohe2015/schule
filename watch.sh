#!/bin/bash

update_hash () {
	hash=($(sha512sum www/$1))
	sed -r -i 's/'$1'\?v=[a-f0-9]+/'$1'\?v='$hash'/g' www/index.html
}

update_hashes () {
	update_hash 'bootstrap.css'
	update_hash 'all.css'
	update_hash 'summernote-bs4.css'
	update_hash 'index.css'
	update_hash 'mathlive.core.css'
	update_hash 'mathlive.css'
	update_hash 'jquery-3.3.1.js'
	update_hash 'popper.js'
	update_hash 'bootstrap.js'
	update_hash 'summernote-bs4.js'
	update_hash 'visual-diff.js'
	update_hash 'index.js'
	update_hash 'mathlive.js'
	update_hash 'summernote-math.js'
}

update_hashes

while true; do

inotifywait --event modify -r www/ --exclude '.*kate-swp'
update_hashes

done

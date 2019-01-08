#!/bin/bash
while true; do

inotifywait --event modify -r www/ --exclude '.*kate-swp' && echo "Change detected"

done

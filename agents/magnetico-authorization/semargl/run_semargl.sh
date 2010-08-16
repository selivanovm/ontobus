#!/bin/sh
while [ 1 ]; do
        ./Semargl
        time=`date +%Y-%m-%d_%T`
        mv app.log "app.$time.log"
done
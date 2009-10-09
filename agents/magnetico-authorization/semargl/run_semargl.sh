#!/bin/sh
while [ 1 ]; do
        ./Semargl.test
        time=`date +%Y-%m-%d_%T`
        mv app.log "app.$time.log"
done
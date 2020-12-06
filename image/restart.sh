#!/bin/sh
while true
do
        sh start.sh
        echo "Run Ctrl+C to cancell the auto restart process"
        echo "Rebooting in"
        for i in 5 4 3 2 1
        do
                echo "$i..."
                sleep 1
        done
        echo "Rebooting now!"
done

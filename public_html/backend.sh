#!/bin/sh

echo "Content-Type: text/plain\n\n"
mongoexport -h 172.31.74.128 -d db1 -c dataSet 2>&1 | grep '^[{]' | sed 's/"_id.*}, //'

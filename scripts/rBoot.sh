#!/bin/bash

WCOUNT="$(ls -1q /usr/share/plymouth/themes/ | wc -l)"
WCOUNT=$(($WCOUNT - 3))

if [ ! -z $1 ]; then
    WHICH=$1
else
    WHICH=$((1+$RANDOM%$WCOUNT))
fi
echo $WHICH > /tmp/bootAnimation
plymouth-set-default-theme -R $WHICH

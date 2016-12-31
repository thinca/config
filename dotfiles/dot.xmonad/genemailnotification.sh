#!/bin/bash
while true ; do
    python /home/thinca/.xmonad/dzenGmailNotify.py
    sleep 30
done | dzen2 -ta r -l 5 -bg '#808080' -x 700 -w 380

#!/bin/sh

echo "=== $(date) launching ninbot" >> /tmp/ninbot.log
exec java -jar "$HOME/mcsr/Ninjabrain-Bot-1.5.2.jar" >> /tmp/ninbot.log 2>&1

#!/bin/bash

cd /home/millankumar/code/ImageConvertBot/image_convert_bot

docker build -t imageconvertbot .

docker run --rm -e DISCORD_BOT_TOKEN="" imageconvertbot
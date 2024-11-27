#!/bin/bash

cd /home/millankumar/code/ImageConvertBot/image_convert_bot
export DISCORD_BOT_TOKEN=""

mix deps.get
mix compile
mix run --no-halt


# docker build -t imageconvertbot .
# docker run --rm -e DISCORD_BOT_TOKEN="" imageconvertbot

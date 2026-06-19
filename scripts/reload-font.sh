#!/bin/bash
# Toggle iTerm profile to force font cache reload
printf '\e]1337;SetProfile=Default\a'
sleep 0.3
printf '\e]1337;SetProfile=valentine\a'
echo "Font reloaded"

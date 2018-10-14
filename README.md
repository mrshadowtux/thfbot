# thfbot
A telegram bot for Xenforo based communities

This script was originally written for TechHistory (https://www.techhistory.de)

The bot requires the following to be installed on your server:
* bash (although other shells like zsh might work too)
* curl
* cut (should already be installed)
* grep (should already be installed)
* mysql client
* rsstail
* sed (should already be there)

Please run this script directly on your server as it interacts with the local MySQL database. Please also keep in mind that this script runs in foreground by default. I would recommend putting it into a detached session of screen/tmux or letting nohup do its job.


## Configuration
Configuration is done by thfbot.conf

This can be either put into the script directory, into ~/.config/thfbot.conf or into /etc/thfbot.conf

The user-specific paths are preferred by the script against the central one in /etc/thfbot.conf. This makes sure, that multi-user environments are properly supported.

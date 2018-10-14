# thfbot
A telegram bot for Xenforo based communities

This bot requires the following to be installed on your server:
* rsstail
* curl
* sed (should already be there)
* grep (should already be there)
* cut (should alaredy be there)
* mysql client

Please run this script directly on your server as it interacts with the local MySQL database.


## Configuration
Configuration is done by thfbot.conf

This can be either put into the script directory, into ~/.config/thfbot.conf or into /etc/thfbot.conf

The user-specific paths are preferred by the script against the central one in /etc/thfbot.conf. This makes sure, that multi-user environments are properly supported.

#!/bin/bash
# THFbot by mrshadowtux
# telegram bot for Xenforo based communities
# https://github.com/mrshadowtux/thfbot


# Configure me here :)
	# Bot ID - Use the telegram bot "Botfahther" to get a bot ID
	bot_id="xxxx"
	
	# Chat ID of your channel - Use https://api.telegram.org/YOUR_BOT_ID/getUpdates to find this out. Always starts with a -
	chat_id=-0000000000000 # channel
	
	# The interval in seconds at which the forum gets parsed for updates
	interval=30
	
	# Your MySQL credentials
	mysql_user="xxxx"
	mysql_pw="xxxx"
	mysql_db="xenforo"
	
	# The URL to your forum's RSS feed
	feed_url="https://techhistory.de/thf/forums/-/index.rss"
	
	# Localization
	locale_wrote="schrieb gerade"
	locale_goto="Zum Beitrag"



rsstail -u "${feed_url}" -r -l -i ${interval} | while read line
do
	post_link="$(echo ${line} | grep -i 'link' | sed 's/Link://gi')"
	if ! test -z "${post_link}" 
	then
		thread_id=$(echo ${post_link} | cut -d "/" -f 6 | cut -d "." -f 2)
		post_content=$(echo "select message from xf_post where thread_id=${thread_id} order by post_date desc limit 1" \
			| mysql -u${mysql_user} -p${mysql_pw} ${mysql_db} \
			| sed "s/\\\n/%0A/gi" \
			| grep -vi ^message \
		)

		post_user=$(echo "select username from xf_post where thread_id=${thread_id} order by post_date desc limit 1" \
			| mysql -u${mysql_user} -p${mysql_pw} ${mysql_db} \
			| grep -vi ^username \
		)

		post_link_latest=$(echo "${post_link}latest" | sed "s/ //gi")
		
		content_final="<b>${post_user} ${locale_wrote}:</b>%0A${post_content}%0A%0A<a href=\"${post_link_latest}\">${locale_goto}</a>%0A%0A"
		
		curl -s -X POST "https://api.telegram.org/${bot_id}/sendMessage" \
			-d disable_web_page_preview="true" \
			-d chat_id="${chat_id}" \
			-d parse_mode="html" \
			-d text="${content_final}"
	fi
done


#!/bin/bash
# THFbot by mrshadowtux
# telegram bot for Xenforo based communities
# https://github.com/mrshadowtux/thfbot


if test -e ~/.config/thfbot.conf; then
	source ~/.config/thfbot.conf
elif test -e ./thfbot.conf ; then
	source ./thfbot.conf
elif test -e /etc/thfbot.conf; then
	source /etc/thfbot.conf
else
	echo "Configuration file not found. Please put it into either ~/.config/thfbot.conf, directly into the script directory or /etc/thfbot.conf"
	echo "The user-specific variants are preferred to make it compatible with multi user environments. If none of them is found, the global variant in /etc/thfbot.conf is used"
	exit 1
fi


rsstail -u "${feed_url}" -r -l -i ${interval} | while read line
do
	post_link="$(echo ${line} | grep -i 'link' | sed 's/Link://gi')"
	if ! test -z "${post_link}" 
	then
		thread_id=$(echo ${post_link} | cut -d "/" -f 6 | cut -d "." -f 2)
		post_link_latest=$(echo "${post_link}latest" | sed "s/ //gi")
	
		post_content=$(echo "select message from xf_post where thread_id=${thread_id} order by post_date desc limit 1" \
			| mysql -u${mysql_user} -p${mysql_pw} ${mysql_db} \
			| sed "s/\\\n/%0A/gi" \
			| grep -vi ^message \
			| sed "s/\[URL\]//gi;s/\[\/URL\]//gi" \
			| sed "s/\[MEDIA=youtube\]/https:\/\/youtube.com\/watch?v=/gi;s/\[\/MEDIA\]//gi" \
			| sed "s/\[ATTACH=full\]/%0A<a href=\"${attachment_url}\/file\./gi" \
			| sed "s/\[\/ATTACH\]/\">${locale_image}<\/a>%0A/gi" \
			| sed "s/&//gi"
		)

		post_user=$(echo "select username from xf_post where thread_id=${thread_id} order by post_date desc limit 1" \
			| mysql -u${mysql_user} -p${mysql_pw} ${mysql_db} \
			| grep -vi ^username \
		)
		
		thread_title=$(echo "select title from xf_thread where thread_id=${thread_id}" \
			| mysql -u${mysql_user} -p${mysql_pw} ${mysql_db} \
			| grep -vi ^title \
		)

		
		content_final=""
		content_final="${content_final}<b>${post_user} ${locale_wrote} ${locale_inthread} '${thread_title}':</b>%0A"
		content_final="${content_final}${post_content}%0A%0A"
		content_final="${content_final}<a href=\"${post_link_latest}\">${locale_goto}</a>%0A%0A"
			
		
		curl -s -X POST "https://api.telegram.org/${bot_id}/sendMessage" \
			-d disable_web_page_preview="true" \
			-d chat_id="${chat_id}" \
			-d parse_mode="html" \
			-d text="${content_final}"
	fi
done


#!/bin/bash
# this is what connects unbound to pixelserv and tells unbound to redirect 
# ad domains to the pixelserv service

ad_list_url="http://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&mimetype=plaintext"
pixelserv_ip="<your LAN DNS IP here>"
ad_file="/path/to/configuration/dir/adlist.yoyo.conf"
backups="/path/to/configuration/dir/backup"
temp_ad_file="/path/to/configuration/dir/unbound.adlist.conf.tmp"

# NB torsocks may be a good idea if you're not using a VPN
#torsocks curl -sf $ad_list_url | sed "s/127\.0\.0\.1/$pixelserv_ip/" > $temp_ad_file # -silent -quiet-fail
curl -sf $ad_list_url | sed "s/127\.0\.0\.1/$pixelserv_ip/" > $temp_ad_file # -silent -quiet-fail

if [ -f "$temp_ad_file" ]
then
        # take a backup of the old one just in case
        cp $ad_file $backups/previous-$(date +%H-%M-%S-%d%m%Y)
        grep -e "^local-" $temp_ad_file > $ad_file # strip out anything funky
        rm $temp_ad_file

        # now the configuration is updated reload unbound
        # (refreshes the dns cache and updates with new configation of downloaded rules)
        unbound-control reload

        exit 0
else
        logger "Error building the ad list, please try again."
        echo "There was a problem creating the ad list for Unbound. Please check the server" | /opt/send/sendEncryptedMail "Ad smasher"
        exit 1
fi

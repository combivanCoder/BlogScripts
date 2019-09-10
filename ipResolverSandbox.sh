#!/bin/sh
# Because the firewall script needs to work off IP not domains (iptables rules don't work well 
# with domain names in the version on the routers), we simply run this script on a cron every 24
# hours to update a file.
# This file is a plain text list of IP's correlating to known bad-actor DNSoTLS servers, which are
# likely to have embedded use within mobile apps / OS and UWP 

## UK ISP DNS:
# https://www.increasebroadbandspeed.co.uk/uk-isp-dns-server-settings
#62.6.40.178 
#62.6.40.162
#194.72.9.38 indnsc36.nt.net / .ukcore.bt.net / ns8.bt.net
#194.72.9.34
#194.72.0.98
#194.72.0.114
#194.74.65.68
#194.74.65.69

## Configuration
# Special focus on cloudflare as they've partnered with faceflaps. Dns-over-tls ITEF working group was called "DPRIVE"
# https://code.fb.com/security/dns-over-tls/
knownNS="onedotonedotonedotone.cloudflare-dns.com dns.google resolver1-fs.opendns.com resolver2-fs.opendns.com blah.blah"
ipLists=""
failedDomains=""
targetListFile="dns-over-tls-target-servers.config"
failedLookupsFile="dns-over-tls-failed-lookups.config"

## Application and resolution
for server in $knownNS
do
	# NOTE there's some oddities between bash and (router) sh, which is why some of the code below isn't as efficient as
	# it could be e.g. grep return codes, parsing and piping done this way as workarounds
	lookup=$(dig $server)
	if $(echo "$lookup" | grep --quiet NOERROR); then
		for ip in $(echo "$lookup" | grep "^$server" | awk '{print $5}')
		do
			ipLists="$ipLists $ip"
		done
	else
		failedDomains="$failedDomains $server"
	fi
done

## DEBUG PRINTS / VERIFY
# echo "List: $ipLists"
# echo "Failed: $failedDomains"

## Output to list files - overwrite, no need to retain existing contents as landscape changes
echo $ipLists > $targetListFile
echo $failedDomains > $failedLookupsFile

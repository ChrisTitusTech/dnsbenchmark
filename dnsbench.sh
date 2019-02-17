#!/bin/bash

#Check for required utilities
if ! which bc > /dev/null
    then
        echo "bc was not found. Please install bc."
        exit 1
fi

if ! which dig > /dev/null
    then
    	if which drill > /dev/null
   			then
    		alias dig="drill"
    	else
        	echo "neither dig nor drill was not found. Please install dnsutils or ldns."
        	exit 1
    	fi
fi


PROVIDERS="
1.1.1.1#cloudflare 
1.0.0.1#cloudflare2nd 
4.2.2.2#level3
4.2.2.1#level3
208.67.222.222#opendns
208.67.220.220#opendns
209.18.47.61#Spectrum1st  
209.18.47.62#Spectrum2nd  
8.8.8.8#google 
8.8.4.4#google2nd
9.9.9.9#quad9 
185.228.168.168#cleanbrowsing 
176.103.130.132#adguard 
156.154.70.3#neustar 
8.26.56.26#comodo
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="www.google.com amazon.com facebook.com www.youtube.com www.reddit.com  wikipedia.org twitter.com gmail.com 
www.google.com whatsapp.com"


totaldomains=0
printf "%-15s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""


for p in $PROVIDERS; do
    pip=`echo $p| cut -d '#' -f 1`;
    pname=`echo $p| cut -d '#' -f 2`;
    ftime=0

    printf "%-15s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`dig +stats @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
	if [ -z "$ttime" ]; then
	    #let's have time out be 1s = 1000ms
	    ttime=1000
	fi
        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;

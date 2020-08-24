#!/bin/bash

# client.txt her calistirmada uzerine yaziliyor
>client.txt

# mesaj içerik tanimlamalari
ID=1
ogrno=128020080
message="packet from client"


for i in {0..9..1} # tcp  
    do
    timestamp=$(date)
    echo "{id:$ogrno, no:$ID, msg:$message, timestamp:$timestamp}" | socat - TCP4:localhost:5001  # ****port:5001****
    # echo $ogrno,$ID,$message,$timestamp | socat STDIO TCP4:localhost:5001
    echo "CLIENT-->{TCP}: {$message}{$ID}{$timestamp}" >> client.txt
    read -p "" -t 0.1
    ((ID++))
done


for i in {0..9..1} # udp 
    do
    timestamp=$(date)
    echo "{id:$ogrno, no:$ID, msg:$message, timestamp:$timestamp}" | socat - UDP4-DATAGRAM:localhost:5001  # ****port:5001****
    echo "CLIENT-->{UDP}: {$message}{$ID}{$timestamp}" >> client.txt
    read -p "" -t 0.1
    ((ID++))
done

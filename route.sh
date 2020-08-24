#!/bin/bash

# route.txt her calistirmada uzerine yaziliyor
>route.txt

my_func ()  #  "$line" parametre olarak alindi --> $1 degerini aldi
{
    # string manipulasyonları
    temp1=`echo "${1//{}"`       #  { karakteri silindi
    temp1=`echo "${temp1//\}}"`  #  } karakteri silindi, escape kullanildi
    temp1=`echo "${temp1//id:}"` #  "no:" yazisi silindi
    temp1=`echo "${temp1//no:}"` #  "id:"yazisi silindi
    temp1=`echo "${temp1//msg:}"` #  "msg:" yazisi silindi 
    temp1=`echo "${temp1//timestamp:}"` #mesaj a,b,c,d sekline geldi    
    readarray -td '' arr < <(awk '{ gsub(/, /,"\0"); print; }' <<<"$temp1, "); unset 'a[-1]';
    IFS=""
    if [ "$2" -eq 1 ]  # 2.parametre 1 ise tcp 
        then
        tcp_id+=(${arr[1]})        
        tcp_msg+=(${arr[2]})
        tcp_date+=(${arr[3]})
    fi  
    if [ "$2" -eq 2 ]  # 2.parametre 2 ise udp 
        then
        udp_id+=(${arr[1]})
        udp_msg+=(${arr[2]})
        udp_date+=(${arr[3]})
    fi    
}


for i in {0..9..1} # tcp dinleme
    do
        line=`socat - TCP4-LISTEN:5001` # ****port:5001****
        # echo "$line" # debug
        tcp_recv_date[i]=$(date) # her gelen deger icin date kaydedildi
        my_func "$line" "1" # fonksiyon cagrildi, ikinci parametre 1 ise tcp
done


for i in {0..9..1} # udp dinleme
    do
        line=`socat - UDP4-RECVFROM:5001` # ****port:5001****
        # echo "$line" # debug
        udp_recv_date[i]=$(date) # her gelen deger icin date kaydedildi
        my_func "$line" "2" # fonksiyon cagrildi, ikinci parametre 2 ise udp
done


for i in {0..9..1} # tcp olanlar 20002'ye gonderiliyor
    do
        echo "ROUTER-->TCP4: [{${tcp_msg[i]}}{${tcp_id[i]}}{${tcp_date[i]}}] {${tcp_recv_date[i]}} " >> route.txt
        timestamp=$(date) 
        echo "{id:121220094, no:${tcp_id[i]}, msg:${tcp_msg[i]}, timestamp:$timestamp}" | socat - TCP4:localhost:10005  # ****port:20002**** 
        read -p "" -t 0.1
done


for i in {0..9..1} # udp olanlar 10001'e gonderiliyor
    do
        echo "{id:121220094, no:${udp_id[i]}, msg:${udp_msg[i]}, timestamp:$timestamp}" | socat - UDP4-DATAGRAM:localhost:10001  # ****port:10001**** 
        timestamp=$(date) 
        echo "ROUTER-->UDP4: [{${udp_msg[i]}}{${udp_id[i]}}{${udp_date[i]}}] {${udp_recv_date[i]}} " >> route.txt
        read -p "" -t 0.1
done


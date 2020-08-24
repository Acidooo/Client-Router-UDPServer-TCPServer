#!/bin/bash

# udplog.txt her calistirmada uzerine yaziliyor
>udplog.txt

my_func ()  #  "$line" parametre olarak alindi --> $1 degerini aldi
{
    # string manipulasyonları
    temp1=`echo "${1//{}"`       #  { karakteri silindi 
    temp1=`echo "${temp1//\}}"`  #  } karakteri silindi, escape kullanildi
    temp1=`echo "${temp1//id:}"`
    temp1=`echo "${temp1//no:}"`
    temp1=`echo "${temp1//msg:}"`
    temp1=`echo "${temp1//timestamp:}"` # mesaj a,b,c,d sekline getirildi
    readarray -td '' arr < <(awk '{ gsub(/, /,"\0"); print; }' <<<"$temp1, "); unset 'a[-1]'; # arr icine atildi
    IFS=""
    udp_id+=(${arr[1]})
    udp_msg+=(${arr[2]})        
    udp_date+=(${arr[3]})   
}


for i in {0..9..1} # udp dinleme 
    do
        line=`socat - UDP4-RECVFROM:10001` # ****port:10001**** 
        # echo "$line" # debug
        udp_recv_date[i]=$(date)
        my_func "$line"
done


for i in {0..9..1} # alinan mesajlar degerleri ile beraber log dosyasına aktariliyor
    do
        echo "UDP-->[{${udp_msg[i]}}{${udp_id[i]}}{${udp_date[i]}}] {${udp_recv_date[i]}} " >> udplog.txt
done


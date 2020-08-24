#!/bin/bash

# tcplog.txt her calistirmada uzerine yaziliyor
>tcplog.txt

my_func ()  #  $line fonksiyona $1 olarak geldi
{
    # string manipulasyonları
    temp1=`echo "${1//{}"`       #  { karakteri silindi 
    temp1=`echo "${temp1//\}}"`  #  } karakteri silindi, escape kullanildi
    temp1=`echo "${temp1//id:}"`
    temp1=`echo "${temp1//no:}"`
    temp1=`echo "${temp1//msg:}"`
    temp1=`echo "${temp1//timestamp:}"` #mesaj a,b,c,d sekline geldi
    readarray -td '' arr < <(awk '{ gsub(/, /,"\0"); print; }' <<<"$temp1, "); unset 'a[-1]' # arr icine atildi
    IFS=""
    tcp_id+=(${arr[1]})
    tcp_msg+=(${arr[2]})        
    tcp_date+=(${arr[3]})   
}


for i in {0..9..1} # tcp dinleme 
    do
        line=`socat - TCP4-LISTEN:20002` # ****port:20002**** 
        # echo "$line" # debug
        tcp_recv_date[i]=$(date)
        my_func "$line"
done


for i in {0..9..1} # alinan mesajlar degerleri ile beraber log dosyasına aktariliyor
    do
        echo "TCP-->: [{${tcp_msg[i]}}{${tcp_id[i]}}{${tcp_date[i]}}] {${tcp_recv_date[i]}} " >> tcplog.txt
done

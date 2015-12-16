#!/bin/bash
# Collect data from a series of linux commands, then create html by
# substituting each result into template.html using tags

HTML_FN=$(hostname -s).html
rm -f $HTML_FN

ALL_COMMANDS=("hostname" "lscpu" "cat /proc/cpuinfo" "cat /proc/meminfo" "uname -a" \
    "lsblk" "df -h" "cat /etc/issue" "hostname -I")
ALL_TAGS=("TAG_HOSTNAME" "TAG_LSCPU" "TAG_CPUINFO" "TAG_MEMINFO" "TAG_LINUX" \
    "TAG_LSBLK" "TAG_DF" "TAG_OS" "TAG_IPADDR")

INDEX=$(cat template.html)

for ((i = 0; i < ${#ALL_COMMANDS[@]}; i++))
do
    COMMAND=${ALL_COMMANDS[i]}
    TAG=${ALL_TAGS[i]}
    # echo command is \"$COMMAND\", search is \"${TAG}\"
    $COMMAND > tmp
    DATA=$(cat tmp | perl -pe "s/\n/\<br\/\>/g")  # newlines --> line breaks
    DATA=$(echo $DATA | perl -pe "s/<br\/>$//")   # Remove trailing line break
    rm tmp
    HTML1=$(echo $INDEX | perl -pe "s/${TAG}.*//")
    HTML2=$(echo $INDEX | perl -pe "s/^.*${TAG}//")
    INDEX=$(echo $HTML1 $DATA $HTML2)
    echo $INDEX > $HTML_FN
done


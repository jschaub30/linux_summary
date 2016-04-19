#!/bin/bash
# Collect data from a series of linux commands, then create html by
# substituting each result into template.html using tags

HTML_FN=index.html
echo Creating $HTML_FN
rm -f $HTML_FN

ALL_COMMANDS=("hostname" "ifconfig -a" "lscpu" "cat /proc/cpuinfo" "cat /proc/meminfo" "uname -a" \
    "lsblk" "lspci" "df -h" "cat /etc/issue" "hostname -I" "nvidia-smi" \
    "date +%Y%m%d-%H%M%S" "lstopo")
ALL_TAGS=("TAG_HOSTNAME" "TAG_IFCONFIG" "TAG_LSCPU" "TAG_CPUINFO" "TAG_MEMINFO" "TAG_LINUX" \
    "TAG_LSBLK" "TAG_LSPCI" "TAG_DF" "TAG_OS" "TAG_IPADDR" "TAG_GPU" \
    "TAG_DATETIME" "TAG_LSTOPO")

INDEX=$(cat template.html)

for ((i = 0; i < ${#ALL_COMMANDS[@]}; i++))
do
    COMMAND=${ALL_COMMANDS[i]}
    TAG=${ALL_TAGS[i]}
    # echo command is \"$COMMAND\", search is \"${TAG}\"
    $COMMAND 1>tmp 2>/dev/null
    if [ $? -eq 0 ]
    then
      DATA=$(cat tmp | perl -pe "s/\n/\<br\/\>/g")  # newlines --> line breaks
      DATA=$(echo $DATA | perl -pe "s/<br\/>$//")   # Remove trailing line break
      rm tmp
      HTML1=$(echo $INDEX | perl -pe "s/${TAG}.*//")  # before tag
      HTML2=$(echo $INDEX | perl -pe "s/^.*${TAG}//") # after tag
      INDEX=$(echo $HTML1 $DATA $HTML2) # combine before and after
      echo $INDEX > $HTML_FN
    fi
done

IP=$(hostname -I | cut -d' ' -f1)
echo To view $HTML_FN, run \"python -m SimpleHTTPServer 12345\"
echo then navigate to http://${IP}:12345

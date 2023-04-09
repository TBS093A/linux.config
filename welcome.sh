#!/bin/bash

export WHITE="251"
export GRAY="244"
export GREEN="002"
export YELLOW="190"
export RED="196"

TITLE_COLOR=$GREEN
AT_COLOR=$GRAY
UNDERLINE_COLOR=$GRAY
SUBTITLE_COLOR=$GREEN
COLON_COLOR=$GRAY
INFO_COLOR=$GRAY

if [[ $EUID -ne 0 ]]; then
    TITLE_COLOR=$GREEN
    SUBTITLE_COLOR=$GREEN
else
    TITLE_COLOR=$RED
    SUBTITLE_COLOR=$RED
fi

neofetch=`neofetch \
  --disk_percent on \
  --memory_percent on \
  --memory_unit gib \
  --cpu_display barinfo \
  --memory_display barinfo \
  --disk_display barinfo \
  --cpu_speed on \
  --cpu_temp C \
  --colors $TITLE_COLOR $AT_COLOR $UNDERLINE_COLOR $SUBTITLE_COLOR $COLON_COLOR $INFO_COLOR
`

hostName=`uname -n`
diskSpace=`df -Ph | grep xvda1 | awk '{print $4}' | tr -d '\n'`
memoryUsed=`free -t -m | grep Total | awk '{print $3" MB";}'`

echo "

$neofetch"

#  - Hostname............: $hostName
#  - Disk Space..........: $diskSpace
#  - Memory used.........: $memoryUsed
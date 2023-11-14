#!/bin/sh
/usr/bin/websockify -D --web /usr/share/novnc/ 80 localhost:5900
/usr/local/bin/start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0 -serial telnet:127.0.0.1:23,server,nowait
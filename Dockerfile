FROM tianon/qemu
ENV QEMU_HDA_SIZE=4G
ENV QEMU_HDA=/tmp/hda.qcow2
ENV QEMU_HDA_SIZE=4G
ENV QEMU_CPU=4
ENV QEMU_RAM=4096
ENV QEMU_BOOT='order=c'
ENV QEMU_PORTS='2375 2376'
EXPOSE 80
EXPOSE 5900
COPY sources/hda.qcow2 /tmp/hda.qcow2
COPY --chmod=0755 docker-cmd.sh /usr/local/bin/docker-cmd.sh
RUN apt update -y && apt install --no-install-recommends -y  telnet vim novnc procps \
    && cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html
CMD ["/bin/sh","-c","/usr/local/bin/docker-cmd.sh"]
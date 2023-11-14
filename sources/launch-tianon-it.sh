#!/bin/bash
echo "Useful for shrinking the hda image"
echo "cd /tmp"
echo "cp hda.qcow2 old.qcow2"
echo "qemu-img convert -O qcow2 -p -c old.qcow2 hda.qcow2"
docker run -it --rm \
	--name qemu-container-tianon \
	-v ./hda.qcow2:/tmp/hda.qcow2 \
	-e QEMU_HDA=/tmp/hda.qcow2 \
	-e QEMU_HDA_SIZE=4G \
	-e QEMU_CPU=4 \
	-e QEMU_RAM=4096 \
	-v ./alpine.iso:/tmp/alpine.iso:ro \
	-v ./entrypoint:/etc/init.d/entrypoint \
	-e QEMU_CDROM=/tmp/alpine.iso \
	-e QEMU_BOOT='order=c' \
	-e QEMU_PORTS='2375 2376' \
    --entrypoint "" \
	tianon/qemu \
    /bin/bash
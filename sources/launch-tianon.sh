#!/bin/bash
touch ./hda.qcow2
docker run -it --rm \
	--name qemu-container-tianon \
	-v ./hda.qcow2:/tmp/hda.qcow2 \
	-e QEMU_HDA=/tmp/hda.qcow2 \
	-e QEMU_HDA_SIZE=4G \
	-e QEMU_CPU=4 \
	-e QEMU_RAM=4096 \
	-v ./alpine.iso:/tmp/alpine.iso:ro \
	-v ./ext/entrypoint:/ext/entrypoint \
	-e QEMU_CDROM=/tmp/alpine.iso \
	-e QEMU_BOOT='order=c' \
	-e QEMU_PORTS='2375 2376' \
	tianon/qemu  start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0
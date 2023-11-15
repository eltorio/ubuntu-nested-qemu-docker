default: join
	docker build .

join: 
	cat sources/disk/hda.qcow2-part* > sources/hda.qcow2

split:
	rm -f sources/disk/hda.qcow2-part*
	split -b 10M sources/hda.qcow2 sources/disk/hda.qcow2-part

launch-tianon-it: join
	echo -e "Useful tip for shrinking the hda image:\ncd /tmp\ncp hda.qcow2 old.qcow2\nqemu-img convert -O qcow2 -p -c old.qcow2 hda.qcow2\n"
	docker run -it --rm \
		--name qemu-container-tianon \
		-p 5900:5900 \
		-p 23:23 \
		-v ./sources/hda.qcow2:/tmp/hda.qcow2 \
		-e QEMU_HDA=/tmp/hda.qcow2 \
		-e QEMU_HDA_SIZE=4G \
		-e QEMU_CPU=4 \
		-e QEMU_RAM=3000 \
		-v ./sources/ubuntu.iso:/tmp/ubuntu.iso:ro \
		-v ./sources/ext/entrypoint:/ext/entrypoint \
		-e QEMU_CDROM=/tmp/ubuntu.iso \
		-e QEMU_BOOT='order=c,menu=on' \
		-e QEMU_PORTS='2375 2376' \
		--entrypoint "" \
		tianon/qemu \
		/bin/bash

launch-tianon: join launch-simply

launch-simply: 
	touch ./sources/hda.qcow2
	docker run -it --rm \
		--name qemu-container-tianon \
		-p 5900:5900 \
		-p 23:23 \
		-v ./sources/hda.qcow2:/tmp/hda.qcow2 \
		-e QEMU_HDA=/tmp/hda.qcow2 \
		-e QEMU_HDA_SIZE=4G \
		-e QEMU_CPU=4 \
		-e QEMU_RAM=3000 \
		-v ./sources/ubuntu.iso:/tmp/ubuntu.iso:ro \
		-v ./sources/ext/entrypoint:/ext/entrypoint \
		-e QEMU_CDROM=/tmp/ubuntu.iso \
		-e QEMU_BOOT='order=c,menu=on' \
		-e QEMU_PORTS='2375 2376' \
		tianon/qemu  start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0 -serial telnet:127.0.0.1:23,server,nowait
demo: join
	docker run -it -v ./demo-entrypoint:/ext/entrypoint:ro eltorio/ubuntu-nested-qemu-docker:latest

build: join
	docker build -t eltorio/ubuntu-nested-qemu-docker:1.0.3 .

test: build
	docker run -it -v ./demo-entrypoint:/ext/entrypoint:ro eltorio/ubuntu-nested-qemu-docker:latest /bin/bash

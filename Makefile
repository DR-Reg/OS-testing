SOURCE = src
BUILD = build

${BUILD}: ${SOURCE}/*
	nasm -fbin ${SOURCE}/main.nasm -o ${BUILD}/main.bin

.PHONY: run
run: ${BUILD}
	qemu-system-x86_64 -drive format=raw,file=${BUILD}/main.bin
.PHONY: run-slow
run-slow: ${BUILD}
	qemu-system-x86_64 -icount 10,align=on -drive format=raw,file=${BUILD}/main.bin
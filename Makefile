
ASM = nasm

SRC_DIR = src
BUILD_DIR = build

# Default target
all: image

# Ensure the build directory exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

#
# Image
#
image: $(BUILD_DIR)/main.img
	@echo "Creating image..."
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "forkOS" $(BUILD_DIR)/main.img || (echo "Failed to create FAT12 filesystem"; exit 1)
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc
	@echo "Attempting to copy kernel.bin to the image..."
	# Use dd to copy the kernel
	dd if=$(BUILD_DIR)/kernel.bin of=$(BUILD_DIR)/main.img seek=4 conv=notrunc
	@echo "Image created successfully!"

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin
	@echo "Assembling kernel..."
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin
	@if [ $(shell stat -c%s $(BUILD_DIR)/kernel.bin) -gt 1474048 ]; then \
		echo "Error: kernel.bin is too large for a 1.44 MB floppy image"; \
		exit 1; \
	fi

#
# Bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin
	@echo "Assembling bootloader..."
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin
	@if [ $(shell stat -c%s $(BUILD_DIR)/bootloader.bin) -ne 512 ]; then \
		echo "Error: bootloader.bin must be exactly 512 bytes"; \
		exit 1; \
	fi

# Ensure that all targets are created (bootloader -> kernel -> image)
$(BUILD_DIR)/main.img: bootloader kernel
	@echo "All targets built successfully!"

# Ensure the build directory exists before creating any files
$(BUILD_DIR)/bootloader.bin: | $(BUILD_DIR)
$(BUILD_DIR)/kernel.bin: | $(BUILD_DIR)
$(BUILD_DIR)/main.img: | $(BUILD_DIR)


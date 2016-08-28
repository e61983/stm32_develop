#
# @file Makefile
# @brief
# @author Hua-Yuan
# @version 1.0
# @date 2016-08-28
#

# Project Setting
TARGET=test.bin
OUTDIR=out
LDFILE=STM32F439NI_FLASH.ld
INC=-I. \
	-I$(ST_PERIPHERY_INC) \
	-I$(ST_DEVICE_INC) \
	-I$(CMSIS_INC) \

LIB=

SOURCE= \
		$(ST_PERIPHERY_SRC)/stm32f4xx_rcc.c \
		$(ST_DEVICE_SRC)/Templates/gcc_ride7/startup_stm32f429_439xx.s \
		$(ST_DEVICE_SRC)/Templates/system_stm32f4xx.c \
		src/test.c \

# Link for code size
GC=-Wl,--gc-sections

# Create map file
MAP=-Wl,-Map=$(OUTDIR)/$(TARGET:.bin=.map )

VPATH= $(dir $(SOURCE))
OBJS=$(addprefix $(OUTDIR)/, $(addsuffix .o,$(basename $(notdir $(SOURCE)))))
OBJS_DBG=$(addprefix $(OUTDIR)/, $(addsuffix _dbg.o,$(basename $(notdir $(SOURCE)))))

# Tool chain setting
CROSS_COMPILER=arm-none-eabi-
CC=$(CROSS_COMPILER)gcc
SIZE=$(CROSS_COMPILER)size
OBJDUMP=$(CROSS_COMPILER)objdump
OBJCOPY=$(CROSS_COMPILER)objcopy
GDB=$(CROSS_COMPILER)gdb

# Library Path Setting
ST_PERIPHERY_ROOT=Libraries/STM32F4xx_StdPeriph_Driver
ST_PERIPHERY_SRC=$(ST_PERIPHERY_ROOT)/src
ST_PERIPHERY_INC=$(ST_PERIPHERY_ROOT)/inc
ST_DEVICE_SRC=Libraries/CMSIS/Device/ST/STM32F4xx/Source
ST_DEVICE_INC=Libraries/CMSIS/Device/ST/STM32F4xx/Include
CMSIS_INC=Libraries/CMSIS/Include

# Compile Setting
CFLAGS= -std=c99 \
		--specs=rdimon.specs \
		-mcpu=cortex-m3 \
		-mthumb \
		-O0 \
		-T $(LDFILE)\

# ST Periphery Setting
CFLAGS+=-DUSE_STDPERIPH_DRIVER \
		-DSTM32F429_439xx

# Debug Setting
DEBUG_FLAGS= -g3

CFLAGS+= $(INC) $(LIB) $(GC)

all: create_out_dir $(TARGET)

$(TARGET): $(TARGET:.bin=.elf)
	$(OBJCOPY) -Obinary $< $@
	$(OBJDUMP) -S $< > $(OUTDIR)/$(@:.bin=.list)

$(TARGET:.bin=.elf): $(OBJS)
	$(CC) $(CFLAGS) $(MAP) -o $@ $^
	$(SIZE) $@

$(OUTDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTDIR)/%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET:.bin=_dbg.bin): $(TARGET:.bin=_dbg.elf)
	$(OBJCOPY) -Obinary $< $@
	$(OBJDUMP) -S $< > $(OUTDIR)/$(@:.bin=.list)

$(TARGET:.bin=_dbg.elf): $(OBJS_DBG)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(MAP) -o $@ $^
	$(SIZE) $@

$(OUTDIR)/%_dbg.o: %.c
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -c $< -o $@

$(OUTDIR)/%_dbg.o: %.s
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -c $< -o $@

$(OUTDIR):
	mkdir $(OUTDIR)

.PHONY: create_out_dir
create_out_dir: $(OUTDIR)

.PHONY: rebuild
rebuild: clean all

.PHONY: flash
flash:
	st-flash --reset write $(TARGET) 0x8000000

debug: clean  create_out_dir $(TARGET:.bin=_dbg.bin)
	echo "DEBUG MODE"
	st-flash --reset write $(TARGET:.bin=_dbg.bin) 0x8000000

.PHONY: gdb
gdb:
	$(GDB) -q $(TARGET:.bin=_dbg.elf) -ex "target extended-remote :4242 monitor semihosting enable"

.PHONY: clean
clean:
	rm -rf out
	find . -type f -name *.o    -exec rm -rf "{}" \;
	find . -type f -name *.bin  -exec rm -rf "{}" \;
	find . -type f -name *.elf  -exec rm -rf "{}" \;
	find . -type f -name *.list -exec rm -rf "{}" \;

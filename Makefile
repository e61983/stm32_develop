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

# Tool chain setting
CROSS_COMPILER=arm-none-eabi-
CC=$(CROSS_COMPILER)gcc
SIZE=$(CROSS_COMPILER)size
OBJDUMP=$(CROSS_COMPILER)objdump
OBJCOPY=$(CROSS_COMPILER)objcopy

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

CFLAGS+=$(DEBUG_FLAG) $(INC) $(LIB) $(GC)

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

.PHONY: rebuild
rebuild: clean all

.PHONY: create_out_dir
create_out_dir: $(OUTDIR)

$(OUTDIR):
	mkdir $(OUTDIR)

.PHONY: clean
clean:
	rm -rf out
	find . -type f -name *.o    -exec rm -rf "{}" \;
	find . -type f -name *.bin  -exec rm -rf "{}" \;
	find . -type f -name *.elf  -exec rm -rf "{}" \;
	find . -type f -name *.list -exec rm -rf "{}" \;

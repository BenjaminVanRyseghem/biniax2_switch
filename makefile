# BINIAX-2 1.3 MAKEFILE FOR UNIX/LINUX/MACOS SYSTEMS
# (C) 2005-2009, JORDAN TUZSUZOV
# To build the game you need the development libraries of SDL 1.2, SDL_mixer and SDL_image.
# To execute the game you need the runtimes of SDL, SDL_mixer and SDL_image.

#ifeq ($(strip $(DEVKITPRO)),)
#$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>DEVKITPRO")
#endif

INCLUDES_OS := \
		-ISDL_port \
		-I$(DEVKITPRO)/portlibs/switch/include/SDL2 \
		-I$(DEVKITPRO)/portlibs/switch/include \
		-I$(DEVKITPRO)/libnx/include

CFLAGS := -W -fsingle-precision-constant
CXXFLAGS := -c -O2 -fno-rtti $(CFLAGS)

PREFIX := $(DEVKITPRO)/devkitA64/bin/aarch64-none-elf-
CC := ${PREFIX}gcc
CXX := ${PREFIX}g++
LD := ${PREFIX}g++
FILES:= biniax.c hof.c cfg.c gfx.c snd.c inp.c sys.c
INCLUDES := -I . -I./SDLPort -I./cml $(INCLUDES_OS)
LINKTO := -specs=$(DEVKITPRO)/libnx/switch.specs -lSDL2 -lSDL2_mixer -lSDL2_image -L$(DEVKITPRO)/libnx/lib -L$(DEVKITPRO)/portlibs/switch/lib
AUTO := `$(DEVKITPRO)/portlibs/switch/bin/sdl2-config --libs --cflags`
TARGET := biniax2

ALL_OBJS:
	$(CC) $(AUTO) $(FILES) $(INCLUDES) -o $(TARGET) $(LINKTO)

all: $(ALL_OBJS) $(TARGET).nro

$(TARGET).elf: $(ALL_OBJS)
	$(LD) $^ $(LINKTO) -o $@


$(TARGET).nro: $(TARGET).elf
	$(DEVKITPRO)/tools/bin/nacptool --create "$(TARGET)" "rsn8887" "$(VERSION)" $(TARGET).nacp
	$(DEVKITPRO)/tools/bin/elf2nro $(TARGET).elf $(TARGET).nro --icon=./icon.ico --nacp=$(TARGET).nacp


$(TARGET)_switch.zip: $(TARGET).nro
	rm -rf ./release
	mkdir -p ./release
	mkdir -p ./release/${TARGET}
	cp -f ${TARGET}.nro ./release/${TARGET}/${TARGET}.nro
	cp -rf ./data ./release/${TARGET}/
	cd ./release && zip -r ./${TARGET}_${VERSION}_switch.zip ${TARGET} && cd ../
	zip -d ./release/${TARGET}_${VERSION}_switch.zip *.DS_Store *__MAC* || true

clean:
	rm -f *.elf *.nacp *.nro
	rm -rf release
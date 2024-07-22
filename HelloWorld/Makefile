BUILD = ./build
SRC = ./src
PROJECT = hello_world
OBJECTS = main.o

all: build-dir $(PROJECT).nes

clean: build-dir
	rm -rf build/*.o $(PROJECT).nes

build-dir:
	mkdir -p $(BUILD)

$(PROJECT).nes: $(OBJECTS)
	cl65 -t nes -o $(PROJECT).nes $(BUILD)/*.o

%.o: $(SRC)/%.s
	ca65 $< -o $(BUILD)/$@ -t nes
MOD_NAME = sqate

all: build

build:
	@echo "Building 'progs.dat' file."
	@echo -e "\tBuilding process requires you to have fteqcc64, you can get it here:"
	@echo -e "\thttps://fte.triptohell.info/downloads"
	fteqcc64 -src src/ -o progs.dat

package: build
	@echo "Packaging mod in '$(MOD_NAME)' directory."
	mkdir -p $(MOD_NAME)
	cp -r gfx gfx.wad maps progs progs.dat sound CFG\ Files/* demos/* $(MOD_NAME)

clean:
	@echo "Cleaning up project directory."
	command rm progs.lno progs.dat
	command rm -rf $(MOD_NAME)

.PHONY: all build package clean

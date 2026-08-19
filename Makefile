MOD_NAME = KFQuake

all: build

build:
	@echo "Building 'progs.dat' file."
	./tools/fteqcc64 -src src/ -o progs.dat
	
format:
	find src/ -name '*.qc' -exec ./tools/qcstyle --style=quakec -n -s8 {} +

package: build
	@echo "Packaging mod in '$(MOD_NAME)' directory."
	mkdir -p $(MOD_NAME)
	cp -r gfx gfx.wad maps progs progs.dat sound CFG\ Files/* demos/* $(MOD_NAME)

clean:
	@echo "Cleaning up project directory."
	command rm progs.lno progs.dat
	command rm -rf $(MOD_NAME)

.PHONY: all build format package clean

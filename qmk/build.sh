#!/bin/bash

set -e

if [ -z $1 ]; then
	echo "please specify a board"
	exit 1;
fi

regex() {
	[[ $1 =~ $2 ]] && echo "${BASH_REMATCH[1]}"
}

# extract arguments
target=$(regex $1 '^(.*):.*$')
keymap=$(regex $1 '^.*:(.*)$')

# paths
base_path="qmk/firmware/keyboards/${target}"
header_path="${base_path}/${target}.h"
keymap_path="${base_path}/keymaps/${keymap}"
rules_path="${base_path}/rules.mk"

# check if target model is valid in QMK
if ! test -f "$header_path"; then
	echo "Target keyboard \"${target}\" has no QMK definition"
	exit 0
fi

# link files if they exist
if test -f "qmk/${keymap}.c"; then
	mkdir -p "${keymap_path}"
	ln -f "qmk/${keymap}.c" "${keymap_path}/keymap.c"
fi

if test -f "qmk/${keymap}.h"; then
	ln -f "qmk/${keymap}.h" "${header_path}"
fi

if test -f "qmk/${keymap}.mk"; then
	ln -f "qmk/${keymap}.mk" "${rules_path}"
fi

# move into the firmware folder and build
pushd qmk/firmware > /dev/null
make "$1"
popd > /dev/null

# grab the compiled firmware out
mkdir -p build
mv qmk/firmware/${target}_${keymap}.hex build/${keymap}.hex

# if [ $2 ] && [ $2 = "flash" ]; then
	# dfu-programmer atmega32u4 erase --force && \
	# dfu-programmer atmega32u4 flash "qmk/${target}_${keymap}.hex" && \
	# dfu-programmer atmega32u4 reset
# fi
#!/usr/bin/env bash
read -p "Enter file name to run:" name
nasm -f elf64 -g -F dwarf "$name".s -o ./build/"$name".o
ld -o ./build/"$name" ./build/"$name".o
# gdb ./build/"$name"
./build/"$name"

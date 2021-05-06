#!/bin/sh
echo "\n$(tput setaf 6)Clean$(tput sgr0)\n"
python3 setup.py clean --all

rm -rfd fuzzy_parser.egg-info/
rm -rfd dist/

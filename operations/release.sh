#!/bin/sh
pip3 uninstall -y fuzzy_dates
./operations/clean.sh
bumpversion patch
./operations/build.sh
twine upload --skip-existing --repository testpypi dist/*
twine upload --skip-existing dist/*
pip3 install fuzzy_dates
echo "\n$(tput setaf 6)Test run$(tput sgr0)\n"
python3 -m fuzzy_dates '21 juin - 9 juil'

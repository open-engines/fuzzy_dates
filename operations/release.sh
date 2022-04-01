#!/bin/sh
pip3 uninstall -y fuzzy_parser
./operations/clean.sh  \
  && bumpversion patch \
  && ./operations/build.sh \
  && twine upload --skip-existing --repository testpypi dist/* \
  && twine upload --skip-existing dist/* \
  && pip3 install fuzzy_parser \
  && echo "\n$(tput setaf 6)Test run$(tput sgr0)\n"
python3 -m fuzzy_parser '21 Juin - 9 Juil.'

#!/bin/sh
echo "\n$(tput setaf 6)Build$(tput sgr0)\n"
python3 setup.py sdist bdist_wheel
echo "\n$(tput setaf 6)Check$(tput sgr0)\n"
twine check dist/*
<img src=".github/flags-jakearchibald.github.io-scour.svg?raw=true" width="50%" align="right" style="border:20px solid white">

fuzzy_dates
============

A minimal parser for Multilingual Incomplete & Abbreviated Dates 

Usage
-----
From the Command Line type:

```bash
python3 -m fuzzy_parser '21 Juin - 9 Juil.'
[datetime.date(2022, 6, 21), datetime.date(2022, 7, 9)]
['dm(explicit(French))', 'dm(abbreviated(French))']
```

Installation
------------
Install with:

```bash
  pip3 install fuzzy_dates
```

Uninstall with:

```bash
  pip3 uninstall -y fuzzy_dates
```

Requirements
------------

Setup Requirements with:
```bash
./operations/setup-requirements.sh
```

Test
-------------
Test with:

```bash
pytest
```

Compatibility
-------------

Tested with SWI-Prolog version 8.2.4 on Ubuntu 20.04

Licence
-------

MIT

Authors
-------

`fuzzy_dates` was written by `Open Engines<openengines@protonmail.com>`

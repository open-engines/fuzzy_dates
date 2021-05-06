fuzzy_dates
============

A minimal parser for Fuzzy Dates

Usage
-----
From the Command Line type:

```bash
python3 -m fuzzy_dates '21 juin - 9 juil'
```

Or using PrologScript:

```bash
./parser/main.pl '21 juin - 9 juil'
[date(2021,6,21),date(2021,7,9)]
[dm(explicit(french)),dm(explicit(french))]
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
^^^^^^^^^^^^

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

`fuzzy_dates` is maintained by `Conrado M. Rodriguez conrado.rgz@gmail.com`

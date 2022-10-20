<img src="https://raw.githubusercontent.com/crgz/fuzzy_dates/master/.github/images/logo.svg" width="25%" align="right" style="border:0px solid white">

<h3 align="center">Python Parser for Abbreviated Dates</h3>

<p align="center">
    <a href="https://pypi.python.org/pypi/fuzzy_dates">
        <img src="https://img.shields.io/pypi/v/fuzzy_dates.svg" alt="PypI - Version">
    </a>
    <a href="https://github.com/crgz/fuzzy_dates/issues">
        <img src="https://img.shields.io/github/issues/crgz/fuzzy_dates.svg" alt="issues">
    </a>
    <a href="https://github.com/crgz/fuzzy_dates/stargazers">
        <img src="https://img.shields.io/github/stars/crgz/fuzzy_dates.svg" alt="stars - stars">
    </a>
    <a href="https://github.com/crgz/fuzzy_dates/graphs/contributors">
        <img src="https://img.shields.io/github/contributors/crgz/fuzzy_dates.svg" alt="stars - stars">
    </a>
    <a href="https://github.com/crgz/fuzzy_dates/blob/master/CONTRIBUTING.md">
        <img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat" alt="contributions - contributions">
    </a>
</p>

<p align="center">
    <a href="#user-content-key-features">Key Features</a> •
    <a href="#user-content-how-to-use">How To Use</a> •
    <a href="#user-content-how-it-works">How it works</a> •
    <a href="#user-content-common-use-cases">Common use cases</a> •
    <a href="#user-content-operations">Operations</a> •
    <a href="#user-content-roadmap">Roadmap</a>
</p>

Have you ever tried to understand a date like *11-09, št*? Is the *št* an abbreviation of a month or a weekday? Which of
those numbers represent the month or the day? This library leverages on [Good Ol' Fashioned
AI](https://www.cambridge.org/core/books/abs/cambridge-handbook-of-artificial-intelligence/gofai/FCF7D6DD921658FE8AE9F2A2B0FECBDD)
to parse abbreviated, ambiguous, and incomplete dates in multiple languages.

## Key Features

* Language auto-detection
* Easily expandable into new languages (30 languages are currently supported)
* Support for multiple date formats
* Support for abbreviated weekdays
* Support for abbreviated months
* Support for ambiguous month/day numbers

## How To Use

The most straightforward way to parse dates is to use the datetime.date() function, that wraps around most of the
functionality of the module.  This example shows a basic usage of the library to parse the date: *"11-09, št"*:

```bash
fuzzy_parser '11-09, št'
[datetime.date(2024, 11, 9)]
['%m %d %a']
```

## How it works

The abbreviation "št" could stand for:
- Šeštadienis which means in Saturday in Lithuanian
- Štvrtok which means in Thursday in Slovak

Lithuanian is spoken in Lithuania and in Latvia. Slovak is spoken in Slovakia but also by a minority in the Czech Republic.
These countries use different date representations: Czech Republic, Latvia and Slovakia have the day written first because of
the "little" date endianness format used as the standard in the country. Lithuania, on the other hand, uses the "big" date
endianness format which means that the month is written first. The system factor in all these facts and is able to come with
the right answers:

In the case of interpreting the abbreviation as a Saturday:
-  9 of November 2024
- 11 of September 2027

In the case of interpreting the abbreviation as a Thursday:
- 11 of September 2025

For further details have a look at the underlying
[implementation](https://github.com/crgz/abbreviated_dates/blob/main/prolog/abbreviated_dates.pl). In addition, the [unit
tests](https://github.com/crgz/abbreviated_dates/blob/main/prolog/abbreviated_dates.pl.plt) might give an impression on how
to use this library.

## Common use cases

Consuming data from different sources:

* Scraping: extract dates from different places with several formats and languages
* IoT: consuming data coming from different sources with different date formats
* Tooling: consuming dates from different logs / sources
* Format transformations: when transforming dates coming from different files (PDF, CSV, etc.) to other formats (database, etc).

## Operations

We are leveraging GNU Make to automate frequent actions. Please use the following command will show the available recipes
to use for operating the local development environment:

```commandline
make help
```
<details>
  <summary>Click to see the available recipes</summary>

| Command      | Description                                                         |
|--------------|---------------------------------------------------------------------|
| help         | Print this help                                                     |
| synchronize  | Switch to the main branch, fetch changes & delete merged branches   |
| install      | Install the latest library release                                  |
| requirements | Install the packages packs required for the development environment |
| release      | Release recipe to be use from Github Actions                        |
| test         | Run the test suite                                                  |
| bump         | Increase the version number                                         |
| publish      | Publish the diagrams                                                |
| workflow     | Creates the Diagrams                                                |
| clean        | Remove debris                                                       |
| remove-all   | Remove packages and packs                                           |
</details>

### Compatibility

Tested with SWI-Prolog version 8.2.4 on Ubuntu 20.04

## License

Distributed under the MIT License. See `LICENSE` file for more information.

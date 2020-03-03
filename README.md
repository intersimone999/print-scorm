# print-scorm
[![Gem Version](https://badge.fury.io/rb/print-scorm.svg)](https://badge.fury.io/rb/print-scorm)

Simply print SCORM packages.

## Requirements
You need `geckodriver` and Mozilla Firefox to run this.

## Run
To run export a file, simply run `print-scorm -i /path/to/scorm.zip -o path/to/result.pdf`

```sh
Exports SCROM packages to PDF
    -f, --firefox=firefox            Path to firefox binary executable
    -o, --output=OUTPUT              Path to output PDF file
    -i, --input=INPUT                Path to input ZIP file
    -h, --help                       Prints this help
```

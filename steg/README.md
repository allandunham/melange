# Steganography

Written in C, this application is intended to hide text and images within another image.

## Requirements

* Linux Mint
* GCC version 5.4.0

## Compile

Run `make`.

## To Run

Run `./hidden -e <name_of_file_to_encode_to>.png <-u < s | i > | -i <name_of_file_to_hide>.png | -s "string_to_hide">`

Examples:

To hide image two in image one:
> ./hidden -e one.png -i two.png

Or, if the extensions are implied:
> ./hidden -e one -i two

To hide the text:
> ./hidden -e one -s "hello world"

To unhide the image:
> ./hidden -e result.png -u i

To unhide the text:
> ./hidden -e result.png -u s

This application uses steganography on PNG files because using JPEG compresses the images, disturbing the encoding. 

## Memory leaks

To check for memory leaks, install `valgrind`, and run `valgrind` followed by one of the above examples, then pressing Enter.

## Progress

The Issues tab will include what is left to complete.

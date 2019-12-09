#!/bin/bash

mkdir -p bin
mkdir -p output

cd steg
make
cp ./steg ../bin

cd ../filljson
./make.sh
cp filljson ../bin

#!/bin/bash

mkdir bin
cd steg
make
cp ./steg ../bin

cd ../filljson
./make.sh
cp filljson ../bin

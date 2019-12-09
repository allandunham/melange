# melange
Project for the 2019 Dragonchain hackathon

#
# Thanks to:
#   Lode Vandevenne
#     - For his contribution of lodepng.c
#     - None of those components were modified
#   bjchau (github.com)
#     - For his implementation of lodepng found on:
#       https://github.com/bjchau/Steganography.git
#     - The main program from his repository was
#       heavily modified, but provided an excellent
#       starting point for my own steganography
#       program
#   Joe Roets:
#     - Who provided the idea for the project!
#


#
#
# NOTE:
# This program was developed and tested on
# Ubuntu 16.04
#
# Currently only works with .PNG files
#
# Instructions assume you already have a
# Dragonchain level-1 node setup with credentials 
# on your machine.
#
# All instruction paths are relative to the
# directory named "melange"
#
#
# Step 1 - to make, from command line run:
#
#   ./make.sh
#     
# Step 2 - create the "meme" transaction type
#          on your level-1 Dragonchain node by
#          running (found in ./struct/tt.meme):
#
#     dctl tt c "meme" -c '[ \
#        {"fieldName":"img_id","path":"steg.img_id","type":"text","options":{"sortable":true}}, \
#        {"fieldName":"sharer","path":"steg.sharer","type":"text","options":{"sortable":true}} \
#     ]' \
#     
# Step 3 - run:
#
#     ./wyrm.sh {input-file.png} {output-file.png} {hidden text message (optional)}
#
#
# This script will take your input .PNG file and
# attempt to submit a "meme" transaction to your
# level-1 Dragonchain node.  The output file will
# contain a steganographically encoded JSON block
# with img_id, sharer, and the optional message
# from the command line.
#
# If this is a "new" image, having no valid JSON
# info, then the image itself, with the JSON block
# will be converted to base64 format and uploaded
# to the chainto the chain.
#
# If the image already has a valid JSON block, then
# you will be added to the list of "sharers" and 
# a this will be recorded on the chain.
#
#


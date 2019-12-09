#!/bin/bash
#*******************************************************************************
# Script:
#    wyrm.sh (AKA Project Melange)
#
# Author:
#    Allan Dunham
#
# Date:
#    12/7/2019
#
# Purpose:
#    A blockchain project submitted for the 2019 Dragonchain hackathon.
#    
# Description:
#    Takes an input .PNG image (meme) file and submits it to the blockchain.
#    Upon submission to the chain, a copy of the image is created. The copy
#    contains embedded JSON information. The JSON block is encoded into
#    the .PNG file via LSB steganography (using the loadpng libraries).
#
#    The blockchain contains the full history of people who have collected
#    and resubmitted the same image numerous times. This permits a meme file
#    to be "tracked" on it's journey over the webs. Assumes each person
#    uses the wyrm tool before sharing.
#
#*******************************************************************************



#*******************************************************************************
# Function:
#    Usage()
#
# Description:
#    Called when the parameters passed to the script
#    are invalid or incomplete.
#
# Arguments:
#    None
#
# Return:
#    None, exits script.
#*******************************************************************************
usage()
{
    echo "Usage: $0 {filename.png}"
    exit 1
}



#*******************************************************************************
# Function:
#    file_exists
#
# Description:
#    Checks for the existence of a file
#
# Arguments:
#    A string representing a filename
#
# Return:
#    bool   True if file exists
#           False if file does not exist
#*******************************************************************************
file_exists()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}



#*******************************************************************************
#*******************************************************************************
# Main Body of Script
#*******************************************************************************
#*******************************************************************************
INFILE=$1
OUTFILE=$2
MESSAGE="\"$3\""
IMAGE=""

#
# Verify that arg1 was passed on invoke
#
[[ $# -eq 0 ]] && usage
 

#
# Check if arg1 is a valid file
#
if ( !( file_exists "$INFILE" ) )
then
   echo "Input file {$INFILE} not found"
   usage
fi


#
# If the user provided an INFILE ($1), but no OUTFILE ($2) then
# just attemt to decode the INFILE and report the on the contents.
#
if [[ -z $OUTFILE ]]
then
   echo "ERROR(010): No output file specified"

   # NICE TO HAVES
   # TODO: attempt to get contents of INFILE
   # TODO: if valid JSON is present, output the contents to stdout, nice with jq
   # TODO: else no valid JSON is present, state this file is not on-chain

   exit
fi


#
# Check if arg1 is a valid file
#
if ( ( file_exists "$OUTFILE" ) )
then
   echo "WARNING: Output file {$OUTFILE} exists, overwrite? (Y/n)"
   read ANSWER
   case $ANSWER in
      #
      # User wants to keep existing file, so exit here.
      [nN]) exit;;
   esac

   #
   # Clobber the existing output file and move on.
   #
   rm -f $OUTFILE
   if [[ $? -ne 0 ]]
   then
     echo "ERROR(020): Failed while clobbering output file '$OUTFILE'"
     exit
   fi
fi


#
# Make a copy of the INFILE, only the output will be modified.
#
cp $INFILE $OUTFILE
if [[ $? -ne 0 ]]
then
   echo "ERROR(030): Failed while copying to output file '$OUTFILE'"
   exit
fi


#
# Check if the OUTFILE was created successfully.
#
if ( ( ! file_exists "$OUTFILE" ) )
then
   echo "ERROR(040): Failed while creating output file '$OUTFILE'"
   exit
fi


#
# If present, attempt to extract steg info from png file.
# The bin/steg executable will verify file extension.
#
PAYLOAD=$(./bin/steg -d $OUTFILE | tr -cd '\11\12\15\40-\176')


#
# Get the img_id and sharer fields from the JSON
#
IMG_ID_EXISTS=$(echo $PAYLOAD | jq 'has("img_id")' 2> /dev/null)
SHARER_EXISTS=$(echo $PAYLOAD | jq 'has("sharer")' 2> /dev/null)


#
# Get this user's Public wallet address from a local file (.wallet)
#
PUBLICKEY=$(jq '.Keys.PublicKey' < .wallet )


#
# Check the results of the attempted parse
#
if [[ -z $IMG_ID_EXISTS ]] || [[ -z $SHARER_EXISTS ]] || [[ "$IMG_ID_EXISTS" != "true" ]] || [[ "$SHARER_EXISTS" != "true" ]]
then
   #
   # No embedded JSON was found, or JSON had invalid format
   # Proceed to resubmit as a new meme and then exit the script.
   #
   echo "This meme is not yet on-chain, so let's add it to the chain!"


   #
   # Generate a unique/random UUID for the image-ID
   #
   # NOTE: I seem to need to remove the dashes for the 
   #       Redisearch queries to function correctly
   #
   IMG_ID="\"$(python -c 'import uuid; print(uuid.uuid4())' | tr -d '-' )\""


   #
   # Since this is the first post, list this user's address as the
   # first share.
   #
   SHARES="[$PUBLICKEY]"


   #
   # Debug info
   #
   #echo "IMG_ID=$IMG_ID"
   #echo "PUBLICKEY=$PUBLICKEY"
   #echo "MESSAGE=$MESSAGE"
   #echo "SHARES=$SHARES"


   #
   # Start constructing the new transaction.
   #
   NEWTRANS=$(cat ./struct/t.meme | jq '.[0].payload.steg.img_id = '$IMG_ID' | .[0].payload.steg.sharer = '$PUBLICKEY' | .[0].payload.steg.message = '"$MESSAGE"' | .[0].payload.shares = '"$SHARES"' | .[0].payload.image = ""' )
   

   #
   # Deposit the updated steg block into the new copy of the meme
   #
   STEGONLY=$(echo $NEWTRANS | jq '.[0].payload.steg')
   ./bin/steg -e $OUTFILE -s "$STEGONLY"

   
   #
   # Collect the arguments used to construct the JSON transaction file. These 
   # args are used by the filljson utility program further down.
   #
   TMP_UID=$(python -c 'import uuid; print(uuid.uuid1())' )    # arg4, see below
   IMG_FILE="./output/$TMP_UID.hex"                            # arg1, see below
   base64 $OUTFILE | tr -d '\n' > $IMG_FILE
   TRX_FILE="./output/$TMP_UID.json"                           # arg3, see below
   TMP_FILE="./output/$TMP_UID.temp"                           # arg2, see below


   #
   # Take the transaction template file and insert a unique ID into the
   # image field.
   #
   echo $NEWTRANS | jq '.[0].payload.image = '"\"$TMP_UID\""' ' > $TMP_FILE
   #cat $TMP_FILE

   
   #
   # Since the image file is often too large to run on a command-line. Instead
   # we have created a c++ program that does the work for us.
   #
   # filljson
   # arg1 = JSON-template
   # arg2 = File with image converted to base64
   # arg3 = Output JSON file, with base64 image embedded
   # arg4 = Unique ID, that gets replaced with the image file contents
   #
   ./bin/filljson $TMP_FILE $IMG_FILE $TRX_FILE $TMP_UID


   #
   # Now just exectute the transaction using dctl and cleanup the
   # temporary files.
   #
   dctl t b -f $TRX_FILE

   rm -f $TMP_FILE
   rm -f $IMG_FILE
   rm -f $TRX_FILE


   exit
fi 



#*******************************************************************************
#*******************************************************************************
# Below here is executed only if we are processing a share request, where
# the image file is already on-chain, and only the list of shares needs to 
# be updated.
#*******************************************************************************
#*******************************************************************************
echo "IMG_ID found in file, your address will be added to the list of sharers"


#
# The image contains JSON with valid fields, attempt to get a copy of the
# file suitable for sharing. First collect the img_id and sharer, in order
# to query the specific transaction.
#
IMG_ID=$(echo $PAYLOAD | jq '.img_id')
SHARER=$(echo $PAYLOAD | jq '.sharer')


#
# A little trickiness here to get the single/double quotes working correctly
# for the Redisearch query, so first build the dctl command and the query
# separately, then join them together by running with eval.
#
dctlcmd='dctl t q meme '
redistr="@img_id:$IMG_ID, @sharer:$SHARER"


#
# Now go get the transaction associated with this meme from
# our blockchain!
#
PREVTRANS=$(eval $dctlcmd "'$redistr'")


#
# Make sure there is only one matching transaction in our result set.
# A duplicate indicates that this user has previously submitted the
# same image. Maybe this should be allowed? Not sure so, I'll let it
# slide for now.
#
COUNT=1    # not yet used


#
# Get the list of sharers from the previous transaction. This is a list
# of all the PublicKeys of each of the people who have previously shared
# this meme file.
#
SHARES=$(echo $PREVTRANS | jq '.response.results[0].payload.shares' | jq ". |. += [$PUBLICKEY]")


#
# Debug info
#
echo "IMG_ID=$IMG_ID"
echo "PUBLICKEY=$PUBLICKEY"
echo "MESSAGE=$MESSAGE"
echo "SHARES=$SHARES"
echo "IMAGE=$IMAGE"


#
# Create a temp file to store the transaction
#
TMPFILE=$(python -c 'import uuid; print(uuid.uuid1())' )
TMPFILE="./output/$TMPFILE.txt"


#
# Now generate a new transaction for placement on the blockchain.
#
cat ./struct/t.meme | jq '.[0].payload.steg.img_id = '$IMG_ID' | .[0].payload.steg.sharer = '$PUBLICKEY' | .[0].payload.steg.message = '"$MESSAGE"' | .[0].payload.shares = '"$SHARES"' | .[0].payload.image = ""' > $TMPFILE


#
# Deposit the updated steg block into the new copy of the image file.
#
STEGONLY=$(cat $TMPFILE | jq '.[0].payload.steg')
./bin/steg -e $OUTFILE -s "$STEGONLY"
#echo $STEGONLY


#
# Now just exectute the transaction using dctl and cleanup the
# temporary files.
#
dctl t b -f $TMPFILE
#rm -f $TMPFILE


exit








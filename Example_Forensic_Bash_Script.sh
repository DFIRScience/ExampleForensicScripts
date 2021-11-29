#!/bin/sh
# The first line says what interperter should
# be used with this script. When starting out
# use the default: #!/bin/sh

# Add a short description about your script.
# Description: This script will create MD5 hash
# values for each regular file in a disk image.
# RUN THIS SCRIPT ON TSURUGI LINUX WITH
# SuspectData.dd EXAMPLE IMAGE.

# Next, add a last updated data and a contact.
# Users will know if it's out of date and who
# to talk to if they have questions.
# Last updated: 2021-11-29
# Contact: Joshua James <https://DFIR.Science>

# Create variables with obvious names so you
# remember what the variable contains.
# We create a variable "IMG"
# We save the first command-line argument in
# the variable.
IMG=$1
# Creating some variables we will use later
IMGMD5=" "

# Print text to the screen
echo "Fornesic Hashing Script"
# Print the date to the screen
date
# Check if IMG is a file
# If IMG exists AND is a file, then...
if [ $IMG ] && [ -f $IMG ]; then
    # Print some text on the screen
    echo "File was found"
# If IMG is not a file...
else
    # Print an error
    echo "File was not found"
    # Exit the script
    exit
# fi lets the script know that the
# if statement is finished.
fi

# Use the sleuthkit's img_stat to see
# if the image is a raw disk image.
img_stat $IMG | grep raw > /dev/null
# If it is a raw disk image, then...
if [ $? -eq 0 ]; then
    # Print some text for the user
    echo "Hash value for $IMG"
    # Create an MD5 hash of the image
    # and save it to the FILEHASH variable.
    IMGMD5=$(md5sum $IMG | awk '{print $1}')
# If the file is not a raw disk image...
else
    # Print some error text to the user
    echo "File type not supported."
    # Exit the script
    exit
# fi marks the end of an if statement
fi

echo "The image MD5 hash value is: ${IMGMD5}"

# NEW CONCEPT - FUNCTION
# This code is re-usable. You can call the code
# by name "hash_inode". Send an inode to the function
# and get back the file's MD5 hash value.
hash_inode(){
    # Create a variable called INODE.
    # The value is the first argument sent.
    INODE=$1
    # Use the sleuthkit "icat" to read the data from
    # the inode. Use md5sum to hash and awk to
    # remove the filename section. Resulting
    # in only the md5 hash value.
    icat $IMG $INODE | md5sum | awk '{print $1}'
}

# NEW CONCEPT - FOR LOOP
# fls returns several inode addresses.
# Take each address, one at a time, and put it
# in the variable "INODE". Then we can do whatever
# we want with the variable. When done, move to the
# next inode.
# awk is selecting the row with the inode
# sed is filtering out chracters we don't want
for INODE in $(fls $IMG | awk '{print $2}' | sed 's/[\*|:$]//'); do
    echo "Processing inode: $INODE"
    # Call the function "hash_inode" that we made before.
    # Send the value of the INODE variable to the function.
    hash_inode $INODE
# Done signifies the end of a loop
done

# Finished. If there is nothing else to do, the script will exit.


# Here is an example of reading a hash from a report
# and saving it to a variable.
#echo "Hash value from report"
#REPORTHASH = $(cat HDFS-Master.E01.txt | grep verified | head -n1 | awk '{print $3}')
#echo $REPORTHASH

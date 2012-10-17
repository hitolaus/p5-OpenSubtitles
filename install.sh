#!/bin/bash
#
# Jakob Hilarius,  <http://syscall.dk>, 2012
#
##
TMP_DIR=/tmp
TMP_FILE=p5-OpenSubtitles-master.tar.gz

# Check if run as root otherwise give warning
USER_ID=$(id)
if [[ $USER_ID != 0 ]]; then
	echo " ==== WARNING ================================= "
	echo "  You are running as a non-root user!"
	echo "  It may not be possible to install the module."
	echo " ============================================== "
fi

# Save the current directory so we know where to return (we are using multiple cd's so 'cd -' 
# will not work)
CURRENT_DIR=$(pwd)

cd $TMP_DIR
curl -k -L https://github.com/hitolaus/p5-OpenSubtitles/tarball/master > $TMP_FILE
if [[ $? -ne 0 ]]; then
	echo "Unable to fetch the tarball"
	exit 7
fi

tar zxvf $TMP_FILE
if [[ $? -ne 0 ]]; then
	echo "Unable to unpack the tarball"
	exit 7
fi

# TODO: Verify no other hitolaus-p5-OpenSubtitles-* exist

cd hitolaus-p5-OpenSubtitles-*

perl Makefile.PL
if [[ $? -ne 0 ]]; then
	echo "Unable to generate the build file. Are you sure that you have Perl in your path?"
	exit 7
fi

make install
if [[ $? -ne 0 ]]; then
	echo "Unable to build the module. Are you sure that you have make installed?"
	exit 7
fi

cd ..
rm -fr hitolaus-p5-OpenSubtitles-*/

# Return to original directory
cd $CURRENT_DIR
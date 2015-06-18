#!/bin/sh

set -e

if [ "$#" -ne 3 ]; then
	echo "Usage: rpmdiff <RPM NAME> <REPO1> <REPO2>"
	exit 1
fi

RPM_NAME="$1"
REPO_1="$2"
REPO_2="$3"

echo "RPM NAME = $RPM_NAME"
echo "REPO 1 = $REPO_1"
echo "REPO 2 = $REPO_2"

echo "Removing any previously filled folders..."
rm -fr tmp $REPO_1 $REPO_2
mkdir tmp
cd tmp
pwd

yumdownloader --disablerepo=* --enablerepo="$REPO_1" "$RPM_NAME"
RPM_1=`ls`

yumdownloader --disablerepo=* --enablerepo="$REPO_2" "$RPM_NAME"
RPM_2=`ls | grep -v "$RPM_1"`

echo "RPM 1 = $RPM_1"
echo "RPM 2 = $RPM_2"

cd ../
mkdir "$REPO_1"
mkdir "$REPO_2"

cd "$REPO_1"
rpm2cpio "../tmp/$RPM_1" | cpio -idmv

cd "../$REPO_2"
rpm2cpio "../tmp/$RPM_2" | cpio -idmv

cd ../
ls

echo "Removing precert configs from $REPO_1"
find $REPO_1 -name "*precert.json" -type f -delete
echo "Removing precert configs from $REPO_2"
find $REPO_2 -name "*precert.json" -type f -delete

diff -r $REPO_1 $REPO_2 > rpmdiff

rm -rf tmp/
rm -rf "$REPO_1"
rm -rf "$REPO_2"


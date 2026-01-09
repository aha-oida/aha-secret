#!/bin/sh

VERSION_FILE="VERSION"

# Fallback if git is not installed
if ! command -v git >/dev/null 2>&1
then
	echo "Git is not installed. Won't set the BUILD_ID"
	exit 1
fi

BUILD_ID=$(git describe --tags --long --always --dirty 2> /dev/null)

# Fallback if this is not a git installation
if [ $? -ne 0 ]
then
	echo "This seems not to be a git installation."
	exit 0
fi

echo "BUILD_ID: $BUILD_ID"

# Write version to file
echo "$BUILD_ID" > $VERSION_FILE

echo "Version file created: $VERSION_FILE"
exit 0

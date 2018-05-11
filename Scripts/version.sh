#!/bin/bash

BUILD=`git rev-list HEAD | wc -l`

echo $BUILD

echo "#define BUILD_VERSION ${BUILD}" > Demo/InfoPlist.h

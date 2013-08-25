#!/usr/bin/env bash

cd build
tar --exclude=".DS_Store" -cvzf spring-framework.tgz spring-framework.docset
zip -r -X spring-framework.zip spring-framework.docset
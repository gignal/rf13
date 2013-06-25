#!/bin/bash

# Change branches
git checkout gh-pages

# get stuff from master
git checkout master -- index.html
git checkout master -- lib
git checkout master -- images
git commit -m "Updates from master"

# Push 
git push origin gh-pages

# Checkout master
git checkout master
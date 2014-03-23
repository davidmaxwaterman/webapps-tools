webapps-tools
=============

tools I use to manage the 01org webapps

set $GITHUB_TOKEN to your github token - see github api help pages for how to get your own.

USE AT YOUR OWN RISK.

BE SURE TO CHECK THESE WORK AS YOU INTEND BEFORE USING THEM.

I usually check the script will do what I expect by adding 'echo' to the beginning of the appropriate lines.

Note to self :

1. ```cd ~/z/webapps``` # directory with all the webapps cloned into it.
1. ```for app in webapps-*; do cd $app; npm install && grunt release; cd ..; done```
1. ```build-all.sh```
1. ```github-prepare-all```
1. ```github-upload-all```

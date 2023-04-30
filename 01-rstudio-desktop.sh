#!/bin/bash

# reference
# https://earthly.dev/blog/creating-and-hosting-your-own-deb-packages-and-apt-repo/
# https://www.percona.com/blog/how-to-create-your-own-repositories-for-packages/

# if jq is missing, install it
# if ! command -v jq &> /dev/null
# then
#     sudo apt install jq
# fi

# daily

# read https://dailies.rstudio.com/rstudio/latest/index.json and get the url of the latest rstudio-desktop deb file
# url="https://dailies.rstudio.com/rstudio/latest/index.json"
# js=$(curl -s $url)
# fileurl=$(echo $js | jq -r '.products.electron.platforms."jammy-amd64".link')
# file=$(basename $fileurl)

# stable

fileurl="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.03.0-386-amd64.deb"

# file="rstudio-desktop.deb"
# prune the url to get the file name
file=$(basename $fileurl)

# paste apt-repo/pool/main/ to the file name
file="apt-repo/$file"

mkdir -p apt-repo/

# create a minimal index.html apt-repo
# echo '<meta http-equiv = "refresh" content = "0; url = https://github.com/pachadotdev/r-packages-ubuntu"/>' > apt-repo/index.html

# if the file is not already downloaded, download it
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# create a list of packages
cd apt-repo && bash ../02-generate-release.sh > Release && dpkg-scanpackages . /dev/null > Packages && cd ..

# sign
export GNUPGHOME="$(mktemp -d pgpkeys-XXXXXX)"
cat pgp-key.private | gpg --import
cat apt-repo/Release | gpg --default-key Pacha -abs > apt-repo/Release.gpg
cat apt-repo/Release | gpg --default-key Pacha -abs --clearsign > apt-repo/InRelease

# copy the dir to the server
rsync -av --update --exclude='.git' apt-repo/ pacha@tradestatistics.io:~/apt-repo/

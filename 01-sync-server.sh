#!/bin/bash

# reference
# https://earthly.dev/blog/creating-and-hosting-your-own-deb-packages-and-apt-repo/
# https://www.percona.com/blog/how-to-create-your-own-repositories-for-packages/

# if jq is missing, install it
if ! command -v jq &> /dev/null
then
    sudo apt install jq
fi

# RSTUDIO ----

# daily

# read https://dailies.rstudio.com/rstudio/latest/index.json and get the url of the latest rstudio-desktop deb file
url="https://dailies.rstudio.com/rstudio/latest/index.json"
js=$(curl -s $url)
fileurl=$(echo $js | jq -r '.products.electron.platforms."jammy-amd64".link')

# prune the url to get the file name
file=$(basename $fileurl)

# paste apt-repo/pool/main/ to the file name
file="apt-repo-daily/$file"

mkdir -p apt-repo-daily/

# if the file is not already downloaded, download it
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# stable

fileurl="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.12.0-369-amd64.deb"

# file="rstudio-desktop.deb"
# prune the url to get the file name
file=$(basename $fileurl)

# paste apt-repo/pool/main/ to the file name
file="apt-repo/$file"

mkdir -p apt-repo/

# if the file is not already downloaded, download it
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# RSTUDIO SERVER ----

fileurl="https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.12.0-369-amd64.deb "

# file="rstudio-desktop.deb"
# prune the url to get the file name
file=$(basename $fileurl)

# paste apt-repo/pool/main/ to the file name
file="apt-repo/$file"

mkdir -p apt-repo/

# if the file is not already downloaded, download it
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# QUARTO ----

fileurl="https://objects.githubusercontent.com/github-production-release-asset-2e65be/298579934/957f3999-19cf-4d88-a03e-ca0df8126554?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20231222%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231222T223720Z&X-Amz-Expires=300&X-Amz-Signature=fa81df247aef7e9f80b6cef3baf1b0e6e91e3e1dc1cd8306bf7b7dcffd8b7eb8&X-Amz-SignedHeaders=host&actor_id=10091065&key_id=0&repo_id=298579934&response-content-disposition=attachment%3B%20filename%3Dquarto-1.3.450-linux-amd64.deb&response-content-type=application%2Foctet-stream"
file="apt-repo/quarto-1.3.450-linux-amd64.deb"
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# # Create a list of packages ----

cd apt-repo && bash ../02-generate-release.sh > Release && dpkg-scanpackages . /dev/null > Packages && cd ..
cd apt-repo-daily && bash ../02-generate-release.sh > Release && dpkg-scanpackages . /dev/null > Packages && cd ..

# # SIGN ----

# # create a GPG key, I set this to expire in 180 days
# echo "%echo Generating an example PGP key
# Key-Type: RSA
# Key-Length: 4096
# Name-Real: Pacha
# Name-Email: m.sepulveda@mail.utoronto.ca
# Expire-Date: 365
# %no-ask-passphrase
# %no-protection
# %commit" > ~/github/r-packages-ubuntu/rstudioapt-pgp-key.batch
#
# export GNUPGHOME="$(mktemp -d ~/github/r-packages-ubuntu/pgpkeys-XXXXXX)"
#
# gpg --no-tty --batch --gen-key ~/github/r-packages-ubuntu/rstudioapt-pgp-key.batch
#
# ls "$GNUPGHOME/private-keys-v1.d"
#
# gpg --armor --export Pacha > ~/github/r-packages-ubuntu/pgp-key.public
#
# cat ~/github/r-packages-ubuntu/pgp-key.public | gpg --list-packets
#
# gpg --armor --export-secret-keys Pacha > ~/github/r-packages-ubuntu/pgp-key.private

export GNUPGHOME="$(mktemp -d ~/github/r-packages-ubuntu/pgpkeys-XXXXXX)"
gpg --list-keys
cat ~/github/r-packages-ubuntu/pgp-key.private | gpg --import
gpg --list-keys

cat apt-repo/Release | gpg --default-key Pacha -abs > apt-repo/Release.gpg
cat apt-repo/Release | gpg --default-key Pacha -abs --clearsign > apt-repo/InRelease
cat apt-repo-daily/Release | gpg --default-key Pacha -abs > apt-repo-daily/Release.gpg
cat apt-repo-daily/Release | gpg --default-key Pacha -abs --clearsign > apt-repo-daily/InRelease

# copy the public key to apt-repo
cp pgp-key.public apt-repo/pacha.gpg
cp pgp-key.public apt-repo-daily/pacha.gpg

# DEPRECATED :(
# add to http://keyserver.ubuntu.com/
# cat pgp-key.public

# save pgp-key.public as pacha_pubkey.asc
cp pgp-key.public apt_pacha_pubkey.asc

# copy the dirs to the server

rsync -av --update --exclude='.git' apt-repo/ pacha@tradestatistics.io:~/apt-repo/
rsync -av --update --exclude='.git' apt-repo-daily/ pacha@tradestatistics.io:~/apt-repo-daily/

rsync -av --update apt_pacha_pubkey.asc pacha@tradestatistics.io:~/apt-repo/apt_pacha_pubkey.asc

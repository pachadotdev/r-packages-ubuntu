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

fileurl="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.03.0-386-amd64.deb"

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

fileurl="https://objects.githubusercontent.com/github-production-release-asset-2e65be/298579934/3d552f6f-32fb-4d17-91ca-a5436254b886?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230510%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230510T190926Z&X-Amz-Expires=300&X-Amz-Signature=b7ab8e2886eaf5fd41cad9bbdceb799c624d06b7a9e000abd94cac10fe2b4717&X-Amz-SignedHeaders=host&actor_id=10091065&key_id=0&repo_id=298579934&response-content-disposition=attachment%3B%20filename%3Dquarto-1.3.340-linux-amd64.deb&response-content-type=application%2Foctet-stream"
file="apt-repo/quarto-1.3.340-linux-amd64.deb"
if [ ! -f $file ]; then
    curl -s -o $file $fileurl
fi

# # Create a list of packages ----

cd apt-repo && bash ../02-generate-release.sh > Release && dpkg-scanpackages . /dev/null > Packages && cd ..
cd apt-repo-daily && bash ../02-generate-release.sh > Release && dpkg-scanpackages . /dev/null > Packages && cd ..

# # SIGN ----

# create GPG key
echo "%echo Generating a PGP key
Key-Type: RSA
Key-Length: 4096
Name-Real: Pacha
Name-Email: m.sepulveda@mail.utoronto.ca
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit" > /tmp/rstudio-pgp-key.batch

export GNUPGHOME="$(mktemp -d pgpkeys-XXXXXX)"

gpg --no-tty --batch --gen-key /tmp/rstudio-pgp-key.batch
# ls "$GNUPGHOME/private-keys-v1.d"
# gpg --list-keys

# don't run this twice!
# gpg --armor --export Pacha > pgp-key.public
# cat pgp-key.public | gpg --list-packets

# gpg --armor --export-secret-keys Pacha > pgp-key.private
# add this to the .gitignore file
# echo "pgp-key.private" >> .gitignore
# git add .gitignore

# upload the public key to http://keyserver.ubuntu.com/#submitKey

export GNUPGHOME="$(mktemp -d pgpkeys-XXXXXX)"
# gpg --list-keys

cat pgp-key.private | gpg --import
cat apt-repo/Release | gpg --default-key Pacha -abs > apt-repo/Release.gpg
cat apt-repo/Release | gpg --default-key Pacha -abs --clearsign > apt-repo/InRelease

cat pgp-key.private | gpg --import
cat apt-repo-daily/Release | gpg --default-key Pacha -abs > apt-repo-daily/Release.gpg
cat apt-repo-daily/Release | gpg --default-key Pacha -abs --clearsign > apt-repo-daily/InRelease

# copy the public key to apt-repo
cp pgp-key.public apt-repo/pacha.gpg
cp pgp-key.public apt-repo-daily/pacha.gpg

# copy the dirs to the server

rsync -av --update --exclude='.git' apt-repo/ pacha@tradestatistics.io:~/apt-repo/
rsync -av --update --exclude='.git' apt-repo-daily/ pacha@tradestatistics.io:~/apt-repo-daily/

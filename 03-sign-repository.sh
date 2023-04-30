#!/bin/bash

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
ls "$GNUPGHOME/private-keys-v1.d"
# gpg --list-keys
gpg --armor --export Pacha > pgp-key.public
cat pgp-key.public | gpg --list-packets

gpg --armor --export-secret-keys Pacha > pgp-key.private
# add this to the .gitignore file
echo "pgp-key.private" >> .gitignore
git add .gitignore

export GNUPGHOME="$(mktemp -d pgpkeys-XXXXXX)"
# gpg --list-keys
cat pgp-key.private | gpg --import

cat apt-repo/dists/stable/Release | gpg --default-key Pacha -abs > apt-repo/dists/stable/Release.gpg
cat apt-repo/dists/stable/Release | gpg --default-key Pacha -abs --clearsign > apt-repo/dists/stable/InRelease

# copy the public key to apt-repo
cp pgp-key.public apt-repo/pacha.gpg

# copy the dir to the server
rsync -av --update --exclude='.git' apt-repo/ pacha@tradestatistics.io:~/apt-repo/

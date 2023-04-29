#!/bin/bash

# stop if not running as sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as sudo"
  exit
fi

# add an updated R source to the system manager
add-apt-repository ppa:marutter/rrutter4.0

# add a binary R packages source to the system manager
add-apt-repository ppa:c2d4u.team/c2d4u4.0+  # R packages

# update the system (ask if ok)
apt update && apt upgrade

# install dependencies
apt install python3-{dbus,gi,apt}

# install R
apt install r-base

# install bspm as a system package from CRAN
Rscript -e 'install.packages("bspm", repos="https://cran.r-project.org")'

# enable it system-wide
# echo "bspm::enable()" | sudo tee -a /etc/R/Rprofile.site

# enable it for the user
# echo "bspm::enable()" | sudo tee -a ~/Rprofile.site

# ask the user to chose between a system-wide or user-wide activation
echo "Do you want to enable bspm system-wide (all users) or user-wide (only you)?"
select yn in "System-wide" "User-wide"; do
    case $yn in
        "System-wide" ) echo "bspm::enable()" | sudo tee -a /etc/R/Rprofile.site; break;;
        "User-wide" ) echo "bspm::enable()" | sudo tee -a ~/Rprofile.site; break;;
    esac
done

# send msg to ask to test it
echo "Please close and reopen RStudio and test the setup by running 'install.packages("ggplot2")' in R (or any other package)"

#!/bin/bash

echo "This script will install R (if needed) and configure bspm on your system."

# ask to continue or exit
read -p "Do you want to continue? (y/n) " -n 1 -r

# stop if not running as sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as sudo"
  exit
fi

# add an updated R source to the system manager
echo ""
echo "Do you want to add the official CRAN R repository?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) add-apt-repository ppa:marutter/rrutter4.0 && apt update; break;;
        No ) break;;
    esac
done

# add a binary R packages source to the system manager
echo "Do you want to add the official CRAN R packages repository?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && apt update; break;;
        No ) break;;
    esac
done

echo "Is it ok to upgrade system packages now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt upgrade; break;;
        No ) break;;
    esac
done

# install R
echo "Do you want to install R?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install r-base; break;;
        No ) break;;
    esac
done

# ask if the user to install development tools

echo "Do you want to install development tools (i.e, to build R packages)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install r-base-dev; break;;
        No ) break;;
    esac
done

echo "Do you want to install Git?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install git; break;;
        No ) break;;
    esac
done

echo "Is it ok to add apt.pacha.dev as a source for RStudio and/or Quarto?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install gnupg && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FD3445D533FF12B2 && curl -sS https://apt.pacha.dev/pacha.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/pacha.gpg >/dev/null && echo "deb https://apt.pacha.dev ./" | tee /etc/apt/sources.list.d/pacha.list > /dev/null && apt update; break;;
        No ) break;;
    esac
done

echo "Do you want to install RStudio Desktop Stable Edition?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install rstudio; break;;
        No ) break;;
    esac
done

echo "Do you want to install RStudio Desktop Daily Build?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install gnupg && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FD3445D533FF12B2 && curl -sS https://apt-daily.pacha.dev/pacha.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/pacha.gpg >/dev/null && echo "deb https://apt-daily.pacha.dev ./" | tee /etc/apt/sources.list.d/pacha-daily.list > /dev/null && apt update && apt install rstudio; break;;
        No ) break;;
    esac
done

echo "Do you want to install Quarto?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install quarto; break;;
        No ) break;;
    esac
done

# install bspm as a system package from CRAN

echo "Do you want to install bspm to install binary R packages?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install python3-{dbus,gi,apt} r-cran-bspm; break;;
        No ) break;;
    esac
done

# enable it system-wide
# echo "bspm::enable()" | tee -a /etc/R/Rprofile.site

# enable it for the user
# echo "bspm::enable()" | tee -a ~/Rprofile.site

# ask the user to chose between a system-wide or user-wide activation
echo "Do you want to enable bspm system-wide (all users) or user-wide (only you)?"
select yn in "System-wide" "User-wide" "Skip"; do
    case $yn in
        "System-wide" ) echo "bspm::enable()" | tee -a /etc/R/Rprofile.site; break;;
        "User-wide" ) echo "bspm::enable()" | tee -a ~/Rprofile.site; break;;
        "Skip" ) break;;
    esac
done

# send msg to ask to test it
echo "Please close and reopen RStudio and test the setup by running 'install.packages("ggplot2")' in R (or any other package)"

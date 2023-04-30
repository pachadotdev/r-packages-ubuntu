# r-packages-ubuntu

## About

Install R packages as you would do on Windows (i.e., no long compilation time). In addition, this script asks to install R development tools, Git and RStudio.

## Instructions

Just copy and paste this one-line command:

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/pachadotdev/r-packages-ubuntu/main/configure.sh)"
```

## Test if it worked

When you reopen RStudio after running the script, you'll see an output like this:

```r
> install.packages("devtools")
Available system packages...


  There are binary versions available but the source versions are later:
            binary source
fs           1.6.1  1.6.2
...
devtools     2.4.3  2.4.5

Do you prefer later versions from sources? (Yes/no/cancel) n
```

After selecting "n", to install from binaries, R internally communicates with Ubuntu package manager, and installing 'devtools' takes around 10 seconds versus around 5 minutes when building from sources (10 minutes if you need to reinstall because a system dependency was missing).

One advantage of this approach is that it shall satisfy all dependencies (i.e., it will install `libpq-dev` when installing `RPostgres`).

## Automatically update RStudio Desktop

The script above configures an APT repository to my server pacha.dev, which offers the same stable RStudio version as rstudio.com. The advantage is that when the server is updated, when you run `apt update` it will offer a newer version that you can install with `apt upgrade`.

## Does it work on Debian/Mint/Pop/etc?

Yes.

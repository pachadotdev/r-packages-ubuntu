# The Perfect Setup for Ubuntu and R (and how to install/update RStudio with apt install rstudio/apt update)

## About

Install R packages as you would do on Windows (i.e., no long compilation time). In addition, this script asks to install R development tools, Git, RStudio, and Quarto.

## Motivation

Just to save time for my future self. Hopefully, it can help people in the cyberspace too :)

## Instructions

Just copy and paste this one-line command:

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/pachadotdev/r-packages-ubuntu/main/configure.sh)"
```

The command will ask you to install:

1. R
2. R development tools (i.e, r-base-dev)
3. Git
4. RStudio Desktop (stable or daily build)
5. Quarto
6. BSPM (R's Bridge to System Package Manager)

You can use it on a fresh or existing setup.

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

The script above configures an APT repository to my server pacha.dev, which offers the same stable RStudio version as rstudio.com. The advantage is that when the server is updated and you run `apt update` it will offer a newer version that you can install with `apt upgrade`.

In other words, the script enables `apt install rstudio`.

## Does it work on Debian/Mint/Pop/etc?

Yes.

## Can I audit the script?

Yes, you can re-trace all the steps I followed here: https://github.com/pachadotdev/r-packages-ubuntu.

## Notes to myself

I have to run `01-sync-server.sh` twice when updating the RStudio daily build, otherwise `apt udpate` says

```bash
W: Skipping acquire of configured file 'Packages' as repository 'https://apt-daily.pacha.dev ./ InRelease' does not seem to provide it (sources.list entry misspelt?)
```

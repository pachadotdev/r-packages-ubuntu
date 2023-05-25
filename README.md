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

If you are on Ubuntu 22.10 or higher, the script will detect it and exit. This is because the official R sources are not compatible with those versions yet.

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

## Tested platforms

### Linux Mint 21.1 (Vera) - Works ✅

Tested from a graphic environment (Cinnamon). I opened a terminal and pasted the command from the instruction at the start of this README.

### Pop OS 22.04 LTS NVIDIA - Works ✅

According to [#4](https://github.com/pachadotdev/r-packages-ubuntu/issues/4), it works. I am awaiting details from @rishieco.

### Ubuntu 20.04 (Focal) - Works ✅

Tested in a Docker container.

From my laptop I run this, but you don't need to install `wget` and the rest of dependencies in a "real" Ubuntu 22.10:

```bash
~ $ docker run -it ubuntu:22.10
root@c7ed22bee36e:/# apt update && apt install wget software-properties-common gnupg
root@c7ed22bee36e:/# bash -c "$(wget -qO- https://raw.githubusercontent.com/pachadotdev/r-packages-ubuntu/main/configure.sh)"
```

### Ubuntu 22.04 (Jammy) - Works ✅

The test is implicit because Linux Mint 21.1 is based on this version.

### Ubuntu 22.10 (Kinetic) - Fails ❎

Tested in a Docker container.

There is no Release file for `kinetic` in the official R sources, so it does not work.

### Ubuntu 23.04 (Lunar) - Fails ❎

Same reason as 22.10.

## Reported perks

On Ubuntu 22.04 Desktop, when you install a package and R asks "Do you prefer later versions from sources? (Yes/no/cancel)" you should select "yes" or it gets stuck. I could not replicate this with Docker See [#4](https://github.com/pachadotdev/r-packages-ubuntu/issues/4).

## Notes to myself

- [ ] Go to the commented PGP part in `01-sync-server.sh` every 30 days to renew the key
- [ ] Update the public key in `configure.sh` (where it says "Is it ok to add apt.pacha.dev as a source for RStudio and/or Quarto?")

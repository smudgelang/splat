[![Linux Build Status](https://img.shields.io/travis/com/smudgelang/splat.svg?label=Linux%20build&branch=master)](https://travis-ci.com/smudgelang/splat)
[![Windows Build Status](https://img.shields.io/appveyor/ci/smudgelang/splat.svg?label=Windows%20Build&branch=master)](https://ci.appveyor.com/project/smudgelang/splat)

# Splat: The Smudge Platform

## Overview

Splat is the Smudge Platform: Libraries and Toolchain, a combined
distribution of the Smudge compiler and the Smear library.

It is one-stop shopping for your Smudge needs, meant to be a
batteries-included package for development of applications.

## Installing Splat from Binaries

There are binary releases available for Windows and Linux available on
the [Splat releases page](https://github.com/smudgelang/splat/releases).

## Building Splat from Source

First, make sure you have all the prerequisites for Smudge and Smear.
Next, Splat includes Smudge and Smear as submodules, so be sure they
have been updated recursively.

Then, in your shell of choice, run:

    $ make

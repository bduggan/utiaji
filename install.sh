#!/bin/bash -ex

version=2016.04

export PATH=$HOME/.rakudobrew/bin:$PATH
if [ -x $HOME/.rakudobrew/bin/perl6 ]; then
    if $HOME/.rakudobrew/bin/perl6 --version | grep -q "$version"; then
        echo "using $version"
        rakudobrew global $version
        rakudobrew rehash
        panda --notests install DBIish
        panda install HTTP::Tinyish
        exit
    fi
fi

echo "building $version"

rm -rf $HOME/.rakudobrew
git clone https://github.com/tadzik/rakudobrew.git $HOME/.rakudobrew
rakudobrew build moar $version
rakudobrew build-panda
panda --notests install DBIish
panda install HTTP::Tinyish


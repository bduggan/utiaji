#!/bin/bash -ex

version=2016.01

if [ -x $HOME/.rakudobrew/bin/perl6 ]; then
    rakudobrew global $version
    rakudobrew rehash
    panda installdeps .
    exit 0
fi

rm -rf $HOME/.rakudobrew
git clone https://github.com/tadzik/rakudobrew.git $HOME/.rakudobrew
rakudobrew build moar $version
rakudobrew build-panda
# panda installdeps .
panda install DBIish
panda install HTTP::Tinyish


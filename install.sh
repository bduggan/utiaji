#!/bin/bash -ex

version=2016.05

export PATH=$HOME/.rakudobrew/bin:$PATH

deps() {
    panda --installed list | grep -q DBIish || panda --notests install DBIish
    panda --installed list | grep -q 'HTTP::Tinyish' || panda install HTTP::Tinyish
}

if [ -x $HOME/.rakudobrew/bin/perl6 ]; then
    if $HOME/.rakudobrew/bin/perl6 --version | grep -q "$version"; then
        echo "using $version"
        rakudobrew global $version
        rakudobrew rehash
        install_deps
        exit
    fi
fi

echo "building $version"

rm -rf $HOME/.rakudobrew
git clone https://github.com/tadzik/rakudobrew.git $HOME/.rakudobrew
rakudobrew build moar $version
rakudobrew build-panda
install_deps

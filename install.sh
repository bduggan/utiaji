#!/bin/bash -ex

version=2016.08

export PATH=$HOME/.rakudobrew/bin:$PATH

deps() {
    panda --installed list | grep -q Base64 || panda --notests install Base64
    panda --installed list | grep -q DBIish || panda --notests install DBIish
    panda --installed list | grep -q 'HTTP::Tinyish' || panda install HTTP::Tinyish
    panda --installed list | grep -q 'Digest' || panda install Digest
    panda --installed list | grep -q 'Digest::HMAC' || panda install Digest::HMAC
    panda --installed list | grep -q 'OAuth2::Client::Google' || panda install OAuth2::Client::Google
}

if [ -x $HOME/.rakudobrew/bin/perl6 ]; then
    if $HOME/.rakudobrew/bin/perl6 --version | grep -q "$version"; then
        echo "using $version"
        rakudobrew global $version
        rakudobrew rehash
        rakudobrew build-panda
        deps
        exit
    fi
fi

echo "building $version"

rm -rf $HOME/.rakudobrew
git clone https://github.com/tadzik/rakudobrew.git $HOME/.rakudobrew
rakudobrew build moar $version
rakudobrew build-panda
deps

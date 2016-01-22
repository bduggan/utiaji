#!/bin/sh -ex

version=2015.12

if [ -d $HOME/build_cache/moar-$version ]; then
    rm -rf $HOME/.rakudobrew/moar-$version
    cp -al $HOME/build_cache/moar-$version $HOME/.rakudobrew
    rakudobrew global $version
    rakudobrew rehash
else
    export PATH=~/.rakudobrew/bin:$PATH
    rakudobrew build moar $version
    rakudobrew build-panda
    cp -al $HOME/.rakudobrew/moar-$version $HOME/build_cache
fi

panda installdeps .


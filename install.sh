#!/bin/bash -ex

version=2017.08

export PATH=$HOME/.rakudobrew/bin:$PATH

git clone https://github.com/tadzik/rakudobrew.git $HOME/.rakudobrew
rakudobrew build moar $version
rakudobrew build-zef
zef install --depsonly .

#!/usr/bin/env bash

# note "server" is the default server name used to connect to emacs process started with "emacs"
emacsclient --create-frame --socket-name=server --alternate-editor "emacs" $@

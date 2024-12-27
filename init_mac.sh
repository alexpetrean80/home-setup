#!/usr/bin/env bash

darwin-rebuild switch --flake .

nix run home-manager switch -- --flake '.#alexp@workMac'

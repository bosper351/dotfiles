#!/usr/bin/env bash

# Set up docker-compose with colima
if test ! -L "$HOME/.docker/cli-plugins/docker-compose" && command -v docker >/dev/null && command -v docker-compose >/dev/null; then
    mkdir -pv "$HOME/.docker/cli-plugins"
    ln -s "$(command -v docker-compose)" "$HOME/.docker/cli-plugins/docker-compose"
fi

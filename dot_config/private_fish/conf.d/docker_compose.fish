# Set up docke-compose with colima
if not test -L $HOME/.docker/cli-plugins/docker-compose
    and type -q docker-compose
    and type -q docker
    mkdir -pv $HOME/.docker/cli-plugins
    ln -s (which docker-compose) $HOME/.docker/cli-plugins/docker-compose
end

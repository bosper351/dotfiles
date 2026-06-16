# XDG
if not set -q __xdg_basedirs_set
    set_xdg_basedirs
    set -Ux __xdg_basedirs_set true
end

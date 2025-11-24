function pyclean -d "Clean Python crap"
    set -q argv
    and set -l path_to_clean $argv
    or set -l path_to_clean .

    gfind $path_to_clean -depth \
        -type f -name "*.py[co]" -delete \
        -or -type d -name "__pycache__" -delete \
        -or -type d -name ".mypy_cache" -exec rm -r "{}" + \
        -or -type d -name ".pytest_cache" -exec rm -r "{}" +
end

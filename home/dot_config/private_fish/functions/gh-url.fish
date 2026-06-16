function gh-url --description "Return Github URL of a file"
    set -l path $argv[1]
    gh browse $(grealpath --relative-to $PWD $path)
end

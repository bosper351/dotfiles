function update --description "Update"
    brew update && brew upgrade && brew cleanup

    # Fisher
    fisher update
end

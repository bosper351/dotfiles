# Add ssh key to agent on shell start
if ssh-add -l -q > /dev/null
    ssh-add --apple-load-keychain 2> /dev/null
end

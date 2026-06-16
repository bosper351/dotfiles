function llm --description "Access large language models from the command-line (https://github.com/simonw/llm)"
    uvx --with llm-openrouter,llm-cmd,llm-jq llm $argv
end

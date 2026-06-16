function llm-commit-message --description 'Generate git commit message' --argument-names diff

	# set -l model mlx-community/Qwen3-4B-Instruct-2507-4bit
	set -l model openrouter/openai/gpt-oss-20b
	set -l sysprompt "
Write a commit message based on the supplied diff. Keep it short and under 50 characters.
Only state what has changed. Do not use adjectives.
Return *only* the commit message, nothing else."
	llm -m $model -s $sysprompt $diff | string trim -c '.:'
end

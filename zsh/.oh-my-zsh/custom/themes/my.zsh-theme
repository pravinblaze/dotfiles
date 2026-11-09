
PROMPT='$fg_bold[blue][$fg[red] %T $fg_bold[blue]] $fg_bold[blue][$fg[red] %n@%m:%~ $fg_bold[blue]]$(git_prompt_info)$fg[yellow]$(ruby_prompt_info)$reset_color
 ▶ '

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="\n$fg_bold[blue][ $fg_bold[red]git: $fg_bold[green]"
ZSH_THEME_GIT_PROMPT_SUFFIX=" $fg_bold[blue]]\n"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=" +"


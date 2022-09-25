# -------------------------- #
#  Fish Style Abbreviations  #
# -------------------------- #

# declare a global unique array for abbreviation names
typeset -gaU abbrs

function abbr() {

    if [ ! -v abbrs ]; then
        typeset -aU abbrs
    fi

    if [ "$#" -eq 0 ]; then
        for i in ${abbrs[@]}; do
            builtin alias "$i"
        done
        return 0
    fi

    for arg in "$@"; do
        if [[ $arg == *"="* ]]; then
            builtin alias "${arg}"
            abbrs+=("${arg%%\=*}")
        else
            builtin alias "${arg}"
        fi
    done

}

function unabbr() {

    if [ "$#" -eq 0 ]; then
        echo "${funcstack[-1]}: not enough arguments"
        return 1
    fi

    if [ ! -v abbrs ]; then
        typeset -aU abbrs
    fi

    # loop through arguments
    for arg in "$@"; do

        # if argument not in abbrs then return error
        if [[ ${abbrs[(ie)$arg]} -gt ${#abbrs} ]]; then
            echo "${funcstack[-1]}: no such hash table element: ${arg}"
            return 1
        fi

        # remove alias
        builtin unalias "${arg}"

        # remove item from abbrs array
        abbrs=("${abbrs[@]/$arg}")

    done

}

# Expand any aliases in the current line buffer
function expand-abbr() {
    if [[ $LBUFFER =~ "\<(${(j:|:)abbrs})\$" ]]; then
        zle _expand_alias
        zle expand-word
    fi
    zle magic-space
}
zle -N expand-abbr

# Expand any aliases in the current line buffer
# and accept the line
expand-abbr-and-accept-line() {
    expand-abbr
    zle backward-delete-char
    zle accept-line
}
zle -N expand-abbr-and-accept-line

# Replace the default accept-line function with
# the expand-abbr-and-accept-line function
# zle -N accept-line expand-abbr-and-accept-line

bindkey -M isearch " "      magic-space                             # Space (during searches)
bindkey " " expand-abbr
bindkey "^J" expand-abbr-and-accept-line
bindkey "^M" expand-abbr-and-accept-line
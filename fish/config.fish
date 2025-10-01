if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux EDITOR nvim
keychain --quiet --eval ~/.ssh/id_ed25519 | source
starship init fish | source
zoxide init fish --cmd cd | source

# set -x CPATH /usr/include
# set -x LIBRARY_PATH /usr/lib

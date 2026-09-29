set -gx EDITOR nvim

if status is-interactive
keychain --quiet --immediate --eval ~/.ssh/id_ed25519 | source
starship init fish | source
zoxide init fish --cmd cd | source
direnv hook fish | source
end


# set -x CPATH /usr/include
# set -x LIBRARY_PATH /usr/lib

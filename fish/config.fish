if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux EDITOR nvim
starship init fish | source
zoxide init fish --cmd cd | source

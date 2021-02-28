
# Auto start tmux
# Adapted from https://github.com/fish-shell/fish-shell/issues/4434#issuecomment-332626369 
# only run in interactive (not automated SSH for example) 
if status is-interactive 
# don't nest inside another tmux 
and not set -q TMUX 
  # Adapted from https://unix.stackexchange.com/a/176885/347104 
  # Create session 'main' or attach to 'main' if already exists. 
  tmux new-session -A -s main 
end



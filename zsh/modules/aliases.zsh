# Global aliases for navigating up directories
alias -g ...='../..'                    # Moves up two directory levels
alias -g ....='../../..'                # Moves up three directory levels
alias -g .....='../../../..'            # Moves up four directory levels
alias -g ......='../../../../..'        # Moves up five directory levels

# Quick navigation to previous directories
alias -- -='cd -'                       # Navigates to the previous directory
alias 1='cd -1'                         # Navigates to the first entry in the directory stack
alias 2='cd -2'                         # Navigates to the second entry in the directory stack
alias 3='cd -3'                         # Navigates to the third entry in the directory stack
alias 4='cd -4'                         # Navigates to the fourth entry in the directory stack
alias 5='cd -5'                         # Navigates to the fifth entry in the directory stack
alias 6='cd -6'                         # Navigates to the sixth entry in the directory stack
alias 7='cd -7'                         # Navigates to the seventh entry in the directory stack
alias 8='cd -8'                         # Navigates to the eighth entry in the directory stack
alias 9='cd -9'                         # Navigates to the ninth entry in the directory stack

# Aliases for listing directory contents in various formats
alias la='ls -alhFG'                    # Lists all files, including hidden ones, with detailed info
alias ll='ls -lhFG'                     # Lists files with detailed info without hidden files
alias ls='ls -G'                        # Enable color support of ls

# Function: d
# Purpose:
#   The 'd' function is a custom utility to manage and view the directory stack,
#   which allows for efficient navigation between recently visited directories.
#   It displays a list of directories in the stack, making it easier to jump
#   back to previous locations in your command-line session.
#
# Usage:
#   d [n]
#   - Without arguments, it lists the top 10 entries in the directory stack.
#   - With an argument (n), it shows specific entries or modifies the stack.
#
# Arguments:
#   - n (optional): The directory stack entry or option passed to the 'dirs' command.
#     For example, `d +1` shows the second-most-recent directory in the stack.
#
function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

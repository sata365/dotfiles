
# Update HomeBrew
if command -v brew > /dev/null 2>&1; then
  brew update > /dev/null 2>&1 &
  brew outdated &
fi

[ -f ~/.zprofile.local ] && source ~/.zprofile.local

#!/bin/bash -eu

echo "------- Start Defaults settings."

# NSGlobalDomain
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false 
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
defaults write NSGlobalDomain AppleLanguages "(en-US,ja-JP)"
defaults write NSGlobalDomain AppleLocale -string "en_JP"
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"


# com.apple.dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.dock expose-animation-duration -float 0.12
defaults write com.apple.dock largesize -int 65
defaults write com.apple.dock magnification -int 1
defaults write com.apple.dock mineffect -string 'scale'
defaults write com.apple.dock orientation -string 'bottom'
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.Dock showhidden -bool YES
defaults write com.apple.dock tilesize -int 36

# com.apple.screencapture
defaults write com.apple.screencapture include-date -bool true
defaults write com.apple.screencapture location -string '~/Documents/screenshots' && [ -d ~/Documents/screenshots ] || mkdir ~/Documents/screenshots
defaults write com.apple.screencapture show-thumbnail -bool false 
defaults write com.apple.screencapture type -string 'png' 

# com.apple.finder
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
defaults write com.apple.finder QLEnableTextSelection -bool TRUE
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowTabView -bool true

# com.apple.controlcenter
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -int 0

# com.apple.menuextra.clock
defaults write com.apple.menuextra.clock DateFormat -string 'EEE d MMM HH:mm:ss'

defaults write com.apple.menuextra.battery ShowPercent -string 'YES'

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false

sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# tabなどでMacのボタンのフォーカスを変えられるフルコントロールを設定
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# キーリピートの高速化
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# スペルの訂正を無効にする
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

killall Dock
killall Finder

echo "------- Finish Defaults settings."

exit 0
#!/usr/bin/bash
# Update the oh-my-posh binary and themes

set -e

bin_dir=/usr/local/bin
themes_dir=~/.poshthemes

# Request rights to overwrite the binary
# >/dev/null sudo echo

echo Downloading binary…
# Overwrite only if -Newer (does not seem to have an effect)
sudo wget -N -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O $bin_dir/oh-my-posh

echo Changing permissions
sudo chmod +x $bin_dir/oh-my-posh

echo Downloading themes…
mkdir -p $themes_dir
wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O $themes_dir/themes.zip

echo Unzipping
# Extract in -destination folder and -quietly -overwrite
unzip -q -o $themes_dir/themes.zip -d $themes_dir

echo Changing permissions
chmod u+rw $themes_dir/*.omp.*

echo Cleaning
rm $themes_dir/themes.zip
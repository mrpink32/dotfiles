#!/bin/bash
pacman -Syu
pacman -R plasma-meta
pacman -S --needed plasma --asexplicit
pacman -Rncsu vim
pacman -Rncsu nano
pacman -Rncsu discover
pacman -Rncsu konsole
pacman -Rncsu kate
pacman -Rncsu kwrited
pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
pacman -S alacritty neovim flatpak --noconfirm
flatpak install flathub io.gitlab.librewolf-community
pacman -S clang rustup zig zls go jdk-openjdk --noconfirm
pacman -S steam lutris --noconfirm
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.spotify.Client
flatpak install flathub com.heroicgameslauncher.hgl
flatpak install flathub org.inkscape.Inkscape
flatpak install https://flathub.org/beta-repo/appstream/org.gimp.GIMP.flatpakref
flatpak install flathub org.kde.arianna
flatpak install flathub com.protonvpn.www
flatpak install flathub com.github.zadam.trilium
flatpak install flathub com.github.xournalpp.xournalpp

# overwatch/battlenet
pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 \
lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm




rustup default nightly
cargo install ncspot

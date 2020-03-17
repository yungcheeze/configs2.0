#!/usr/bin/env bash

cp xmonad.session /usr/share/gnome-session/sessions/xmonad.session
cp xmonad-gnome-session.desktop /usr/share/xsessions/xmonad-gnome-session.desktop
cp xmonad.desktop /usr/share/applications/xmonad.desktop
cp xmonad-gnome-session-composite.desktop /usr/share/xsessions/xmonad-gnome-session-composite.desktop
cp gnome-xmonad-composite /usr/sbin/gnome-xmonad-composite
chown root /usr/share/gnome-session/sessions/xmonad.session /usr/share/xsessions/xmonad-gnome-session.desktop /usr/share/applications/xmonad.desktop /usr/share/xsessions/xmonad-gnome-session-composite.desktop /usr/sbin/gnome-xmonad-composite
chmod +x /usr/sbin/gnome-xmonad-composite

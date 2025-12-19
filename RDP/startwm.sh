#!/bin/sh
# XRDP start window manager script
# Lanzar i3 usando la sesión X estándar (Xsession)
# y permitiendo que se ejecute ~/.xsession del usuario.

# Variables de entorno (útil para apps que miran XDG)
export DESKTOP_SESSION=i3
export XDG_SESSION_DESKTOP=i3
export XDG_CURRENT_DESKTOP=i3

# (Opcional) Evita ciertos warnings/errores con algunas apps
export XDG_SESSION_TYPE=x11

# Carga locales si existen
[ -r /etc/default/locale ] && . /etc/default/locale
export LANG LANGUAGE

# Arranca la sesión X (esto leerá ~/.xsession si existe)
exec /etc/X11/Xsession
#!/bin/bash

#############
# VARIABLES #
#############

# Colores para el output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${YELLOW}[*] Iniciando script de configuración de entorno debian i3...${RESET}"

# Real user
REAL_USER=$(logname)
USER_ZSHRC="/home/$REAL_USER/.zshrc"

# Verificar si se ejecuta como root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}[!] Este script debe ejecutarse como root. Usa sudo.${RESET}"
  exit 1
fi

# Función para verificar si un paquete está instalado
check_installed() {
  if dpkg -s "$1" &>/dev/null; then
    echo -e "${YELLOW}[-] $1 ya está instalado.${RESET}"
    return 0  # Paquete ya instalado
  else
    return 1  # Paquete no instalado
  fi
}


###############
# APT INSTALL #
###############

# Instalar aplicaciones
sudo apt update
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting kitty curl python3-pip python3-venv pipx docker.io docker-compose locate tree i3 i3blocks i3lock i3lock-fancy i3status i3-wm picom rofi feh fonts-font-awesome jq nmap netdiscover make gcc build-essential python3-dev libffi-dev libssl-dev rustc cargo firefox-esr pcmanfm -y


#############
# PIP TOOLS #
#############
sudo -u "$REAL_USER" pipx ensurepath
sudo -u "$REAL_USER" pipx install git+https://github.com/Pennyw0rth/NetExec
sudo -u "$REAL_USER" python3 -m pipx install impacket
sudo -u "$REAL_USER" pip3 install i3-workspace-names-daemon --break-system-packages


############
# TERMINAL #
############

# Instalar OhMyZsh
echo -e "${GREEN}[+] Instalando Oh My Zsh para usuario $REAL_USER...${RESET}"

if [ ! -d "/home/$REAL_USER/.oh-my-zsh" ]; then
  sudo -u "$REAL_USER" -H bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
else
  echo -e "${YELLOW}[-] Oh My Zsh ya está instalado para $REAL_USER. Omitiendo.${RESET}"
fi

# Instalar Oh My Zsh si no está ya instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}[+] Instalando Oh My Zsh...${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo -e "${YELLOW}[-] Oh My Zsh ya está instalado. Omitiendo instalación.${RESET}"
fi

# Añadiendo los plugins a la ZSH
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$USER_ZSHRC"
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /root/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$USER_ZSHRC"
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /root/.zshrc

# Cambiar el tema robbyrussell.zsh-theme solo para root
echo -e "${GREEN}[+] Personalizando tema robbyrussell para el usuario root...${RESET}"

cat > /root/.oh-my-zsh/themes/robbyrussell.zsh-theme << 'EOF'
PROMPT="%(?:%{$fg_bold[red]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[red]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%})"
EOF


#######################
# i3 ENTORNO COMPLETO #
#######################

# Permisos de ejecucion a los .sh
chmod +x config/i3/scripts/*
chmod +x config/i3blocks/scripts/*

# Crear carpetas necesarias en .config
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config"
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config/i3"
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config/i3blocks"
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config/kitty"
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config/picom"
sudo -u "$REAL_USER" mkdir -p "/home/$REAL_USER/.config/rofi"

# Copia de los dot files y la fuente
cp -r config "/home/$REAL_USER/.config/"

# Fuentes de NerdFonts
/home/$REAL_USER/OrangePi2w-I3-Config
mkdir Fonts
cd Fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Ubuntu.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/UbuntuMono.zip
unzip Ubuntu.zip
rm -rf *.txt *.md
unzip UbuntuMono.zip
rm -rf *.txt *.md
sudo mkdir -p /usr/local/share/fonts
cp *.ttf /usr/local/share/fonts
cd ..

# Wallpaper
sudo -u "$REAL_USER" mkdir -p /home/banyio/Pictures
cp Wallpapers/porsche-wallpaper.jpg /home/banyio/Pictures/


##########
# RDP+I3 # 
##########
sudo apt install xorg xserver-xorg xinit i3 xrdp dbus-x11 xorgxrdp -y
sudo -u "$REAL_USER" cp RDP/xsession "/home/$REAL_USER/.xsession"
chmod +x "/home/$REAL_USER/.xsession"

sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak
sudo mv RDP/startwm.sh /etc/xrdp/startwm.sh

sudo systemctl restart xrdp xrdp-sesman



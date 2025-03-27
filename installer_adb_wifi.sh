#!/bin/bash

# =============================================
# TERMUX INSTALLER SCRIPT (AUTO-PERMISSÃO + LOGS)
# =============================================

# --- Auto-permissão (não precisa rodar chmod +x) ---
if [[ ! -x "$0" ]]; then
    echo -e "\033[1;36m[SETUP] Garantindo permissões de execução...\033[0m"
    chmod +x "$0"
    exec "$0"
    exit 1
fi

# --- Cores para melhor visualização ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# --- Configuração de Logs ---
LOG_DIR="$HOME/termux_install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/installation_$(date +'%Y-%m-%d_%H-%M-%S').log"

# --- Funções de log ---
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[✓] $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${CYAN}[ℹ] $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[⚠] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[✗] $1${NC}" | tee -a "$LOG_FILE"
}

header() {
    echo -e "${BLUE}\n===================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}===================================${NC}"
}

# --- Início da Instalação ---
header "INICIANDO INSTALAÇÃO NO TERMUX"
info "Todos os logs serão salvos em: $LOG_FILE"

# Atualizar repositórios
header "ATUALIZANDO REPOSITÓRIOS"
info "Atualizando lista de pacotes..."
if pkg update -y >> "$LOG_FILE" 2>&1; then
    success "Repositórios atualizados com sucesso!"
else
    error "Falha ao atualizar repositórios"
    exit 1
fi

# Instalar android-tools
header "INSTALANDO ANDROID-TOOLS"
info "Instalando pacote android-tools..."
if pkg install android-tools -y >> "$LOG_FILE" 2>&1; then
    success "Android-tools instalado com sucesso!"
else
    error "Falha ao instalar android-tools"
    exit 1
fi

# Instalar nmap
header "INSTALANDO NMAP"
info "Instalando pacote nmap..."
if pkg install nmap -y >> "$LOG_FILE" 2>&1; then
    success "Nmap instalado com sucesso!"
else
    error "Falha ao instalar nmap"
    exit 1
fi

# Configurar permissões do Termux
header "CONFIGURANDO PERMISSÕES"
info "Habilitando allow-external-apps..."

TERMUX_CONFIG="/data/data/com.termux/files/home/.termux/termux.properties"
CONFIG_KEY="allow-external-apps"
CONFIG_VALUE="true"

info "Criando diretório de configuração..."
mkdir -p "$(dirname "$TERMUX_CONFIG")" && chmod 700 "$(dirname "$TERMUX_CONFIG")"

info "Aplicando configuração..."
if ! grep -q "^$CONFIG_KEY=" "$TERMUX_CONFIG" 2>/dev/null; then
    echo "$CONFIG_KEY=$CONFIG_VALUE" >> "$TERMUX_CONFIG"
else
    sed -i "s/^$CONFIG_KEY=.*/$CONFIG_KEY=$CONFIG_VALUE/" "$TERMUX_CONFIG"
fi

if grep -q "^$CONFIG_KEY=$CONFIG_VALUE" "$TERMUX_CONFIG"; then
    success "Permissões configuradas com sucesso!"
    info "Reinicie o Termux ou execute: termux-reload-settings"
else
    error "Falha ao configurar permissões"
    exit 1
fi

# Finalização
header "INSTALAÇÃO COMPLETA"
success "Todos os componentes foram instalados!"
info "Log completo: $LOG_FILE"
info "Recomendado reiniciar o Termux para aplicar todas as configurações."
echo -e "${GREEN}\n✔ Script concluído com sucesso!${NC}"

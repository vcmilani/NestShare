#!/usr/bin/env bash
# ============================================================
#  NestShare — Instalação
# ============================================================
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERR]${NC}   $*"; exit 1; }

[ "$(id -u)" -eq 0 ] || error "Execute como root: sudo bash install.sh"

INSTALL_DIR="/opt/nestshare"
PORT=5000

info "Instalando Python3 e dependências do sistema..."
apt-get update -qq
apt-get install -y python3 python3-pip python3-venv libpam0g-dev openssl

info "Copiando arquivos para $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r . "$INSTALL_DIR/"

info "Criando ambiente virtual e instalando dependências..."
python3 -m venv "$INSTALL_DIR/venv"
"$INSTALL_DIR/venv/bin/pip" install -q -r "$INSTALL_DIR/requirements.txt"

info "Gerando certificado SSL auto-assinado..."
openssl req -x509 -newkey rsa:2048 \
  -keyout "$INSTALL_DIR/key.pem" \
  -out    "$INSTALL_DIR/cert.pem" \
  -days 3650 -nodes \
  -subj "/CN=$(hostname)" 2>/dev/null
chmod 600 "$INSTALL_DIR/key.pem"

info "Instalando serviço systemd..."
cp nestshare.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable nestshare
systemctl start nestshare

IP=$(hostname -I | awk '{print $1}')
echo ""
echo -e "${GREEN}✓ NestShare instalado!${NC}"
echo ""
echo "  Acesse: https://${IP}:${PORT}"
echo ""
echo "  sudo systemctl status nestshare"
echo "  sudo journalctl -u nestshare -f"

# Soletrando

## Como testar
Para testar a aplicação, é necessário ter um banco SQL Server com o banco e tabelas do 
script `database/scripts/soletrando.sql`. Desse modo, há duas opções para atingir isso:

### Via Docker
Pré-requisito(s): Docker

1. Executar `docker compose up -d`, no terminal Linux

Caso queira executar via Docker no Windows, mas não o tem instalado, duas possíveis opções são:
- Instalar o [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) (Mais fácil)
- Instalar o [Docker Engine + WSL 2](https://github.com/codeedu/wsl2-docker-quickstart) (Mais recomendado):
```bash
# 1. Instalar WSL via PowerShell
wsl --update
wsl --set-default-version 2
wsl --install

# 2. Após criar o Linux User, executar no Bash:
sudo apt update && sudo apt -y upgrade
sudo apt install -y build-essential bc git
# 2.1. Docker - https://docs.docker.com/engine/install/ubuntu/
sudo sh -c "$(curl -fsSL https://get.docker.com)"
sudo usermod -aG docker $USER

# 3. Testar o Soletrando
git clone https://github.com/gustavenrique/soletrando.git ./development/soletrando

explorer.exe ./development/soletrando
```

### Via SQL Server instalado local
Pré-requisito(s): SQL Server e SQL Server Management Studio (SSMS)

1. Executar script do `database/scripts/soletrando.sql`, no SSMS
2. Comentar connection string do SQL Server do Docker & Descomentar a connection string de banco local

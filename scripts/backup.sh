cat << 'EOF' > ~/enterprise-homelab-infrastructure/scripts/backup.sh

set -euo pipefail

# 1. Основные переменные
BACKUP_DIR="/var/backups/infra"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="infra_backup_${DATE}.tar.gz"
LOG_FILE="/var/log/infra_backup.log"
RETENTION_DAYS=7

# 2. Создаем директорию для бэкапов, если её нет
mkdir -p "${BACKUP_DIR}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

log "=== Starting the backup ==="

# 3. Список архивируемых директорий и файлов
SOURCE_DIRS=(
    "/etc/bind"                             # Конфигурация и зоны DNS
    "/etc/netplan"                          # Конфигурация сети
    "/home/ivan/infra/nginx"                # Конфигурация Reverse Proxy
    "/home/ivan/infra/prometheus"           # Настройки метрик
    "/home/ivan/infra/docker-compose.yml"   # Оркестрация сервисов
)

# 4. Архивация и сжатие
log "Archiving configuration files in ${BACKUP_DIR}/${ARCHIVE_NAME}..."
if tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" "${SOURCE_DIRS[@]}" 2>> "${LOG_FILE}"; then
    log "The archive has been successfully created. Size: $(du -h "${BACKUP_DIR}/${ARCHIVE_NAME}" | cut -f1)"
else
    log "ERROR: Failed to create archive!"
    exit 1
fi

# 5. Ротация: удаление архивов старше 7 дней
log "leaning up old backups (older than ${RETENTION_DAYS} days)..."
DELETED_COUNT=$(find "${BACKUP_DIR}" -type f -name "infra_backup_*.tar.gz" -mtime +${RETENTION_DAYS} -print -delete | wc -l)
log "Removed outdated archives: ${DELETED_COUNT}"

log "=== Backup completed successfully ==="
EOF
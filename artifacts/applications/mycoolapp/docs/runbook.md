# Operational Runbook: mycoolapp LAMP Deployment

**Application**: mycoolapp  
**Stack**: Ubuntu 22.04 LTS, Apache 2.4, PHP 8.2, MySQL 8.0  
**Last Updated**: 2026-02-07  
**Runbook Version**: 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [Deployment Procedures](#deployment-procedures)
3. [Operational Procedures](#operational-procedures)
4. [Monitoring & Alerting](#monitoring--alerting)
5. [Backup & Recovery](#backup--recovery)
6. [Scaling](#scaling)
7. [Troubleshooting](#troubleshooting)
8. [Incident Response](#incident-response)

---

## Overview

### System Architecture

```
Internet
   ↓
[Public IP: xxx.xxx.xxx.xxx]
   ↓
[NSG Rules: Allow 80, 443, 22]
   ↓
[Azure Linux VM: Standard_B4ms (prod) / Standard_B2s (dev)]
   ├─ Apache 2.4 (Web Server)
   ├─ PHP 8.2 (Application Runtime)
   └─ MySQL 8.0 (Database)
   ↓
[Azure Monitor & Log Analytics]
```

### Contact Information

- **On-Call Engineer**: _______________________ (Phone: _______________)
- **Application Owner**: _______________________ (Email: _______________)
- **Database Administrator**: _______________________ (Email: _______________)
- **Security Officer**: _______________________ (Email: _______________)

---

## Deployment Procedures

### Prerequisites

```bash
# Install required tools
az bicep install
az extension add --name monitor
az extension add --name log-analytics

# Verify authentication
az account show
```

### Initial Deployment (Dev Environment)

```powershell
# Navigate to deployment scripts
cd artifacts/applications/mycoolapp/scripts

# Run prerequisite checks
pwsh ./prereqs-check.ps1

# Deploy infrastructure
pwsh ./deploy.ps1 -Environment dev -ResourceGroupName mycoolapp-dev-rg

# Validate deployment
pwsh ./validate-deployment.ps1 -ResourceGroupName mycoolapp-dev-rg -Environment dev
```

### Production Deployment

```powershell
# Deploy to production (REQUIRES APPROVAL)
pwsh ./deploy.ps1 -Environment prod -ResourceGroupName mycoolapp-prod-rg
```

---

## Operational Procedures

### SSH Access

```bash
# Get public IP
az network public-ip show --resource-group mycoolapp-dev-rg \
  --name mycoolapp-dev-pip --query ipAddress -o tsv

# SSH into VM
ssh azureuser@<public_ip>

# Become root (with sudo)
sudo su -
```

### Service Management

#### Check Service Status

```bash
# Apache
sudo systemctl status apache2
sudo apache2ctl -S  # Configuration syntax check

# PHP-FPM
sudo systemctl status php8.2-fpm

# MySQL
sudo systemctl status mysql
mysql -u root -p  # Connect to database
```

#### Restart Services

```bash
# Apache
sudo systemctl restart apache2

# PHP-FPM
sudo systemctl restart php8.2-fpm

# MySQL
sudo systemctl restart mysql

# All services
sudo systemctl restart apache2 php8.2-fpm mysql
```

### Log Files

| Service | Log Location |
|---------|--------------|
| Apache (access) | `/var/log/apache2/access.log` |
| Apache (errors) | `/var/log/apache2/error.log` |
| Apache (SSL) | `/var/log/apache2/ssl_error.log` |
| PHP-FPM | `/var/log/php8.2-fpm.log` |
| MySQL | `/var/log/mysql/error.log` |
| Setup Script | `/var/log/mycoolapp-setup.log` |
| System | `/var/log/syslog` |

#### View Logs

```bash
# Real-time log watching
tail -f /var/log/apache2/access.log

# Search for errors
grep ERROR /var/log/apache2/error.log

# Last 100 lines
tail -100 /var/log/apache2/access.log
```

### Application Deployment

```bash
# Application directory
cd /var/www/html/app

# Deploy new version (example with git)
git pull origin main
php artisan migrate  # If using Laravel or similar

# Set permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

---

## Monitoring & Alerting

### Health Check Endpoint

```bash
# Test health endpoint
curl http://<public_ip>/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2026-02-07T12:34:56+00:00",
#   "uptime": "3 days",
#   "apache": "running",
#   "php": "8.2.0",
#   "mysql": "available"
# }
```

### Azure Monitor Metrics

```bash
# Query CPU usage (last hour)
az monitor metrics list \
  --resource /subscriptions/<sub_id>/resourceGroups/mycoolapp-dev-rg/providers/Microsoft.Compute/virtualMachines/mycoolapp-dev-vm \
  --metric "Percentage CPU" \
  --aggregation Average \
  --interval PT5M \
  --start-time 2026-02-07T00:00:00 \
  --end-time 2026-02-07T23:59:59

# Query memory usage
az monitor metrics list \
  --resource /subscriptions/<sub_id>/resourceGroups/mycoolapp-dev-rg/providers/Microsoft.Compute/virtualMachines/mycoolapp-dev-vm \
  --metric "Available Memory Bytes" \
  --aggregation Average
```

### Alert Rules

The following alerts are configured (see `alert-rules.bicep`):

1. **CPU > 80%** (5 minutes) → Severity: Warning
2. **Memory < 20%** (5 minutes) → Severity: Warning
3. **Disk Read > 100 MB/s** (15 minutes) → Severity: Info
4. **Network In > 1 TB** (5 minutes) → Severity: Info
5. **VM Stopped/Deallocated** → Severity: Critical

### Responding to Alerts

```
Alert: CPU > 80%
├─ Action: Check running processes (top, htop)
├─ Action: Review Apache connections (netstat -an | grep :80)
├─ Decision: Scale up? (manual for now)
└─ Resolution: Kill inactive processes or upgrade SKU

Alert: Memory < 20%
├─ Action: Check memory usage (free -h)
├─ Action: Identify memory leaks (PHP opcache, MySQL buffers)
├─ Decision: Increase zend.memory_limit in php.ini?
└─ Resolution: Restart services or upgrade SKU

Alert: VM Stopped
├─ Action: Investigate why VM stopped
├─ Action: Check Azure Activity Log
├─ Action: Verify no manual shutdown
└─ Resolution: Restart VM (az vm start --resource-group ...)
```

---

## Backup & Recovery

### Manual Backup

#### Database Backup

```bash
# Backup MySQL database
mysqldump -u root -p mycoolapp_db > db_backup_$(date +%Y%m%d).sql

# Backup all databases
mysqldump -u root -p --all-databases > full_backup_$(date +%Y%m%d).sql

# Backup to Azure Blob Storage
az storage blob upload \
  --account-name <storage_account> \
  --container-name backups \
  --name db_backup_$(date +%Y%m%d).sql \
  --file db_backup_$(date +%Y%m%d).sql
```

#### File System Backup

```bash
# Backup application files
tar -czf app_backup_$(date +%Y%m%d).tar.gz /var/www/html/app

# Upload to storage
az storage blob upload \
  --account-name <storage_account> \
  --container-name backups \
  --name app_backup_$(date +%Y%m%d).tar.gz \
  --file app_backup_$(date +%Y%m%d).tar.gz
```

### Automated Backup (via scripts)

```bash
# Create backup script: /etc/cron.daily/mycoolapp-backup.sh
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"

# MySQL backup
mysqldump -u root -p$MYSQL_ROOT_PASS mycoolapp_db | \
  gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Sync to Azure
az storage blob upload --batch-source-pattern "*.gz" \
  --destination-container backups \
  --source $BACKUP_DIR

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +30 -delete
```

### Restore Procedures

#### Restore MySQL Database

```bash
# From local file
mysql -u root -p mycoolapp_db < db_backup_20260207.sql

# From Azure Blob Storage
az storage blob download \
  --account-name <storage_account> \
  --container-name backups \
  --name db_backup_20260207.sql \
  --file db_backup_20260207.sql

mysql -u root -p mycoolapp_db < db_backup_20260207.sql
```

#### Restore Application Files

```bash
# Extract from backup
tar -xzf app_backup_20260207.tar.gz -C /

# Restore permissions
sudo chown -R www-data:www-data /var/www/html/app
sudo chmod -R 755 /var/www/html/app
```

#### VM Snapshot Recovery (Infrastructure-level)

```bash
# Create VM snapshot
az snapshot create \
  --resource-group mycoolapp-dev-rg \
  --name mycoolapp-vm-snapshot-$(date +%Y%m%d) \
  --source /subscriptions/<sub_id>/resourceGroups/mycoolapp-dev-rg/providers/Microsoft.Compute/disks/mycoolapp-dev-osdisk

# Restore from snapshot (creates new VM)
# Use the snapshot as the source when creating a new managed disk
```

### Recovery Time Objectives (RTO)

| Scenario | RTO | Procedure |
|----------|-----|-----------|
| Service restart | 5 minutes | `systemctl restart` |
| Database restore | 15-30 minutes | `mysqldump` restore |
| Application restore | 10 minutes | Extract from backup |
| VM recreate | 30 minutes | Redeploy via Bicep |
| Full site restore | 1 hour | All of above |

---

## Scaling

### Vertical Scaling (Upgrade SKU)

Current SKUs: `Standard_B2s` (dev), `Standard_B4ms` (prod)

Available SKUs (cost-optimized from infrastructure/001):
- `Standard_B2s` (2 vCores, 4 GB RAM)
- `Standard_B4ms` (4 vCores, 16 GB RAM)
- `Standard_D4s_v3` (4 vCores, 16 GB RAM)
- `Standard_D8s_v3` (8 vCores, 32 GB RAM)

**Upgrade Procedure**:

```bash
# Deallocate VM
az vm deallocate --resource-group mycoolapp-prod-rg --name mycoolapp-prod-vm

# Resize VM
az vm resize --resource-group mycoolapp-prod-rg \
  --name mycoolapp-prod-vm \
  --size Standard_D4s_v3

# Start VM
az vm start --resource-group mycoolapp-prod-rg --name mycoolapp-prod-vm

# Verify
az vm get-instance-view --resource-group mycoolapp-prod-rg \
  --name mycoolapp-prod-vm --query hardwareProfile.vmSize
```

### Horizontal Scaling (Multiple VMs - Future)

For future multi-VM deployments:

1. Create VM #2 using same Bicep template
2. Add both VMs to backend pool
3. Deploy Azure Load Balancer (standard tier)
4. Configure health probes on `/health` endpoint
5. Update DNS to point to load balancer

### Connection Pooling & Performance Tuning

```bash
# Increase Apache MaxClients
sudo nano /etc/apache2/mods-available/mpm_prefork.conf
# Set: MaxRequestWorkers 256

# MySQL buffer pool size
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Set: innodb_buffer_pool_size = 8G (for production)

# PHP opcache
sudo nano /etc/php/8.2/mods-available/opcache.ini
# Set: opcache.memory_consumption = 256
```

---

## Troubleshooting

### Apache Not Responding

```bash
# Check service status
sudo systemctl status apache2

# Check error log
sudo tail -50 /var/log/apache2/error.log

# Check configuration
sudo apache2ctl -S

# Restart service
sudo systemctl restart apache2

# Verify on port 80
curl -v http://localhost/
```

### High CPU Usage

```bash
# Identify processes
top -b -n 1 | head -20
ps aux --sort=-%cpu | head -10

# Check Apache connections
netstat -an | grep :80 | wc -l

# Check MySQL queries
mysql -u root -p -e "SHOW PROCESSLIST;"

# Kill runaway PHP process
pkill -f "php"
sudo systemctl restart php8.2-fpm
```

### Disk Space Issues

```bash
# Check disk usage
df -h
du -sh /*

# Find large files
find / -type f -size +1G -exec ls -lh {} \;

# Clean up logs
sudo truncate --size 0 /var/log/apache2/access.log
sudo journalctl --vacuum=1d

# Cleanup package manager cache
sudo apt clean
sudo apt autoclean
```

### MySQL Connection Issues

```bash
# Check MySQL status
sudo systemctl status mysql

# Test connection
mysql -u root -p -h localhost -e "SELECT 1;"

# Check open connections
mysql -u root -p -e "SHOW STATUS LIKE '%connections%';"

# Reset password
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';"
```

### PHP Errors

```bash
# Check PHP error log
sudo tail -50 /var/log/php8.2-fpm.log

# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Test PHP CLI
php -v
php -i | grep "error_log"

# Enable debug mode (temporary)
sudo nano /etc/php/8.2/fpm/conf.d/99-custom.ini
# Set: error_reporting = E_ALL
# Set: display_errors = On
```

---

## Incident Response

### Critical: VM Down

**Impact**: mycoolapp inaccessible

**Response**:

1. **Assessment** (1-2 min):
   - Check Azure portal for VM status
   - Review activity log for recent changes
   - Check alert notifications

2. **Immediate Action** (2-5 min):
   ```bash
   # Try restart
   az vm restart --resource-group mycoolapp-prod-rg --name mycoolapp-prod-vm
   
   # Wait 2 minutes, then retest
   curl http://<public_ip>/health
   ```

3. **If Restart Fails** (5-15 min):
   - Check VM serial console for errors
   - Review system disk for corruption
   - Restore from snapshot if available
   - Redeploy VM using Bicep template

4. **Post-Incident**:
   - Document root cause
   - Update runbook
   - Implement preventive measures

### Warning: High Resource Usage

**Impact**: Potential performance degradation

**Response**:

1. Identify bottleneck (CPU, memory, disk, network)
2. Implement temporary fix (kill runaway process, clear cache, etc.)
3. Short-term: Vertical scale (upgrade SKU)
4. Long-term: Horizontal scale + load balancer

### Security: Unauthorized Access Attempt

**Impact**: Potential compromise

**Response**:

1. Review SSH logs: `sudo grep "Failed password" /var/log/auth.log`
2. Block suspicious IPs in NSG
3. Rotate SSH keys
4. Run security scan
5. Review file integrity

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial runbook for mycoolapp MVP deployment |

---

**Runbook Owner**: _______________________ **Last Review**: __________ (**Next Review**: __________)

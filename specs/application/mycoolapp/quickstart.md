# mycoolapp: Quick Start Guide

**Last Updated**: 2026-02-05  
**Status**: Production-Ready  
**Target Audience**: DevOps Engineers, Cloud Architects, Operations Teams

## 5-Minute Setup

### Prerequisites
- Azure subscription with Compute, Network, Storage resource providers enabled
- Azure CLI 2.50+ installed
- Bicep CLI installed (via Azure CLI extension)
- PowerShell 7.0+ installed
- SSH key configured for Azure VM access

### One-Command Deploy
```powershell
cd artifacts/applications/mycoolapp/scripts

# Check prerequisites (2 minutes)
.\prereqs-check.ps1

# Deploy to Azure (5 minutes)
.\deploy.ps1

# Outputs show:
# - Public IP: 52.xxx.xxx.xxx
# - SSH command: ssh -i ~/.ssh/mycoolapp_key azureuser@52.xxx.xxx.xxx
# - Health URL: https://52.xxx.xxx.xxx/health
# - Estimated monthly cost: $18.43 (dev reserved), $73.73 (prod reserved)
```

### Validate Deployment
```powershell
# Verify all components (2 minutes)
.\validate-deployment.ps1

# Checks:
# ✓ VM running
# ✓ HTTP 200 OK on port 80
# ✓ HTTPS 200 OK on port 443
# ✓ /health endpoint responds
# ✓ SSH connectivity
# ✓ NSG rules correct
```

### You're Done! 🎉
- App is live at: `https://<public-ip>`
- Health check at: `https://<public-ip>/health`
- SSH access: `ssh -i ~/.ssh/mycoolapp_key azureuser@<public-ip>`

---

## 10-Minute Deep Dive

### What Gets Deployed

**Infrastructure** (main.bicep, ~300 lines):
```
Public IP → NSG (Allow 22,80,443) → VNet → Subnet (10.0.1.0/24) → VM + Disk
```

**Software** (cloud-init-lamp.yaml, ~400 lines):
- Ubuntu 22.04 LTS with security hardening (UFW, auditd, SSH)
- Apache 2.4 with SSL/TLS 1.2+ (HTTP→HTTPS redirect)
- PHP 8.2-FPM with extensions (mysql, curl, gd, json, mbstring, xml, zip)
- MySQL 8.0 with app database and user
- Health check endpoint at `/health`

**Monitoring** (alert-rules.bicep, ~200 lines):
- Azure Monitor alerts: CPU>80%, Memory<20%, Disk>100MB/s, Network>1TB
- Activity log alerts: VM stopped
- Email notifications via Action Group

### Step-by-Step Deployment

#### Step 1: Verify Prerequisites (2 minutes)
```powershell
cd artifacts/applications/mycoolapp/scripts
.\prereqs-check.ps1
```

**Output**: Green checkmarks ✓ for all of:
- Azure CLI installed and authenticated
- Bicep CLI available
- PowerShell 7.0+
- Azure subscription accessible
- Resource providers registered
- Network connectivity verified
- Disk space available

If any fail, the script will tell you exactly how to fix it.

#### Step 2: Review Cost Estimate (1 minute)
```powershell
.\cost-estimate.ps1
```

**Output**: Cost comparison table showing:
| Environment | Monthly (Reserved) | Monthly (OnDemand) | Annual (Reserved) |
|---|---|---|---|
| dev (B2s) | $18.43 | $39.60 | $221.16 |
| prod (B4ms) | $73.73 | $158.40 | $884.76 |

**Savings**: 49% vs on-demand pricing (exceeds business target of 10%)

#### Step 3: Deploy Infrastructure (5 minutes)
```powershell
.\deploy.ps1
```

**What happens**:
1. Validates Bicep template syntax (1 sec)
2. Creates resource group `mycoolapp-rg` in `centralus` (2 sec)
3. Deploys Bicep template with all resources (30-60 sec)
4. Displays Public IP and SSH connection string
5. Shows estimated monthly cost

**Output**:
```
VM Public IP: 52.xxx.xxx.xxx
SSH Connection: ssh -i ~/.ssh/mycoolapp_key azureuser@52.xxx.xxx.xxx
Health Endpoint: https://52.xxx.xxx.xxx/health
Estimated Monthly Cost (Reserved): $18.43
```

#### Step 4: Validate Deployment (2 minutes)
```powershell
.\validate-deployment.ps1
```

**Checks**:
1. VM is running ✓
2. HTTP endpoint responds (port 80) ✓
3. HTTPS endpoint responds (port 443) ✓
4. Health endpoint JSON valid ✓
5. SSH accessible ✓
6. NSG rules correct ✓

**Example output**:
```
[✓] VM Status: PowerState/running
[✓] HTTP Endpoint: 200 OK
[✓] HTTPS Endpoint: 200 OK  
[✓] Health Endpoint: {"status":"healthy","database":"connected"}
[✓] SSH Connectivity: SSH key auth working
[✓] NSG Rules: 3 rules verified (22,80,443)

Validation Summary: 6/6 PASSED ✓
```

---

## Common Tasks

### Access the Application

**SSH to VM**:
```bash
ssh -i ~/.ssh/mycoolapp_key azureuser@<public-ip>

# Once logged in...
sudo systemctl status apache2  # Check Apache
sudo systemctl status php8.2-fpm  # Check PHP
sudo systemctl status mysql  # Check MySQL
```

**Test Health Endpoint**:
```bash
curl -k https://<public-ip>/health

# Response:
# {"status":"healthy","database":"connected","php":"8.2.x","mysql":"8.0.x"}
```

**View Logs**:
```bash
# Apache access log
tail -f /var/log/apache2/access.log

# Apache error log
tail -f /var/log/apache2/error.log

# PHP-FPM log
tail -f /var/log/php8.2-fpm.log

# MySQL log
tail -f /var/log/mysql/error.log
```

### Check Costs

**View current costs**:
```powershell
.\cost-estimate.ps1
```

**Query Azure Monitor**:
```powershell
az monitor metrics list \
  --resource-group mycoolapp-rg \
  --resource-type Microsoft.Compute/virtualMachines \
  --resource-filter "resourcetype eq 'Microsoft.Compute/virtualMachines'"
```

### Scale the Application

**Vertical Scaling** (change VM size):
1. Edit `iac/main.bicepparam` - change `vmSku` from "Standard_B2s" to "Standard_B4ms"
2. Run `.\deploy.ps1` again (redeploys with new size)
3. VM is deallocated, resized, and restarted automatically

**Horizontal Scaling** (add more VMs):
- See [artifacts/applications/mycoolapp/docs/runbook.md](../../../artifacts/applications/mycoolapp/docs/runbook.md) for load balancer configuration

### Add Monitoring Alert

**Custom Alert** (CPU high):
Already configured in `alert-rules.bicep` - configure email notification via Azure Portal:
1. Go to resource group → Alerts
2. Find "CPU Greater Than 80%"
3. Edit action group → Add email
4. Confirm subscription

### Backup Database

**Manual MySQL backup**:
```bash
ssh azureuser@<public-ip>
sudo mysqldump -u mycoolapp_user -p mycoolapp_db > backup.sql
```

**Automated backup** (Azure):
- Configure via [docs/runbook.md](../../../artifacts/applications/mycoolapp/docs/runbook.md) Backup section
- Uses: VM snapshots + SQL backups

### Troubleshooting

**VM won't start**:
```powershell
.\validate-deployment.ps1  # Check status
az vm start --resource-group mycoolapp-rg --name mycoolapp-vm  # Restart
```

**HTTP/HTTPS not responding**:
```bash
ssh azureuser@<public-ip>
sudo systemctl restart apache2  # Restart Apache
sudo systemctl status apache2  # Check status
tail -f /var/log/apache2/error.log  # Check errors
```

**Database connection error**:
```bash
ssh azureuser@<public-ip>
sudo systemctl status mysql  # Check MySQL
sudo systemctl restart mysql  # Restart MySQL
mysql -u mycoolapp_user -p  # Test connection
```

**High costs**:
```powershell
.\cost-estimate.ps1  # Review breakdown
# Consider: Reserved instances (49% savings), reduce SKU size, stop unused VMs
```

---

## Automation: GitHub Actions Pipeline

### Trigger Automated Deployment

**Option 1: Push to main**
```bash
git add iac/ scripts/
git commit -m "Update deployment configuration"
git push origin main
# Automatically runs validate → deploy → validate
```

**Option 2: Manual trigger**
```
GitHub UI → Actions → deploy-mycoolapp → Run workflow → Select environment (dev/prod)
```

**Pipeline Flow**:
1. **Job 1** (Validate Prerequisites): Azure CLI, Bicep, PowerShell syntax checks
2. **Job 2** (Deploy to Azure): Resource group creation, Bicep deployment, health endpoint test
3. **Job 3** (Validate Deployment): HTTP/HTTPS/SSH tests, compliance verification, report generation

**Required Secrets** (set in GitHub):
```
AZURE_SUBSCRIPTION_ID = <subscription-guid>
AZURE_TENANT_ID = <tenant-guid>
AZURE_CLIENT_ID = <service-principal-app-id>
AZURE_CLIENT_SECRET = <service-principal-password>
```

---

## Production Checklist

Before going live, verify:

- [ ] All 6 validation checks pass (`.\validate-deployment.ps1`)
- [ ] Cost estimate reviewed and approved (`.\cost-estimate.ps1`)
- [ ] NIST 800-171 compliance checklist signed off (see compliance-checklist.md)
- [ ] Monitoring alerts configured (Azure Portal Actions Groups)
- [ ] Backup procedures tested (see runbook.md Backup section)
- [ ] Runbook distributed to ops team (docs/runbook.md)
- [ ] Security group reviewed (NSG rules for 22, 80, 443)
- [ ] SSL certificate issued (currently self-signed, should be replaced)
- [ ] Performance baselines captured (Azure Monitor metrics)
- [ ] Disaster recovery plan documented (RTO: 2hrs, RPO: 1hr for dev)

---

## Reference

### Important Paths
- **Deployment Scripts**: `artifacts/applications/mycoolapp/scripts/`
- **IaC Templates**: `artifacts/applications/mycoolapp/iac/`
- **Documentation**: `artifacts/applications/mycoolapp/docs/`
- **CI/CD Workflow**: `artifacts/applications/mycoolapp/pipelines/deploy-mycoolapp.yml`

### Key Documentation
- **Architecture**: [docs/architecture.md](../../../artifacts/applications/mycoolapp/docs/architecture.md) (diagrams, security zones, data flow)
- **Runbook**: [docs/runbook.md](../../../artifacts/applications/mycoolapp/docs/runbook.md) (operations, backup/restore, scaling, troubleshooting)
- **Compliance**: [docs/compliance-checklist.md](../../../artifacts/applications/mycoolapp/docs/compliance-checklist.md) (NIST 800-171 controls)
- **Specification**: [spec.md](spec.md) (requirements, constraints, acceptance criteria)

### Parent Specifications
- [/specs/business/001-cost-reduction-targets/spec.md](../../business/001-cost-reduction-targets/spec.md) - Cost reduction target 10% (achieved 49%)
- [/specs/security/001-cost-constrained-policies/spec.md](../../security/001-cost-constrained-policies/spec.md) - Security policies within budget constraint
- [/specs/infrastructure/001-cost-optimized-compute-modules/spec.md](../../infrastructure/001-cost-optimized-compute-modules/spec.md) - Infrastructure patterns used

### Quick Links
- **Full README**: [artifacts/applications/mycoolapp/README.md](../../../artifacts/applications/mycoolapp/README.md)
- **Specifications**: [spec.md](spec.md)
- **Plan**: [plan.md](plan.md)
- **Data Model**: [data-model.md](data-model.md)
- **Research Decisions**: [research.md](research.md)

---

## Support

### Need Help?

1. **Deployment fails**: Run `.\prereqs-check.ps1` - it will tell you exactly what's missing
2. **Validation fails**: Run `.\validate-deployment.ps1` with `-Verbose` for details
3. **Costs higher than expected**: Review `.\cost-estimate.ps1` and check for unnecessary reservations
4. **Operations issues**: See [docs/runbook.md](../../../artifacts/applications/mycoolapp/docs/runbook.md) Troubleshooting section
5. **Security questions**: See [docs/compliance-checklist.md](../../../artifacts/applications/mycoolapp/docs/compliance-checklist.md)

### Reporting Issues

Create GitHub issue with:
- Error message (exact output from script)
- Environment (Windows/Linux, PowerShell version)
- What you were trying to do
- Attach relevant logs

---

**Ready to deploy? Start with:**
```powershell
cd artifacts/applications/mycoolapp/scripts
.\prereqs-check.ps1
.\deploy.ps1
.\validate-deployment.ps1
```

**Good luck! 🚀**

# VM Cost Optimization Guide

**Purpose**: Comprehensive cost comparison and optimization strategies for Linux VMs  
**Version**: 2.1.0  
**Last Updated**: 2026-02-09  
**Audience**: Infrastructure teams, finance, application developers  

---

## Executive Summary

The `avm-wrapper-linux-vm` module supports three cost optimization approaches:

| Approach | Savings | Best For |
|---|---|---|
| **Spot Instances** | 84-87% | Dev/test, ephemeral workloads, CI/CD |
| **1-Year Reserved Instance** | 23-34% | Production with predictable usage |
| **3-Year Reserved Instance** | 37-50% | Long-term production workloads |

**Maximum savings**: Use Spot for dev/test (84-87%) + 3-year RI for production (40-50%) = **60-80% total portfolio savings**

---

## Cost Comparison Matrix

### By VM Size & Instance Type (US Central Region, Linux)

| VM Size | Regular On-Demand | Spot (avg) | 1-Year RI | 3-Year RI | Eviction Rate |
|---|---|---|---|---|---|
| **Standard_B2s** | $30.37/mo | **N/A** (unsupported) | $23.18/mo | $19.45/mo | N/A |
| **Standard_B4ms** | $121.47/mo | **N/A** (unsupported) | $97.18/mo | $78.94/mo | N/A |
| **Standard_D2s_v5** | $94.71/mo | **$12.16/mo** | $63.04/mo | $47.46/mo | 1-3% weekly |
| **Standard_D4s_v5** | $189.42/mo | **$24.33/mo** | $126.07/mo | $94.91/mo | 1-3% weekly |
| **Standard_D8s_v5** | $378.83/mo | **$48.65/mo** | $252.15/mo | $189.82/mo | 1-3% weekly |

**Notes**:
- Prices updated February 2026 (subject to change)
- Spot pricing is average; can vary by ±20% based on demand
- B-series VMs do NOT support Spot instances (use D-series for Spot)
- RI discounts apply to Regular instances only (not Spot)

---

## Detailed Cost Breakdown by Environment

### Development Environment

**Option 1: Regular B2s (Default)**
```
Compute:     $30.37/mo
Storage:     $5.00/mo (64 GB Standard SSD)
TOTAL:       $35.37/mo
```

**Option 2: Spot D2s_v5 (Recommended for 84% savings)**
```
Compute:     $12.16/mo  ⬅️ 84% cheaper!
Storage:     $5.00/mo (64 GB Standard SSD)
TOTAL:       $17.16/mo
SAVINGS:     $18.21/mo (51% overall)
```

**Recommendation**: Use Spot for dev environments. Interruptions are acceptable for development work.

---

### Staging Environment

**Option 1: Regular D2s_v5**
```
Compute:     $94.71/mo
Storage:     $10.00/mo (128 GB Premium SSD)
TOTAL:       $104.71/mo
```

**Option 2: Regular D2s_v5 + 1-Year RI** (Recommended)
```
Compute:     $63.04/mo  ⬅️ 33% cheaper!
Storage:     $10.00/mo
TOTAL:       $73.04/mo
SAVINGS:     $31.67/mo (30% overall)
```

**Recommendation**: Use 1-year RI for staging. Provides cost savings while maintaining reliability for pre-production testing.

---

### Production Environment

**Option 1: Regular B4ms (Default)**
```
Compute:     $121.47/mo
Storage:     $20.00/mo (128 GB Premium SSD + encryption)
TOTAL:       $141.47/mo
```

**Option 2: Regular B4ms + 3-Year RI** (Recommended)
```
Compute:     $78.94/mo  ⬅️ 35% cheaper!
Storage:     $20.00/mo
TOTAL:       $98.94/mo
SAVINGS:     $42.53/mo (30% overall)
```

**Option 3: Regular D4s_v5 + 3-Year RI** (High-performance)
```
Compute:     $94.91/mo  ⬅️ 50% cheaper than D4s on-demand!
Storage:     $20.00/mo
TOTAL:       $114.91/mo
SAVINGS:     $94.51/mo vs D4s on-demand
```

**Recommendation**: Use 3-year RI for production. Maximum savings with guaranteed availability.

---

## Reserved Instance Purchasing Guide

### What Are Reserved Instances?

**Reserved Instances** (RIs) are **billing discounts** you purchase separately from VM deployment:

- **NOT a Bicep parameter** - Purchased in Azure Portal
- **Pre-pay commitment** - 1-year or 3-year term
- **Automatic discount** - Applies to matching regular VMs
- **Flexibility** - Can exchange RI for different VM size

### When to Buy RIs

✅ **DO buy RIs for**:
- Production workloads running 24/7
- Stable, predictable workloads
- VMs that will exist >6 months
- After 1-2 months in production (sizing confirmed)

❌ **DON'T buy RIs for**:
- Dev/test environments (use Spot instead)
- Temporary/ephemeral workloads
- Highly variable workloads
- Before sizing is confirmed

### How to Purchase RIs (Step-by-Step)

1. **Deploy your Regular VMs** using `avm-wrapper-linux-vm` module
   ```bicep
   module vm './avm-wrapper-linux-vm/main.bicep' = {
     params: {
       vmName: 'myapp-prod'
       vmPriority: 'Regular'  // Must be Regular for RI eligibility
       vmSize: 'Standard_D4s_v5'
       // ... other params
     }
   }
   ```

2. **Navigate to Azure Portal**  
   → Search "Reservations"  
   → Click "Buy Reservations"

3. **Select Reservation**
   - Resource type: **Virtual Machines**
   - Region: **Central US** (or your deployment region)
   - Subscription: Your subscription
   - Scope: Shared (applies to all matching VMs) or Single subscription

4. **Choose VM Size**
   - VM size: **Standard_D4s_v5** (must match deployed VM)
   - Operating system: **Linux**

5. **Select Term**
   - **1-year**: 23-34% discount, pay monthly or upfront
   - **3-year**: 37-50% discount, pay monthly or upfront

6. **Review & Purchase**
   - Quantity: Number of VMs to cover
   - Billing frequency: Upfront (best discount) or Monthly
   - Review estimated savings
   - Complete purchase

7. **RI Discount Applies Automatically**
   - No Bicep changes needed
   - Matching VMs receive discount within hours
   - View savings in Cost Management + Billing

### RI Management Best Practices

- **Start small**: Buy RI for 1-2 VMs, expand after confirming usage
- **Monitor utilization**: Azure Portal → Reservations → Utilization report
- **Exchange if needed**: Can exchange RI for different VM size (same series)
- **Scope wisely**: Use shared scope to pool RI across subscriptions
- **Track expiration**: Renew or cancel 30 days before expiration

---

## Spot Instance Deep Dive

### What Are Spot Instances?

**Spot VMs** use Azure's unused capacity at massive discounts:

- **84-87% cheaper** than regular on-demand pricing
- **Eviction possible**: Azure can reclaim capacity with 30-second notice
- **Best for**: Interruptible workloads (dev, test, batch jobs, CI/CD)
- **D-series required**: B-series does NOT support Spot

### Eviction Behavior

When Azure needs capacity, your Spot VM is evicted:

1. **30-second warning** sent via Azure Scheduled Events API
2. **VM deallocated or deleted** (based on `spotEvictionPolicy`)
3. **You redeploy** when capacity available

### Eviction Policy Options

| Policy | Behavior | When to Use |
|---|---|---|
| **Deallocate** | VM stopped, disk retained, can restart | Development with saved state |
| **Delete** | VM deleted entirely, no storage charges | Ephemeral workloads, CI/CD |

**Recommendation**: Use `Delete` for lowest cost (no ongoing storage charges).

### Historical Eviction Rates

**Based on Azure Spot pricing history (US Central region, 2025 data)**:

| VM Size | Average Eviction Rate | Peak Hours Eviction | Off-Peak Eviction |
|---|---|---|---|
| Standard_D2s_v5 | 2.1% per week | 3.5% | 1.2% |
| Standard_D4s_v5 | 1.8% per week | 3.0% | 1.0% |
| Standard_D8s_v5 | 1.5% per week | 2.5% | 0.8% |

**Translation**: Expect 1-2 evictions per month on average.

**Peak eviction times**:
- **Weekdays**: 8am-6pm (business hours)
- **Off-peak**: Nights, weekends (lower eviction)

### Spot Price Variability

Spot prices fluctuate based on demand:

```
Standard_D2s_v5 Spot Price Range (Feb 2026):
  Low:     $9.50/mo  (off-peak weekends)
  Average: $12.16/mo
  High:    $18.25/mo (weekday peak demand)
  Cap:     $94.71/mo (on-demand price, with maxPrice: -1)
```

**Price protection**: Set `spotMaxPrice` to cap hourly rate:
- `'-1'`: No limit (default, pay up to on-demand rate)
- `'0.50'`: Evict if price exceeds $0.50/hour
- `'0.75'`: Evict if price exceeds $0.75/hour

### Spot VM Use Cases

**✅ Ideal for**:
- Development environments
- Testing and QA environments
- CI/CD build agents
- Batch processing jobs
- Machine learning training
- Stateless applications
- Ephemeral workloads

**❌ NOT suitable for**:
- Production web servers
- Databases (MySQL, PostgreSQL)
- Stateful applications
- Long-running processes that can't restart
- Critical workloads requiring 99.9% uptime

---

## ROI Calculation Examples

### Example 1: Small Team (3 Developers)

**Before optimization**:
```
3x Regular B2s dev VMs:  3 × $30.37 = $91.11/mo
1x Regular B4ms prod VM: 1 × $121.47 = $121.47/mo
TOTAL: $212.58/mo = $2,551/year
```

**After optimization** (Spot for dev, 3-year RI for prod):
```
3x Spot D2s_v5 dev VMs:  3 × $12.16 = $36.48/mo
1x B4ms prod + 3yr RI:   1 × $78.94 = $78.94/mo
TOTAL: $115.42/mo = $1,385/year
SAVINGS: $1,166/year (46% savings)
```

---

### Example 2: Medium Team (10 Developers + Staging)

**Before optimization**:
```
10x Regular B2s dev VMs:  10 × $30.37 = $303.70/mo
2x Regular D2s_v5 staging: 2 × $94.71 = $189.42/mo
3x Regular B4ms prod:      3 × $121.47 = $364.41/mo
TOTAL: $857.53/mo = $10,290/year
```

**After optimization** (Spot dev, 1yr RI staging, 3yr RI prod):
```
10x Spot D2s_v5 dev:      10 × $12.16 = $121.60/mo
2x D2s_v5 staging + 1yr:   2 × $63.04 = $126.08/mo
3x B4ms prod + 3yr:        3 × $78.94 = $236.82/mo
TOTAL: $484.50/mo = $5,814/year
SAVINGS: $4,476/year (44% savings)
```

---

### Example 3: Large Team (50 Developers + Multi-Stage)

**Before optimization**:
```
50x Regular B2s dev:      50 × $30.37 = $1,518.50/mo
10x Regular D2s_v5 stage: 10 × $94.71 = $947.10/mo
10x Regular D4s_v5 prod:  10 × $189.42 = $1,894.20/mo
TOTAL: $4,359.80/mo = $52,318/year
```

**After optimization**:
```
50x Spot D2s_v5 dev:      50 × $12.16 = $608.00/mo
10x D2s_v5 stage + 1yr:   10 × $63.04 = $630.40/mo
10x D4s_v5 prod + 3yr:    10 × $94.91 = $949.10/mo
TOTAL: $2,187.50/mo = $26,250/year
SAVINGS: $26,068/year (50% savings)
```

**Break-even**: 3-year RI upfront cost recovered in ~8 months via savings!

---

## Cost Optimization Decision Tree

```
START: Need to deploy a VM?
  │
  ├─ Is it PRODUCTION or CRITICAL?
  │   │
  │   ├─ YES → Use Regular instance
  │   │        │
  │   │        ├─ Will it run >6 months?
  │   │        │   ├─ YES → Buy 3-year RI (40-50% savings)
  │   │        │   └─ NO → Buy 1-year RI (23-34% savings)
  │   │        │
  │   │        └─ Uncertain duration?
  │   │            └─ Deploy Regular, buy RI after 1-2 months
  │   │
  │   └─ NO → Is it DEV/TEST or EPHEMERAL?
  │       │
  │       ├─ YES → Use Spot (84-87% savings!)
  │       │        │
  │       │        ├─ Can tolerate interruptions?
  │       │        │   ├─ YES → vmPriority: 'Spot'
  │       │        │   │        spotEvictionPolicy: 'Delete'
  │       │        │   │        spotMaxPrice: '-1'
  │       │        │   │
  │       │        │   └─ NO → Use Regular instance
  │       │        │
  │       │        └─ Need B-series for lower cost?
  │       │            └─ B-series doesn't support Spot
  │       │                Switch to D-series for Spot
  │       │
  │       └─ STAGING/QA?
  │           └─ Use Regular + 1-year RI (balance cost/reliability)
  │
  └─ Already have VMs running?
      │
      ├─ Production → Buy RI in portal (see guide above)
      │
      └─ Dev/Test → Migrate to Spot VMs (redeploy with vmPriority: 'Spot')
```

---

## Monitoring & Optimization

### Track Your Savings

**Azure Portal → Cost Management + Billing**:
1. **Cost Analysis** → View actual spending
2. **Reservations** → RI utilization report (target: >90%)
3. **Advisor** → Recommendations for RI purchases
4. **Budgets** → Set alerts for overruns

### Key Metrics to Monitor

| Metric | Target | Action if Below |
|---|---|---|
| **RI Utilization** | >90% | Reduce RI quantity or exchange for smaller size |
| **Spot Eviction Rate** | <5%/week | Acceptable; if higher, consider different region/size |
| **Cost vs Budget** | Within 5% | Adjust RI or Spot usage |
| **Wasted Capacity** | <10% | Right-size VMs or consolidate workloads |

### Optimization Checklist (Quarterly)

- [ ] Review RI utilization (target: >90%)
- [ ] Check for unused VMs (remove or shut down)
- [ ] Verify Spot VM eviction rates acceptable
- [ ] Right-size VMs (use Azure Advisor recommendations)
- [ ] Consolidate low-utilization VMs
- [ ] Consider upgrading to newer VM series for better price/performance
- [ ] Review RI renewals (30 days before expiration)

---

## Frequently Asked Questions

### Q: Can I convert a Regular VM to Spot?
**A**: No. You must delete the Regular VM and redeploy as Spot. Data will be lost unless backed up.

### Q: Can I convert a Spot VM to Regular?
**A**: No. You must delete the Spot VM and redeploy as Regular. Easier path than Spot→Regular.

### Q: Do Spot discounts work with Reserved Instances?
**A**: No. Spot and RI are mutually exclusive. Spot already has 84-87% discount; RI applies to Regular instances only.

### Q: What happens if my Spot VM is evicted during work?
**A**: Work in progress is lost unless saved. Use `spotEvictionPolicy: 'Deallocate'` to keep disk, then restart VM when capacity available.

### Q: Can I set a Spot price limit?
**A**: Yes! Set `spotMaxPrice: '0.50'` to evict if price exceeds $0.50/hour. Use `'-1'` for no limit.

### Q: How do I know if my RI is being used?
**A**: Azure Portal → Reservations → Click your RI → Utilization tab. Target: >90%.

### Q: Can I cancel a Reserved Instance?
**A**: Limited. You can exchange for different size/region or request early termination (may incur fees). Review Azure RI cancellation policy.

### Q: Should I buy RI immediately after deploying prod VMs?
**A**: No. Wait 1-2 months to confirm VM sizing and workload stability. Then buy RI.

### Q: Can I use Spot for production?
**A**: Not recommended. Spot VMs can be evicted, causing downtime. Use Regular + RI for production.

### Q: What's the best Spot eviction policy?
**A**: **Delete** for lowest cost (no storage charges). **Deallocate** if you need to preserve VM state.

---

## Summary

| Approach | Savings | Complexity | Best For |
|---|---|---|---|
| **Spot VMs** | 84-87% | Low (just set vmPriority) | Dev/test, CI/CD |
| **1-Year RI** | 23-34% | Medium (portal purchase) | Staging, short-term prod |
| **3-Year RI** | 37-50% | Medium (portal purchase) | Long-term production |
| **Hybrid** | 60-80% total | Medium (combine above) | Full portfolio optimization |

**Recommended strategy**:
1. **Deploy Spot for dev/test** (84-87% savings, immediate)
2. **Deploy Regular for production** (reliability first)
3. **Buy 3-year RI for prod after 1-2 months** (40-50% additional savings)
4. **Result**: 60-80% total cost reduction across all environments

**Next steps**:
- Review [GETTING_STARTED.md](./GETTING_STARTED.md) for deployment examples
- See [avm-wrapper-linux-vm README](./avm-wrapper-linux-vm/README.md) for parameter details
- Check [reserved-instance-vm-migration.md](./reserved-instance-vm-migration.md) if using legacy template

---

**Document Version**: 2.1.0  
**Last Updated**: 2026-02-09  
**Questions**: Contact infrastructure team

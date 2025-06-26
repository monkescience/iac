# EKS Setup

This component handles the setup of an EKS (Elastic Kubernetes Service) cluster infrastructure.

## DNS Configuration for Route53

When using Route53 for DNS management with your EKS cluster, you need to configure your domain's nameservers to point to the Route53 nameservers. This step is essential for DNS resolution to work correctly.

### Steps to Configure DNS Nameservers:

1. **Find your Route53 Hosted Zone nameservers**:
   - Go to the AWS Management Console
   - Navigate to Route53 > Hosted Zones
   - Select your hosted zone
   - Note the four NS (nameserver) records listed under "Name servers"

2. **Update your domain registrar**:
   - Log in to your domain registrar (e.g., GoDaddy, Namecheap, etc.)
   - Find the DNS or nameserver settings for your domain
   - Replace the existing nameservers with the four Route53 nameservers
   - Save the changes

3. **Verify the configuration**:
   - DNS changes can take up to 48 hours to propagate globally, though often complete within a few hours
   - Use the `dig ns yourdomain.com` command to verify the nameservers have been updated
   - You can also use online DNS lookup tools to check the NS records

### Example Route53 Nameservers:

```
ns-1234.awsdns-12.org
ns-567.awsdns-34.com
ns-890.awsdns-56.net
ns-1234.awsdns-78.co.uk
```

> **Note**: DNS propagation takes time. After updating the nameservers, wait at least a few hours before expecting the changes to take effect. During this propagation period, DNS resolution might be inconsistent.

### Troubleshooting

If you experience DNS resolution issues after the propagation period:

- Verify that all four Route53 nameservers are correctly configured at your registrar
- Check if your Route53 zone has the correct DNS records configured
- Ensure that there are no conflicting DNS records at your registrar

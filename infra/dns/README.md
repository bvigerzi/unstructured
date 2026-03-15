# DNS Configuration

## ALIAS Record Workaround

If the Porkbun Terraform provider does not support ALIAS records, the apex
domain record must be created manually:

1. Log in to [Porkbun](https://porkbun.com)
2. Navigate to **Domain Management** → **unstructured.fyi** → **DNS Records**
3. Add a new record:
   - **Type:** ALIAS
   - **Host:** *(leave blank for apex)*
   - **Answer:** `<pullzone_hostname>` (from `cd ../cdn && terraform output pullzone_hostname`)
   - **TTL:** 600
4. Comment out or remove the `porkbun_dns_record.apex` resource in `main.tf`

The `www` CNAME record can still be managed via Terraform.

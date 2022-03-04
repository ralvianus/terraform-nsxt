This is the lab topology for AKO demo in NSX-T Cloud environment
Clone repository and adjust `terraform.tfvars` and `main.tf` as required  

---

#### `run`
```
terraform init
terraform plan
terraform apply
```

#### `destroy` [optional]
```
terraform destroy
```

---

#### `terraform.tfvars`
```
# NSX-T parameters
nsxt_host                  = "172.16.10.117"
nsxt_username              = "admin"
nsxt_password              = "VMware1!SDDC"

```

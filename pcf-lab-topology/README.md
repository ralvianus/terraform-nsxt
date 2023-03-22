## [`terraform-nsxt`](../README.md)`/pcf-lab-topology`
This is the lab topology for AVI to support Tanzu Application Service (TAS) in NSX-T Cloud environment
Clone repository and adjust `terraform.tfvars` and `main.tf` as required  

![](https://i.imgur.com/kv9B0GM.png)
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
nsxt_host                  = "<NSX-T Manager Address>"
nsxt_username              = "<Username>"
nsxt_password              = "<Password>"

```

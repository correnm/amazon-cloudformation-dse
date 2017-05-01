# DSE with Terraform & Ansible

### Requiremnts ###

* [Ansible 2.2][1]
* [Terraform][2]
* [Boto] [3]

## Manage Infrastructure As Code ##
### Terraform ###

First, create a local RSA private/public keypair. Note the password and path/filename for later.

Second, setup a `my.tfvars` file in the following format:
                
```ini
access_key = "<YOUR AWS ACCESS KEY>"
secret_key = "<YOUR AWS SECRET KEY>"
g2ops_owner =  "<YOUR NAME>"
```

Third, update the terraform variables in the `variables.tf` file: 
* Set `public_key_path` to the local public key created above
* Set `key_name`, usually the same as the file name in the `public_key_path`
* Update `region` and `region_zone` if not preferring `us-west-2`
* Add / update the ami in the `amis` map.

Third, run Terraform commands:
* Plan: `terraform plan -var-file my.tfvars`
* Apply: `terraform apply -var-file my.tfvars`
* Plan destroy: `terraform plan -destroy -var-file my.tfvars`
* Destroy: `terraform destroy -var-file my.tfvars`


[1]: http://docs.ansible.com/ansible/intro_installation.html
[2]: https://www.terraform.io/
[3]: https://aws.amazon.com/developers/getting-started/python/

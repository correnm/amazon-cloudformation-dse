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
aws_keypair = "aws_keypair_name_string_which_can_include_spaces"
```

Third, update the terraform variables in the `variables.tf` file: 
* Update `region` and `region_zone` if not preferring `us-west-2`
* Add / update the ami in the `amis` map.
* Set the cluster size with `seed_node_count` and `total_node_count`

Fourth, run Terraform commands:
* Plan: `terraform plan -var-file my.tfvars`
* Apply: `terraform apply -var-file my.tfvars`
* Plan destroy: `terraform plan -destroy -var-file my.tfvars`
* Destroy: `terraform destroy -var-file my.tfvars`

Note: The build process will prompt for a `var.expire_after_date` value. This can be any string, even empty, but is intended to be a date in the form: `yyyy-mm-dd`. All instances will be tagged with this "expiration" date.

Note: The current configuration opens the following ports on the EC2 instances to the world: 7000, 7001, 7199, 9042

## Manage Server Configuration As Code ##
### Ansible ###

Note: it is possible to have Ansible configured as a [provisioner in Terraform][4] but they are being kept separate while these scripts are being developed. 

Note: Ansible requires an inventory of the systems. The `ec2.py` script accomplishes this. 

First: Set the `datastax_academy_username` in `group_vars\tag_is_dse_node_1`. 

Second: run the playbook with: 
```bash
ansible-playbook -i ec2.py --private-key=~/.ssh/aws_private_key_filename.pem ansible_configure_instances.yml
```





[1]: http://docs.ansible.com/ansible/intro_installation.html
[2]: https://www.terraform.io/
[3]: https://aws.amazon.com/developers/getting-started/python/
[4]: https://github.com/jonmorehouse/terraform-provisioner-ansible
[5]: http://docs.ansible.com/ansible/intro_inventory.html
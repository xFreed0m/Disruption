# Disruption
Terraform IaC to deploy small AD env in Azure

## Architecture
![Architecture overview](https://github.com/xFreed0m/Disruption/blob/master/Architecture.png)

## Details
Disruption is a code for Terraform to deploy a small AD domain-based environment in Azure.
The environment contains two domain controllers (Windows Server 2012), Fileserver + Web server (Windows Server 2019), Windows 7 client, Windows 10 client, and kali Linux machine. They are connected to the same subnet.
Each windows machine has some packages being installing during deployment (the list can be viewed and modified here: [chocolist](https://github.com/xFreed0m/Disruption/blob/master/choco_packages.tf)).
All the needed configurations (Domain creation, DC promotion, joining the machines to the domain and more are automated and part of the deployment. However, there are more improvments to be added (creating OUs, Users, and stuff like that. I'll might get to it in the future, or, you will submit a pull request :)) 

## Deployment instructions
1. Have Terraform installed on your machine - [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) (I'm not covering the instruction for that part as it's already widely covered on the internet)
2. Duplicate the variables.tf.template and remove the 'template' from the duplicated file name.
3. Fill in the details in the variables.tf file you just created, those variables are used during the deployment.
4. `terraform init && terraform plan && terraform apply`
5. Have a coffee or something, this takes ~45 minutes to complete the deployment fully
6. When the deployment is done Terraform will print all the IPs (public and private) - note that the public IPs will be configured to allow external connections only from the deploying machine public IP and the rules allow port 80, 3389 and 22.
7. Make sure to destroy the environment to avoid being charged a considerable amount of money.

### Issues, bugs and other code-issues
Yeah, I know, this code isn't the best. I'm fine with it as I'm not a developer and this is part of my learning process.
If there is an option to do some of it better, please, let me know.

_Not how many, but where._

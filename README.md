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
4. Have a coffee or something, this takes ~45 minutes to complete the deployment fully
5. Make sure to destroy the environment to avoid being charged a considerable amount of money.

### Donations
Did my work helped you? Did it save you some time and money?
Well, just in case you want to buy me a coffee (or beer), feel free to donate, it will be highly appreciated!

Thanks in advance!

[![Donate with Ethereum](https://en.cryptobadges.io/badge/big/0xC1c9F71cb7845D7c3254Fa6b8b968ceDb5FA1bBE)](https://en.cryptobadges.io/donate/0xC1c9F71cb7845D7c3254Fa6b8b968ceDb5FA1bBE)[![Donate with Bitcoin](https://en.cryptobadges.io/badge/big/1Nkqjt7fZ8NDJdeRKZcGKUQREoaSyLhvde)](https://en.cryptobadges.io/donate/1Nkqjt7fZ8NDJdeRKZcGKUQREoaSyLhvde)
>_If you use another crypto, please send me a message, and I will pass you a specific address for that coin_

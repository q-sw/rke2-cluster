rke2-cluster
------------------------------------------
*Déploiement d'un cluster Kubernetes RKE2 avec Terraform et Ansible sur AWS*  

Sommaire
-----------------------------------------
- [Déployer un cluster](#déployer-un-cluster)
- [Construction de l'infrastructure](#construction-de-linfrastructure)
	- [Prérequis](#prérequis)
		- [Système](#système)
		- [Provider Terraform](#provider-terraform)
		- [Variables Terraform](#variables-terraform)
	- [Ressources créées](#ressources-créées)
	- [Outputs Terraform](#outputs-terraform)
	- [Déploiment de l'infrastructure](#déploiment-de-linfrastructure)
		- [Etape 1: Configurer ses identifiants AWS](#etape-1-configurer-ses-identifiants-aws)
		- [Etape 2: Configurer le backend des states Terraform](#etape-2-configurer-le-backend-des-states-terraform)
		- [Etape 3: Déployer l'infrastructure](#etape-3-déployer-linfrastructure)
- [Configuration du cluster Kubernetes](#configuration-du-cluster-kubernetes)
	- [Prérequis](#prérequis-1)
		- [Système](#système-1)
		- [Modules Ansible utilisés](#modules-ansible-utilisés)
	- [Variables Ansible](#variables-ansible)
	- [Description des playbooks](#description-des-playbooks)
		- [00_LoadBalancer.yaml](#00_loadbalanceryaml)
			- [Description:](#description)
			- [Varibles utilisées:](#varibles-utilisées)
			- [templates/files utilisés:](#templatesfiles-utilisés)
		- [01_PrepMaster.yaml](#01_prepmasteryaml)
			- [Description:](#description-1)
			- [Varibles utilisées:](#varibles-utilisées-1)
			- [templates/files utilisés:](#templatesfiles-utilisés-1)
		- [02_InitCluster.yaml](#02_initclusteryaml)
			- [Description:](#description-2)
			- [Varibles utilisées:](#varibles-utilisées-2)
			- [templates/files utilisés:](#templatesfiles-utilisés-2)
		- [03_AddWorker.yaml](#03_addworkeryaml)
			- [Description:](#description-3)
			- [Varibles utilisées:](#varibles-utilisées-3)
			- [templates/files utilisés:](#templatesfiles-utilisés-3)
		- [04_SetupK8sEnv.yaml](#04_setupk8senvyaml)
			- [Description:](#description-4)
			- [Varibles utilisées:](#varibles-utilisées-4)
			- [templates/files utilisés:](#templatesfiles-utilisés-4)
	- [Déploiement du Cluster](#déploiement-du-cluster)
# Déployer un cluster
*La commande ci-dessous est definie par le fichier [makefile](makefile) du projet.*  
*Elle  permet en une seule étape de construire l'infrastructure du AWS et de configure le cluster Kubernetes.*
> /!\ Des adaptations sont à faire en fonction de son environnement AWS (ex: ID AMI, ID subnet ...)
```
make build-cluster
```
# Construction de l'infrastructure
*La construction de l'infrastructure se fait à l'aide de [Terraform](https://www.terraform.io/) en utilisant le [provider AWS officiel](https://registry.terraform.io/providers/hashicorp/aws/latest). L'ensemble du code Terraform se trouve dans le dossier [**terraform**](terraform/).*  
## Prérequis 
### Système
|Package|Version|
|-------|-------|
|Terraform|>= 1.0.5|
|AWS programmatic access| n/a |

### Provider Terraform
| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.68.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |

### Variables Terraform
*Toutes les variables peuvent etre surchargées dans le fichier [terraform.tfvars](terraform/terraform.tfvars) du projet*

| Nom | Description | Type | Valeur par défaut | Requise |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ami_id"></a> [aws\_ami\_id](#input\_aws\_ami\_id) | ID de l'ami à utiliser | `string` | n/a | oui |
| <a name="input_cloud_region"></a> [cloud\_region](#input\_cloud\_region) | Nom de la region aws | `string` | n/a | oui |
| <a name="input_lb_instance_flavor"></a> [lb\_instance\_flavor](#input\_lb\_instance\_flavor) | Flavor à utiliser pour le load-balancer | `string` | `"t2.small"` | non |
| <a name="input_lb_nb"></a> [lb\_nb](#input\_lb\_nb) | Nombre de load-balancer à déployer | `number` | `1` | non |
| <a name="input_lb_net_part"></a> [lb\_net\_part](#input\_lb\_net\_part) | Partie réseau pour les load-balancer | `number` | n/a | oui |
| <a name="input_master_instance_flavor"></a> [master\_instance\_flavor](#input\_master\_instance\_flavor) | Flavor à utiliser pour les master nodes | `string` | `"t2.medium"` | non |
| <a name="input_master_nb"></a> [master\_nb](#input\_master\_nb) | Nombre de master à déployer | `number` | `1` | non |
| <a name="input_master_net_part"></a> [master\_net\_part](#input\_master\_net\_part) | Partie réseau pour les masters | `number` | n/a | oui |
| <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags) | Tags par défaut du projet | `map` | n/a | oui |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | ID du security group à utiliser | `string` | n/a | oui |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Nom de la clé SSH à utiliser | `string` | n/a | oui |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR du subnet sous forme de liste | `list` | n/a | oui |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID du subnet à utiliser | `string` | n/a | oui |
| <a name="input_worker_instance_flavor"></a> [worker\_instance\_flavor](#input\_worker\_instance\_flavor) | Flavor à utiliser pour les worker nodes | `string` | `"t2.medium"` | non |
| <a name="input_worker_nb"></a> [worker\_nb](#input\_worker\_nb) | Nombre de worker à déployer | `number` | `1` | non |
| <a name="input_worker_net_part"></a> [worker\_net\_part](#input\_worker\_net\_part) | Partie réseau pour les worker | `number` | n/a | oui |

## Ressources créées 

| Name | Type |
|------|------|
| [aws_instance.lb](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/instance) | resource |
| [aws_instance.master](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/instance) | resource |
| [aws_instance.worker](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/instance) | resource |
| [aws_network_interface.lb_int](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/network_interface) | resource |
| [aws_network_interface.master_int](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/network_interface) | resource |
| [aws_network_interface.worker_int](https://registry.terraform.io/providers/hashicorp/aws/3.68.0/docs/resources/network_interface) | resource |
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/2.1.0/docs/resources/file) | resource |
| [local_file.ansible_infrastructure_vars](https://registry.terraform.io/providers/hashicorp/local/2.1.0/docs/resources/file) | resource |

## Outputs Terraform
*Aucun Output Terraform personnalié n'est configuré.*  

*A la fin de la construction de l'infrastructure, Terraform construit l'inventaire Ansible au format YAML. Par défaut l'inventaire utilise les IPs publique des instances EC2. La construction de cet inventaire s'appuie sur le fichier template [inventory.tpl](terraform/templates/inventory.tpl).*   
*Le fichier d'inventaire est donc managé par Terraform.*   
*Terraform s'occupe de:*  
- *créé le fichier **ansible/inventory.yaml***
- *mettre à jour le fichier*
- *supprimer le fichier*   
    
*au meme titre que l'infrastructure*

*Exemple du fichier généré:*
```
all:
  hosts:
    lb0:
      ansible_host: xx.xx.xx.xx
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ssh_key.pem
    master0:
      ansible_host: xx.xx.xx.xx
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ssh_key.pem
    master1:
      ansible_host: xx.xx.xx.xx
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ssh_key.pem
    worker0:
      ansible_host: xx.xx.xx.xx
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ssh_key.pem
master:
  hosts:
    master0:
master_init:
  hosts:
    master0:
additionnal_master:
  hosts:
    master1:
worker:
  hosts:
    worker0:
lb:
  hosts:
    lb0:
```

*En plus de créer le fichier d'inventaire, Terraform manage aussi un fichier de variable ansible dérivant l'infrastruture. La génération de fichier est géré par le template [infrastructure.tpl](terraform/templates/infrastructure.tpl)*  
*Le fichier créé se trouve dans [ansible/group_vars/all](ansible/group_vars/all)*  *Exemple du fichier généré:*
```
master_init:
  - name: "master0"
    ip: "yy.yy.yy.yy"
additionnal_master:
  - name: "master0"
    ip: "yy.yy.yy.yy"
worker:
%{ for info in worker ~}
  - name: "worker0"
    ip: "yy.yy.yy.yy"
lb:
  - name: "lb0"
    ip: "yy.yy.yy.yy"
```

## Déploiment de l'infrastructure
### Etape 1: Configurer ses identifiants AWS
```
export AWS_ACCESS_KEY_ID="****"
export AWS_SECRET_ACCESS_KEY="****"
export AWS_DEFAULT_REGION="eu-west-3"
```
### Etape 2: Configurer le backend des states Terraform
*Pour cette étape il faut éditer le fichier [terraform/backend.tf](terraform/backend.tf), dans lequel on va spécifier:* 
- *le bucketS3*  
- *le chemin dans lequel on va sauvegarder les states* 
[cf. docucmentation Terraform](https://www.terraform.io/docs/language/settings/backends/s3.html)
```
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```
> Pour garder les states en local, il suffit de supprimer le fichier [terraform/backend.tf](terraform/backend.tf)

### Etape 3: Déployer l'infrastructure
*La commande ci-dessous est definie par le fichier [makefile](makefile) du projet*
```
make build-infra
```
# Configuration du cluster Kubernetes
*L'ochestration et le déploiment de la configuration de l'infrastructure est fait par [Ansible](https://docs.ansible.com/). L'ensemble du code Ansible se trouve dans le dossier [**ansible**](ansible/)*
## Prérequis
### Système
|Package|Version|
|-------|-------|
|Ansible |>= 2.10|
|Clé SSH | n/a |
### Modules Ansible utilisés
- apt
- file
- blockinfile
- lineinfile
- service
- template
- shell
- user

## Variables Ansible
*Toutes les variables peuvent etre surchargées dans le fichier [general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml) du projet*

| Nom | Description | Type | Valeur par défaut | Requise |
|------|-------------|------|---------|:--------:|
| url_script_rke2 | URL d'accès au script d'installation RKE2 | `string` | `"https://get.rke2.io"` | non |
| RKE2_PORT | Port d'écoute de l'agent RKE2 | `number` | `9345` | non |
| rancher_config_path | Chemin vers la configuration de l'agent RKE2 | `string` | `"/etc/rancher/rke2"` | non |
| kubernetes_fqdn | FQDN du cluster Kubernetes | `string` | `"my-kubernetes.local"` | non |
| rke_data_dir | Chemin utiliser par RKE2 pour stocker les fichiers de configuration du cluster | `string` | `"/var/lib/rancher/rke2"` | non |
| cluster_cidr | CIDR utilisé par les POD | `string` | `"10.42.0.0/16"` | non |
| service_cidr | CIDR utilisé par les services Kubernetes | `string` | `"t2.medium"` | non |
| service_node_port_range | Range de port utilisé pour les services Kubernetes | `string` | `"30000-32767"` | non |
| cluster_dns | IP du pod coredns Kubernetes | `string`  | `"10.43.0.10"` | non |
| cluser_domain | Domain DNS interne du cluster Kubernetes | `string` | `"cluster.local"` | non |
| etcd_snapshot_dir | Chemin utilisé pour stocker les snapshots de l'ETCD | `string` | `"/var/lib/rancher/rke2/db/snapshots"` | non |
| rke2_token | chaine de caractère aléatoire pour identifier les membres du cluster | `string` | `"c56bssw8gfrlslxlmtcdjrxc52hsdkfj5mgc2bg2l85w7kjbbtzbj5"` | non |
| cis_profile | Profile CIS à utilisé  valeur possible (cis-1.5, cis-1.6 ) cf.[docs](https://docs.rke2.io)| `string` | `""` | non |
| system_environnement | Liste contenant la personnalisation de l'environnement système| `list[dict]` | `- {path: "/etc/profile", line: "export PATH=/var/lib/rancher/rke2/bin:$PATH"}  - {path: "/etc/profile", line: "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml"}  - {path: "/root/.bashrc", line: "source <(kubectl completion bash)"}  - {path: "/root/.bashrc", line: "alias k=kubectl"}` | non |

## Description des playbooks
### 00_LoadBalancer.yaml
#### Description:
*Installe et configure les frontends et backends HAPROXY pour rendre le cluster kubernetes hautement disponible. Il ecoutes les ports 6443 (apiserver kubernets) et 9345(agent RKE2)*
#### Varibles utilisées:
|Variable|emplacement|
|--------|-----------|
|RKE2_PORT|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|master_init|[infrastructure.yaml](ansible/group_vars/all/)|
|additionnal_master|[infrastructure.yaml](ansible/group_vars/all/)|
#### templates/files utilisés:
### 01_PrepMaster.yaml
#### Description:
*Mets en place les prérequis systemes pour le bon fonctionnement de RKE2 et Kubernetes*
#### Varibles utilisées:
|Variable|emplacement|
|--------|-----------|
|lb|[infrastructure.yaml](ansible/group_vars/all/)|
|kubernetes_fqdn|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|additionnal_master|[infrastructure.yaml](ansible/group_vars/all/)|
#### templates/files utilisés:
- [protect_kernel_panic.conf](ansible/templates/protect_kernel_panic.conf)
- [crictl_config.yaml](ansible/templates/crictl_config.yaml)
### 02_InitCluster.yaml
#### Description:
*Ce playbook réalise l'initialisation du premier master kubernetes (groupe inventaire=init_master) et ajoute  les master supplémentaire (groupe iventaire=additionnal_master)*
#### Varibles utilisées:
|Variable|emplacement|
|--------|-----------|
|rancher_config_path|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|url_script_rke2|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
#### templates/files utilisés:
- [rke2_config.yaml](ansible/templates/rke2_config.yaml)
- [rke2_config_add_master.yaml](ansible/templates/rke2_config_add_master.yaml)
- [crictl_config.yaml](ansible/templates/crictl_config.yaml)
### 03_AddWorker.yaml
#### Description:
*Ajoute des workers au cluster précédemment créé*
#### Varibles utilisées:
|Variable|emplacement|
|--------|-----------|
|lb|[infrastructure.yaml](ansible/group_vars/all/)|
|kubernetes_fqdn|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|rancher_config_path|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
#### templates/files utilisés:
- [protect_kernel_panic.conf](ansible/templates/protect_kernel_panic.conf)
- [crictl_config.yaml](ansible/templates/crictl_config.yaml)
- [rke2_config_worker.yaml](ansible/templates/rke2_config_worker.yaml)
### 04_SetupK8sEnv.yaml
#### Description:
*Dans un premier temps le playbook configure l'environnement systeme sur les masters pour administrer le cluster Kubernetes. Dans une deuxième étape le playbook ajoute un label kubernetes sur les workers*
#### Varibles utilisées:
|Variable|emplacement|
|--------|-----------|
|system_environnement|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|rke_data_dir|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|rancher_config_path|[general_purpose.yaml](ansible/group_vars/all/general_purpose.yaml)|
|worker|[infrastructure.yaml](ansible/group_vars/all/)|

#### templates/files utilisés:

## Déploiement du Cluster
*La commande ci-dessous est definie par le fichier [makefile](makefile) du projet*
```
make setup-cluster
```
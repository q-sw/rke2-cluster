build-infra: init-infra apply-infra
setup-cluster: install-lb post-install-master build-master build-worker setup-k8s-env
build-cluster: build-infra wait-infra  setup-cluster

terrform-lint:
	cd terraform && terrafom fmt
ansible-lint:
	cd ansible && ansible-lint

init-infra:
	cd terraform && terraform init
apply-infra:
	cd terraform && terraform apply --auto-approve
destroy-infra:
	cd terraform && terraform destroy --auto-approve
install-lb:
	cd ansible && ansible-playbook -i inventory.yaml 00_LoadBalancer.yaml
post-install-master:
	cd ansible && ansible-playbook -i inventory.yaml 01_PrepMaster.yaml
build-master:
	cd ansible && ansible-playbook -i inventory.yaml 02_InitCluster.yaml
build-worker:
	cd ansible && ansible-playbook -i inventory.yaml 03_AddWorker.yaml
setup-k8s-env:
	cd ansible && ansible-playbook -i inventory.yaml 04_SetupK8sEnv.yaml
wait-infra:
	sleep 60

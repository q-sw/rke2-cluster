all:
  hosts:
%{ for info in loadbalancer ~}
    ${info.tags.Name}:
      ansible_host: ${info.public_ip}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: aws_perso.pem
%{ endfor ~}
%{ for info in master ~}
    ${info.tags.Name}:
      ansible_host: ${info.public_ip}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: aws_perso.pem
%{ endfor ~}
%{ for info in worker ~}
    ${info.tags.Name}:
      ansible_host: ${info.public_ip}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: aws_perso.pem
%{ endfor ~}
master:
  hosts:
%{ for info in master ~}
    ${info.tags.Name}:
%{ endfor ~}
master_init:
  hosts:
    ${master.0.tags.Name}:
additionnal_master:
  hosts:
%{ for info in additionnal_master ~}
    ${info.tags.Name}:
%{ endfor ~}
worker:
  hosts:
%{ for info in worker ~}
    ${info.tags.Name}:
%{ endfor ~}
lb:
  hosts:
%{ for info in loadbalancer ~}
    ${info.tags.Name}:
%{ endfor ~}
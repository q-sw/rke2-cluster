master_init:
  - name: "${master.0.tags.Name}"
    ip: "${master.0.private_ip}"
additionnal_master:
%{ for info in additionnal_master ~}
  - name: "${info.tags.Name}"
    ip: "${info.private_ip}"
%{ endfor ~}
worker:
%{ for info in worker ~}
  - name: "${info.tags.Name}"
    ip: "${info.private_ip}"
%{ endfor ~}
lb:
%{ for info in loadbalancer ~}
  - name: "${info.tags.Name}"
    ip: "${info.private_ip}"
%{ endfor ~}
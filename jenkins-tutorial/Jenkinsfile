pipeline {
  agent any

  stages {
    stage('Packer - Build RHEL9 Image on vSphere') {
      steps {
        sh """
        #!/bin/bash
        cd /root/packer/builds/rhel9
        packer init .
        packer build -var-file=rhel9.auto.pkrvars.hcl -var-file=vsphere.pkrvars.hcl -var-file=common.pkrvars.hcl .
        """
      }
    }
  }
}

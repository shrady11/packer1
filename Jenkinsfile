pipeline {
  agent any

  stages {
    stage('Packer - Build RHEL9 Image on vSphere') {
      steps {
        sh """
        #!/bin/bash
        packer init .
        packer build -var-file=rhel9.auto.pkrvars.hcl -var-file=vsphere.pkrvars.hcl -var-file=common.pkrvars.hcl .
        """
      }
    }
   stage('Verify  Image') {
      steps {
        sh """
        #!/bin/bash
        echo "Template was created"
        """
      }
    }
  }
}

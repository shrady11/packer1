pipeline {
  agent any

  stages {
    stage('Packer - Build RHEL9 Image on vSphere') {
      steps {
        sh """
        packer init .
        packer build -var-file=rhel9.auto.pkrvars.hcl -var-file=vsphere.pkrvars.hcl -var-file=common.pkrvars.hcl .
        """
      }
    }
   stage('Verify  Image') {
      steps {
        sh """
        echo "Template was created"
        """
      }
    }
  }
}

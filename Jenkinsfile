node{
  commit = "";
  prod = "";
  stage('Checkout') {
    git url: 'https://github.com/nclouds/demo-crystal.git', branch: 'master'
    commit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
  }
  stage('Build') {
      container('docker') {
          script {
            sh 'docker --version'
            //sh 'helm version'
            sh "docker build -t nclouds-eks-crystal --network=host ."
            sh "\$(aws ecr get-login --no-include-email --region us-east-1)"
            sh "docker tag nclouds-eks-crystal 695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:${commit}"
            sh "docker tag nclouds-eks-crystal 695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:latest"
            sh "docker push 695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:${commit}"
            sh "docker push 695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:latest"
          }
      }
  }
  stage('Test') {
    echo "testing ..."
  }
  stage('Vulnerability Scanner') {
    echo "testing ..."
  }
  stage('Dev Deployment') {
    echo "Deployment ..."
    container('docker') {
        script {
            sh "aws eks update-kubeconfig --name nclouds-eks-dev --region us-east-1"
            sh "kubectl set image deployment/ecsdemo-crystal ecsdemo-crystal=695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:${commit} --record"
        }
    }
  }
}

node{
  stage('Check for deployment'){
  def userInput = true
  def IsTimeout = false
    script{
      try {
        timeout(time: 60, unit: 'SECONDS') {
        userInput = input(
          id: 'userInput', message: 'Deploy to Prod?', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: true, description: 'Deploy to Production?', name: 'PROD']
          ]);
        }
      } 
      catch(err) { // timeout reached or input false
        userInput = false
      }
      if (userInput == true) {
        stage('Prod Deployment') {
            container('docker') {
                script {
                    sh "echo deploying to prod..."
                    sh "aws eks update-kubeconfig --name nclouds-eks-prod --region us-east-1"
                    sh "kubectl set image deployment/ecsdemo-crystal ecsdemo-crystal=695292474035.dkr.ecr.us-east-1.amazonaws.com/nclouds-eks-crystal:${commit} --record"
                }
          }
        }
      }
    }
  }
}
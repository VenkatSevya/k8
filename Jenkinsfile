pipeline {
  agent any

  tools {
    // Install the Maven version configured as "M2_HOME" and add it to the path.
    maven "M2_HOME"
  }
  environment{
	AWS_ACCOUNT_ID = "962826464166" 
	AWS_DEFAULT_REGION = "us-east-1"
	IMAGE_REPO_NAME = "webapp"
	IMAGE_TAG = "${BUILD_NUMBER}"
	REPOSIT_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazon.aws.com/${IMAGE_REPO_NAME}"
  }

  stages {
    
  stage('GIT Clone') {
            steps {
                checkout([
                 $class: 'GitSCM',
                 branches: [[name: 'main']],
                 userRemoteConfigs: [[
                    url:  "https://github.com/PavanDeepakPagadala/PavanDevOpsProject.git",
                    credentialsId: '',
                 ]]
                ])
            }
        }
	stage('Build') {
	     steps {
	         sh "mvn clean  package"
	     }
	}
	stage('Test') {
	    steps {
	        sh "mvn clean verify -DskipITs=true',junit '**/target/surefire-reports/TEST-*.xml'archive 'target/*.jar"

	    }
	}
	
	
  post {
	always {
		
		emailext body: '$DEFAULT_CONTENT', //configure message in body in jenkins
		 subject: 'Jenkins Build Status', 
		 to: 'pavandeepakpagadala@gmail.com'
		

	}
  }

}

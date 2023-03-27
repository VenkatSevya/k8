pipeline {
  agent any

  tools {
    // Install the Maven version configured as "M2_HOME" and add it to the path.
    maven "M2_HOME"
	
  }
  environment{
	
	DOCKERHUB_CREDENTIALS= credentials('dockerhubcreds')  
	
  }

  stages {
    
  stage('GIT Clone') {
            steps {
                checkout([
                 $class: 'GitSCM',
                 branches: [[name: 'main']],
                 userRemoteConfigs: [[
                    url:  "https://github.com/VenkatSevya/Devops.git",
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

	//stage('SonarQube Analysis') {
            steps {
                // Define the SonarScanner tool with version 4.8.0
                tool name: 'SonarScanner-4.8.0', type: 'hudson.plugins.sonar.SonarRunnerInstallation'

                // Set the environment variables for the SonarQube server configuration
                withSonarQubeEnv('sonar') {
                    // Run the SonarScanner command to analyze the code
                    sh 'mvn sonar:sonar'
                }
            }
        }

	
	//TO upload war file into S3 bucket using IAM role and S3Profile configuration in jenkins.
	 stage('Upload To S3 Bucket ') {
      steps {
        s3Upload consoleLogLevel: 'INFO',
	dontSetBuildResultOnFailure: false,
	dontWaitForConcurrentBuildCompletion: false,
	entries: [
				[
					bucket: 'myaawsbucket', 
					excludedFile: '/webapp/target',
					flatten: false,
					gzipFiles: false,
					keepForever: false,
					managedArtifacts: false,
					noUploadOnFailure: false,
					selectedRegion: 'us-east-1',
					showDirectlyInBrowser: false,
					sourceFile: '**/webapp/target/*.war',
					storageClass: 'STANDARD',
					uploadFromSlave: false,
					useServerSideEncryption: false
				]
			], 
	pluginFailureResultConstraint: 'FAILURE', 
	profileName: 'S3Profile', //Give same name as configured in jenkins
	userMetadata: []

      }
    }
	//To remove old war files
	stage('Clean'){
		steps{
			sh "sudo rm -rf /opt/tomcat/webapps/webapp.war" 
		}
	}
	//To download war files from s3 bucket to tomcat 
	stage('Deploy to Tomcat from S3') {
	    steps {
			
				sh " sudo aws s3 cp s3://myaawsbucket/webapp/target/webapp.war /opt/tomcat/webapps/" 
				sh "sudo sh /opt/tomcat/bin/shutdown.sh"
				sh "sudo sh /opt/tomcat/bin/startup.sh"
	    }
	}

	stage('Docker Build') {

			steps {
				echo ' Build number ${BUILD_NUMBER}'
				sh 'docker build --no-cache  -t webapp:${BUILD_NUMBER} .'
				sh 'docker tag webapp:${BUILD_NUMBER} venkata141/webapp:${BUILD_NUMBER}  '
				
				
			}
		}

	stage('Login to Docker Hub') { 

    		steps{                       	
					sh 'echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'                		
					echo 'Login Completed'      
    }           
}   	
		stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: "dockerhubcreds", url: "https://index.docker.io/v1/"]) {
                    sh "docker push venkata141/webapp:${BUILD_NUMBER}"
                }
            }
        }


		stage('Deploy to K8s'){
            steps{
                script{
                    kubernetesDeploy (configs: 'deploymentservice.yaml',kubeconfigId: 'kubeconfig')
                }
            }
        }    

  }

  post {
	always {
		
		emailext body: '$DEFAULT_CONTENT', //configure message in body in jenkins
		 subject: 'Jenkins Build Status',
		 to: 'gopiperumalla14@gmail.com'

		 sh 'docker logout' 
		

	}
  }

}

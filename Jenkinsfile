pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'
        IMAGE_NAME = 'sirimakg/jenkins-test'
        IMAGE_TAG = 'v2'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'Develop', url: 'https://github.com/sirimaSamin/myApp.git'
            }
        }

        stage('Build Docker Image') {
           steps {
              script {
                  sh """
                  docker build --no-cache -t $IMAGE_NAME:$IMAGE_TAG .
                  """
        }
    }
}

        stage('Security scan')
            steps{
                // สแกนหาcritical
                def trivyExitCode = sh(
                    script : "docker run --rm -v /var/run/dovker.sock:/var/run/docker.sock aquasec/trivy image --exit-code 1
                    --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                    returnStatus: true
                )

                // if critical found  stop pipeline
                if (trivyExitCode == 1 ){
                    error("Critical vulnerability found, process stopped")
                }


                //สแกนและเซฟรายงานเป็นHTML
                sh"""
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                -v ${WORKSPACE}:/report aquasec/trivy image --severity CRITICAL \
                --format template --template "@contrib/html.tpl" \ -o /report/trivy-report.html ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }






        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        def image = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")
                        image.push()
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh """
                    docker-compose down
                    docker-compose up -d

                    """
                }
            }
        }
    }
}

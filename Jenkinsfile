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
        stage('Trivy Scan'){
            steps{
                sh "Trivy --severity CRITICAL --no-progress image --format table -o trivy-scan-report.txt  $IMAGE_NAME:$IMAGE_TAG "
            }
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

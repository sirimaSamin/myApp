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
        stage('Security Scan Trivy') {
           steps {
              script {
            // สแกนและตรวจสอบ Critical Vulnerabilities
                  def trivyExitCode = sh(
                      script: "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image \
                       --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                      returnStatus: true
            )

            // ถ้าเจอ Critical ให้หยุด Pipeline
                  if (trivyExitCode == 1) {
                      error("พบ CRITICAL! หยุดกระบวนการ")
            }
            
            // เซฟรายงานเป็น HTML (จะทำงานเสมอไม่ว่าจะพบ vulnerability หรือไม่)
                  sh """
                     docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \\
                     -v ${WORKSPACE}:/report aquasec/trivy image --severity CRITICAL \\ 
                     --format template --template \"@/contrib/html.tpl\" -o /report/trivy-scan-report.txt ${IMAGE_NAME}:${IMAGE_TAG}
                  """
        }
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

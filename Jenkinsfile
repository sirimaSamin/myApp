pipeline {
    agent any
    

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'
        IMAGE_NAME = 'sirimakg/jenkins-test'
        IMAGE_TAG = 'v2'
    }

 // ✅ ตั้งค่าลบ build เก่าให้อัตโนมัติ
    options {
        buildDiscarder(logRotator(
            numToKeepStr: '5',
            artifactNumToKeepStr: '5',
            daysToKeepStr: '3'
        ))
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
            // เซฟรายงานเป็น HTML (จะทำงานเสมอไม่ว่าจะพบ vulnerability หรือไม่)
                  sh """
                     docker run --rm \\
                     -v /var/run/docker.sock:/var/run/docker.sock \\
                     -v ${WORKSPACE}:/report \\
                     -v ${WORKSPACE}/html.tpl:/html.tpl \\
                     aquasec/trivy image \\
                     --no-progress \\
                     --severity CRITICAL \\
                     --format template \\
                     --template "/html.tpl" \\
                     -o /report/trivy-scan-report.html \\
                     ${IMAGE_NAME}:${IMAGE_TAG}
                  """
              post {
                    always {
                       archiveArtifacts artifacts: 'trivy-scan-report.json', fingerprint: false
                    }
                  }
              }

                  // สแกนและตรวจสอบ Critical Vulnerabilities
                  def trivyExitCode = sh(
                      script: "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image \
                       --no-progress --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                      returnStatus: true
                     ) 
                  // ถ้าเจอ Critical ให้หยุด Pipeline
                  if (trivyExitCode == 1) {
                      error("พบ CRITICAL! หยุดกระบวนการ")
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


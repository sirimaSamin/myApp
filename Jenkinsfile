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
                       --no-progress --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",

                      returnStatus: true
            )           
            
            // เซฟรายงานเป็น HTML (จะทำงานเสมอไม่ว่าจะพบ vulnerability หรือไม่)
                  sh """
                     docker run --rm \\
                     -v /var/run/docker.sock:/var/run/docker.sock \\
                    -v /reports:/report \\
                     aquasec/trivy image \\
                     --no-progress \\
                     --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}\\ 
                     --format template \\
                     --template \"@/contrib/html.tpl\" \\
                     -o /report/trivy-scan-report.html \\ 
                     
                  """
                  // ถ้าเจอ Critical ให้หยุด Pipeline
                  if (trivyExitCode == 1) {
                      error("พบ CRITICAL! หยุดกระบวนการ")
            }
        }
    }

           post {
             always {
            // เนื่องจากไฟล์อยู่ภายนอก Jenkins workspace
            // อาจต้องใช้วิธีอื่นในการ archive
                 sh """
                    # คัดลอกไฟล์จาก /reports มาไว้ใน workspace เพื่อ archive
                    cp /reports/trivy-scan-report.html ./
                 """
                 archiveArtifacts artifacts: 'trivy-scan-report.html', fingerprint: false

                  // เพิ่ม publishHTML เพื่อดู report ใน Jenkins UI
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '',
                        reportFiles: 'trivy-scan-report.html',
                        reportName: 'Trivy Security Report'
                    ])
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

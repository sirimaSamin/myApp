pipeline {
    agent any
    

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'
        IMAGE_NAME = 'sirimakg/jenkins-test'
        IMAGE_TAG = 'v2'
        // กำหนด URL ของ Trivy HTML Template เพื่อให้อ่านง่าย
        TRIVY_TPL_URL = 'https://raw.githubusercontent.com/aquasec/trivy/main/contrib/html.tpl'
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
                    // สแกนและสร้างรายงาน HTML
                    sh """
                    docker run --rm \\
                    -v /var/run/docker.sock:/var/run/docker.sock --entrypoint sh -c "wget -qO html.tpl https://raw.githubusercontent.com/aquasec/trivy/main/contrib/html.tpl && trivy image image --no-progress --severity CRITICAL --format template --template @html.tpl ${IMAGE_NAME}:${IMAGE_TAG}" > scan-report.html
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'scan-report.html', fingerprint: false
                }
            }
        }

        stage('Check Critical') {
            steps {
                script {
                    // สแกนและตรวจสอบ Critical Vulnerabilities
                    def trivyExitCode = sh(
                        script: "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --no-progress --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                        returnStatus: true
                    ) 
                    
                    // ถ้าเจอ Critical ให้หยุด Pipeline
                    if (trivyExitCode == 1) {
                        error("พบ CRITICAL! หยุดกระบวนการ")

                     // แสดงสรุปผลการสแกน
                    echo " สรุปผลการ Security Scan"
                    if (fileExists('scan-report.html')) {
                        echo " สร้างรายงานการสแกนเรียบร้อยแล้ว"
                    } 
                    else {
                        echo " ไม่พบไฟล์รายงาน"                              
        
                    }
                }
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

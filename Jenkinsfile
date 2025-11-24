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
    options { //ฟังก์ชันที่บอกให้ Jenkins ลบ Build เก่าๆ ที่ไม่จำเป็นออกไป
        buildDiscarder(logRotator(
            numToKeepStr: '3',           //จำนวน Build ที่จะเก็บไว้
            artifactNumToKeepStr: '2',   //จำนวน Artifact ที่จะเก็บไว้ เช่น html report
            daysToKeepStr: '3'           //จำนวนวันที่เก็บไว้
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
                    // -v trivy container เข้าไปใน docker.sock เพื่อสแกน image 
                    sh """
                    docker run --rm \\
                    -v /var/run/docker.sock:/var/run/docker.sock \\    
                    --entrypoint sh aquasec/trivy:latest \\
                    -c "wget -qO html.tpl ${TRIVY_TPL_URL} && trivy image --no-progress --severity CRITICAL --format template --template @html.tpl ${IMAGE_NAME}:${IMAGE_TAG}" > scan-report.html
                    """
                    //-c(comman) "wget(ดาวโหลดไฟล์) (แบบไม่แสดงผล)-qO html.tpl(เก็บในชื่อนี้) ${TRIVY_TPL_URL}(ที่ลิ้งนี้) && trivy image(แล้วสแกน image)
                    //output ออกมาชื่อนี้ > scan-report.html เก็บที่workspace
                }
            }
            post {
                always {// Archive ไฟล์ไว้ดูเสมอ ไม่ว่าจะผ่านหรือพัง
                    archiveArtifacts artifacts: 'scan-report.html', fingerprint: false
                }
            }
        }

        stage('Check Critical') {
            steps {
                script {
                    // สแกนและตรวจสอบ Critical Vulnerabilities
                    //เก็บ Exit Code ในตัวแปร trivyExitCode
                    def trivyExitCode = sh(
                        script: "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --no-progress --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}",
                        returnStatus: true
                    ) 

                     // แสดงสรุปผลการสแกน
                    echo " สรุปผลการ Security Scan"
                    if (fileExists('scan-report.html')) {
                        echo " สร้างรายงานการสแกนเรียบร้อยแล้ว"
                    } 
                    else {
                        echo " ไม่พบไฟล์รายงาน"                              
        
                    }
                    // ถ้าเจอ Critical ให้หยุด Pipeline
                    if (trivyExitCode == 1) {
                        error("พบ CRITICAL! หยุดกระบวนการ")
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

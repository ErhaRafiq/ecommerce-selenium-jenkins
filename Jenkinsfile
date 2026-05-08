pipeline {
    agent any

    environment {
        APP_IMAGE  = 'ecommerce-app'
        TEST_IMAGE = 'ecommerce-test-app'

        // Replace this with your AWS EC2 public IP
        APP_URL    = 'http://YOUR_EC2_PUBLIC_IP:5000'
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm

                script {
                    env.COMMITTER_EMAIL = sh(
                        script: "git log -1 --format='%ae'",
                        returnStdout: true
                    ).trim()

                    echo "Push made by: ${env.COMMITTER_EMAIL}"
                }
            }
        }

        stage('Clean Old Docker Data') {
            steps {
                sh '''
                    echo "Cleaning old containers and Docker cache..."

                    docker rm -f ecommerce-app 2>/dev/null || true
                    docker container prune -f || true
                    docker builder prune -af || true

                    echo "Disk status after cleanup:"
                    df -h || true
                    docker system df || true
                '''
            }
        }

        stage('Build Application Image') {
            steps {
                echo "Building Ecommerce Flask application image..."
                sh "docker build -t ${APP_IMAGE} ."
            }
        }

        stage('Deploy Application') {
            steps {
                echo "Deploying Ecommerce Flask application..."

                sh """
                    docker rm -f ${APP_IMAGE} 2>/dev/null || true

                    docker run -d \
                        --name ${APP_IMAGE} \
                        --restart unless-stopped \
                        -p 5000:5000 \
                        ${APP_IMAGE}
                """

                sh """
                    echo 'Waiting for Ecommerce app to start...'

                    for i in \$(seq 1 12); do
                        if curl -sf http://localhost:5000 > /dev/null 2>&1; then
                            echo 'Ecommerce app is running successfully!'
                            break
                        fi

                        echo "Attempt \$i/12 — app not ready yet, waiting 5 seconds..."
                        sleep 5
                    done
                """
            }
        }

        stage('Build Selenium Test Image') {
            steps {
                echo "Building Selenium Chrome test image..."
                sh "docker build -t ${TEST_IMAGE} -f Dockerfile.test ."
            }
        }

        stage('Run Selenium Tests') {
            steps {
                echo "Running 15 Selenium test cases in Docker container..."

                sh """
                    docker run --rm \
                        --network host \
                        --shm-size=1g \
                        -e APP_URL=http://127.0.0.1:5000 \
                        ${TEST_IMAGE}
                """
            }
        }
    }

    post {
        always {
            script {
                def status    = currentBuild.result ?: 'SUCCESS'
                def emoji     = status == 'SUCCESS' ? '✅' : '❌'
                def committer = env.COMMITTER_EMAIL ?: 'unknown'

                /*
                 If GitHub hides the committer email using noreply,
                 send test result to instructor email.
                */
                def recipient = committer.contains('noreply.github.com')
                    ? 'qasimalik@gmail.com'
                    : committer

                /*
                 Also keep instructor in CC because assignment requires
                 test results to be emailed to the collaborator/instructor.
                */
                def body = """
                    <html>
                    <body>
                        <h2>ShopWave Ecommerce App — Jenkins Test Results</h2>

                        <p>
                            This Jenkins pipeline automatically builds, deploys,
                            and tests the Flask-based Ecommerce ShopWave web application.
                        </p>

                        <table border="1" cellpadding="8" cellspacing="0">
                            <tr>
                                <td><b>Project Name</b></td>
                                <td>ShopWave Ecommerce Selenium Jenkins Project</td>
                            </tr>

                            <tr>
                                <td><b>Build Status</b></td>
                                <td>${status}</td>
                            </tr>

                            <tr>
                                <td><b>Build Number</b></td>
                                <td>${env.BUILD_NUMBER}</td>
                            </tr>

                            <tr>
                                <td><b>Triggered By</b></td>
                                <td>${committer}</td>
                            </tr>

                            <tr>
                                <td><b>Application URL</b></td>
                                <td><a href="${APP_URL}">${APP_URL}</a></td>
                            </tr>

                            <tr>
                                <td><b>Test Type</b></td>
                                <td>Headless Chrome Selenium Tests</td>
                            </tr>

                            <tr>
                                <td><b>Total Test Cases</b></td>
                                <td>15 Selenium Test Cases</td>
                            </tr>

                            <tr>
                                <td><b>Docker Images</b></td>
                                <td>
                                    Application Image: ${APP_IMAGE}<br>
                                    Test Image: ${TEST_IMAGE}
                                </td>
                            </tr>
                        </table>

                        <br>

                        <p>
                            <a href="${env.BUILD_URL}">
                                Click here to view full Jenkins build console output
                            </a>
                        </p>
                    </body>
                    </html>
                """

                try {
                   emailext(
    to: "${recipient},qasimalik@gmail.com",
    subject: "${emoji} ShopWave Ecommerce Tests ${status} — Build #${env.BUILD_NUMBER}",
    body: body,
    mimeType: 'text/html'
)
                } catch (Exception e) {
                    echo "Email sending failed, but pipeline execution completed."
                    echo "Email error: ${e.getMessage()}"
                }
            }
        }

        success {
            echo "Pipeline completed successfully. Ecommerce app deployed and Selenium tests passed."
        }

        failure {
            echo "Pipeline failed. Check Docker, Selenium test, or Jenkins email configuration."
        }
    }
}

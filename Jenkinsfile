pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'ecommerce-test-app'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository from GitHub
                checkout scm
            }
        }

        stage('Build Test Image') {
            steps {
                script {
                    // Build the Docker image from Dockerfile.test
                    echo "Building Docker image for testing..."
                    sh "docker build -t ${DOCKER_IMAGE_NAME} -f Dockerfile.test ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Run the container which will execute run_tests.sh
                    echo "Running tests in Docker container..."
                    sh "docker run --rm ${DOCKER_IMAGE_NAME}"
                }
            }
        }
    }

    post {
        always {
            script {
                // Determine build status
                def currentStatus = currentBuild.result ?: 'SUCCESS'
                
                // Email configuration
                def toEmail = 'qasimalik@gmail.com'
                def subject = "Jenkins Pipeline Execution: ${currentBuild.fullDisplayName} - ${currentStatus}"
                def body = """
                <p>Hello,</p>
                <p>The Jenkins pipeline for the eCommerce application has completed.</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Build Status:</strong> ${currentStatus}</p>
                <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                <br>
                <p>Regards,<br>Jenkins Automation Pipeline</p>
                """

                echo "Sending email notification to ${toEmail}..."
                
                emailext(
                    to: toEmail,
                    subject: subject,
                    body: body,
                    mimeType: 'text/html'
                )
            }
        }
    }
}

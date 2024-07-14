// https://medium.com/@torkashvand/complete-setup-of-a-cicd-pipeline-using-jenkins-docker-and-django-54cfa5dd19f4
// https://mdyzma.github.io/2017/10/14/python-app-and-jenkins/

pipeline {
    agent {
        docker {
            image 'python:3.10'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    // environment {
    //     // DOCKER_REGISTRY = 'docker-registry'
    //     // DOCKER_CREDENTIALS_ID = 'docker-hub-token'
    // }
    stages {
        stage('Build container') {
            steps {
                echo 'docker build'
                sh '''
                docker build -t library:latest . --target prod
                 '''
            }
        }
        stage('Run tests') {
            steps {
                echo 'docker run'
                sh '''
                docker run library:latest python manage.py test
                '''
            }
        }
        stage('Login to Docker Registry') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub-token',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]
                ) {
                        sh 'echo $DOCKER_PASSWORD | docker login \
                        -u $DOCKER_USERNAME --password-stdin'
                    }
                }
            }
        }

        stage('Push container') {
            steps {
                echo 'docker push'
                sh '''
                docker tag library:latest mikeh74/library:latest
                docker push mikeh74/library:latest
                '''
            }
        }

        stage('Logout from Docker Registry') {
            steps {
                script {
                    sh 'docker logout $DOCKER_REGISTRY'
                }
            }
        }
    }

    post {
        always {
            echo 'Clean up'
        }
        success {
            echo 'Code to run on success - this could be deployment or notifications'
        }
        failure {
            echo 'Send notifications'
        }
    }
}

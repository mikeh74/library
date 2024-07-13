// https://medium.com/@torkashvand/complete-setup-of-a-cicd-pipeline-using-jenkins-docker-and-django-54cfa5dd19f4
// https://mdyzma.github.io/2017/10/14/python-app-and-jenkins/

pipeline {
    // agent {
    //     dockerfile { filename 'Dockerfile.build' }
    // }
    agent any
    environment {
        DOCKER_REGISTRY = 'https://docker-registry'
        DOCKER_CREDENTIALS_ID = 'docker-registry-credentials'
    }
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
                            credentialsId: 'docker-registry-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]
                ) {
                        sh 'echo $DOCKER_PASSWORD | docker login \
                        $DOCKER_REGISTRY -u $DOCKER_USERNAME --password-stdin'
                    }
                }
            }
        }

        stage('Push container') {
            steps {
                echo 'docker push'
                sh '''
                docker tag library:latest localhost:5050/library:latest
                docker push localhost:5050/library:latest
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

        // stage('Code Coverage') {
        //     steps {
        //         echo 'Run and output code coverage report'
        //         sh '''
        //         echo "Code coverage"
        //         python -m coverage run --source='.' manage.py test
        //         coverage xml -o reports/coverage.xml
        //         '''
        //     }
        //     post {
        //         always {
        //             step([$class: 'CoberturaPublisher',
        //         autoUpdateHealth: false,
        //         autoUpdateStability: false,
        //         coberturaReportFile: 'reports/coverage.xml',
        //         failUnhealthy: false,
        //         failUnstable: false,
        //         maxNumberOfBuilds: 0,
        //         onlyStable: false,
        //         sourceEncoding: 'ASCII',
        //         zoomCoverageChart: false
        //         ])
        //         }
        //     }
        // }
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

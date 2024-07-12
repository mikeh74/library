// https://medium.com/@torkashvand/complete-setup-of-a-cicd-pipeline-using-jenkins-docker-and-django-54cfa5dd19f4
// https://mdyzma.github.io/2017/10/14/python-app-and-jenkins/

pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // Retain history on the last 10 builds
        timeout(time: 10, unit: 'MINUTES') // Set a timeout on the total execution time of the job
    }
    agent {
        // Run this job within a Docker container built using Dockerfile.build
        // contained within your projects repository. This image should include
        // the core runtimes and dependencies required to run the job,
        // for example Python 3.x and NPM.
        dockerfile { filename 'Dockerfile.build' }
    }
    stages {
        stage('Copy Reports') {
            steps {
                echo 'Copying eslint report'
                sh '''
                cat /code/build/reports/eslint.xml > eslint.xml
                cat /code/build/reports/stylelint.xml > stylelint.xml
                cat /code/build/reports/pylint.log > pylint.log
                '''
            }
        }
        stage('Test') {
            steps {
                sh 'python manage.py test'
            }
        }
        stage('Code Coverage') {
            steps {
                echo 'Run and output code coverage report'
                sh '''
                echo "Code coverage"
                python -m coverage run --source='.' manage.py test
                coverage xml -o reports/coverage.xml
                '''
            }
            post {
                always {
                    step([$class: 'CoberturaPublisher',
                autoUpdateHealth: false,
                autoUpdateStability: false,
                coberturaReportFile: 'reports/coverage.xml',
                failUnhealthy: false,
                failUnstable: false,
                maxNumberOfBuilds: 0,
                onlyStable: false,
                sourceEncoding: 'ASCII',
                zoomCoverageChart: false
                ])
                }
            }
        }
    }

    post {
        always {
            echo 'Clean up'
        }
        success {
            echo 'Code to run on success'
            recordIssues(
                tool: checkStyle(pattern: '**/*.xml'),
                enabledForFailure: true,
            )
            // https://stackoverflow.com/questions/41875412/use-pylint-on-jenkins-with-warnings-plugin-and-pipeline
            recordIssues(
                tool: pyLint(pattern: '**/pylint.log'),
                enabledForFailure: true,
                aggregatingResults: true,
            )
        }
        failure {
            echo 'Send notifications'
        }
    }
}

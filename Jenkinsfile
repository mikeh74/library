// https://medium.com/@torkashvand/complete-setup-of-a-cicd-pipeline-using-jenkins-docker-and-django-54cfa5dd19f4
// https://mdyzma.github.io/2017/10/14/python-app-and-jenkins/

pipeline {
    // agent {
    //     dockerfile { filename 'Dockerfile.build' }
    // }
    agent any
    stages {
        stage('Make image') {
            steps {
                echo 'Copying eslint report'
                sh '''
                docker build -t library:latest . --target prod
                 '''
            }
        }
        // stage('Test') {
        //     steps {
        //         sh 'python manage.py test'
        //     }
        // }
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
            echo 'Code to run on success'
            // recordIssues(
            //     tool: checkStyle(pattern: '**/*.xml'),
            //     enabledForFailure: true,
            // )
            // // https://stackoverflow.com/questions/41875412/use-pylint-on-jenkins-with-warnings-plugin-and-pipeline
            // recordIssues(
            //     tool: pyLint(pattern: '**/pylint.log'),
            //     enabledForFailure: true,
            //     aggregatingResults: true,
            // )
        }
        failure {
            echo 'Send notifications'
        }
    }
}

pipeline {
    agent { 
        node {
            label 'docker'
            }
      }
    triggers {
        pollSCM '* * * * *'
    }
    stages {
        stage('Build') {
            steps {
                echo "Building.."
                sh '''
                cd myapp
                pip install -r requirements.txt
                '''
            }
        }
        stage('Test') {
            steps {
                echo "Testing.."
                sh '''
                cd myapp
                python3 hello.py
                python3 hello.py --name=Abdullah
                '''
            }
        }
        stage('Deliver') {
            steps {
                echo 'Delivering..'
                sh '''
                echo "doing delivery"
                '''
            }
        }
    }
}
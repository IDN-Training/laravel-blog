pipeline {
    agent { label 'devops-01-user' }

    stages {
        stage('Pull SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/username/laravel-blog.git'
            }
        }
        
        stage('Scanning') {
            steps {
                sh'''
                sonar-scanner \
                -Dsonar.projectKey=laravel-blog \
                -Dsonar.sources=. \
                -Dsonar.host.url=http://10.10.10.212:9000 \
                -Dsonar.token=sqp_5ee859014e1cdf2230187e02a0f90d1eb2913843
                '''
            }
        }

        stage('Containerized Apps') {
            steps {
                sh'''
                docker compose build
                '''
            }
        }

        stage('Push to Registry') {
            steps {
                 sh 'docker compose push' 
            }
        }

        stage('Deploy Apps') {
            steps {
                sh'''
                docker compose up -d
                '''
            }
        }   
    }
}
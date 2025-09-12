pipeline {
    agent { label 'devops-01-user' }

    stages {
        stage('Pull SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/username/laravel-blog.git'
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
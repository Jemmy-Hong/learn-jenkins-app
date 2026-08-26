pipeline {
    agent any

    stages {
        /*
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }*/

        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    test -f build/index.html
                    mkdir -p test-results
                    JEST_JUNIT_OUTPUT_DIR=test-results JEST_JUNIT_OUTPUT_NAME=jest-results.xml npm test
                '''
            }
        }

        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install
                    npx serve -s build -l 3000 &
                    npx wait-on http://localhost:3000
                    npx playwright test --reporter=html --reporter=junit:test-results/playwright-results.xml
                '''
            }
        }

    }

    post {
        always {
            junit 'test-results/*.xml'
        }
    }
}
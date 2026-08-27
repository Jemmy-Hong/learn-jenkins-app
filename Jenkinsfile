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
        }
        */

        stage('Tests') {
            parallel {
                stage('Unit Tests') {
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
                    post {
                        always {
                            script {
                                sh '''
                                    ls -la test-results/ || echo "test-results目录不存在"
                                '''
                                junit(
                                    testResults: 'test-results/*.xml',
                                    allowEmptyResults: true
                                )
                            }
                        }
                    }
                }

                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install
                            mkdir -p test-results
                            npx serve -s build -l 3000 &
                            npx wait-on http://localhost:3000
                            PLAYWRIGHT_JUNIT_OUTPUT_FILE=test-results/playwright-results.xml npx playwright test --reporter html --reporter junit
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: true,
                                alwaysLinkToLastBuild: false,
                                icon: '',
                                keepAll: true,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright HTML Report',
                                reportTitles: '',
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    npx netlify --version
                '''
            }
        }
    }
}
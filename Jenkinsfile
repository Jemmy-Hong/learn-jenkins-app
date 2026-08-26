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
                    mkdir -p test-results
                    npx serve -s build -l 3000 &
                    npx wait-on http://localhost:3000
                    PLAYWRIGHT_JUNIT_OUTPUT_FILE=test-results/playwright-results.xml npx playwright test --reporter html --reporter junit
                '''
            }
        }


    }


    post {
        always {
            script {
                // 打印目录看文件情况
                sh '''
                    ls -la test-results/ || echo "test-results目录不存在"
                '''
                // catchError捕获junit找不到文件的错误，不会让整个流水线失败
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    junit(
                        testResults: 'test-results/*.xml',
                        allowEmptyResults: true
                    )
                }
            }
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}
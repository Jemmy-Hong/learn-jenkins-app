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
                def reportFiles = findFiles(glob: 'test-results/*.xml')
                echo "检测报告列表: ${reportFiles}"
                if (reportFiles.length > 0) {
                    junit(
                        testResults: 'test-results/*.xml',
                        allowEmptyResults: true
                    )
                } else {
                    echo "警告：未找到任何junit测试报告，跳过junit收集，不导致构建失败"
                }
            }
        }
    }
}
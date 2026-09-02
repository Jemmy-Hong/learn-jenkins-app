pipeline {
    agent any

    environment {
        // site_id 也放到jenkins凭证，不要硬编码到代码
        NETLIFY_SITE_ID = '51ca60ee-a888-4f68-b6cb-3f513b046a1b'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_NUMBER"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'Small  change'
                    ls -la
                    node --version
                    npm --version
                    npm config set registry https://registry.npmmirror.com
                    npm ci
                    npm run build
                    ls -la
                '''
            }
            post {
                always {
                    // 关键：把build产物打包缓存，跨stage传递
                    stash includes: 'build/**', name: 'build-artifact'
                }
            }
        }

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
                        // 拿到build产物
                        unstash 'build-artifact'
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
                            image 'my-playwright'
                            reuseNode true
                        }
                    }
                    steps {
                        unstash 'build-artifact'
                        sh '''
                            npm config set registry https://registry.npmmirror.com
                            npm install
                            mkdir -p test-results
                            serve -s build -l 3000 &
                            wait-on http://localhost:3000
                            PLAYWRIGHT_JUNIT_OUTPUT_FILE=test-results/playwright-results.xml npx playwright test --reporter html,junit
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
                                    reportName: 'Playwright Local Report',
                                    reportTitles: '',
                                    useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            steps {
                unstash 'build-artifact'
                sh '''
                    npx netlify --version
                    echo "Deploying to Staging. Site ID: ${NETLIFY_SITE_ID}"
                    npx netlify status
                    # --no-build 禁止netlify重新执行构建，直接上传本地build文件夹
                    npx netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(npx node-jq -r '.deploy_url' deploy-output.json)
                    PLAYWRIGHT_JUNIT_OUTPUT_FILE=test-results/playwright-results.xml npx playwright test --reporter=html,junit
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
                            reportName: 'Playwright Prod E2E Report',
                            reportTitles: '',
                            useWrapperFileDirectly: true
                    ])
                }
            }
        }



        // stage('Approval') {
        //     steps {
        //         timeout(time: 15, unit: 'MINUTES') {
        //             input message: 'Do you wish to deploy to production?', ok: 'Yes, I am sure!'
        //         }
        //     }
        // }

        stage('Deploy prod') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                // 解压拿到build目录！！
                unstash 'build-artifact'
                sh '''
                    npx netlify --version
                    echo "Deploying to Production. Site ID: ${NETLIFY_SITE_ID}"
                    npx netlify status
                    # --no-build 禁止netlify重新执行构建，直接上传本地build文件夹
                    npx netlify deploy --dir=build --prod
                '''
            }
        }

        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://sensational-semifreddo-386a48.netlify.app/'
            }

            steps {
                unstash 'build-artifact'
                sh '''
                    npm install
                    PLAYWRIGHT_JUNIT_OUTPUT_FILE=test-results/playwright-results.xml npx playwright test --reporter=html,junit
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
                            reportName: 'Playwright Prod E2E Report',
                            reportTitles: '',
                            useWrapperFileDirectly: true
                    ])
                }
            }
        }
    }
}

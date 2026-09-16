pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        APP_NAME = 'learnjenkinsapp'
        AWS_DEFAULT_REGION = 'ap-southeast-1'
        AWS_DOCKER_REGISTRY = '650708167380.dkr.ecr.ap-southeast-1.amazonaws.com/eks-devops'
        AWS_ECS_CLUSTER = 'LearnJenkinsApp-Cluster-Prod'
        AWS_ECS_SERVICE_PROD = 'LearnJenkinsApp-TaskDefinition-Prod-service-u652q2ry'
        AWS_ECS_TD_PROD = 'LearnJenkinsApp-TaskDefinition-Prod'
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
                    ls -la
                    node --version
                    npm --version
                    npm config set registry https://registry.npmmirror.com
                    npm ci --registry=https://registry.npmmirror.com
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Build Docker image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                    docker --version
                    docker build -t $AWS_DOCKER_REGISTRY:$APP_NAME-$REACT_APP_VERSION .
                    aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_DOCKER_REGISTRY
                    docker push $AWS_DOCKER_REGISTRY:$APP_NAME-$REACT_APP_VERSION
                '''
                }
            }
        } 


        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root --entrypoint=''"
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        sed -i "s/#APP_VERSION#/$REACT_APP_VERSION/g" aws/task-definition-prod.json
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
                        # 👇 这一行！就是 update-service（切换服务到新版本，触发自动部署）
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
                    '''
                }
            }
        }
    }
}
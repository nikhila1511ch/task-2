pipeline{
    agent any

    environment{
        REPO_URL= "https://github.com/nikhila1511ch/task-2.git"
        REPO_DIR='-'
        BRANCH_NAME='main'
        DOCKER_REPO="nikhila1511/task-2"
        DOCKER_USERNAME='nikhila1511'
        DOCKER_PASSWORD='Nikhila@1511'
        IMAGE_NAME ='ubuntu'
        IMAGE_TAG='latest'
        TARGET_SERVER='13.203.96.238'
        webhook_url='https://13.203.96.238:8080/github-webhook/'
    }
        
    
        stages{
            stage('check'){
                steps{
                    script{
                        try{
                            if(fileExists(REPO_DIR)){
                                sh "ls -la ${REPO_DIR}"
                                echo "file  exists in the $REPO_URL"
                            } else {
                                echo "file doesn't exist in $REPO_URL "
                            }
                            env.CHECK_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.CHECK_STATUS ='FAILED'
                            error("failed to check the $REPO_URL:${e.getMessage()}")
                        }
                    }    
                }
            }
        
            stage('pull'){
                steps{
                    script{
                        try{
                            if(fileExists(REPO_DIR)){
                                echo "pulled latest version of the code from ${REPO_URL} to ${REPO_DIR}"
                                sh "cd ${REPO_DIR} && git pull origin ${BRANCH_NAME}"
                                dir(REPO_DIR) {
                            checkout([$class: 'GitSCM',
                                branches: [[name: BRANCH_NAME]],
                                userRemoteConfigs: [[url: REPO_URL]]
                            ])
                        }
                            
                            } else {
                                echo "cloned code from ${REPO_URL} and pulling latest version of the code to ${REPO_DIR}"
                                sh """
                                git clone -b ${BRANCH_NAME} ${REPO_URL} ${REPO_DIR}
                                cd ${REPO_DIR} && git pull origin ${BRANCH_NAME}
                                """
                                dir(REPO_DIR) {
                            checkout([$class: 'GitSCM',
                                branches: [[name: BRANCH_NAME]],
                                userRemoteConfigs: [[url: REPO_URL]]
                            ])} 
                            }
                            env.PULL_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.PULL_STATUS ='FAILED'
                            error("failed to pull the latest version from ${REPO_URL}:${e.getMessage()}")
                        }
                    }
                }
        }
            

            stage('input') {
                steps{
                    script{
                        try{
                            input(' creating docker image') 
                            env.INPUT_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.INPUT_STATUS ='FAILED'
                            error("failed to get input :${e.getMessage()}")
                        }
                            
                    }
                }
            }
        
            stage('build and pull images in parallel') {
                parallel {

                
                    stage('build1 and push') {
                        steps{
                            script{
                                try{
                                    dir(REPO_DIR) {        
                                        sh """
                                        docker build -t ${DOCKER_REPO}:${IMAGE_TAG} .
                                        docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                                        docker tag ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_USERNAME}/${REPO_NAME}:${IMAGE_TAG}
                                        docker push ${DOCKER_USERNAME}/${REPO_NAME}:${IMAGE_TAG}
                                        """
                                    }
                                        echo "docker image created and pushed to $DOCKER_REPO"
                                    
                                        env.BUILD1_AND_PUSH_STATUS='SUCCESS'
                                } catch(Exception e) {
                                        env.BUILD1_AND_PUSH_STATUS ='FAILED'
                                        error("failed to build and push the image :${e.getMessage()}")
                                }
                            }
                        
                        }
                    }
            
                    

                    stage('build2andpush') {
                        steps{
                            script{
                                try{
                                    sh """
                                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                                    docker pull alpine:3.21
                                    docker tag ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_USERNAME}/${REPO_NAME}:alpine
                                    docker push ${DOCKER_USERNAME}/${REPO_NAME}:alpine
                                    """
                                    echo "docker image created and pushed to $DOCKER_REPO"

                                    env.BUILD2_AND_PUSH_STATUS ='SUCCESS'
                                } catch(Exception e) {
                                    env.BUILD2_AND_PUSH_STATUS ='FAILED'
                                    error("failed to build to the image:${e.getMessage()}")
                                }
                            
                            }
                        }
                    }

                    stage('build3andpush') {
                        steps{
                            script{
                                try{

                                    sh """
                                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                                    docker pull busybox:1.37.0-glibc
                                    docker tag ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_USERNAME}/${REPO_NAME}:busybox
                                    docker push ${DOCKER_USERNAME}/${REPO_NAME}:busybox
                                    """
                                    echo "docker image created and pushed to $DOCKER_REPO"
                                    env.BUILD3_AND_PUSH_STATUS ='SUCCESS'
                                } catch(Exception e) {
                                    env.BUILD3_AND_PUSH_STATUS ='FAILED'
                                    error("failed to build and push the image :${e.getMessage()}")
                                }


                            }
                        }
                    }
                }   

            }   

            stage('pull from docker repo') {
                steps{
                    script{
                        try{
                            echo " pulling from ${DOCKER_REPO} "
                            sh """
                            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                            docker pull ${DOCKER_REPO}:${IMAGE_TAG}
                            docker pull ${DOCKER_USERNAME}/${REPO_NAME}:alpine
                            docker pull ${DOCKER_USERNAME}/${REPO_NAME}:busybox
                            """
                            env.PULL_FROM_DOCKER_REPO_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.PULL_FROM_DOCKER_REPO_STATUS ='FAILED'
                            error("failed to pull from $DOCKER_USERNAME:${e.getMessage()}")
                        }
                        
                    }
                }
            }
            
            stage('deploy') {
                steps{
                    script{
                        try{
                            echo "running image comtainer"
                            sh"""
                            docker rm -f task1app || true
                            docker run -d -p 9000:80 --name task2app ${DOCKER_USERNAME}/${REPO_NAME}:${IMAGE_TAG}
                            """
                            env.DEPLOY_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.DEPLOY_STATUS ='FAILED'
                            error("failed to deploy ${DOCKER_REPO}:${IMAGE_TAG}:${e.getMessage()}")
                        }
                    }
                }
            }
        }
}



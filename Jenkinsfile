pipeline{
    agent any

    environment{
        REPO_URL= "https://github.com/nikhila1511ch/task-2.git"
        WORK_DIR='task-2'
        BRANCH_NAME='main'
        DOCKER_REPO="nikhila1511/task-2"
        REPO_DIR='task-2'
        REPO_NAME='task-2'
        DOCKER_USERNAME='nikhila1511'
        DOCKER_PASSWORD='Nikhila@1511'
        IMAGE_NAME ='ubuntu'
        IMAGE_TAG='latest'
        TARGET_SERVER='54.161.13.134'
    }
        

        stages{
            stage('check and pull') {
                steps{
                    script{
                        try{
                            

                            echo "code is already exits.pull latest code from ${REPO_URL} TO ${BRANCH_NAME}"
                            if(fileExists(WORK_DIR)) {
                            sh "cd ${WORK_DIR} && git pull origin ${BRANCH_NAME}"
                            } else {
                                echo "code is doesn't exits.clone latest code from ${REPO_URL} TO ${BRANCH_NAME}"
                                sh """
                                git clone -b ${BRANCH_NAME} ${REPO_URL} ${WORK_DIR}
                                cd ${WORK_DIR} && git pull origin ${BRANCH_NAME}
                                """
                            }

                            dir(REPO_DIR) {
                                checkout([$class: 'GitSCM',
                                    branches: [[name: BRANCH_NAME]], 
                                    userRemoteConfigs: [[url: REPO_URL]]
                                ])
                            }
                            env.CHECK_AND_PULL_STATUS ='SUCCESS'
                        } catch(Exception e) {
                            env.CHECK_AND_PULL_STATUS ='FAILED'
                            error("failed to check and pull the $REPO_URL:${e.getMessage()}")
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



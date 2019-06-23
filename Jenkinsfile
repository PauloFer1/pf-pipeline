pipeline {

    agent {
        label 'java-build'
    }

    stages {
        stage('Build') {
            steps {

                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                              credentialsId: "github-jenkins-repo",
                              usernameVariable: 'GIT_USERNAME',
                              passwordVariable: 'GIT_PASSWORD']]) {
                    sh "git config --global userAuthDetails.email paulo.r.r.fernandes@gmail.com"
                    sh "git config --global userAuthDetails.name paulofer1"
                    sh "git config remote.origin.url https://\${GIT_PASSWORD}@github.com/paulofer1/pf-pipeline.git"
                    sh "git fetch --tags"

                    script {
                        env.RELEASE = isReleaseBranch() ?
                            nextRelease()
                            : currentCommitSha()
                    }
                }

                script {
                    build job: 'service/pf-pipeline/pf-pipeline-build', parameters: [
                                                stringParameterVal('DEPLOY_VERSION', "${env.RELEASE}"),
                                                stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                                                ]
                }
            }
        }

        stage('Build transient environment') {
            steps {
                script {
                    build job: 'service/pf-pipeline/pf-pipeline-build-transient-environment', parameters: [
                                                stringParameterVal('DEPLOY_VERSION', "${env.RELEASE}"),
                                                stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                                                ]
                }
            }
        }

        stage('Integration tests') {
            steps {
                script {
                    build job: 'service/pf-pipeline/pf-pipeline-integration-tests', parameters: [
                                                stringParameterVal('DEPLOY_VERSION', "${env.RELEASE}"),
                                                stringParameterVal('DEPLOY_ENVIRONMENT', "transient"),
                                                stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                                                ]
                }
            }
        }

        stage('Teardown transient environment') {
            steps {
                build job: 'service/pf-pipeline/pf-pipeline-teardown-transient', parameters: [
                                                                stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                ]
            }
        }

        stage('Deploy to UAT') {
            when {
                expression { isReleaseBranch() }
            }
            steps {
                build job: 'service/pf-pipeline/pf-pipeline-deploy', parameters: [
                                            stringParameterVal('DEPLOY_VERSION', (String) env.RELEASE),
                                            stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                                            stringParameterVal('DEPLOY_ENVIRONMENT', "uat"),
                                        ]
            }
        }

        stage('E2E test UAT environment') {
            when {
                expression { isReleaseBranch() }
            }
            steps {
                script {
                    build job: 'service/pf-pipeline/pf-pipeline-e2e-tests', parameters: [
                                                stringParameterVal('DEPLOY_VERSION', "${env.RELEASE}"),
                                                stringParameterVal('DEPLOY_ENVIRONMENT', "uat"),
                                                stringParameterVal('BRANCH', "${env.BRANCH_NAME}"),
                                                ]
                }
            }
        }
    }

    tweet {
        success {
            script {
                if (isReleaseBranch()) {
                    sh "git tag -a ${env.RELEASE} -m 'Jenkins'"
                    sh "git push --tags"
                }
            }
        }
        failure {

            step([
                $class: 'Mailer',
                notifyEveryUnstableBuild: false,
                recipients: emailextrecipients([[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]),
                sendToIndividuals: true
            ])
        }
        always {
            cucumber '**/cucumber-json-report.json'
        }
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
    }
}

def currentCommitSha() {
    sh "git rev-parse --short HEAD > .git/current-commit"
    return "${env.BRANCH_NAME}_" + readFile(".git/current-commit").trim()
}

def nextRelease() {
    sh "git tag -l --sort version:refname | awk '/^([0-9]+).([0-9]+).([0-9]+)\$/{split(\$0,v,\".\")}END{printf(\"%d.%d.%d\",v[1],v[2],v[3]+1)}' > .git/current-tag"
    readFile(".git/current-tag").trim()
}

def isReleaseBranch() {
    env.BRANCH_NAME == "master"
}

static stringParameterVal(String name, String  value) {
    [$class: 'StringParameterValue', name: name, value: value]
}

job('service/pf-pipeline/pf-pipeline-build') {

    displayName('pf-pipline-build')

    label('java-build')

    parameters {
        stringParam('DEPLOY_VERSION','','Deployment version')
        stringParam('BRANCH', 'master', 'Git branch')
    }

    scm {
        git {
            branch('${BRANCH}')
            remote {
                credentials('cc1d4123-c18e-403b-b790-1e072cd0583d')
                url('git@github.com:paulofer1/pf-pipeline.git')
            }
            extensions {
                cleanBeforeCheckout()
            }
        }
    }

    steps {
        shell('''
        #!/usr/bin/env bash

        tools/bin/build.sh -d -v ${DEPLOY_VERSION}
        tools/bin/create-application-container.sh -d -v ${DEPLOY_VERSION}
        ''')
    }
}
job('service/pf-pipeline/pf-pipeline-build-transient-environment') {

    displayName('pf-pipeline-build-transient-environment')

    parameters {
        stringParam('BRANCH', 'master', 'Git branch')
        stringParam('DEPLOY_VERSION','','Deployment version')
        stringParam('PROXY_URL', '172.17.0.1', 'IP of proxy url')
        stringParam('PROXY_PORT','4140','Port for the proxy server')
        stringParam('DEPLOY_ENVIRONMENT','transient','Deployment environment')
    }

    wrappers {
        deliveryPipelineVersion('\${DEPLOY_VERSION}', true)

        environmentVariables{
            env('mysql_root_password','fagookez')
        }
        timeout {
            absolute(5)
        }
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
        tools/bin/deploy-dependencies.sh -v ${DEPLOY_VERSION} -m ${MARATHON_DEV} -p ${mysql_root_password}
        ''')
    }

    steps {
        shell('''
        #!/usr/bin/env bash
        
        echo "Sleeping 10 seconds before service discovery"
        sleep 10
        
        export APP_ID=${DEPLOY_ENVIRONMENT}-nm-nutmail-sender-service
        export SWAGGER_ENABLED=true
        export AMAZONS3CLIENT_REGION=eu-west-1
        export BASE_ATTACHMENT_FOLDER="staging/attachment/document/"
        
      
        export TRANSIENT_S3_MOCK_URL="http://${transient_s3mock_host}:${transient_s3mock_port}"
        
        tools/bin/deploy-application.sh  -a \${APP_ID}                   \\
                                         -e \${DEPLOY_ENVIRONMENT}       \\
                                         -h \${EXPOSED_API}              \\
                                         -m \${MARATHON_DEV}             \\
                                         -n \${NUTCRACKER_SERVER}        \\
                                         -u \${DB_USER}                  \\
                                         -v \${DEPLOY_VERSION}           \\
                                         -p \${PROXY_URL}                \\
                                         -E \${TRANSIENT_S3_MOCK_URL}    \\
                                         -t \${PROXY_PORT}        ''')
    }
}
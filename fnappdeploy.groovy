pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID = '040f44e2-71b6-4118-bbad-a91af78ac245'
        AZURE_TENANT_ID = 'dafe49bc-5ac3-4310-97b4-3e44a28cbf18'
        AZURE_CREDENTIALS_ID = 'Az-UCI-SPN'
        RESOURCE_GROUP = 'az03-di-dfx-research-sandbox-rg'
        LOCATION = 'eastus'
        STORAGE_ACCOUNT = 'jenkinstoreacc'
        FUNCTION_APP = 'jenkinfnapp'
        FUNCTION_VERSION = '4'
        OS_TYPE = 'linux'
        RUNTIME_SLACK = 'python'
        RUNTIME_VERSION = '3.9'
    }

    stages {
        stage('Deploy') {
            steps {
              // login Azure
              withCredentials([usernamePassword(credentialsId: 'Az-UCI-SPN', passwordVariable: 'AZURE_CLIENT_SECRET', usernameVariable: 'AZURE_CLIENT_ID')]) {
              sh '''
                 az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                 az account set -s $AZURE_SUBSCRIPTION_ID
              '''
              }
              sh "az storage account create --name $STORAGE_ACCOUNT --location $LOCATION --resource-group $RESOURCE_GROUP --sku Standard_GRS --kind StorageV2 --require-infrastructure-encryption"
              sh "az functionapp create --resource-group $RESOURCE_GROUP --runtime $RUNTIME_SLACK --consumption-plan-location $LOCATION --runtime-version $RUNTIME_VERSION --functions-version $FUNCTION_VERSION --name $FUNCTION_APP --os-type $OS_TYPE --storage-account $STORAGE_ACCOUNT"
              sh 'az logout'
            }
        }
         
    }
}

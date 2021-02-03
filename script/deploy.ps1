# read from setting file
$settings = Get-Content .\config.txt | ConvertFrom-StringData

# login
Write-Host "start login..."
az login --service-principal `
    --username $settings.USER_NAME `
    --tenant $settings.TENANT `
    --password $settings.PASSWORD
if ( $LastExitCode -ne 0 )
{
    Write-Host "login into azure failed."
    exit 1
}
else
{
    Write-Host "login completed."
}

# registory_name
$REGISTORY_NAME = $settings.REGISTORY_NAME
# Docker image full name
$image_name_tag = $settings.IMAGE_NAME + ":" + $settings.TAG
# Container Registory login server
$ACR_LOGIN_SERVER = "${REGISTORY_NAME}.azurecr.io"

Write-Host "start create container..."
# https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az_container_create
az container create `
    --resource-group ${settings}.RESOURCE_GROUP `
    --name ${settings}.CONATINER_NAME `
    --image "${ACR_LOGIN_SERVER}/${image_name_tag}" `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $settings.USER_NAME `
    --registry-password $settings.PASSWORD `
    --restart-policy Never
if ( $LastExitCode -ne 0 )
{
    Write-Host "create container failed."
    exit 1
}
else
{
    Write-Host "create container completed."
}

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
$acr_path = "${REGISTORY_NAME}.azurecr.io/${image_name_tag}"

# login into ACR
$is_login = az acr login --name ${REGISTORY_NAME}
if ( $is_login -cne "Login Succeeded" )
{
    Write-Host "login into acr failed."
    exit 1
}
else
{
    Write-Host "login into acr completed."
}

docker build -t $image_name_tag .
if ( $LastExitCode -eq 1 )
{
    Write-Host "docker build failed."
    exit 1
}
else
{
    Write-Host "docker build completed."
}

docker tag $settings.IMAGE_NAME $acr_path

docker push $acr_path
if ( $LastExitCode -eq 1 )
{
    Write-Host "docker push failed."
    exit 1
}
else
{
    Write-Host "docker push ${acr_path} completed."
}

docker rmi -f $acr_path
if ( $LastExitCode -eq 1 )
{
    Write-Host "remove ${acr_path} failed."
    exit 1
}
else
{
    Write-Host "remove ${acr_path} completed."
}
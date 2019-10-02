###########################################################################
# Description: 
# This script is intended to copy backups to AWS from Azure. 
# You may have to hack it a bit for it to work for your needs!             
# 
# Author: gazataeon
# 
###########################################################################



# Variables
$container_name= $env:AZ_CONTAINER
$dailyDbNames = @("customer", "archive", "mudkips")
$rcloneConfig="/root/.config/rclone/rclone.conf"

# Functions
function invoke-azToAws ($storageAccountName, $envName)
{
    write-host "Checking the backups in Azure for $($envName). This can take a while...."  -ForegroundColor Yellow

    #clear file away in case of previous runs
    if ((test-path -Path .\filestosend.txt) -eq $true) {Remove-Item .\filestosend.txt}
    $dbFiles = $null

    # Get last night's  backups
    foreach ($dbname in $dailyDbNames)
    {
        write-host "last night's daily backups for: $($dbname)" -ForegroundColor Green
        $dbFiles = az storage blob list --account-name $storageAccountName --container-name $container_name --num-results 900000 --prefix "$dbname"
        $filenameSearch = "$($dbname)*"
        $outputFiles = (($dbFiles | ConvertFrom-Json) | Where-Object name -like $filenameSearch) | Select-Object name -Last 1
        $outputFiles.name | out-file filestosend.txt -Append
        write-host $outputFiles.name
        if ($outputFiles.count -lt 1){
            Write-host "Problem with $($dbname) Daily copy to AWS, check S3/script - $($envName)" -ForegroundColor red
        }
    }

    # read text file
    $filesToSend = (get-content filestosend.txt)
    write-host "Files to be sent to AWS:" -ForegroundColor Green
    foreach ($fileName in $filesToSend){write-host "$($fileName)"}

    # Upload files
    rclone copy --files-from "filestosend.txt" "$($envName):backupcontainer/$($line)" "aws:$($env:S3_BUCKET)/$($envName)" --progress 
    write-host "Done uploads for $($envName)" -ForegroundColor Green
}

## Body

# Update the rclone config file
sed -i "s/<AWS_ACCESS_KEY_ID>/$($env:AWS_ACCESS_KEY_ID)/g" $rcloneConfig
sed -i "s/<AWS_SECRET_ACCESS_KEY>/$($env:AWS_SECRET_ACCESS_KEY)/g" $rcloneConfig
sed -i "s/<SITE1_SAS>/$($env:SITE1_SAS)/g" $rcloneConfig
sed -i "s/<SITE2_SAS>/$($env:SITE2_SAS)/g" $rcloneConfig
sed -i "s/<SITE1_SA>/$($env:SITE1_SA)/g" $rcloneConfig
sed -i "s/<SITE2_SA>/$($env:SITE2_SA)/g" $rcloneConfig


# Login to azure
az login --service-principal -u $env:AZ_SP_NAME -p $env:AZ_SP_PASS --tenant $env:AZ_TENANT

# Trigger Uploads
invoke-azToAws -storageAccountName $env:SITE1_SA -envName "azure_site1"
invoke-azToAws -storageAccountName $env:SITE2_SA -envName "azure_site2"

write-host "All uploads Complete" -ForegroundColor Green
az logout
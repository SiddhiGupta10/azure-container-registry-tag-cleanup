#This script deletes all the tags from the registry except the ones mentioned to skip either by specific tag number or recent ones from all.

#Parameters:
# registryName(String)   - Name of the Azure Container Registry. Mandatory parameter
# skipLastTags(int)      - Count of the recent tags to be skipped. Mandatory parameter
# doNotDeleteTags(array) - Array of tags which needs to be ignored for deletion. Optional parameter

#Example:
# .\deleteTagsWithSkip.ps1 -registryName <Name-of-ACR> -skipLastTags 10 -doNotDeleteTags 42712, 42761, 43614

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]$registryName,

    [Parameter(Mandatory = $true)]
    [int]$skipLastTags,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int[]]$doNotDeleteTags
)

try{
    #Fetch the list of repositories in passed registry
    $repoArray = az acr repository list --name $registryName -o json | ConvertFrom-Json

    #To pass specific repository, name them in array
    #$repoArray = ("jobs/azuresearchfunc","jobs/manageeventfunc","jobs/notificationfunc")

    foreach ($repository in $repoArray)
    {
        $tagsArray = ( az acr repository show-tags --name $registryName --repository $repository --orderby time_asc -o json | ConvertFrom-Json ) | Select-Object -SkipLast $skipLastTags
        
        foreach($tag in $tagsArray) {
            if ($donotdeletetags -Contains $tag) {
                Write-Output " $($repository) : This tag is not deleted $($tag)"
            } 
            elseif ($donotdeletetags -NotContains $tag) {     
                az acr repository delete --name $registryName --image $repository":"$tag --yes
                Write-Output "Repository $($repository): Deleted $($tag)"
            }
        }
    }
}
catch {
    ShowError $_.Exception.Message
}

function ShowError {
    $errorMessage = $args[0]
    write-host "------------------------------------------------------------------"
    Write-host "$errorMessage"
    write-host "------------------------------------------------------------------"
  }

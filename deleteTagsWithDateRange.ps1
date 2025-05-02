#This script deletes all the tags from the registry for specified date range.

#Parameters:
# registryName(String) - Name of the Azure Container Registry. Mandatory parameter
# startDate(string)    - To fetching tags start from specified date range. Mandatory parameter
# endDate(string)      - To fetching tags within end date range. Mandatory parameter

#Example:
# .\deleteTagsWithDateRange.ps1 -registryName <Name-of-ACR> -startDate "2025-01-01" -endDate "2025-02-28"

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]$startDate,

    [Parameter(Mandatory = $true)]
    [string]$endDate,

    [Parameter(Mandatory = $true)]
    [string]$registryName
)

try{
    #Fetch the list of repositories in passed registry
    $repoArray = az acr repository list --name $registryName -o json | ConvertFrom-Json

    #To pass specific repository, name them in array
    #$repoArray = ("jobs/azuresearchfunc","jobs/manageeventfunc","jobs/notificationfunc")

    foreach ($repository in $repoArray)
    {
        # Get all tags in the repository
        $tagsArray = az acr repository show-tags --name $registryName --repository $repository --orderby time_desc --output json | ConvertFrom-Json

        # Filter tags based on date range
        $tagsToDelete = $tagsArray | Where-Object {
            $tagDate = [datetime]::ParseExact($_.lastUpdateTime, "yyyy-MM-ddTHH:mm:ssZ", $null)
            $tagDate -ge [datetime]$startDate -and $tagDate -le [datetime]$endDate
        }
                
        # Delete filtered tags
        foreach ($tag in $tagsToDelete) {
            az acr repository delete --name $registryName --image $repository":"$tag --yes
            Write-Output "Repository $($repository): Deleted $($tag)"
        }
    }
    

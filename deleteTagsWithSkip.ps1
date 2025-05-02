[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string[]]$doNotDeleteTags,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$skipLastTags,

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

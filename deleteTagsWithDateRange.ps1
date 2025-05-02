# Define variables
$registryName = "YourRegistryName"
$repositoryName = "YourRepositoryName"
$startDate = "2023-01-01"
$endDate = "2023-12-31"

# Get all tags in the repository
$tags = az acr repository show-tags --name $registryName --repository $repositoryName --orderby time_desc --output json | ConvertFrom-Json

# Filter tags based on date range
$tagsToDelete = $tags | Where-Object {
    $tagDate = [datetime]::ParseExact($_.lastUpdateTime, "yyyy-MM-ddTHH:mm:ssZ", $null)
    $tagDate -ge [datetime]$startDate -and $tagDate -le [datetime]$endDate
}

# Delete filtered tags
foreach ($tag in $tagsToDelete) {
    az acr repository delete --name $registryName --image "$repositoryName:$tag" --yes
    Write-Output "Deleted tag: $tag"
}


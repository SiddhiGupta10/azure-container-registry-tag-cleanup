# azure-container-registry-tag-cleanup

Azure Container Registry (ACR) vulnerabilities can arise from several factors like outdated base image, unpatched dependencies, misconfigurations, embedded secrets, insufficient Access Controls, lack of regular scanning.

In production environment, we have seen scenarios where thousand of old tags are exists in mutiple repositiories of  ACR, resulting into the vulnerability issues in future. In such scenarios, deleting old tags is the best way to remediate vulnerabilies arising from outdated base images or unpatched dependencies.

We have curated 2 powershell scripts to delete multiple tags in one run.
1. [**deleteTagsWithSkip**](https://github.com/SiddhiGupta10/azure-container-registry-tag-cleanup/blob/main/deleteTagsWithSkip.ps1) -
   - This script deleted all the tags from the registry except the ones mentioned to skip.
   - There are two parameters which decides undeleted tags list - doNotDeleteTags(array), skipLastTags(int).
   - _Example_: .\deleteTagsWithSkip.ps1 -skipLastTags 10 -registryName <name-of-ACR> -doNotDeleteTags <array-of-tag
1. [**deleteTagsWithDateRange**](https://github.com/SiddhiGupta10/azure-container-registry-tag-cleanup/blob/main/deleteTagsWithDateRange.ps1) - 

## Delete untagged Manifest

If an image with a stable tag is updated, the previously tagged image is untagged, resulting in an orphaned image. The previous image's manifest and unique layer data remain in the registry. To maintain your registry size, you can periodically delete untagged manifests resulting from stable image updates using either **auto-purge** or by **setting a retention policy**.

1. [Auto-purge](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auto-purge) removes untagged manifests older than a specified duration. But this cmd does not delete an image tag or repository where the _write-enabled_ attribute is set to **false**. _az acr run --registry <YOUR_REGISTRY> --cmd 'acr purge --untagged --ago <2d3h6m> --keep <int>' /dev/null_

You can use _--dry-run_ parameter for testing a purge command to make sure it does not inadvertently delete data you intend to preserve.

For example, _az acr run --registry <YOUR_REGISTRY> --cmd 'acr purge --untagged --ago 2d3h6m --keep 5 --dry-run' /dev/null_

1. Set a [retention policy for untagged manifests](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy). When a retention policy is enabled, untagged manifests in the registry are automatically deleted after a number of days you set. This feature prevents the registry from filling up with artifacts that aren't needed and helps you save on storage costs.

## How long it takes to get updated vulnerabilities reports after deletion?

Azure Container Registries notifies Defender for Cloud when images are deleted, and removes the vulnerability assessment for deleted images within one hour. In some rare cases, Defender for Cloud might not be notified on the deletion, and deletion of associated vulnerabilities in such cases might take up to three days.

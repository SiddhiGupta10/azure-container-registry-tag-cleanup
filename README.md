# azure-container-registry-tag-cleanup

Azure Container Registry (ACR) vulnerabilities can arise from several factors like outdated base image, unpatched dependencies, misconfigurations, embedded secrets, insufficient Access Controls, lack of regular scanning.

In production environment, we have seen sceanrios where thousand of old tags are exists in mutiple repositiories of  ACR, resulting into the vulnerability issues in future. In such scenarios, deleting old tags is the best way to remediate vulnerabilies arising from outdated base images or unpatched dependencies.

We have curated 2 powershell scripts to delete multiple tags in one run.
1. [deleteTagsWithSkipFeature]() -
1. [deleteTagsWithDateRange]() - 

Azure Container Registries notifies Defender for Cloud when images are deleted, and removes the vulnerability assessment for deleted images within one hour. In some rare cases, Defender for Cloud might not be notified on the deletion, and deletion of associated vulnerabilities in such cases might take up to three days.

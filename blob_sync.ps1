#####################################################################
#
#  This loops through all files on S3 and downloads all versions
#  then uploads those in reverse order to Blob storage.
#
#####################################################################

param (
    [String][Parameter(Mandatory)]$awsBucketName,
    [String][Parameter(Mandatory)]$awsKeyPrefix,
	[String][Parameter(Mandatory)]$awsProfile,
	[String][Parameter(Mandatory)]$azureBlobAccessToken,
	[String][Parameter(Mandatory)]$azureBlobStorageName,
	[String][Parameter(Mandatory)]$azureBlobContainerName
)

Remove-Item -Path "$PSScriptRoot/download/$awsKeyPrefix" -Force -Recurse -ErrorAction SilentlyContinue
mkdir "$PSScriptRoot/download/$awsKeyPrefix"

$objects = Get-S3Object -BucketName $awsBucketName -ProfileName $awsProfile -Prefix $object.Key

$c = 0
foreach($object in $objects) {
	$localFileName = $object.Key -replace $awsKeyPrefix, ''
	if ($localFileName -ne '') {
		Write-Host "Now processing $($object.Key)"

		$versions = Get-S3Version -BucketName $awsBucketName -ProfileName $awsProfile -Prefix $object.Key
		for ($i = $versions.Versions.Count - 1; $i -ge 0; $i--) {
			$ver = $versions.Versions[$i]
			$downloadedFileName = "$PSScriptRoot/download/$awsKeyPrefix/$c-$($ver.VersionId)_$localFileName"
			Write-Host "Found Version $($ver.VersionId), Last Modified at $($ver.LastModified)"
			Read-S3Object -BucketName $awsBucketName -ProfileName $awsProfile -Key $object.Key -Version $ver.VersionId -File $downloadedFileName

			$blobContents = Get-Content -Path $downloadedFileName

			$headers = @{
				"Authorization"="Bearer  " + $azureBlobAccessToken
				"x-ms-date"= Get-Date -Format R
				"x-ms-version"= "2019-10-10"
				"x-ms-blob-type"= "BlockBlob"
				"x-ms-meta-s3version"= $ver.VersionId
			}
			$putResponse = Invoke-WebRequest "https://$azureBlobStorageName.blob.core.windows.net/$azureBlobContainerName/$localFileName" -Body $blobContents -Method PUT -Headers $headers
		
			$blobVersion = $putResponse.Headers['x-ms-version-id']
			Write-Host "AWS Version of $localFileName is $($ver.VersionId), Blob Version is $blobVersion"


		}
		$c += 1
	}
}
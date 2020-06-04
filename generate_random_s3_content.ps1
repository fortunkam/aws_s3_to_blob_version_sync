#####################################################################
#
#  Generate text files in an S3 bucket.  
#  Each file will have one or versions associated with it
#
#####################################################################

param (
    [String][Parameter(Mandatory)]$bucketName,
    [String][Parameter(Mandatory)]$keyPrefix,
    [String][Parameter(Mandatory)]$awsProfile,
    [int]$fileCount=10,
    [int]$maxVersionCount=10
)

for ($i = 0; $i -lt $fileCount; $i++) {
    $filePrefix = [System.IO.Path]::GetRandomFileName()
    $fileName = "$filePrefix.txt"

    $revisionCount = Get-Random -Minimum 1 -Maximum $maxVersionCount

    for ($j = 0; $j -lt $revisionCount; $j++) {
        Write-Host "Creating $keyPrefix$fileName"
        Write-S3Object -BucketName $bucketName -Key "$keyPrefix$fileName" `
            -Content "FileName $fileName Version $j" -ProfileName $awsProfile
    }
}
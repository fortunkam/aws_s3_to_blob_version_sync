# Copying version data from AWS S3 to Azure Blob

## This relies on the Blob Versioning feature detailed [here](https://docs.microsoft.com/en-us/azure/storage/blobs/versioning-overview?tabs=powershell), this feature is currently in Preview and only available in a limited set of regions.

Contains 2 powershell scripts 

[The first is for populating an S3 bucket with sample files with Version history](./generate_random_s3_content.ps1)

[The second synchronises the files from S3 to blob storage](./blob_sync.ps1) 


# Azure to AWS Sync

## Example

```
docker run --env AZ_SP_PASS="password123" \
--env AZ_TENANT="xxxxxxx-xxxxxx-xxxxxx-xxxxx-xxxxxxxx" \
--env SITE1_SA="examplessa1" \
--env SITE2_SA="examplessa2" \
--env AZ_SP_NAME="http://sp_examplename" \
--env SITE1_SAS="sv=2019-03-28&ss=bfqt&srt=sco&sp=rlacup&se=2022-09-17T14:55:48Z&st=2019-09-17T06:55:48Z&spr=https&sig=ITHISISALLEXAMPLEDATA" \
--env SITE2_SAS="sv=2019-03-28&ss=bfqt&srt=sco&sp=rlacup&se=2022-09-30T14:53:20Z&st=2019-09-17T06:53:20Z&spr=https&sig=ITHISISALLEXAMPLEDATAAGAIN" \
--env AWS_ACCESS_KEY_ID="THISTOOISNOTREAL" \
--env AWS_SECRET_ACCESS_KEY="ZJKHDdddUWHD+DSDWDDdd" \
--env S3_BUCKET="mys3bucketname"
--env AZ_CONTAINER="backups"
gazataeon/azuretoawssync:latest

```

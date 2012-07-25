## What it does

- Uses a Ruby / Sinatra server to receive web hook posts from GitHub
- Pulls and generates Jekyll or static sites with git / Jekyll
- Pushes content to S3 bucket with s3cmd

## TODO

- install script
- automatically configure buckets
- finish email setup

## Bucket configuration

- enable website config, index.html, 404.html
- add the following bucket policy

```json
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Sid": "PublicReadForGetBucketObjects",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::[bucketname]/*"
		}
	]
}
```

## Try it

- Add `ds-static` github user as a contributer to your repos. He's in the `mapbox/static-deployer` team too.
- Add this as a web hook to your repos: `http://ec2-50-17-32-7.compute-1.amazonaws.com:8080/api`

- Your site will be built as `http://[user].dhcole.com/[repos]/` or `http://[cname].dhcole.com/`


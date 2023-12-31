# doc-pipe
Generate TechDocs with a Tekton pipeline

# Build and test local

## Build container
```
podman build -t techdocs .
```

## Generate TechDocs
```
mkdir /tmp/out && chmod 777 /tmp/out
podman run -it --rm --volume $PWD/test:/mnt/in:Z --volume /tmp/out:/mnt/out:Z techdocs ./techdocs-cli generate  --no-docker --source-dir /mnt/in --output-dir /mnt/out
```

## Publish TechDocs to S3 bucket `techdocs` on minio

```
podman run -it --rm --volume /tmp/out:/mnt/out:Z \
-e AWS_REGION=$AWS_REGION \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e NODE_TLS_REJECT_UNAUTHORIZED=0 \
techdocs ./techdocs-cli publish --directory /mnt/out --publisher-type awsS3 --storage-name  techdocs --awsEndpoint https://minio-api-minio.apps.<your-ocp-clsuter>.com --awsS3ForcePathStyle --entity default/Component/my-rhoai-sklearn-dsp-dev
```


# Build Tech Docs with a pipeline 

## First, create a secret with the S3 credentials

Create an `.s3-env` file. E.g.:

```
AWS_REGION=<region>
AWS_ACCESS_KEY_ID=<access-key>
AWS_SECRET_ACCESS_KEY=<secrect-key>
S3_URL=<s3-url>
S3_BUCKET=<bucket-name>
```

Add `NODE_TLS_REJECT_UNAUTHORIZED=0`, in case your S3 service runs with a self-signed certificate.

Create the secret:
```
oc create secret generic s3-env --from-env-file=.s3-env -n <namespace>
``` 


## Update `doc-pipe/values.yaml`
Update at least `app.namespace` and `docs:` section to fit to your needs.


## Deploy helm chat
```
helm template  -f doc-pipe/values.yaml doc-pipe/ | oc apply -f -
```

Note, the build for a container image for a pipeline task has to finish first. You might have to restart the pipeline run.


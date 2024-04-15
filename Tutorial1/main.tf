import { Construct } from "constructs";
import { App, TerraformStack, TerraformOutput } from "cdktf";
import { Provider, S3Bucket, S3BucketPolicy } from '@cdktf/provider-aws';


class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Define AWS provider
    new Provider(this, 'awsconstruct', {
      region: 'us-east-1',
      profile: 'staticWebsiteAssignment',
      sharedCredentialsFile: "C:/Users/olibo/CDKTF"
    });

    // Create S3 bucket
    const bucket = new S3Bucket(this, 'staticWebsiteBucket', {
      bucket: 'StaticWebSite', // Replace 'your-bucket-name' with your desired bucket name
      website: [{
        indexDocument: 'index.html', // The default page when accessing the root URL
        errorDocument: 'error.html' // The error page
      }]
    });

    // Create a bucket policy to allow public read access
    new S3BucketPolicy(this, 'staticWebsiteBucketPolicy', {
      bucket: bucket.bucketName,
      policy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
          Effect: "Allow",
          Principal: "*",
          Action: [
            "s3:GetObject"
          ],
          Resource: [
            `arn:aws:s3:::${bucket.bucketName}/*`
          ]
        }]
      })
    });

    // Output the bucket website URL
    new TerraformOutput(this, 'bucketWebsiteUrl', {
      value: bucket.websiteEndpoint
    });
  }
}

const app = new App();
new MyStack(app, 'MyStack');
app.synth();

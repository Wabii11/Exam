import { Construct } from 'constructs';
import { App, TerraformStack, TerraformOutput } from 'cdktf'
import { Provider, Instance, SecurityGroup, Subnet, Vpc } from '@cdktf/provider-aws';
class MyWebsiteStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    // Define AWS provider
    new Provider(this, 'aws', {
      region: 'us-east-1', // Change to your desired region
    });

    // Create VPC
    const vpc = new Vpc(this, 'MyVpc', {
      cidrBlock: '10.0.0.0/16',
    });

    // Create security group
    const securityGroup = new SecurityGroup(this, 'MySecurityGroup', {
      vpcId: vpc.id,
      ingress: [{
        fromPort: 80,
        toPort: 80,
        protocol: 'tcp',
        cidrBlocks: ['0.0.0.0/0'],
      }],
    });

    // Create subnet
    const subnet = new Subnet(this, 'MySubnet', {
      vpcId: vpc.id,
      cidrBlock: '10.0.0.0/24',
      availabilityZone: 'us-east-1a', // Change to your desired AZ
    });

    // Create EC2 instance
    const instance = new Instance(this, 'MyEC2Instance', {
      ami: '296190057073', // Amazon Linux 2 AMI ID
      instanceType: 't2.micro',
      subnetId: subnet.id,
      securityGroups: [securityGroup.name],
      userData: `#!/bin/bash\nsudo yum install -y httpd\nsudo systemctl start httpd\nsudo systemctl enable httpd`,
    });

    // Output instance's public IP
    new TerraformOutput(this, 'PublicIP', {
      value: instance.publicIp,
    });
  }
}

const app = new App();
new MyWebsiteStack(app, 'MyWebsiteStack');
app.synth();

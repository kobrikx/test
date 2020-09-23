# Infrastructure as Code

This directory contains infrastructure configuration that is required to deploy full environment from scratch, as long as you have proper AWS credentials and AWS *devEnvironmentName* tag configured.
You can also `export ENV="<your-env-name>"` to deploy a custom env.
Let's assume for the purpose of this guide your `ENV` is `dev`. Whenever you'd like to change the environment, do the whole guide from the very beginning, at least once.

## Creating your personal dev environment
### 1. Obtain AWS credentials
- Username / Password
- AWS Access Key / AWS Access Secret
- Request *devEnvironmentName* tag to be set in [AWS IAM](https://console.aws.amazon.com/iam/) by AWS administrator - this will be your default dev environment name

### 2. Configure AWS profile:
__Note: Profile name can be different, but must remain consistent everywhere. It is also NOT recommended to use `default` profile, do to possible mixups with different accounts in the future.__
```
aws configure --profile infra-dev
```

And enter when prompted:
- AWS Your Access key
- AWS Your Secret Key
- Region (`us-east-1`)

### 3. Export AWS profile name
```shell script
export AWS_PROFILE=infra-dev
```
It us suggested that you could also use [direnv](https://direnv.net/) to set `AWS_PROFILE` when cd'ed into project directory.
Remember, it is crucial to be sure which AWS credentials you are using.

### 4. Deploy the environment to AWS
```shell script
make use # Only when using the ENV for the first time
make infra
```

### 5. Deploy an App
__Every app deployment is described in Makefile.__
Assuming we're building and deploying current commit of _app_:
```shell script
make app
```

### 6. Secrets
__We use AWS Parameter Store (from SSM) to store secrets and integrate them with ECS__
In order to add secrets for your service, create a local json file with secrets in .infra/secrets/ and then:
```shell script
make secrets
```

Or for web app individually:
```shell script
make app.secrets
```

### 7. One-liner (optional)
This one-liner will deploy infrastructure and app(s) (but not secrets)
```shell script
make deploy
```
 
### 8. Private Network Access
__Currently we use bastion host for access to the internal resources inside of the VPC.__
In order to be able to access internal services and databases we need to create a ssh tunnel

```shell script
make tunnel
```

### Other Tunnel Commands
```
# Establish a tunnel
make tunnel.up

# Stop a tunnel
make tunnel.down

# Tunnel status
make tunnel.status
```

## Diagram
![](./Infra.svg)

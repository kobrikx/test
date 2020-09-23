# SLS Quickstart
Let's assume we're creating a new Serverless.com project and would like to add it to `dev` and `prod` environments.
Let's pick a good name for the project. There are some [recommendations]() on the naming. 
The name of the current project is `chip-analyzer`. 

## Resources
Let's assume Chip Analyzer uses S3 Bucket and SQS.


## Configure Dev
### Create `dev` Terraform File
`.infra/env/dev/chip-analyzer.tf`:
```hcl-terraform
module "chip_analyzer" {
  name = "chip-analyzer"
  source = "../../terraform/sls-service"
  env = local.env
  vpc = local.vpc

  parameters = {
    S3_BUCKET_NAME = module.scheduler_dynamodb.this_dynamodb_table_arn
    SQS_QUEUE = module.scheduler_sqs.this_sqs_queue_arn
    SECURITY_GROUP_ID = local.security_groups[0]
  }

  secrets = [
    "demo_secret_name"
  ]

  // This is needed to prevent race condition between ssm params and some resource creation
}
```
## Create Secrets
`.infra/env/dev/secrets/chip-analyzer.json`

## Configure CI/CD
`.github/workflows/dev.yml`:
```yaml
# TBD
```

## Configure Prod
### Create `prod` Terraform File
`.infra/env/prod/chip-analyzer.tf`
Same configuration as `dev`, unless there some static parameters. 

### Configure Secrets
Secrets go into `.infra/env/prod/secrets/chip-analyzer.json`

### Configure CI/CD
`.github/workflows/dev.yml`:
```yaml
# TBD
```

## Configure ICMK
### Add a block to `Makefile`

### Deploy Infra
CI/CD or `make infra`

### Push Secrets and Deploy Application
`make chip-analyzer.secrets`


## Create package.json
In order for the automation to work properly, ensure package.json is installed and all plugins are listed in ther
```shell script
npm init
```

Make sure to use `--save-dev`
```shell script
npm install --save-dev serverless-<plugin-name>
```



//// TODO: Until we migrate to terraform 0.13 SLS services have to be commented out on first deployment
//module "krtek" {
//  name = "krtek"
//  source = "../../terraform/sls-service"
//  env = local.env
//  vpc = module.vpc
//
//
//    parameters = {
//      security_group_id = aws_security_group.default_permissive.id
//    }
//
//  secrets = [
//    "demo_secret_name"
//  ]
//
//  // This is needed to prevent race condition between ssm params and some resource creation
//}

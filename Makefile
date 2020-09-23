NAMESPACE = nutcorp
ICMK_VERSION ?= master

include .infra/icmk/init.mk

deploy: infra.deploy squibby.deploy
destroy: infra.destroy
secrets: squibby.secrets ingest.secrets

# Infrastructure
infra: terraform.init terraform.apply
terraform.test: terraform.checkov terraform.tflint

###################################################################################################
# Services
squibby: squibby.image squibby.push squibby.deploy
squibby.image: docker
	$(CMD_SERVICE_DOCKER_BUILD)
squibby.push: docker ecr.login
	$(CMD_SERVICE_DOCKER_PUSH)
squibby.deploy: ecs jq ## Deploy service
	$(CMD_SERVICE_DEPLOY)
squibby.scale: ecs ## Change scale (`make squibby.scale SCALE=n`)
	$(CMD_SERVICE_SCALE)
squibby.destroy: confirm
	$(CMD_SERVICE_DESTROY)
squibby.secrets:
	$(CMD_SERVICE_SECRETS_PUSH)
squibby.up:
	$(CMD_SERVICE_LOCAL_UP)
squibby.down:
	$(CMD_SERVICE_LOCAL_DOWN)
####################################################################################################
# Serverless
krtek.install:
	$(CMD_SLS_SERVICE_INSTALL)
krtek.deploy:
	$(CMD_SLS_SERVICE_DEPLOY)
krtek.invoke:
	$(CMD_SLS_SERVICE_INVOKE)
krtek.destroy:
	$(CMD_SLS_SERVICE_DESTROY)
krtek.create_domain:
	$(CMD_SLS_SERVICE_CREATE_DOMAIN)
krtek.delete_domain:
	$(CMD_SLS_SERVICE_DELETE_DOMAIN)

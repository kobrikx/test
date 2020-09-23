#!/bin/bash
# ECS config
{
    echo "ECS_CLUSTER=${ecs_cluster_name}"
    echo "ECS_INSTANCE_ATTRIBUTES={\"service-group\":\"${service_group}\"}"
    echo "ECS_ENABLE_TASK_IAM_ROLE=true"
} >> /etc/ecs/ecs.config
start ecs
echo "Done"

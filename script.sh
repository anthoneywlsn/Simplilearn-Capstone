#!/bin/bash

set -euo pipefail

ROLE_ARN="arn:aws:iam::195879934828:role/ecsTaskExecutionRole"
echo "ROLE_ARN: ${ROLE_ARN}"

FAMILY="aetna-capstone-definition"
echo "FAMILY: ${FAMILY}"

NAME="simplilearn-aetna-container"
echo "NAME: ${NAME}"

task_json=$(cat task-template.json)
task_json="${task_json//CI_BUILD_NUMBER/${IMAGE_TAG}}"
task_json="${task_json//CI_REPOSITORY_URI/${REPOSITORY_URI}}"
task_json="${task_json//CI_ROLE_ARN/${ROLE_ARN}}"
task_json="${task_json//CI_FAMILY/${FAMILY}}"
task_json="${task_json//CI_NAME/${NAME}}"

echo "${task_json}" > task_definition.json

aws ecs register-task-definition --region="${AWS_DEFAULT_REGION}" --cli-input-json "${task_json}"

REVISION=$(aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq -r .taskDefinition.revision)
echo "REVISION: ${REVISION}"

aws ecs update-service --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${TASK_DEFINITION_NAME}":"${REVISION}" --desired-count "${DESIRED_COUNT}"


#!/bin/bash
# This is a comment. It is ignored by the system.
echo "Hello, World!"
              git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '1{p;q;}' 03_trigger/02_downstream)
              second_line=$(sed -n '2{p;q;}' 03_trigger/02_downstream)
              third_line=$(sed -n '3{p;q;}' 03_trigger/02_downstream)
              echo "$first_line"
              echo "$second_line"
              
              if [ "$second_line" == "aws" ]; then
              
              NEW_VAR="${first_line}_${second_line}.yaml"
              touch n8n-in/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/01_pipeline.yaml n8n-in/.github/workflows/"$NEW_VAR"
              sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              ls -la n8n-in/.github/workflows

              NEW_VAR_2="${first_line}_${second_line}_upstream"
              mkdir n8n-in/01_infra/01_aws/"$NEW_VAR_2"
              touch n8n-in/01_infra/01_aws/"$NEW_VAR_2"/provider.tf
              cp 02_template/aws/02_provider.yaml n8n-in/01_infra/01_aws/"$NEW_VAR_2"/provider.tf

              touch n8n-in/01_infra/01_aws/"$NEW_VAR_2"/terraform.tfvars
              cp 02_template/aws/03_terraform.tfvars n8n-in/01_infra/01_aws/"$NEW_VAR_2"/terraform.tfvars
              ls -la n8n-in/01_infra/01_aws/"$NEW_VAR_2"
              fi

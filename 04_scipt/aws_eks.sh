echo "Hello, World!"
              git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '1{p;q;}' 03_trigger/aws/03_eks)
              
              NEW_VAR="aws_eks_${first_line}.yaml"
              touch n8n-in/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/eks/app/01_pipeline.yaml n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_aws_eks"
              mkdir n8n-in/01_infra/01_aws/03_eks/"$NEW_VAR_2"
              touch n8n-in/01_infra/01_aws/03_eks/"$NEW_VAR_2"/provider.tf
              cp 02_template/aws/eks/app/02_provider.yaml n8n-in/01_infra/01_aws/03_eks/"$NEW_VAR_2"/provider.tf

              touch n8n-in/01_infra/01_aws/03_eks/"$NEW_VAR_2"/terraform.tfvars
              cp 02_template/aws/03_terraform.tfvars n8n-in/01_infra/01_aws/03_eks/"$NEW_VAR_2"/terraform.tfvars

              mkdir n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"
              touch n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/01_locals.tf
              cp 02_template/aws/eks/terraform/01_locals.tf n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/01_locals.tf

              touch n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/02_variables.tf
              cp 02_template/aws/eks/terraform/02_variables.tf n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/02_variables.tf

              touch n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/03_main.tf
              cp 02_template/aws/eks/terraform/03_main.tf n8n-in/02_temp/01_aws/03_eks/"$NEW_VAR_2"/03_main.tf

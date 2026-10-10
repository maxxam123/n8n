echo "Hello, World!"
              git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '1{p;q;}' 03_trigger/aws/02_vm)
              # second_line=$(sed -n '2{p;q;}' 03_trigger/aws/02_vm)
              # third_line=$(sed -n '3{p;q;}' 03_trigger/aws/02_vm)
              # fourth_line=$(sed -n '4{p;q;}' 03_trigger/aws/02_vm)
              
              NEW_VAR="aws_vm_${first_line}.yaml"
              touch n8n-in/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/vm/pipeline/pipeline.yaml n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_aws_vm"
              mkdir n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"
              touch n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/01_locals.tf
              cp 02_template/aws/vm/terraform/01_locals.tf n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/01_locals.tf

              touch n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/02_variables.tf
              cp 02_template/aws/vm/terraform/02_variables.tf n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/02_variables.tf
              
              touch n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/03_main.tf
              cp 02_template/aws/vm/terraform/03_main.tf n8n-in/01_infra/01_aws/02_vm/"$NEW_VAR_2"/03_main.tf

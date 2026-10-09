echo "Hello, World!"
              git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '1{p;q;}' 03_trigger/gcp/gvm)
              # second_line=$(sed -n '2{p;q;}' 03_trigger/aws/02_vm)
              # third_line=$(sed -n '3{p;q;}' 03_trigger/aws/02_vm)
              # fourth_line=$(sed -n '4{p;q;}' 03_trigger/aws/02_vm)
              
              NEW_VAR="gcp_gvm_${first_line}.yaml"
              touch n8n-in/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/01_pipeline.yaml n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/c"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_gcp_gvm"
              mkdir n8n-in/01_infra/02_gcp/02_gvm/"$NEW_VAR_2"
              touch n8n-in/01_infra/02_gcp/02_gvm/"$NEW_VAR_2"/provider.tf
              cp 02_template/aws/02_provider.yaml n8n-in/01_infra/02_gcp/02_gvm/"$NEW_VAR_2"/provider.tf

              touch n8n-in/01_infra/02_gcp/02_gvm/"$NEW_VAR_2"/terraform.tfvars
              cp 02_template/aws/03_terraform.tfvars n8n-in/01_infra/02_gcp/02_gvm/"$NEW_VAR_2"/terraform.tfvars

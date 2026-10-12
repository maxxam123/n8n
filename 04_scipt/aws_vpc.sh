echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/aws/01_vpc)
              second_line=$(sed -n '1{p;q;}' 03_trigger/aws/01_vpc)
              
              NEW_VAR="aws_vpc_${first_line}.yaml"
              touch ${second_line}/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/vpc/pipeline/pipeline.yaml ${second_line}/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_aws_vpc"
              cp locals.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/locals.tf
              
              cp 02_template/aws/vpc/terraform/03_main.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/main.tf

              cp 02_template/aws/vpc/terraform/04_provider.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/provider.tf

              ls -la
              ls -la ${second_line}
              ls -la ${second_line}/01-infra/aws/01_vpc/$NEW_VAR_2

echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '1{p;q;}' 03_trigger/aws/01_vpc)
              second_line=$(sed -n '2{p;q;}' 03_trigger/aws/01_vpc)
              
              NEW_VAR="aws_vpc_${first_line}.yaml"
              touch ${second_line}/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/vpc/pipeline/pipeline.yaml ${second_line}/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_aws_vpc"
              mkdir ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"
              touch ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/01_locals.tf
              cp 02_template/aws/vpc/terraform/01_locals.tf ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/01_locals.tf

              touch ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/02_variables.tf
              cp 02_template/aws/vpc/terraform/02_variables.tf ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/02_variables.tf

              touch ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/03_main.tf
              cp 02_template/aws/vpc/terraform/03_main.tf ${second_line}/01_infra/aws/01_vpc/"$NEW_VAR_2"/03_main.tf

              ls -la
              ls -la ${second_line}
              ls -la ${second_line}/01_infra/aws/o1_vpc/$NEW_VAR_2

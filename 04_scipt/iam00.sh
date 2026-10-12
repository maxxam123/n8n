echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/aws/01_iam)
              second_line=$(sed -n '1{p;q;}' 03_trigger/aws/01_iam)
              third_line=$(sed -n '3{p;q;}' 03_trigger/aws/01_iam)
              fourth_line=$(sed -n '4{p;q;}' 03_trigger/aws/01_iam)
              
              NEW_VAR="aws_iam_${first_line}.yaml"
              NEW_VAR_2="${first_line}_aws_iam"
              
              touch ${second_line}/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/iam/pipeline/pipeline.yaml ${second_line}/.github/workflows/"$NEW_VAR"
              sed -i "s/REPO2/$NEW_VAR_2/g" ${second_line}/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              mkdir ${second_line}/01-infra/aws/05_iam/"$NEW_VAR_2"
              ls -la ${second_line}/01-infra/aws/05_iam
              cp locals.tf ${second_line}/01-infra/aws/05_iam/"$NEW_VAR_2"/locals.tf
              
              cp 02_template/aws/iam/terraform/03_main.tf ${second_line}/01-infra/aws/05_iam/"$NEW_VAR_2"/main.tf

              cp 02_template/aws/iam/terraform/04_provider.tf ${second_line}/01-infra/aws/05_iam/"$NEW_VAR_2"/provider.tf
              sed -i "s/REPO/$third_line/g" "$second_line/01-infra/aws/05_iam/$NEW_VAR_2/provider.tf"
              sed -i "s/BUCKET/${fourth_line}/g" ${second_line}/01-infra/aws/05_iam/"$NEW_VAR_2"/provider.tf

              ls -la
              ls -la ${second_line}
              ls -la ${second_line}/01-infra/aws/05_iam/$NEW_VAR_2

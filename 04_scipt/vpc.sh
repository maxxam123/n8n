
              repo=$(sed -n '1{p;q;}' 03_trigger/vpc)
              provider=$(sed -n '2{p;q;}' 03_trigger/vpc)
              SVC=$(sed -n '3{p;q;}' 03_trigger/vpc)
              customer=$(sed -n '4{p;q;}' 03_trigger/vpc)
              environment=$(sed -n '5{p;q;}' 03_trigger/vpc)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/vpc)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/vpc)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/vpc)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/vpc)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/vpc)
              TAG=$(sed -n '11{p;q;}' 03_trigger/vpc)
              NUMBER=$(sed -n '12{p;q;}' 03_trigger/vpc)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              # cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/
              cp -r $SOUR_01/* $DEST_01/
              # cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/terragrunt.hcl $DEST_02
              # cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $DEST_02
              # sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl
              sed -i "s/ENV/$environment/g" $DEST_02/env.hcl


                echo "HIT HIT"
                sed -i "s|SUB_PRI_01|$SUB_PR_01|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
                sed -i "s|SUB_PRI_02|$SUB_PR_02|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
                sed -i "s|SUB_PUB_01|$SUB_PU_01|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
                sed -i "s|SUB_PUB_02|$SUB_PU_02|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
                sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
                sed -i "s|ENV|$environment|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl


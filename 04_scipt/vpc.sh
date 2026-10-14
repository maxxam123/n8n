
              repo=$(sed -n '1{p;q;}' 03_trigger/mdls)
              provider=$(sed -n '2{p;q;}' 03_trigger/mdls)
              SVC=$(sed -n '3{p;q;}' 03_trigger/mdls)
              customer=$(sed -n '4{p;q;}' 03_trigger/mdls)
              environment=$(sed -n '5{p;q;}' 03_trigger/mdls)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/mdls)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/mdls)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/mdls)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/mdls)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/mdls)
              TAG=$(sed -n '11{p;q;}' 03_trigger/mdls)
              INSTANCE=$(sed -n '12{p;q;}' 03_trigger/mdls)
              AMI=$(sed -n '13{p;q;}' 03_trigger/mdls)
              VER=$(sed -n '14{p;q;}' 03_trigger/mdls)
              NAME=$(sed -n '15{p;q;}' 03_trigger/mdls)
              MACHINE=$(sed -n '16{p;q;}' 03_trigger/mdls)
              DES_SIZE=$(sed -n '17{p;q;}' 03_trigger/mdls)
              MAX_SIZE=$(sed -n '18{p;q;}' 03_trigger/mdls)
              MIN_SIZE=$(sed -n '19{p;q;}' 03_trigger/mdls)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC

              cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/
              cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl

              if [ "$SVC" == "vpc" ]
              then
                echo "HIT HIT"

                sed -i "s|SUB_PRI_01|$SUB_PR_01|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|SUB_PRI_02|$SUB_PR_02|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|SUB_PUB_01|$SUB_PU_01|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|SUB_PUB_02|$SUB_PU_02|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|ENV|$environment|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
              fi

              if [ "$SVC" == "ec2" ]
              then
                echo "HIT HIT"
                sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|INSTANCE|$INSTANCE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|AMI|$AMI|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
              fi

              if [ "$SVC" == "eks" ]
              then
                echo "HIT HIT"
                sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|VER|$VER|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|NAME|$NAME|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|MACHINE|$MACHINE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|DES_SIZE|$DES_SIZE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|MAX_SIZE|$MAX_SIZE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|MIN_SIZE|$MIN_SIZE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
              fi

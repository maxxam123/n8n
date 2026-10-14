
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

              # mkdir $repo/02_modules/$provider/module-$SVC/$customer
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}

              # cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              # cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              


              repo=$(sed -n '1{p;q;}' 03_trigger/ec2)
              provider=$(sed -n '2{p;q;}' 03_trigger/ec2)
              SVC=$(sed -n '3{p;q;}' 03_trigger/ec2)
              customer=$(sed -n '4{p;q;}' 03_trigger/ec2)
              environment=$(sed -n '5{p;q;}' 03_trigger/ec2)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/ec2)
              TAG=$(sed -n '7{p;q;}' 03_trigger/ec2)
              INSTANCE=$(sed -n '8{p;q;}' 03_trigger/ec2)
              AMI=$(sed -n '9{p;q;}' 03_trigger/ec2)


              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC

              cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/
              cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl

 

                echo "HIT HIT"
                sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|INSTANCE|$INSTANCE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl
                sed -i "s|AMI|$AMI|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/terragrunt.hcl

              # mkdir $repo/02_modules/$provider/module-$SVC/$customer
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}

              # cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              # cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              

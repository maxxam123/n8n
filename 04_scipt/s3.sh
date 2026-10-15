
              repo=$(sed -n '1{p;q;}' 03_trigger/s3)
              provider=$(sed -n '2{p;q;}' 03_trigger/s3)
              SVC=$(sed -n '3{p;q;}' 03_trigger/s3)
              customer=$(sed -n '4{p;q;}' 03_trigger/s3)
              environment=$(sed -n '5{p;q;}' 03_trigger/s3)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/s3)
              TAG=$(sed -n '7{p;q;}' 03_trigger/s3)
              INSTANCE=$(sed -n '8{p;q;}' 03_trigger/s3)
              AMI=$(sed -n '9{p;q;}' 03_trigger/s3)
              NUMBER=$(sed -n '10{p;q;}' 03_trigger/s3)


              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              # cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/
              cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $DEST_01/
              # cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/terragrunt.hcl $DEST_02
              cp -u 02_template/aws_mdls/env.hcl $DEST_02
              sed -i "s/ENV/$environment/g" $DEST_02/env.hcl

              # sed -i "s|TAG|$TAG|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
              # sed -i "s|INSTANCE|$INSTANCE|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl
              # sed -i "s|AMI|$AMI|g" $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/terragrunt.hcl

              echo "HIT HIT"
              # sed -i "s|TAG|$TAG|g" $DEST_01/terragrunt.hcl
              # sed -i "s|INSTANCE|$INSTANCE|g" $DEST_01/terragrunt.hcl
              # sed -i "s|AMI|$AMI|g" $DEST_01/terragrunt.hcl

              # mkdir $repo/02_modules/$provider/module-$SVC/$customer
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}

              # cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              # cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              

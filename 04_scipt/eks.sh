
              repo=$(sed -n '1{p;q;}' 03_trigger/eks)
              provider=$(sed -n '2{p;q;}' 03_trigger/eks)
              SVC=$(sed -n '3{p;q;}' 03_trigger/eks)
              customer=$(sed -n '4{p;q;}' 03_trigger/eks)
              environment=$(sed -n '5{p;q;}' 03_trigger/eks)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/eks)
              TAG=$(sed -n '7{p;q;}' 03_trigger/eks)
              VER=$(sed -n '8{p;q;}' 03_trigger/eks)
              NAME=$(sed -n '9{p;q;}' 03_trigger/eks)
              MACHINE=$(sed -n '10{p;q;}' 03_trigger/eks)
              DES_SIZE=$(sed -n '11{p;q;}' 03_trigger/eks)
              MAX_SIZE=$(sed -n '12{p;q;}' 03_trigger/eks)
              MIN_SIZE=$(sed -n '13{p;q;}' 03_trigger/eks)
              NUMBER=$(sed -n '14{p;q;}' 03_trigger/eks)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              # cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/
              cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $DEST_01/
              cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl

                echo "HIT HIT"
                sed -i "s|TAG|$TAG|g" $DEST_01/terragrunt.hcl
                sed -i "s|VER|$VER|g" $DEST_01/terragrunt.hcl
                sed -i "s|NAME|$NAME|g" $DEST_01/terragrunt.hcl
                sed -i "s|MACHINE|$MACHINE|g" $DEST_01/terragrunt.hcl
                sed -i "s|DES_SIZE|$DES_SIZE|g" $DEST_01/terragrunt.hcl
                sed -i "s|MAX_SIZE|$MAX_SIZE|g" $DEST_01/terragrunt.hcl
                sed -i "s|MIN_SIZE|$MIN_SIZE|g" $DEST_01/terragrunt.hcl

              # mkdir $repo/02_modules/$provider/module-$SVC/$customer
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}

              # cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              # cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              

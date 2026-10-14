
              repo=$(sed -n '1{p;q;}' 03_trigger/tgwa)
              provider=$(sed -n '2{p;q;}' 03_trigger/tgwa)
              SVC=$(sed -n '3{p;q;}' 03_trigger/tgwa)
              customer=$(sed -n '4{p;q;}' 03_trigger/tgwa)
              environment=$(sed -n '5{p;q;}' 03_trigger/tgwa)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/tgwa)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC

              cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC/
              cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl


              # mkdir $repo/02_modules/$provider/module-$SVC/$customer
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}

              # cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              # cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              

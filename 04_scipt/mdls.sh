echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              repo=$(sed -n '1{p;q;}' 03_trigger/mdls)
              provider=$(sed -n '2{p;q;}' 03_trigger/mdls)
              SVC=$(sed -n '3{p;q;}' 03_trigger/mdls)
              customer=$(sed -n '4{p;q;}' 03_trigger/mdls)

              ls -la
              ls -la $repo
              ls -la $repo/02_modules
              ls -la $repo/02_modules/$provider
              ls -la $repo/02_modules/$provider/module-$SVC

              mkdir $repo/02_modules/$provider/module-$SVC/$customer
              mkdir -p $repo/02_modules/$provider/module-$SVC/$customer/{infrastructure-module,infrastructure-live}
              # mkdir $repo/02_modules/$providermodule-$SVC/$customer/infrastructure-module
              # mkdir $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live
              mkdir $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/{prod,dev}
              # mkdir $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              # mkdir $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev

              cp -r 02_template/aws_mdls/$SVC/environment/dev/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/dev
              cp -r 02_template/aws_mdls/$SVC/environment/prod/$SVC/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-live/prod
              cp -r 02_template/aws_mdls/$SVC/module/* $repo/02_modules/$provider/module-$SVC/$customer/infrastructure-module
              ls -la $repo/02_modules/$provider/module-$SVC/$customer//infrastructure-live
              ls -la $repo/02_modules/$provider/module-$SVC/$customer//infrastructure-module
              

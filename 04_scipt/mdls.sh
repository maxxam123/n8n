echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/mdls)
              second_line=$(sed -n '1{p;q;}' 03_trigger/mdls)
              third_line=$(sed -n '3{p;q;}' 03_trigger/mdls)
              fourth_line=$(sed -n '4{p;q;}' 03_trigger/mdls)
              fifth_line=$(sed -n '5{p;q;}' 03_trigger/mdls)
              customer=$(sed -n '6{p;q;}' 03_trigger/mdls)

              ls -la
              ls -la $second_line
              ls -la $second_line/02_modules
              ls -la $second_line/02_modules/$first_line
              ls -la $second_line/02_modules/$first_line/$third_line

              mkdir $second_line/02_modules/$first_line/$third_line/$customer
              mkdir $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-module
              mkdir $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-live
              mkdir $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-live/prod
              mkdir $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-live/dev

              cp -r 02_template/aws_mdls/$fifth_line/environment/dev/$fifth_line/* $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-live/dev
              cp -r 02_template/aws_mdls/$fifth_line/environment/prod/$fifth_line/* $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-live/prod
              cp -r 02_template/aws_mdls/$fifth_line/module/* $second_line/02_modules/$first_line/$third_line/$customer/infrastructure-module
              ls -la $second_line/02_modules/$first_line/$third_line/$customer//infrastructure-live
              ls -la $second_line/02_modules/$first_line/$third_line/$customer//infrastructure-module
              

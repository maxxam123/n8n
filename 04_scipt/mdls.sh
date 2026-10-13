echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/mdls)
              second_line=$(sed -n '1{p;q;}' 03_trigger/mdls)
              third_line=$(sed -n '3{p;q;}' 03_trigger/mdls)
              fourth_line=$(sed -n '4{p;q;}' 03_trigger/mdls)

              ls -la
              ls -la $second_line
              ls -la $second_line/02_modules
              ls -la $second_line/02_modules/$first_line
              ls -la $second_line/02_modules/$first_line/$third_line
              
              mkdir $second_line/02_modules/$first_line/$third_line/infrasructure-module
              mkdir $second_line/02_modules/$first_line/$third_line/infrasructure-live

              cp r 02_template/aws/aws_modules/environment/* $second_line/02_modules/$first_line/$third_line/infrasructure-live
              cp r 02_template/aws/aws_modules/module/* $second_line/02_modules/$first_line/$third_line/infrasructure-module
              ls -la $second_line/02_modules/$first_line/$third_line/infrasructure-live
              ls -la $second_line/02_modules/$first_line/$third_line/infrasructure-module
              

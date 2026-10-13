echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/aws/01_iam)
              second_line=$(sed -n '1{p;q;}' 03_trigger/aws/01_iam)
              third_line=$(sed -n '3{p;q;}' 03_trigger/aws/01_iam)
              fourth_line=$(sed -n '4{p;q;}' 03_trigger/aws/01_iam)

              ls -la
              ls -la $second_line
              ls -la $second_line/02_modules
              ls -la $second_line/02_modules/$first_line
              ls -la $second_line/02_modules/$first_line/$third_line


              repo=$(sed -n '1{p;q;}' 03_trigger/iam)
              provider=$(sed -n '2{p;q;}' 03_trigger/iam)
              SVC=$(sed -n '3{p;q;}' 03_trigger/iam)
              customer=$(sed -n '4{p;q;}' 03_trigger/iam)
              environment=$(sed -n '5{p;q;}' 03_trigger/iam)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/iam)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/iam)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/iam)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/iam)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/iam)
              TAG=$(sed -n '11{p;q;}' 03_trigger/iam)
              NUMBER=$(sed -n '12{p;q;}' 03_trigger/iam)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon
              cp -u $SOUR_02/account.hcl $repo/02_modules/$provider/$environment/$customer/_envcommon/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_envcommon

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/account/
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/account/iam-roles
              cp -u 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/_global/account/iam-roles/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_global

              # cp -r 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER/
              cp -r $SOUR_01/* $DEST_01/
              # cp -u 02_template/aws_mdls/terragrunt.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u $SOUR_02/terragrunt.hcl $DEST_02
              # cp -u 02_template/aws_mdls/env.hcl $repo/02_modules/$provider/$environment/$customer
              cp -u 02_template/aws_mdls/env.hcl $DEST_02
              # sed -i "s/ENV/$environment/g" $repo/02_modules/$provider/$environment/$customer/env.hcl
              sed -i "s/ENV/$environment/g" $DEST_02/env.hcl

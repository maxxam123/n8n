
              repo=$(sed -n '1{p;q;}' 03_trigger/budgets)
              provider=$(sed -n '2{p;q;}' 03_trigger/budgets)
              SVC=$(sed -n '3{p;q;}' 03_trigger/budgets)
              customer=$(sed -n '4{p;q;}' 03_trigger/budgets)
              environment=$(sed -n '5{p;q;}' 03_trigger/budgets)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/budgets)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/budgets)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/budgets)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/budgets)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/budgets)
              TAG=$(sed -n '11{p;q;}' 03_trigger/budgets)
              NUMBER=$(sed -n '12{p;q;}' 03_trigger/budgets)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon/billing-and-budgets
              cp -u $SOUR_02/budgets.hcl $repo/02_modules/$provider/$environment/$customer/_envcommon/billing-and-budgets/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_envcommon

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/billing-and-budgets/
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/billing-and-budgets/budgets-$NUMBER
              cp -u 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/_global/billing-and-budgets/budgets-$NUMBER/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_global

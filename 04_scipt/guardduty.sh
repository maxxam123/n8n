
              repo=$(sed -n '1{p;q;}' 03_trigger/guardduty)
              provider=$(sed -n '2{p;q;}' 03_trigger/guardduty)
              SVC=$(sed -n '3{p;q;}' 03_trigger/guardduty)
              customer=$(sed -n '4{p;q;}' 03_trigger/guardduty)
              environment=$(sed -n '5{p;q;}' 03_trigger/guardduty)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/guardduty)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/guardduty)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/guardduty)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/guardduty)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/guardduty)
              TAG=$(sed -n '11{p;q;}' 03_trigger/guardduty)
              NUMBER=$(sed -n '12{p;q;}' 03_trigger/guardduty)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon/security
              cp -u $SOUR_02/guardduty.hcl $repo/02_modules/$provider/$environment/$customer/_envcommon/security/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_envcommon

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/security/
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/security/guardduty-$NUMBER
              cp -u 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/_global/security/guardduty-$NUMBER/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_global

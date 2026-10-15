
              repo=$(sed -n '1{p;q;}' 03_trigger/cloudfront)
              provider=$(sed -n '2{p;q;}' 03_trigger/cloudfront)
              SVC=$(sed -n '3{p;q;}' 03_trigger/cloudfront)
              customer=$(sed -n '4{p;q;}' 03_trigger/cloudfront)
              environment=$(sed -n '5{p;q;}' 03_trigger/cloudfront)
              CATEGORY=$(sed -n '6{p;q;}' 03_trigger/cloudfront)
              SUB_PR_01=$(sed -n '7{p;q;}' 03_trigger/cloudfront)
              SUB_PR_02=$(sed -n '8{p;q;}' 03_trigger/cloudfront)
              SUB_PU_01=$(sed -n '9{p;q;}' 03_trigger/cloudfront)
              SUB_PU_02=$(sed -n '10{p;q;}' 03_trigger/cloudfront)
              TAG=$(sed -n '11{p;q;}' 03_trigger/cloudfront)
              NUMBER=$(sed -n '12{p;q;}' 03_trigger/cloudfront)

              mkdir -p $repo/02_modules/$provider/$environment/$customer
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY
              mkdir -p $repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER

              DEST_01=$repo/02_modules/$provider/$environment/$customer/$CATEGORY/$SVC-$NUMBER
              DEST_02=$repo/02_modules/$provider/$environment/$customer
              SOUR_01=02_template/aws_mdls/$SVC/environment/$environment/$SVC
              SOUR_02=02_template/aws_mdls

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_envcommon/cdn
              cp -u $SOUR_02/cloudfront.hcl $repo/02_modules/$provider/$environment/$customer/_envcommon/cdn/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_envcommon

              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/cdn/
              mkdir -p $repo/02_modules/$provider/$environment/$customer/_global/cdn/cloudfront-$NUMBER
              cp -u 02_template/aws_mdls/$SVC/environment/$environment/$SVC/* $repo/02_modules/$provider/$environment/$customer/_global/cdn/cloudfront-$NUMBER/
              echo "INPUT"
              ls -la $repo/02_modules/$provider/$environment/$customer/
              ls -la $repo/02_modules/$provider/$environment/$customer/_global

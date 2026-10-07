#!/bin/bash
# This is a comment. It is ignored by the system.
echo "Hello, World!"
              first_line=$(sed -n '1{p;q;}' 03_trigger/02_downstream)
              second_line=$(sed -n '2{p;q;}' 03_trigger/02_downstream)
              echo "$first_line"
              echo "$second_line"
              
              NEW_VAR="${first_line}_${second_line}.yaml"
              touch n8n-in/.github/workflows/"$NEW_VAR"
              cp 02_template/01_pipeline.yaml n8n-in/.github/workflows/"$NEW_VAR"
              sed -i "s/AAA/$first_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              ls -la n8n-in/.github/workflows

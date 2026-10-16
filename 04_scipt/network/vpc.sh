#!/usr/bin/env bash
set -euo pipefail

echo "$GLOBAL_FIRST_LINE"
echo "$GLOBAL_SRV_01"
echo "$GLOBAL_CATE"

# TRIGGER_FILE="03_trigger/network/vpc" #  /network/vpc
TRIGGER_FILE="03_trigger/$GLOBAL_CATE/$GLOBAL_SRV_01" #  /network/vpc

if [[ ! -f "$TRIGGER_FILE" ]]; then
    echo "Error: Trigger file '$TRIGGER_FILE' not found." >&2
    exit 1
fi

# 1. Read all 12 positional lines into memory at once
mapfile -t lines < <(tr -d '\r' < "$TRIGGER_FILE")

REPO="${lines[0]}"
PROVIDER="${lines[1]}"
SVC="${lines[2]}"
CUSTOMER="${lines[3]}"
ENVIRONMENT="${lines[4]}"
CATEGORY="${lines[5]}"
NUMBER="${lines[6]}"
TAG="${lines[7]}"

ONE="${lines[8]}"
TWO="${lines[9]}"
THREE="${lines[10]}"

# 2. Define clean destination and source variables
DEST_02="$REPO/02_modules/$PROVIDER/$CUSTOMER"
DEST_01="$DEST_02/$ENVIRONMENT/$CATEGORY/$SVC-$NUMBER"
ENV_COMMON="$DEST_02/_envcommon/$CATEGORY"

SOUR_02="02_template/aws_mdls/$CATEGORY/$SVC"

# 3. Create structure and copy baseline config files
mkdir -p "$DEST_01" "$ENV_COMMON"

cp -u "$SOUR_02/$SVC.hcl" "$ENV_COMMON/"

echo "INPUT"
ls -la "$DEST_02/" "$ENV_COMMON/"

cp -r "$SOUR_02/terragrunt.hcl" "$DEST_01/"
cp -u "02_template/aws_mdls/env.hcl" "$DEST_02/"
cp -u "02_template/aws_mdls/terragrunt.hcl" "$DEST_02/"

# 4. Perform dynamic template string updates efficiently
sed -i "s/ENV/$ENVIRONMENT/g" "$DEST_02/env.hcl"

if [[ "$SVC" == "vpc" ]]; then
    sed -i "s|VPC_NAME|$ONE|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|VPC_CIDR|$TWO|g" "$DEST_01/terragrunt.hcl"
    
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
fi
if [[ "$SVC" == "tgw" ]]; then
    sed -i "s|SPOKE_01|$TWO|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|SPOKE_02|$THREE|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|TGW_NAME|$ONE|g" "$ENV_COMMON/$SVC.hcl"
fi
if [[ "$SVC" == "tgwa" ]]; then
    sed -i "s|TGW_NAME|$ONE|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|TGWA_NAME|$TWO|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|VPC_NAME|$THREE|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
fi
if [[ "$SVC" == "ec2" ]]; then
    sed -i "s|ENV|$ONE|g" "$DEST_01/terragrunt.hcl"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
fi
if [[ "$SVC" == "eks" ]]; then
    sed -i "s|TAG|$TAG|g" "$DEST_01/terragrunt.hcl"
fi
if [[ "$SVC" == "s3" ]]; then
    sed -i "s|TAG|$TAG|g" "$DEST_01/terragrunt.hcl"
fi
if [[ "$SVC" == "rds" ]]; then
    sed -i "s|TAG|$TAG|g" "$DEST_01/terragrunt.hcl"
fi



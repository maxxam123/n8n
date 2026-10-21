#!/usr/bin/env bash
set -euo pipefail

echo "$GLOBAL_FIRST_LINE"
echo "$GLOBAL_SRV_01"
echo "$GLOBAL_CATE"

# TRIGGER_FILE="03_trigger/network/vpc" #  /network/vpc
TRIGGER_FILE="03_trigger/$GLOBAL_SRV_01/$GLOBAL_SRV_01" #  /network/vpc

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

SOUR_02="02_template/aws_mdls/$CATEGORY/$SVC"

mkdir -p "$REPO/management/"
mkdir -p "$REPO/management/_global"
mkdir -p "$REPO/management/_global/$SVC"
DEST_01="$REPO/managment/_global"

# cp -n "02_template/aws_mdls/account.hcl" "$REPO/02_modules/$PROVIDER/$CUSTOMER/$ENVIRONMENT/"
# cp -n "02_template/aws_mdls/region.hcl" "$REPO/02_modules/$PROVIDER/$CUSTOMER/$ENVIRONMENT/"

# cp -n "02_template/aws_mdls/common.hcl" "$REPO/02_modules/$PROVIDER/$CUSTOMER/"

# cp -u "$SOUR_02/$SVC.hcl" "$ENV_COMMON/"

echo "INPUT"

cp -r "$SOUR_02/terragrunt.hcl" "$DEST_01/$SVC/"
# cp -u "02_template/aws_mdls/env.hcl" "$DEST_02/"
# cp -u "02_template/aws_mdls/terragrunt.hcl" "$DEST_02/"


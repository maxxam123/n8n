#!/usr/bin/env bash
set -euo pipefail

echo "$GLOBAL_FIRST_LINE"
echo "$GLOBAL_SRV_01"
echo "$GLOBAL_CATE"

TRIGGER_FILE="03_trigger/$GLOBAL_CATE/$GLOBAL_SRV_01"
# TRIGGER_FILE="03_trigger/global/iam-roles"

if [[ ! -f "$TRIGGER_FILE" ]]; then
    echo "Error: Trigger file '$TRIGGER_FILE' not found." >&2
    exit 1
fi

# 1. Read all 12 positional lines into memory at once and clean up format
mapfile -t lines < <(tr -d '\r' < "$TRIGGER_FILE")

repo="${lines[0]}"
provider="${lines[1]}"
SVC="${lines[2]}"
customer="${lines[3]}"
environment="${lines[4]}"
CATEGORY="${lines[5]}"
NUMBER="${lines[6]}"
CATE="${lines[7]}"
TAG="${lines[8]}"
UNDER_CAT="${lines[9]}"

ONE="${lines[9]}"

# 2. Define consolidated base and destination paths
DEST_02="$repo/02_modules/$provider/$customer"
DEST_01="$DEST_02/$CATEGORY/$SVC-$NUMBER"
ENV_COMMON="$DEST_02/_envcommon/$CATE"
# ENV_COMMON="$DEST_02/_envcommon/account"
GLOBAL_DIR="$DEST_02/_global/$CATE/$SVC-$NUMBER"
# GLOBAL_DIR="$DEST_02/_global/account/iam-roles-$NUMBER"

SOUR_01="02_template/aws_mdls/$CATEGORY/$UNDER_CAT/$SVC"
SOUR_02="02_template/aws_mdls/$CATEGORY/$UNDER_CAT/$SVC"


# 3. Create target directory structures
mkdir -p "$DEST_01" "$ENV_COMMON" "$GLOBAL_DIR"

# 4. Copy baseline environment-common configuration
cp -u "$SOUR_02/$SVC.hcl" "$ENV_COMMON/"

echo "INPUT"
ls -la "$DEST_02/"
ls -la "$DEST_02/_envcommon"

# 5. Populate global account IAM templates
cp -u "$SOUR_01"/terragrunt.hcl "$GLOBAL_DIR/"

if [[ "$SVC" == "iam-roles" ]]; then
    echo "iam-roles"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|ROLE_NAME|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi

if [[ "$SVC" == "cloudtrail" ]]; then
    echo "cloudtrail"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|BUCKET_NAME|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi

if [[ "$SVC" == "guardduty" ]]; then
    echo "guardduty"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|BUCKET_NAME|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi

if [[ "$SVC" == "cloudfront" ]]; then
    echo "cloudfront"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|PATH_ALB|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi

if [[ "$SVC" == "route53" ]]; then
    echo "route53"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|PATH_VPC|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi

if [[ "$SVC" == "budgets" ]]; then
    echo "budgets"
    sed -i "s|TAG|$TAG|g" "$ENV_COMMON/$SVC.hcl"
    sed -i "s|BUDGETS_ACCOUNT|$ONE|g" "$GLOBAL_DIR/terragrunt.hcl"
fi


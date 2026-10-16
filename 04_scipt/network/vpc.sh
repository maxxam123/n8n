#!/usr/bin/env bash
set -euo pipefail

ls -la ${{ env.GLOBAL_FIRST_LINE }}

TRIGGER_FILE="03_trigger/network/vpc"

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
SUB_PR_01="${lines[6]}"
SUB_PR_02="${lines[7]}"
SUB_PU_01="${lines[8]}"
SUB_PU_02="${lines[9]}"
TAG="${lines[10]}"
NUMBER="${lines[11]}"

# 2. Define clean destination and source variables
DEST_02="$REPO/02_modules/$PROVIDER/$CUSTOMER"
DEST_01="$DEST_02/$ENVIRONMENT/$CATEGORY/$SVC-$NUMBER"
ENV_COMMON="$DEST_02/_envcommon/network"

SOUR_02="02_template/aws_mdls/network/$SVC"

# 3. Create structure and copy baseline config files
mkdir -p "$DEST_01" "$ENV_COMMON"

cp -u "$SOUR_02/vpc.hcl" "$ENV_COMMON/"

echo "INPUT"
ls -la "$DEST_02/" "$ENV_COMMON/"

cp -r "$SOUR_02/terragrunt.hcl" "$DEST_01/"
cp -u "$SOUR_02/terragrunt.hcl" "$DEST_02/"
cp -u "02_template/aws_mdls/env.hcl" "$DEST_02/"

# 4. Perform dynamic template string updates efficiently
sed -i "s/ENV/$ENVIRONMENT/g" "$DEST_02/env.hcl"

echo "HIT HIT"
sed -i \
  -e "s|SUB_PRI_01|$SUB_PR_01|g" \
  -e "s|SUB_PRI_02|$SUB_PR_02|g" \
  -e "s|SUB_PUB_01|$SUB_PU_01|g" \
  -e "s|SUB_PUB_02|$SUB_PU_02|g" \
  -e "s|TAG|$TAG|g" \
  -e "s|ENV|$ENVIRONMENT|g" \
  "$DEST_01/terragrunt.hcl"

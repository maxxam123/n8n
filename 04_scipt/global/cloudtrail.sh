#!/usr/bin/env bash
set -euo pipefail

TRIGGER_FILE="03_trigger/global/cloudtrail"

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

# 2. Define consolidated base and destination paths
DEST_02="$repo/02_modules/$provider/$customer"
DEST_01="$DEST_02/$CATEGORY/$SVC-$NUMBER"
ENV_COMMON="$DEST_02/_envcommon/security"
GLOBAL_DIR="$DEST_02/_global/security/cloudtrail-$NUMBER"

SOUR_01="02_template/aws_mdls/$SVC"
SOUR_02="02_template/aws_mdls/$SVC"

# 3. Create target directory structures
mkdir -p "$DEST_01" "$ENV_COMMON" "$GLOBAL_DIR"

# 4. Copy baseline environment-common configuration
cp -u "$SOUR_02/iam-roles.hcl" "$ENV_COMMON/"

echo "INPUT"
ls -la "$DEST_02/"
ls -la "$DEST_02/_envcommon"

# 5. Populate global account IAM templates
cp -u "$SOUR_01"/terragrunt.hcl "$GLOBAL_DIR/"

#!/usr/bin/env bash

# Week 7 - Azure Security Posture Audit
# Read-only Azure audit. This script never modifies Azure resources.

set -u
set -o pipefail

FULL_NAME="Matthew Bardi"
REPORT_FILE="audit-report.txt"

NSG_RG="bookreview-rg"
VM_RG="bookreview-rg"
MYSQL_RG="bookreview-rg"
STORAGE_RG="mini-finance-rg"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# Write all normal script output to both terminal and report.
exec > >(tee "$REPORT_FILE") 2>&1

record_result() {
    local status="$1"
    local check="$2"

    case "$status" in
        PASS)
            PASS_COUNT=$((PASS_COUNT + 1))
            ;;
        WARN)
            WARN_COUNT=$((WARN_COUNT + 1))
            ;;
        FAIL)
            FAIL_COUNT=$((FAIL_COUNT + 1))
            ;;
    esac

    echo "[$status] $check"
}

port_is_sensitive() {
    local port="${1:-}"

    case "$port" in
        "*"|"22"|"3389")
            return 0
            ;;
    esac

    if [[ "$port" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        local start="${BASH_REMATCH[1]}"
        local end="${BASH_REMATCH[2]}"

        if (( start <= 22 && end >= 22 )); then
            return 0
        fi

        if (( start <= 3389 && end >= 3389 )); then
            return 0
        fi
    fi

    return 1
}

echo "============================================================"
echo "Azure Security Posture Audit"
echo "Full Name: $FULL_NAME"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "============================================================"
echo

# Verify Azure authentication without displaying subscription or tenant IDs.
if ! SUBSCRIPTION_NAME=$(az account show --query name -o tsv 2>/dev/null); then
    echo "Azure CLI authentication could not be verified."
    echo "Audit cannot safely continue."
    exit 1
fi

echo "Azure subscription: $SUBSCRIPTION_NAME"
echo

# -------------------------------------------------------------------
# CHECK 1 - NSG rules exposing SSH/RDP to the Internet
# Read-only commands:
#   az network nsg list
#   az network nsg rule list
# -------------------------------------------------------------------
check_nsg_exposure() {
    echo "------------------------------------------------------------"
    echo "CHECK 1 - NSG SSH/RDP Internet Exposure"
    echo "------------------------------------------------------------"

    local nsgs
    if ! nsgs=$(az network nsg list \
        --resource-group "$NSG_RG" \
        --query "[].name" \
        --output tsv 2>/dev/null); then

        echo "Evidence: Unable to read NSGs in $NSG_RG."
        record_result "WARN" "NSG SSH/RDP exposure"
        echo
        return
    fi

    if [[ -z "$nsgs" ]]; then
        echo "Evidence: No NSGs found in $NSG_RG."
        record_result "WARN" "NSG SSH/RDP exposure"
        echo
        return
    fi

    local exposed=0
    local unreadable=0

    while IFS= read -r nsg; do
        [[ -z "$nsg" ]] && continue

        echo "NSG inspected: $nsg"

        local rules
        if ! rules=$(az network nsg rule list \
            --resource-group "$NSG_RG" \
            --nsg-name "$nsg" \
            --query "[?direction=='Inbound' && access=='Allow'].[name,sourceAddressPrefix,destinationPortRange,priority]" \
            --output tsv 2>/dev/null); then

            echo "  Evidence: Rules could not be read."
            unreadable=1
            continue
        fi

        while IFS=$'\t' read -r rule source port priority; do
            [[ -z "${rule:-}" ]] && continue

            if [[ "$source" == "0.0.0.0/0" ||
                  "$source" == "::/0" ||
                  "$source" == "*" ||
                  "$source" == "Internet" ]]; then

                if port_is_sensitive "$port"; then
                    echo "  OPEN RULE: $rule | Source=$source | Port=$port | Priority=$priority"
                    exposed=1
                fi
            fi
        done <<< "$rules"
    done <<< "$nsgs"

    if (( exposed == 1 )); then
        echo "Evidence: At least one inbound rule exposes SSH/RDP to the Internet."
        record_result "FAIL" "NSG SSH/RDP exposure"
    elif (( unreadable == 1 )); then
        echo "Evidence: Some NSG rules could not be inspected."
        record_result "WARN" "NSG SSH/RDP exposure"
    else
        echo "Evidence: No inbound SSH/RDP rule open to 0.0.0.0/0, ::/0, Internet, or * was found."
        record_result "PASS" "NSG SSH/RDP exposure"
    fi

    echo
}

# -------------------------------------------------------------------
# CHECK 2 - Storage Account public blob access
# Read-only command:
#   az storage account list
# -------------------------------------------------------------------
check_storage_public_access() {
    echo "------------------------------------------------------------"
    echo "CHECK 2 - Storage Account Public Blob Access"
    echo "------------------------------------------------------------"

    local accounts
    if ! accounts=$(az storage account list \
        --resource-group "$STORAGE_RG" \
        --query "[].[name,allowBlobPublicAccess,publicNetworkAccess]" \
        --output tsv 2>/dev/null); then

        echo "Evidence: Unable to read Storage Accounts in $STORAGE_RG."
        record_result "WARN" "Storage Account public blob access"
        echo
        return
    fi

    if [[ -z "$accounts" ]]; then
        echo "Evidence: No Storage Accounts found in $STORAGE_RG."
        record_result "WARN" "Storage Account public blob access"
        echo
        return
    fi

    local public_allowed=0
    local unknown=0

    while IFS=$'\t' read -r account allow_blob public_network; do
        [[ -z "${account:-}" ]] && continue

        local normalized="${allow_blob,,}"

        echo "Storage Account: $account"
        echo "  allowBlobPublicAccess: ${allow_blob:-Unknown}"
        echo "  publicNetworkAccess: ${public_network:-Unknown}"

        case "$normalized" in
            false)
                ;;
            true)
                public_allowed=1
                ;;
            *)
                unknown=1
                ;;
        esac
    done <<< "$accounts"

    if (( public_allowed == 1 )); then
        echo "Evidence: At least one account permits blob public access at the account level."
        echo "Container-level anonymous exposure is not assumed without evidence."
        record_result "WARN" "Storage Account public blob access"
    elif (( unknown == 1 )); then
        echo "Evidence: Public blob access configuration could not be determined for every account."
        record_result "WARN" "Storage Account public blob access"
    else
        echo "Evidence: Blob public access is disabled at the Storage Account level."
        record_result "PASS" "Storage Account public blob access"
    fi

    echo
}

# -------------------------------------------------------------------
# CHECK 3 - VM managed disk encryption status
# Read-only commands:
#   az vm list
#   az vm show
#   az disk show
# -------------------------------------------------------------------
check_vm_disk_encryption() {
    echo "------------------------------------------------------------"
    echo "CHECK 3 - Azure VM Disk Encryption Status"
    echo "------------------------------------------------------------"

    local vms
    if ! vms=$(az vm list \
        --resource-group "$VM_RG" \
        --query "[].name" \
        --output tsv 2>/dev/null); then

        echo "Evidence: Unable to read VMs in $VM_RG."
        record_result "WARN" "VM disk encryption"
        echo
        return
    fi

    if [[ -z "$vms" ]]; then
        echo "Evidence: No VMs found in $VM_RG."
        record_result "WARN" "VM disk encryption"
        echo
        return
    fi

    local failed=0
    local unknown=0

    while IFS= read -r vm; do
        [[ -z "$vm" ]] && continue

        echo "VM inspected: $vm"

        local os_disk_id
        os_disk_id=$(az vm show \
            --resource-group "$VM_RG" \
            --name "$vm" \
            --query "storageProfile.osDisk.managedDisk.id" \
            --output tsv 2>/dev/null)

        if [[ -z "$os_disk_id" ]]; then
            echo "  OS disk: encryption evidence unavailable"
            unknown=1
            continue
        fi

        local disk_name="${os_disk_id##*/}"
        local enc_type

        enc_type=$(az disk show \
            --ids "$os_disk_id" \
            --query "encryption.type" \
            --output tsv 2>/dev/null)

        echo "  OS disk: $disk_name"
        echo "  Encryption type: ${enc_type:-Unknown}"

        case "$enc_type" in
            EncryptionAtRestWithPlatformKey|\
            EncryptionAtRestWithCustomerKey|\
            EncryptionAtRestWithPlatformAndCustomerKeys)
                ;;
            "")
                unknown=1
                ;;
            *)
                failed=1
                ;;
        esac

        local data_disk_ids
        data_disk_ids=$(az vm show \
            --resource-group "$VM_RG" \
            --name "$vm" \
            --query "storageProfile.dataDisks[].managedDisk.id" \
            --output tsv 2>/dev/null)

        if [[ -n "$data_disk_ids" ]]; then
            while IFS= read -r disk_id; do
                [[ -z "$disk_id" ]] && continue

                disk_name="${disk_id##*/}"
                enc_type=$(az disk show \
                    --ids "$disk_id" \
                    --query "encryption.type" \
                    --output tsv 2>/dev/null)

                echo "  Data disk: $disk_name"
                echo "  Encryption type: ${enc_type:-Unknown}"

                case "$enc_type" in
                    EncryptionAtRestWithPlatformKey|\
                    EncryptionAtRestWithCustomerKey|\
                    EncryptionAtRestWithPlatformAndCustomerKeys)
                        ;;
                    "")
                        unknown=1
                        ;;
                    *)
                        failed=1
                        ;;
                esac
            done <<< "$data_disk_ids"
        fi
    done <<< "$vms"

    if (( failed == 1 )); then
        echo "Evidence: At least one managed disk did not report an approved encryption-at-rest type."
        record_result "FAIL" "VM disk encryption"
    elif (( unknown == 1 )); then
        echo "Evidence: Encryption evidence could not be collected for every disk."
        record_result "WARN" "VM disk encryption"
    else
        echo "Evidence: All inspected managed disks report Azure encryption at rest."
        record_result "PASS" "VM disk encryption"
    fi

    echo
}

# -------------------------------------------------------------------
# CHECK 4 - MySQL Flexible Server public network access
# Read-only commands:
#   az mysql flexible-server list
#   az mysql flexible-server firewall-rule list
# -------------------------------------------------------------------
check_mysql_public_access() {
    echo "------------------------------------------------------------"
    echo "CHECK 4 - MySQL Flexible Server Public Network Access"
    echo "------------------------------------------------------------"

    local servers
    if ! servers=$(az mysql flexible-server list \
        --resource-group "$MYSQL_RG" \
        --query "[].[name,network.publicNetworkAccess]" \
        --output tsv 2>/dev/null); then

        echo "Evidence: Unable to read MySQL Flexible Servers in $MYSQL_RG."
        record_result "WARN" "MySQL public network access"
        echo
        return
    fi

    if [[ -z "$servers" ]]; then
        echo "Evidence: No MySQL Flexible Servers found in $MYSQL_RG."
        record_result "WARN" "MySQL public network access"
        echo
        return
    fi

    local broad_public=0
    local enabled_public=0
    local unknown=0

    while IFS=$'\t' read -r server public_access; do
        [[ -z "${server:-}" ]] && continue

        echo "MySQL Server: $server"
        echo "  publicNetworkAccess: ${public_access:-Unknown}"

        case "${public_access,,}" in
            disabled)
                ;;
            enabled)
                enabled_public=1

                local rules
                if ! rules=$(az mysql flexible-server firewall-rule list \
                    --resource-group "$MYSQL_RG" \
                    --name "$server" \
                    --query "[].[name,startIpAddress,endIpAddress]" \
                    --output tsv 2>/dev/null); then

                    echo "  Firewall evidence unavailable."
                    unknown=1
                    continue
                fi

                while IFS=$'\t' read -r rule start_ip end_ip; do
                    [[ -z "${rule:-}" ]] && continue

                    echo "  Firewall rule: $rule | $start_ip - $end_ip"

                    if [[ "$start_ip" == "0.0.0.0" &&
                          "$end_ip" == "255.255.255.255" ]]; then
                        broad_public=1
                    fi
                done <<< "$rules"
                ;;
            *)
                unknown=1
                ;;
        esac
    done <<< "$servers"

    if (( broad_public == 1 )); then
        echo "Evidence: A MySQL firewall rule permits the full public IPv4 range."
        record_result "FAIL" "MySQL public network access"
    elif (( enabled_public == 1 )); then
        echo "Evidence: MySQL public network access is enabled, but no full-Internet firewall rule was proven."
        record_result "WARN" "MySQL public network access"
    elif (( unknown == 1 )); then
        echo "Evidence: MySQL network exposure could not be fully determined."
        record_result "WARN" "MySQL public network access"
    else
        echo "Evidence: MySQL public network access is disabled."
        record_result "PASS" "MySQL public network access"
    fi

    echo
}

check_nsg_exposure
check_storage_public_access
check_vm_disk_encryption
check_mysql_public_access

echo "============================================================"
echo "AUDIT SUMMARY"
echo "============================================================"
echo "PASS: $PASS_COUNT"
echo "WARN: $WARN_COUNT"
echo "FAIL: $FAIL_COUNT"
echo "Report: $REPORT_FILE"

if (( FAIL_COUNT > 0 )); then
    echo "Overall result: FAIL"
    exit 2
elif (( WARN_COUNT > 0 )); then
    echo "Overall result: WARN"
    exit 1
else
    echo "Overall result: PASS"
    exit 0
fi

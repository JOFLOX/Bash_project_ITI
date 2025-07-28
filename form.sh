#!/bin/bash

# Function to create a zenity form from a metadata file and save results to data file
# Usage: create_zenity_form <metadata_file> <data_file>
# Returns: 0 on success, non-zero on failure
source validate.sh
create_zenity_form() {
    local meta_file="${1}.meta"
    local data_file="${1}.data"
   
    
    # # Validate arguments
    # if [ $# -ne 2 ]; then
    #     echo "Usage: create_zenity_form <metadata_file> <data_file>" >&2
    #     return 1
    # fi
    
    # # Check if metadata file exists
    # if [ ! -f "$meta_file" ]; then
    #     echo "Error: Metadata file '$meta_file' not found" >&2
    #     return 1
    # fi
    
    # # Check if metadata file is not empty
    # if [ ! -s "$meta_file" ]; then
    #     echo "Error: Metadata file '$meta_file' is empty" >&2
    #     return 1
    # fi
    
    local zenity_args=()
    local field_names=()
    local field_types=()
    local pk_fields=()
    
    # Build zenity command arguments
    zenity_args+=("--forms")
    zenity_args+=("--title=Data Entry Form: $1 ")
    zenity_args+=("--text=Please fill in the following fields:")
    
    # Parse metadata file and build form
    while IFS=':' read -r field_name field_type pk_flag || [ -n "$field_name" ]; do
        # Skip empty lines and comments
        [[ -z "$field_name" || "$field_name" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        field_name=$(echo "$field_name" | tr -d '[:space:]')
        field_type=$(echo "$field_type" | tr -d '[:space:]')
        pk_flag=$(echo "$pk_flag" | tr -d '[:space:]')
        
        # Store field information
        field_names+=("$field_name")
        field_types+=("$field_type")
        pk_fields+=("$pk_flag")

        # echo "field_name: $field_name, field_type: $field_type, pk_flag: $pk_flag"
        
        # Add appropriate zenity field based on type
        case "${field_type}" in
            "int")
                if [[ "$pk_flag" == "PK" ]]; then
                    zenity_args+=("--add-entry=$field_name (PK - Integer)")
                else
                    zenity_args+=("--add-entry=$field_name (Integer)")
                fi
                ;;
            "string")
                if [[ "$pk_flag" == "PK" ]]; then
                    zenity_args+=("--add-entry=$field_name (PK - String)")
                else
                    zenity_args+=("--add-entry=$field_name (String)")
                fi
                ;;
            *)
                # Default to string
                # if [[ "$pk_flag" == "PK" ]]; then
                #     zenity_args+=("--add-entry=$field_name (PK)")
                # else
                #     zenity_args+=("--add-entry=$field_name")
                # fi
             ;;
        esac
    done < "$meta_file"
    
    # Check if we have any fields
    # if [ ${#field_names[@]} -eq 0 ]; then
    #     echo "Error: No valid fields found in metadata file" >&2
    #     zenity --error --text="No valid fields found in metadata file"
    #     return 1
    # fi

 
    # Execute zenity and capture output
    local result

    while true; do
    result=$(zenity "${zenity_args[@]}" 2>/dev/null)
    local exit_code=$?
    
    # Check if user cancelled or zenity failed
    if [ $exit_code -ne 0 ]; then
        # echo "Form cancelled by user" >&2
        return $exit_code
    fi
    
    # Split the result by pipe separator
    IFS='|' read -ra form_values <<< "$result"
    
    # Verify we got the expected number of values
    # if [ ${#form_values[@]} -ne ${#field_names[@]} ]; then
    #     echo "Error: Expected ${#field_names[@]} values, got ${#form_values[@]}" >&2
    #     zenity --error --text="System error: Expected ${#field_names[@]} values, got ${#form_values[@]}"
    #     return 1
    # fi
    
    local renter=0
    # Validate data types
    for i in "${!form_values[@]}"; do
        local value="${form_values[$i]}"
        local type="${field_types[$i]}"
        local field="${field_names[$i]}"
        
        # Check for empty required fields (assuming PK fields are required)
        if [[ "${pk_fields[$i]}" == "PK" && -z "$value" ]]; then
            # echo "Error: Primary key field '$field' cannot be empty" >&2
            zenity --error --text="Primary key field '$field' cannot be empty"
            renter=1
            break
        fi
        if [[ "${pk_fields[$i]}" == "PK" ]]; then
            if ! check_duplicate_pk "${form_values[$i]}" "$i" "$data_file"; then
                renter=1
                break
            fi
        fi
        
        # Validate integer fields
        if [[ "$type" == "int" ]] && [[ -n "$value" ]]; then
            if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                # echo "Error: Field '$field' must be an integer, got: '$value'" >&2
                zenity --error --text="Field '$field' must be an integer, got: '$value'"
                renter=1
                break
            fi
        fi
    done
    
    if [ $renter -eq 1 ]; then
        continue
    fi
        break

    # # Create data file if it doesn't exist
    # if [ ! -f "$data_file" ]; then
    #     touch "$data_file"
    # fi
done    
    # Build the data line (colon-separated values)
    local data_line=""
    for i in "${!form_values[@]}"; do
        if [ $i -eq 0 ]; then
            data_line="${form_values[$i]}"
        else
            data_line="$data_line:${form_values[$i]}"
        fi
    done
    
    # Append to data file
    echo "$data_line" >> "$data_file"
    
    # echo "Data successfully saved to '$data_file'"
    zenity --info --text="Data saved to: $data_file file successfully!"
    return 0
}



#create_zenity_form $1 $2
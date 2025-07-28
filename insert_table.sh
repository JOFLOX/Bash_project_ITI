#!/bin/bash
source list_tables_radio.sh 
source form.sh



insert_table() {
    local tb=""
    
    tb=$(list_tables_radio)
    [[ $? -ne 0 || -z "$tb" ]] && return
    create_zenity_form "$tb"
    
}


# insert_table() {
# echo " in insert_table"
# pwd
# # Check if metadata file exists
# if [ ! -f "tb1.meta" ]; then
#     zenity --error --title="File Error" --text="tb1.meta file not found!"
#     exit 1
# fi

# # Initialize arrays
# col_names=()
# col_types=()
# is_pk=()

# # Read metadata file
# while IFS=':' read -r name type flags; do
#     col_names+=("$name")
#     col_types+=("$type")
#     [[ "$flags" == *"PK"* ]] && is_pk+=("PK") || is_pk+=("")
# done < "tb1.meta"

# num_cols=${#col_names[@]}

# # Build Zenity form arguments
# zenity_args=("--forms" "--title=Data Entry" "--separator=|")
# for ((i=0; i<num_cols; i++)); do
#     # Add field label
#     field_label="${col_names[$i]}"
    
#     # Add validation for PK fields
#     if [ "${is_pk[$i]}" = "PK" ]; then
#         zenity_args+=("--add-entry=$field_label")
#         zenity_args+=("--column-required=$((i+1))")
#     else
#         zenity_args+=("--add-entry=$field_label")
#     fi
# done

# # Show form and get user input
# result=$(zenity "${zenity_args[@]}" 2>/dev/null)

# # Exit if user canceled
# [ $? -ne 0 ] && exit 0 

# # Validate input types
# IFS='|' read -ra values <<< "$result"
# valid_input=true
# error_msg=""

# for ((i=0; i<num_cols; i++)); do
#     value="${values[$i]}"
    
#     # PK validation (already handled by Zenity, but double-check)
#     if [ "${is_pk[$i]}" = "PK" ] && [ -z "$value" ]; then
#         valid_input=false
#         error_msg+="\n- ${col_names[$i]} is required (Primary Key)"
#     fi
    
#     # Integer validation
#     if [ "${col_types[$i]}" = "int" ] && [ -n "$value" ]; then
#         if ! [[ "$value" =~ ^[0-9]+$ ]]; then
#             valid_input=false
#             error_msg+="\n- ${col_names[$i]} must be an integer"
#         fi
#     fi
# done

# # Show errors if any
# if ! $valid_input; then
#     zenity --error --title="Validation Error" --text="Invalid input:$error_msg"
#     exit 1
# fi

# # Append to data file
# echo "${result}" >> "tb1.data"
# zenity --info --title="Success" --text="Data saved successfully!"
# }


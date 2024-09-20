#!/bin/bash
# validate.sh - A script to validate JSON files against specified schemas
# Version: 0.2
# License: GPL-3.0
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.


# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Check if npx is available
if ! command -v npx &> /dev/null; then
    echo -e "${RED}=================================================${NC}"
    echo -e "${RED} ERROR: npx could not be found! ${NC}"
    echo -e "${RED}=================================================${NC}"
    echo -e "${YELLOW}Please install Node.js and npm by following the instructions at:${NC}"
    echo -e "${GREEN}https://nodejs.org/${NC}"
    echo -e "${RED}=================================================${NC}"
    exit 1
fi

# Check if ajv is installed
if ! npx -q ajv --version &> /dev/null; then
    echo -e "${RED}=================================================${NC}"
    echo -e "${RED} ERROR: ajv is not installed! ${NC}"
    echo -e "${RED}=================================================${NC}"
    echo -e "${YELLOW}Please install it by running:${NC}"
    echo -e "${GREEN}npm install -g ajv-cli${NC}"
    echo -e "${RED}=================================================${NC}"
    exit 1
fi

# Function to prompt for input with validation.
prompt_for_input() {
    local prompt_message=$1
    local user_input
    while true; do
        read -p "$prompt_message" user_input
        if [ -n "$user_input" ]; then
            echo "$user_input"
            break
        else
            echo -e "${YELLOW}Input cannot be empty. Please try again.${NC}"
        fi
    done
}

# Function to perform JSON validation.
validate_json() {
    local schema=$1
    local file=$2
    echo -e "${GREEN}Validating ${file} against ${schema}${NC}"
    npx ajv validate --spec=draft7 --validate-formats=false --strict=false -s "$schema" -d "$file" --verbose
}

# Declare an associative array of schemas.
declare -A schemas
schemas[CBOM]="bom-1.4-cbom-1.0.schema.json"
schemas[SBOM]="santander-cryptographic-properties-0.2.schema.json"
schemas[ALL]=""

# Prompt for validation type if not provided.
if [ -z "$1" ]; then
    echo -e "${YELLOW}Available validation types: CBOM, SBOM, ALL${NC}"
    validation_type=$(prompt_for_input "Enter validation type (CBOM, SBOM, ALL): ")
else
    validation_type=$1
fi

# Validate that the input is correct.
if [[ ! ${schemas[$validation_type]} && "$validation_type" != "ALL" ]]; then
    echo -e "${RED}Invalid validation type. Please use [CBOM|SBOM|ALL].${NC}"
    exit 1
fi

# Prompt for JSON file path if not provided.
if [ -z "$2" ]; then
    file_path=$(prompt_for_input "Enter path to JSON file: ")
else
    file_path=$2
fi

# Check if the file exists, which is always important.
if [ ! -f "$file_path" ]; then
    echo -e "${RED}File not found: ${file_path}${NC}"
    exit 1
fi

# Perform validations based on the type selected by the user.
if [ "$validation_type" == "ALL" ]; then
    for type in CBOM SBOM; do
        validate_json "${schemas[$type]}" "$file_path"
    done
else
    validate_json "${schemas[$validation_type]}" "$file_path"
fi

#!/bin/bash

# CLI validation using ajv 

case "$1" in
    "CBOM" | "ALL")
        echo "Validating ${2} against CBOM"
        npx ajv validate --spec=draft7 --validate-formats=false -r spdx.schema.json -r jsf-0.82.schema.json --strict=false -s bom-1.4-cbom-1.0.schema.json -d $2
        ;;&
    "SBOM" | "ALL")
        echo "Validating ${2} against SBOM"
        npx ajv validate --spec=draft7 --validate-formats=false --strict=false -s santander-cryptographic-properties-0.2.schema.json -d ${2} --verbose
        ;;
    *)
        echo "validate [CBOM|SBOM|ALL] path/to/cbom.json"
        ;;
esac
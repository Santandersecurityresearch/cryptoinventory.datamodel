# Cryptoinventory Data Model PoC

Currently using CycloneDX 1.6 schema [CycloneDX 1.6](https://github.com/CycloneDX/specification).
This repository has also schemas and objects valid for IBM CBOM (bom-1.4-cbom-1.0.schema.json) for documentation purposes.

## Experiment using "ajv"

[ajv](https://www.npmjs.com/package/ajv) is the recommended tool to validate schemas.

To install `ajv` as a node library:

```bash
npm install ajv-cli
```

***Note: it is important to install the CLI version to be able to talk to it from the console. Once installed, we have prepared the validate.sh script to do the testing:***

```
# validate certificate-object against CBOM 
./validate.sh CBOM certificate-object-4.json
 
# validate certificate-object against SANTANDER BOM 
./validate.sh SBOM certificate-object-4.json
 
# validate certificate-object against BOTH 
./validate.sh ALL certificate-object-4.json
```

We have created the santander-cryptographic-properties schema to do the extra validations for our own data model.

***Note: We decided to disregard our initial attempts with Python because of the difficulties found in managing dependent schemas (CBOM's case).***

## CBOM Comments

* You can generate an empty record. We think that the minimum CBOM object should be a kind of asset, and depending on that, validate the proper minimum related fields.
* CBOM does not define a current state of the certificates. We have defined a state field to track it.
* Field serialNumber is validated as 32 bytes of data. This is not consistent with the serial number format for a certificate (40 bytes of data). That's why we needed to define a new field called serialNumberCA.
* The model proposes the option to use the block properties to define fields not in the model. We propose renaming this block to extendedAttributes because "properties" is a reserved word in JSON schema, so using it for a definition is confusing and can conflict with some JSON schema readers.
* For the owner, we have used the new fields publisher and group (defined in CycloneDX 1.6) that can serve this purpose, but we still think there's space for an owner field, which would be more precise in its semantics from our perspective.
* certificateExtensions should be an array instead of a single string, to permit the possibility of mixed certificates.
* We have defined appIdentifier to link the certificate to an application. We think this is a very important relation.
* We have defined the field keys as an array of objects to be able to track hybrid certificates in the future. This is not incompatible with current certificates, because the array has a minimum of one value, which is the case with standard certificates. In the case that we define the keys this way, we don't need the pre-defined CBOM field certificateAlgorithm. The objects inside the keys array are more complete. We are aware that there's a separate kind of object in CBOM to define keys, but we are not inventorying keys at the moment, and we wish to have a minimum set of data of the keys attached to the certificate object, which is why we added keyIdentifier, keySize, and algorithm properties to the key objects inside certs definitions.

***Note: If many fields are being added to the properties block, it may indicate that the model is missing some important information. Currently, we are defining 13 new values to capture critical data that we believe should be considered for incorporation into the model.***

## To-Do

* Conditional validation of schemas: for certs and keys right now we are using oneOf, but this does not enforce adding key properties if you define a key, and cert properties if you define a cert. With the current definition, you can add cert properties to a key and vice versa, and it would validate.
* Should the securityStrength field be linked to each key? (Now that we have defined several keys). In that case, current standard fields classicalSecurityLevel and nistQuantumSecurityLevel shouldn't be at the cryptoproperties level, at least for certs.
* Discuss if it makes sense to add an identifier of the issuer's certificate, so we can track the full certificate chain from the CMDB.
* Discuss if it makes sense to define appIdentifier as an array of internal references for the case where there's more than one application related to this certificate.
* "format": "date-time" is not validating properly: it permits arbitrary values like "ddd" because we are not validating formats, but if we enable it, we get an "unknown format" error.

***Note: This is a problem with the validator, not the schema. Look for different validators.***


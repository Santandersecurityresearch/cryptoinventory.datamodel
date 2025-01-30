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
./validate.sh CBOM certificate-object-cyclonedx-1.6-tactical-keys.json
 
# validate certificate-object against SANTANDER BOM 
./validate.sh SBOM certificate-object-cyclonedx-1.6-tactical-keys.json
 
# validate certificate-object against BOTH 
./validate.sh ALL certificate-object-cyclonedx-1.6-tactical-keys.json
```

We have created the santander-cryptographic-properties schema to do the extra validations for our own data model.

***Note: We decided to disregard our initial attempts with Python because of the difficulties found in managing dependent schemas (CBOM's case).***

## Data Model for certificates - v.1.0.0

You can check the agreed final model [here](data-model-for-certificates-v.1.0.0.md).

## CBOM 1.6 Comments

* You can generate an **empty record**. We think that the minimum CBOM object should be a kind of asset, and depending on that, validate the proper minimum related fields.
* CBOM does not define a current **state** of the certificates. We have defined a state field to track it, in agreement with Santander CMDB owner. We think this property should be included in CBOM standard definition.
* Field **serialNumber** is validated as 32 bytes of data. This is not consistent with the serial number format for a certificate (40 bytes of data). We have defined a new serialNumber field attached to the extended properties of the certificate. We think this property should be included in CBOM standard definition.
* The model proposes the option to use the block properties to define fields not in the model. We propose renaming this block to **extendedProperties** because "properties" is a reserved word in a JSON schema, so using it for a definition is confusing and can conflict with some JSON schema readers.
* Also, regarding the **extended properties**, CycloneDX 1.6 defines this objects strictly as name-value pairs with the value restricted to a string type. Opening this attribute to an object would make the schema completely opened to model lots of different use cases that are not (and don't need to be) in the standard specification. Besides it will add other benefits like: 
    1. Different type of items, for example simple items validating to true/false right now have to be represented as "true"/"false" instead of the actual boolean value. 
    2. Possibility of validating mandatory/non mandatory items in a different schema. Right now, as it is defined, it is not possible to validate some items of the extended properties as mandatory and others as non mandatory. If it were possible to have different structures, it would be easy to define complete objects with their own validation rules.
* For the **owner**, we have used the new fields publisher and group (defined in CycloneDX 1.6) that can serve this purpose, but we still think there's space for an "owner" field, which would be more precise semantically.
* We have defined the **keys** in the components array instead of using CBOM fields in order to be able to define several keys so we can track hybrid certificates in the future. This is not incompatible with current standard (non-hybrid) certificates, because the array has a minimum of one value, with no maximum. The keys objects are kept with a minimum set of properties at the moment (keyIdentifier, keySize, and algorithm properties), because we are focusing on tracking certs for now. - **Note:** This is the ideal, target, scenario. For now our definition has changed to a single list of keys+sizes with multiple options due to CMDB limitations.
* We have defined the **fingerprint** information using the hash object defined by CBOM, but that object does not have the possibility of adding a name or a label to it, so you don't know that information corresponds to the fingerprint at all.
* We have defined several **administrative dates** as external properties that we agreed to be left out of the standard, because there's no standard spec or recommendation. However, some of the proposed dates were finally added into CBOM 1.7 in [commit cdf825049be776acc3acf6ad5fec8c942d78e1b8](https://github.com/CycloneDX/specification/pull/543/commits/cdf825049be776acc3acf6ad5fec8c942d78e1b8), into `certificateProperties` object.
* We have defined almost all the **x509v3 extended properties** as non required extended properties.

## Requests for IBM / CycloneDX

The following inclussions in CBOM definition for certificates were requested:

Request | Status
--- | ---
**certificateState** | Included in v.1.7 in `certificateProperties` object - [commit cdf825049be776acc3acf6ad5fec8c942d78e1b8](https://github.com/CycloneDX/specification/pull/543/commits/cdf825049be776acc3acf6ad5fec8c942d78e1b8)
Include **revocationReason** in CBOM definition for certificates. | Under analysis. Depends on `state` inclussion
**serialNumber** | Included in v.1.7 in `certificateProperties` object - [commit 0e9eb6a1a3c553583c60e3551dcffb0e8f22ec41](https://github.com/CycloneDX/specification/pull/543/commits/0e9eb6a1a3c553583c60e3551dcffb0e8f22ec41)
**fingerPrint**  | Included in v.1.7 in `certificateProperties` object, and in `relatedCryptoMaterial` object as well - [commit 0e9eb6a1a3c553583c60e3551dcffb0e8f22ec41](https://github.com/CycloneDX/specification/pull/543/commits/0e9eb6a1a3c553583c60e3551dcffb0e8f22ec41)
Add the possibility of a new property **name/label for hashes** to define what the hash is representing. | Included in v.1.7 (¿?) - Not necessary because the `fingerprint` property was added.
Add the possibility of defining the **extended properties value as an object** in CBOM definition. | Rejected
Array to manage a list of keys | The `subjectPublicKeyRef` has been depreprecated in [commit 0502e1103f58187e5efb2d26fee8200a25b19f0d](https://github.com/CycloneDX/specification/pull/543/commits/0502e1103f58187e5efb2d26fee8200a25b19f0d)
Array to manage a list of signatures | The `signatureAlgorithmRef` has been deprecated in [commit 0502e1103f58187e5efb2d26fee8200a25b19f0d](https://github.com/CycloneDX/specification/pull/543/commits/0502e1103f58187e5efb2d26fee8200a25b19f0d)
Add an object inside certProperties to define **x509v3 extended properties** | Requested. Pending decission.

## To-Do

* Conditional validation of schemas: for certs and keys right now we are using oneOf, but this does not enforce adding key properties if you define a key, and cert properties if you define a cert. With the current definition, you can add cert properties to a key and vice versa, and it would validate.
* Is it possible to validate that some extended properties should be mandatory? How?
* "format": "date-time" is not validating properly: it permits arbitrary values like "ddd" because we are not validating formats, but if we enable it, we get an "unknown format" error. - **Note: This is a problem with the validator, not the schema. Look for different validators.**


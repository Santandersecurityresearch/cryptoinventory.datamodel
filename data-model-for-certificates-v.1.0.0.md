# Data model for certificates - v1.0.0

> **Important Note:** 
> All the information available in the certificate MUST be included in the CMDB, whether it is mandatory or not.

* **SerialNumber** - string(40), maybe string(59) if we want to allow `##:##:...:##` format.
* Name - A name for the certificate. For example: "TLS certificate for blockchain network"
* **Owner (assignedTo)** - Reference to a single person in CMDB, that is accountable for the certificate. In the beginning, the person who requested it through ITSM.
* **Group (managedBy)** - Reference to group or team in CMDB, that is accountable for the certificate. (Owner or Group) is mandatory (at least one of those).
* Applications - List of applications in CMDB that use the certificate. Note: For now it's a list of `services`.
* Machines - List of devices in CMDB where the certificate is installed
* **SubjectName** - Distinguished Name (DN) for the certificate's subject
* **IssuerName** - Distinguished Name (DN) for the certificate's issuer
* **notValidBefore** - Activation date
* **notValidAfter** - Expiry date
* **signaturesAlgorithms** - List of algorithms used to sign the certificate. It is a list to have the possibility to define Hybrid Certificates in the case we use them. Each algorithm field should be free text, string(50) for each.
* **certificateFormat** - Options: `[X.509v3, X.509v2, X.509, CVC]`
* certificateEncoding - Options: `[PEM, PKCS#7/P7B, DER, PKCS#12/PFX]`
* **fingerprintAlgorithm** - Free text, string(50).
* **fingerPrint** - Certificate's fingerprint - string with variable length, depending on the algorithm used.
* **state** - Certificate's state. Options: `[pre-operational, operational, retired, suspended, revoked, destroyed]`
* revocationReason - Options: `[keyCompromise, administrativeReason]`. Should be mandatory in the case that the state is revoked.
* ~~**keys** - Certificate's private keys array. It can be more than one to have into account the possibility of Mixed Certificates. Ideally:  `[ {size1, algo1}, {size2, algo2}, …, {sizeN, algoN} ]`. In the future it will be an array of CMDB references.~~
* **keys** - Certificate's key algorithms and parameters. Tactical approach until we have an inventory of keys. List of possible values in the keys-list document.

## management dates (these ones are exactly as they are in CMDB now)

* receivedDate
* updatedDate
* installedDate
* availableDate
* removalDate
* revocationDate

## extended properties

* basicConstraintsCA - true/false
* keyUsage - List of possible values: `[ digitalSignature, nonRepudiation, contentCommitment, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly ]`. More than 1 can be present. A string size of 256 should be enough.
* extendedKeyUsage - List of possible values: `[ TLS WWW server authentication, TLS WWW client authentication, Signing of downloadable executable code, E-mail protection, Binding the hash of an object to a time, Signing OCSP responses ]`. More than 1 can be
 present. A string size of 256 should be enough.
* subjectAlternativeName - string
* authorityKeyIdentifier - string(40), maybe string(59) if we want to allow `##:##:...:##` format.
* subjectKeyIdentifier - string(40), maybe string(59) if we want to allow `##:##:...:##` format.
* authorityInformationAccess - URL or list of URLs. String size of 256 should be enough.
* certificatePolicies - Policies list under which the certificate was issued, and under which can be used. String size of 256 should be enough. - NEXT ITERATION
* CRLDistributionPoints - URL or list of URLs where you can get a CRL (Certificate Revocation List). String size of 256 should be enough. - NEXT ITERATION

## Notes:

* Properties in bold mean they are mandatory.
* We have kept the original proposal for `keys` (crossed out) because the current definition is a compromise for CMDB current capacities. In the future we may evolve to the ideal proposal.
* The model should be able to continue evolving. For example the "keys" information will be changed for CMDB references when we have a keys inventory.

## References:

* [RFC 5280 - Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile](https://www.rfc-editor.org/rfc/rfc5280)
* [IBM - An Overview of X.509 Certificates](https://www.ibm.com/support/pages/system/files/inline-files/An_Overview_of_x.509_certificates.pdf)

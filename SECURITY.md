# Security Policy

> Please do not disclose security vulnerabilities publicly without consulting the AHA-secret maintainer team first. [See below for more information.](#reporting-a-vulnerability)

## Supported Versions

Builds are continually released and security fixes will always be available in the latest build.

## Reporting a Vulnerability

>**NOTE:** Before reporting a vulnerability, please verify that you have followed the published guidelines for configuring the AHA-secret project and that the vulnerability is still repeatable with the recommended configuration applied. Vulnerabilities reported about information leakage when debug mode is enabled are usually not helpful and are generally a waste of time for both the maintainer team and the security researchers involved.

If you discover a security vulnerability within AHA-secret, please [submit a new Security Advisory through Github](https://github.com/aha-oida/aha-secret/security/advisories/new). All security vulnerabilities will be promptly addressed. We will review the security vulnerability and will publish an advisory if we determine that the vulnerability exists and can be exploited, and have made available the steps to mitigate the vulnerability. 

Please note that Github is the CVE Numbering Authority (CNA) of choice for the AHA-secret project and all related projects. In accordance with [CNA Rules 4.3.2](https://www.cve.org/ResourcesSupport/AllResources/CNARules#section_4-3_Notification) any alternative CNA is required to notify us through this method before they are permitted to publish a CVE.

If a CVE is published by an alternative CNA without consulting with the AHA-secret team first then we will publish a security advisory targeting that CVE providing either a fix if the report was valid or an explanation of why the report was invalid. Please be aware that incorrect, poorly considered, or improperly notified reports do not reflect positively on either the security research who submitted them or the CNA who issued the CVE. The AHA-secret team will follow [published MITRE processes](https://cve.mitre.org/cve/list_rules_and_guidance/correcting_counting_issues.html) in order to Reject or Dispute any improperly issued CVEs; so for the sake of everyone's time; please use the official reporting channel above to report / disclose any security issues.

## Disclosing Vulnerabilities

The AHA-secret maintainer team is committed to ethical and responsible disclosure of security vulnerabilities if they are discovered. We will publish all advisories of all severity levels on our [Security Advisories list](https://github.com/aha-oida/aha-secret/security/advisories?state=published). Once this has occurred, the discoverer of the vulnerability may publish it on their own platform. Please discuss this with maintainer team first.


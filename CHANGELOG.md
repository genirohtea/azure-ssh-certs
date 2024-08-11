# Changelog

## 1.0.0 (2024-08-11)


### Features

* **ansible:** added ansible playbooks to sign + use ssh CAs on workstations and servers ([040e069](https://github.com/genirohtea/azure-ssh-certs/commit/040e0694e810ea195f72f1cfefc6f3664488dfcf))
* **azure vault:** added terraform generation of SSH CA keys ([69830b6](https://github.com/genirohtea/azure-ssh-certs/commit/69830b693327e48cd6a8f3cb7b77aec065209528))
* **github template:** initialized repo with 1.1 github template ([1912e50](https://github.com/genirohtea/azure-ssh-certs/commit/1912e50fa3cbad9cf5ecaf9dd90fda2ffdfa7ad0))


### Bug Fixes

* **host key:** fixed issue where ansible wouldnt create cert due to existing file ([d37d55f](https://github.com/genirohtea/azure-ssh-certs/commit/d37d55f71d61cf01c3966e0c84693434b63f4c24))

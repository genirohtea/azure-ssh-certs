# Ansible Collection - geniroh.azure_ssh_certs

Documentation for the collection.
ansible-playbook sign_user_local.yml -vvv
ansible-playbook sign_host_remote.yml -i curie.klaus.geniroh.com, --ask-pass
ansible-playbook accept_host_ca_local.yml
ansible-playbook accept_user_ca_remote.yml  -i curie.klaus.geniroh.com, --ask-pass

When rotating, rotate the servers first then the workstations.

## Usage

On first, provision:

```bash
./setup_host_server.sh --host curie.klaus.geniroh.com --site klaus --env prod --verbose --disable_key_check
```

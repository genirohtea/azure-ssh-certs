ssh_certificates
=========

Sets up user workstations and host servers with SSH certificates.

Requirements
------------

Either Azure or BWS generated SSH keys.

Role Variables
--------------

- `accept_host_ca`: Setup the host to accept the Host certificate
- `accept_user_ca`: Setup the host to accept the User certificate
- `sign_host_key`: Sign the host's key
- `sign_user_key`: Sign the user's key

Dependencies
------------

None.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: servers
  roles:
      - role: ssh_certificates
        vars:
          accept_host_ca: true
          sign_user_key: true
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).

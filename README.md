# ansible

Inventory and automation of NeonTech infrastructure using [Ansible](https://www.ansible.com). Ansible's [sample directory layout](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html#sample-directory-layout) is adhered to for this repository.

## Getting Started

1. Clone the repository:

   `git clone https://github.com/NeonTech/ansible.git`

2. Set the working directory as the root of the repository:

   `cd ./ansible`

3. Decrypt the Ansible vaults in `./ssh` and copy their values to `./.ssh`:

   `./scripts/setup_ssh.sh`

4. Test connections to hosts:

   `ansible all --inventory ./production.ini --vault-password-file ./vault-password-file --module-name ansible.builtin.ping`

5. Run the `site.yml` playbook to deploy **_everything_**:

   `ansible-playbook --inventory ./production.ini --vault-password-file ./vault-password-file site.yml`

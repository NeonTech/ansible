# ansible-playbooks

Inventory and automation of NeonTech infrastructure using [Ansible playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html). Ansible's [sample directory layout](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html#sample-directory-layout) is adhered to for this repository.

## Getting Started

1. Clone the repository: `git clone https://github.com/NeonTech/ansible-playbooks.git`
2. Set the working directory as the root of the repository: `cd ./ansible-playbooks`
3. Decrypt the Ansible vaults in `./ssh` and copy their values to `./.ssh`: `./scripts/setup_ssh.sh`
4. Run `ansible all --inventory production --module-name ansible.builtin.ping` to test connections to hosts.

Playbooks can now be executed: `ansible-playbook --inventory production --vault-password-file vault-password-file site.yml`

# Configure K8s nodes

# Description

Current only configures control plane node

## Installation

- Need to add private key in inventory/group_vars/ssh_config
- Update IP addresses in inventory





## random notes

{{ some_var | default() }} *pretty much the same a helm

if empty or false
{{ lookup('env', 'MY_USER') | default('admin', true)}}

DEFAULT_UNDEFINED_VAR_BEHAVIOR

{{ var | mandatory }}

"{{ undef(hint= "replace this") }}"

{{ (status == 'needs_restart') | ternary('restart', 'continue') }}


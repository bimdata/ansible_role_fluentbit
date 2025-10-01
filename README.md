Ansible role Fluentbit
=========

This role installs and configures Fluentbit.

Requirements
------------

* This role is only tested with Ansible >= 2.9.

Role Variables
--------------

This role tries to keep the same default configuration as if you manually install
Fluentbit.
You can find more information about each option in the [Fluentbit documentation](
https://docs.fluentbit.io/manual/v/1.6/administration/configuring-fluent-bit/configuration-file).

Variables used for the installation:

| Variables                       | Default value                               | Description                                                 |
|---------------------------------|---------------------------------------------|-------------------------------------------------------------|
| fluentbit_prerequisites         | ['apt-transport-https', 'curl', 'gnupg']    | List of package that need to be installed before Fluentbit. |
| fluentbit_apt_use_deb822        | true                                        | Use APT deb822 format for the fluent-bit source file.       |
| fluentbit_apt_key_path          | "/usr/share/keyrings/fluentbit-keyring.gpg" | APT keyring path use to store the fluentbit key.            |
| fluentbit_apt_key_url           | https://packages.fluentbit.io/fluentbit.key | The APT key for the Fluentbit package.                      |
| fluentbit_apt_repos_url         | "https://packages.fluentbit.io/{{ ansible_distribution \| lower }}/{{ ansible_distribution_release \| lower }}"  | The APT repository address needed to install Fluentbit. |
| fluentbit_apt_repos_component   | main                                        | APT repository component.                                   |
| fluentbit_pkg_name              | fluent-bit                                  | The Fluentbit APT package name.                             |
| fluentbit_pkg_version           | ""                                          | Install a specific version of the package.                  |
| fluentbit_pkg_version_hold      | "{{ fluentbit_pkg_version \| default(False) \| ternary(True, False) }}" | Lock package version to prevent accidental updates. By default, `True` if `fluentbit_pkg_version` is defined, `False` otherwise. |
| fluentbit_svc_name              | fluent-bit                                  | The Fluentbit service name to start/stop the daemon.        |
| fluentbit_apt_cleanup_legacy    | false                                       | Remove old keys and old APT sources if true.                |
| fluentbit_apt_key_legacy_id     | F209D8762A60CD49E680633B4FF8368B6EA0722A    | ID of the old GPG key to remove from keyring.               |
| fluentbit_naming_cleanup_legacy | false                                       | Remove old service / conf / apt with td-agent name.         |
| fluentbit_pkg_name_legacy       | td-agent-bit                                | Pkg name that will be remove by legacy cleaner.             |
| fluentbit_svc_name_legacy       | td-agent-bit                                | Service name that will be remove by legacy cleaner.         |
| fluentbit_conf_directory_legacy | /etc/td-agent-bit/                          | Conf directory that will be remove by legacy cleaner.       |


Variables used for the general configuration:

| Variables                        | Default value     | Description                                               |
|----------------------------------|-------------------|-----------------------------------------------------------|
| fluentbit_svc_flush              | 5                 | Flush time in *seconds.nanoseconds* format.               |
| fluentbit_svc_grace              | 5                 | Set the grace time is *seconds*.                          |
| fluentbit_svc_daemon             | "off"             | On/Off value to specify if Fluentbit runs as a Deamon. Should be Off when using the provided Systemd unit. |
| fluentbit_svc_logfile            | ""                | Absolute path for an optional log file. Log to stdout if not specified. |
| fluentbit_svc_loglevel           | info              | Set the logging verbosity level.                          |
| fluentbit_svc_parsers_file       | ["parsers.conf"]  | List of paths for *parsers* configuration files.          |
| fluentbit_svc_plugins_file       | ["plugins.conf"]  | List of paths for *plugins* configuration files.          |
| fluentbit_svc_streams_file       | []                | List of paths for *stream processors* configuration files.|
| fluentbit_managed_parsers_enable | "{{ ((_fluentbit_parsers \| length) or (_fluentbit_mlparsers \| length)) \| bool }}" | Define if Ansible should create/update a custom file for user defined parser. |
| fluentbit_managed_parsers_file   | "{{ fluentbit_conf_directory }}/managed-parsers.conf"                                | File where the custom parsers are defined if needed. |
| fluentbit_svc_http               | {}                | Dictionary for HTTP built-in server configuration.        |
| fluentbit_svc_storage            | {}                | Dictionary for storage/buffer configuration.              |
| fluentbit_svc_limit_open_files   | Undefined         | Configure LimitNOFILE for systemd service if defined      |

For `fluentbit_svc_http`, each key is used as a configuration option name and values as values.
But you don't need to add the prefix `HTTP_`, it will be added by the template.
For example, you can define it like this:
```
fluentbit_svc_http:
  server: On
  listen: 0.0.0.0
  port: "{{ fluentbit_monitoring_port }}"
```

It's the same for `fluentbit_svc_storage`: you don't need to specify the prefix `storage.`.
Example:
```
fluentbit_svc_storage:
  path: /var/log/flb-storage/
  sync: full
  checksum: "off"
```

Other variables:

| Variables               | Default value | Description                                               |
|-------------------------|---------------|-----------------------------------------------------------|
| fluentbit_dbs_path      | ""            | A path for a directory that will be created by the role. For example to store your input DB files. |

Variables for log processing:

| Variables               | Default value                                                                      | Description                                    |
|-------------------------|------------------------------------------------------------------------------------|------------------------------------------------|
| _fluentbit_inputs       | "{{ lookup('template', 'get_vars.j2'), template_vars=dict(var_type='input') }}"    | List of dictionaries defining all log inputs.  |
| _fluentbit_filters      | "{{ lookup('template', 'get_vars.j2'), template_vars=dict(var_type='filter') }}"   | List of dictionaries defining all log filters. |
| _fluentbit_outputs      | "{{ lookup('template', 'get_vars.j2'), template_vars=dict(var_type='output') }}"   | List of dictionaries defining all log outputs. |
| _fluentbit_parsers      | "{{ lookup('template', 'get_vars.j2'), template_vars=dict(var_type='parser') }}"   | List of dictionaries defining all log managed parser. |
| _fluentbit_mlparsers    | "{{ lookup('template', 'get_vars.j2'), template_vars=dict(var_type='mlparser') }}" | List of dictionaries defining all log managed multiline parser. |

**In most cases, you should not modify these variables.**
Templating is used to build these lists with other variables.
* `_fluentbit_inputs` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_input(s)?$'`.
* `_fluentbit_filters` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_filter(s)?$'`.
* `_fluentbit_outputs` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_output(s)?$'`.
* `_fluentbit_parsers` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_parser(s)?$'`.
* `_fluentbit_mlparsers` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_mlparser(s)?$'`.

Each variables matching these regexes must be:
  - a dictionary defining one input/filter/output/parser **or**
  - a list of dictionaries defining one or more inputs/filters/outputs/parser.

Each dictionary is used to define one `[INPUT]`, `[FILTER]`, `[OUTPUT]`, `[PARSER]` or `[MULTILINE_PARSER]` section
in the Fluentbit configuration file or in managed parser file. Each configuration section
is configured with key/value couples, so the dictionary's keys are used as
configuration keys and values as values.

For example:
```
fluentbit_nginx_input:
  - name: tail
    path: /var/log/nginx/access.log
  - name: tail
    path: /var/log/nginx/error.log

fluentbit_kernel_input:
  name: tail
  path: /var/log/kern.log
```

will create:
```
[INPUT]
  name tail
  path /var/log/nginx/access.log
[INPUT]
  name tail
  path /var/log/nginx/error.log
[INPUT]
  name tail
  path /var/log/kern.log
```

It allows you to define variables in multiple group_vars and cumulate them for
hosts in multiples groups without the need to rewrite the complete list.

Ansible dictionaries can't have the same key multiple times. This can be a problem
to use stuff like `record`.
To overcome this issue, each key can be prefix with a number that will be remove
in the template file. It needs to match this regex: `'^[0-9]+__'`.

Fir example:
```
fluentbit_add_context_filter:
  - name: record_modifier
    match: '*'
    0__record: hostname ${HOSTNAME}
    1__record: product Awesome_Tool
```

will create:
```
[FILTER]
  name record_modifier
  match *
  record hostname ${HOSTNAME}
  record product Awesome_Tool

```

Dependencies
------------

None

Example Playbook
----------------

in `group_vars/all.yml`:
```
fluentbit_kernel_input:
  name: tail
  path: /var/log/kern.log

fluentbit_env_filter
  name: record_modifier
  match: '*'
  record: "env {{ env }}"

fluentbit_central_output:
  name: forward
  match: '*'
  host: "{{ logs_server_address }}"
  port: "{{ log_forward_port }}"
```

in `group_vars/web.yml`:
```
fluentbit_nginx_input:
  - name: tail
    path: /var/log/nginx/access.log
  - name: tail
    path: /var/log/nginx/error.log
```

in `playbook.yml`:
```
- hosts: web
  gather_facts: True
  become: yes
  roles:
    - bimdata.fluentbit
```

License
-------

BSD

Author Information
------------------

[BIMData.io](https://bimdata.io/)

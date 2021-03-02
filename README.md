Ansible role Fluentbit
=========

This role installs and configures Fluentbit.

Requirements
------------

* This role is only tested on Debian 10.x (Buster).

Role Variables
--------------

This role tries to keep the same default configuration as if you manually install
Fluentbit.
You can find more information about each option in the [Fluentbit documentation](
https://docs.fluentbit.io/manual/v/1.6/administration/configuring-fluent-bit/configuration-file).

Variables used for the installation:

| Variables               | Default value                               | Description                                               |
|-------------------------|---------------------------------------------|-----------------------------------------------------------|
| fluentbit_prerequisites | ['apt-transport-https', 'curl', 'gnupg']    | List of package that need to be installed before Fluentbit. |
| fluentbit_apt_key_url   | https://packages.fluentbit.io/fluentbit.key | The APT key for the Fluentbit package.                        |
| fluentbit_apt_repos_url | "https://packages.fluentbit.io/\{{ ansible_distribution \| lower }}/{{ ansible_distribution_release \| lower }} {{ ansible_distribution_release \| lower }}"  | The APT repository address needed to install Fluentbit. |
| fluentbit_pkg_name      | td-agent-bit                                | The Fluentbit APT package name.                           |
| fluentbit_svc_name      | td-agent-bit                                | The Fluentbit service name to start/stop the daemon.      |
| fluentbit_version       | *Undefined*                                 | If undefined and Fluentbit not already present, install the latest. If undefined and Fluentbit already present, do nothing.|
| fluentbit_extra_groups  | adm                                         | Extra groups to add to the user which run the service.|

Variables used for the general configuration:

| Variables                 | Default value                 | Description                                               |
|---------------------------|-------------------------------|-----------------------------------------------------------|
| fluentbit_svc_flush       | 5                             | Flush time in *seconds.nanoseconds* format.               |
| fluentbit_svc_grace       | 5                             | Set the grace time is *seconds*.                          |
| fluentbit_svc_daemon      | "off"                         | On/Off value to specify if Fluentbit runs as a Deamon. Should be Off when using the provided Systemd unit. |
| fluentbit_svc_logfile     | ""                            | Absolute path for an optional log file. Log to stdout if not specified. |
| fluentbit_svc_loglevel    | error                         | Set the logging verbosity level.                          |
| fluentbit_svc_parsers     | ["custom_parsers.conf"]       | List of paths for *parsers* configuration files.          |
| fluentbit_svc_plugins     | ["plugins.conf"]              | List of paths for *plugins* configuration files.          |
| fluentbit_svc_streams     | []                            | List of paths for *stream processors* configuration files.|
| fluentbit_svc_http        | {server:on, listen:127.0.0.1} | Dictionary for HTTP built-in server configuration.        |
| fluentbit_monitoring_port | {}                            | Port used for http service to monitor fluentbit.          |
| fluentbit_svc_storage     | {path: "/var/run/fluentbit/fluentbit.buffer", sync: normal, backlog.mem_limit: "10M", metrics: On }                            | Dictionary for storage/buffer configuration.              |

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

| Variables               | Default value                                         | Description                                         |
|-------------------------|-------------------------------------------------------|-----------------------------------------------------|
| _fluentbit_inputs       | "{{ lookup('template', './lookup/get_inputs.j2') }}"  | List of dictionaries defining all log inputs.       |
| _fluentbit_filters      | "{{ lookup('template', './lookup/get_filters.j2') }}" | List of dictionaries defining all log filters.      |
| _fluentbit_outputs      | "{{ lookup('template', './lookup/get_outputs.j2') }}" | List of dictionaries defining all log outputs.      |
| _fluentbit_parsers      | "{{ lookup('template', './lookup/get_parsers.j2') }}" | List of dictionaries defining all log parsers.      |  
| _fluentbit_nodes        | "{{ lookup('template', './lookup/get_nodes.j2') }}"   | List of dictionaries defining all nodes to forward. |

**In most cases, you should not modify these variables.**
Templating is used to build these lists with other variables.
* `_fluentbit_inputs` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_input$`.
* `_fluentbit_filters` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_filter$'`.
* `_fluentbit_outputs` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_output$`.
* `_fluentbit_parsers` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_parsers$`.
* `_fluentbit_nodes` will aggregate all the variables whose name matches this regex: `^fluentbit_.+_nodes$`.

Each variables matching these regexes must be:
  - a dictionary defining one input/filter/output **or**
  - a list of dictionaries defining one or more inputs/filters/outputs.

Each dictionary is used to define one `[INPUT]`, `[FILTER]`, `[OUTPUT]`, `[PARSER]` or `[NODE]` section
in the Fluentbit configuration file. Each configuration section
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

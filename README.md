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
You can find more informations about each option in the [Fluentbit documentation](
https://docs.fluentbit.io/manual/v/1.6/administration/configuring-fluent-bit/configuration-file).

Variables use for the installation:

| Variables               | Default value                               | Description                                               |
|-------------------------|---------------------------------------------|-----------------------------------------------------------|
| fluentbit_prerequisites | ['apt-transport-https', 'curl', 'gnupg']    | List of Package that need to be install before Fluentbit. |
| fluentbit_apt_key_url   | https://packages.fluentbit.io/fluentbit.key | The APT key for Fluentbit package.                        |
| fluentbit_apt_repos_url | "https://packages.fluentbit.io/\{{ ansible_distribution \| lower }}/{{ ansible_distribution_release \| lower }} {{ ansible_distribution_release \| lower }}"  | The APT repository address needed to install Fluentbit. |
| fluentbit_pkg_name      | td-agent-bit                                | The Fluentbit APT package name.                           |
| fluentbit_svc_name      | td-agent-bit                                | The Fluentbit service name to start/stop the daemon.      |
| fluentbit_version       | *Undefined*                                 | If undefined and Fluentbit not already present, install the latest. If undefined ans Fluentbit already present, do nothing.|

Variables use for the general configuration:

| Variables               | Default value   | Description                                               |
|-------------------------|-----------------|-----------------------------------------------------------|
| fluentbit_svc_flush     | 5               | Flush time in *seconds.nanoseconds* format.               |
| fluentbit_svc_grace     | 5               | Set the grace time is *seconds*.                          |
| fluentbit_svc_daemon    | Off             | On/Off value to specify if Fluentbit run as a Deamon. Should be Off when use with Sytemd. |
| fluentbit_svc_logfile   | ""              | Absolute path for an optional log file. Log to stdout if not specify. |
| fluentbit_svc_loglevel  | info            | Set the logging verbosity level.                          |
| fluentbit_svc_parsers   | [parsers.conf]  | List of paths for *parsers* configuration files.          |
| fluentbit_svc_plugins   | [plugins.conf]  | List of paths for *plugins* configuration files.          |
| fluentbit_svc_streams   | []              | List of paths for *stream processors* configuration files.|
| fluentbit_svc_http      | {}              | Dictionary for HTTP built-in server configuration.        |
| fluentbit_svc_storage   | {}              | Dictionary for storage/buffer configuration.              |

Other variables:

| Variables               | Default value | Description                                               |
|-------------------------|---------------|-----------------------------------------------------------|
| fluentbit_dbs_path      | ""            | Path for a directory that will be created by the role. For example to store your input DB files. |

Variables for log processing:

| Variables               | Default value                                         | Description                                    |
|-------------------------|-------------------------------------------------------|------------------------------------------------|
| _fluentbit_inputs       | "{{ lookup('template', './lookup/get_inputs.j2') }}"  | List of dictionaries defining all log inputs.  |
| _fluentbit_filters      | "{{ lookup('template', './lookup/get_filters.j2') }}" | List of dictionaries defining all log filters. |
| _fluentbit_outputs      | "{{ lookup('template', './lookup/get_outputs.j2') }}" | List of dictionaries defining all log outputs. |

**In most cases, you should not modify these variables.**
Templating is use to build these lists with others variables.
* `_fluentbit_inputs` will agregate all the variables whose name matches this regex: `^fluentbit_.+_input$`.
* `_fluentbit_filters` will agregate all the variables whose name matches this regex: `^fluentbit_.+_filter$'`.
* `_fluentbit_outputs` will agregate all the variables whose name matches this regex: `^fluentbit_.+_output$`.

Each varibles matching these regexes must be:
  - a dictionary defining one input/filter/output **or**
  - a list of dictionaries defining one or more inputs/filters/outputs.

Each dictionary is used to define one `[INPUT]`, `[FILTER]` or `[OUTPUT]` section
in Fluentbit configuration file. Keys are used to defined keys of this section
and values to defined the values.

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

This allow you to defined variables in multiples groupvars and cumulate them for
hosts in multiples groups, without the need to rewrite the complete list.


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

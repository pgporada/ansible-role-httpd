# Overview: ansible-role-httpd
This role will set up httpd (Apache), configure any vhosts you've defined, and setup any rewrite/redirect rules. I configure my vhosts in a way that senior admins had taught me when I worked in a datacenter. I've since continued to follow this method for my career. This setup is opinionated. You may not agree.

- - - -

## Variable definitions

Use this if you're running httpd behind a loadbalancer such as ELB or HaProxy. If true will copy the customer_logger.conf in to `/etc/httpd/conf.d/`. The customer logger will get the x-forwarded source IP header.

    httpd_is_behind_loadbalancer: false

Sets the default document root directory in `/etc/httpd/conf/httpd.conf`. This typically needs to be overridden for a vagrant, otherwise leave it alone.

    httpd_conf_docrootdir: /var/www/domains

Set the ports that httpd will listen on.

    httpd_conf_port: 80
    httpd_conf_port_ssl: 443

Enable or disable the httpd keepalive directive. Boolean for ansible. [Docs](https://httpd.apache.org/docs/2.4/mod/core.html#keepalive)

    httpd_conf_keepalive_enable: true

Multi-processing module for processing requests. [Docs](https://httpd.apache.org/docs/2.4/mpm.html)

    httpd_conf_mpm: prefork # Other valid options are 'event' and 'worker'

Use mod_headers to set httponly and secure on all cookies. There are implications here. Boolean, defaults to false. [Docs](https://www.tunetheweb.com/security/http-security-headers/secure-cookies/)

    httpd_conf_securecookies: false

- - - -

# Example Playbook

    ---
    - hosts: localhost
      connection: local
      become: true
      become_method: sudo

      vars:
        httpd_vhosts_enabled:
          - url: jenkins.philporada.com
            enable_ssl_vhost: false
            #path_to_ssl_ca: /path/to/ca.pem
            #path_to_ssl_cert: /path/to/cert.pem
            #path_to_ssl_key: /path/to/key.pem
            #path_to_ssl_chain: /path/to/bundle.pem
            aliases: []
            serveradmin: ops@philporada.com
            errorlog: "/var/log/httpd/error_log"
            accesslog: "/var/log/httpd/access_log"
            directory: "/var/www"
            docrootdir: public_html
            extra_parameters_main: |
              #
          	  #RewriteEngine On
              # Rewrites requests from the ELB to https
              # We want to match on http specifically instead of the negative, !https, due to healthchecks failing at the 301 redirect
              #RewriteCond %{HTTP:X-Forwarded-Proto} ^http$
              #RewriteRule ^.*$ https://%{SERVER_NAME}%{REQUEST_URI}
            extra_parameters_include: |
              #
              # This is vagrant specific
              #EnableSendfile Off
              # Hide git related stuff
              RewriteRule ^(.*/)?\.git+ - [R=404,L]
              RewriteRule ^(.*/)?\.gitignore+ - [R=404,L]

      roles:
        - ansible-roles-httpd
    ...

- - - -

# How to hack away at this role

Prior to running any tests, you should validate your syntax with [yamllint](https://github.com/adrienverge/yamllint).

    find . -type f -name "*.yml*" | sed "s|\./||g" | egrep -v "(\.kitchen/|\[warning\]|\.molecule/)" | xargs yamllint -f parsable

You should see output such as the following which you can take manual action on, or simply ignore. You can easily see we did find an error though. The error would probably prevented ansible from running to completion. Spotting these is a GOOD THING.

    $ find . -type f -name "*.yml*" | sed "s|\./||g" | egrep -v "(\.kitchen/|\[warning\]|\.molecule/)" | xargs yamllint -f parsable
    defaults/main.yml:41:121: [warning] line too long (127 > 120 characters) (line-length)
    meta/main.yml:7:22: [error] syntax error: mapping values are not allowed here
    test/integration/default/default.yml:4:1: [warning] comment not indented like content (comments-indentation)
    test/requirements.yml:2:2: [warning] missing starting space in comment (comments)

You will need a ruby environment to install the gems for [test-kitchen](http://kitchen.ci/). We install the gems through [bundler](https://bundler.io/).

    git clone git@github.com:pgporada/ansible-role-httpd.git
    bundle install
    bundle update
    bundle exec kitchen create
    bundle exec kitchen converge
    bundle exec kitchen verify
    bundle exec kitchen destroy

You should now be able to access the [default page](http://192.168.33.15/) as defined by the `.kitchen.yml` file.

- - - -
# Theme Music
[The Skatalites - Ska Ska Ska](https://www.youtube.com/watch?v=EcoNPm3pyqg)

- - - -
# Author Information

GPLv3

Phil Porada

# == Class: docker
#
# Module to install an up-to-date version of Docker from package.
#
# === Parameters
#
# [*version*]
#   The package version to install, used to set the package name.
#   Defaults to undefined
#
# [*ensure*]
#   Passed to the docker package.
#   Defaults to present
#
# [*prerequired_packages*]
#   An array of additional packages that need to be installed to support
#   docker. Defaults change depending on the operating system.
#
# [*docker_cs*]
#   Whether or not to use the CS (Commercial Support) Docker packages.
#   Defaults to false.
#
# [*tcp_bind*]
#   The tcp socket to bind to in the format
#   tcp://127.0.0.1:4243
#   Defaults to undefined
#
# [*tls_enable*]
#   Enable TLS.
#   Defaults to false
#
# [*tls_verify*]
#  Use TLS and verify the remote
#  Defaults to true
#
# [*tls_cacert*]
#   Path to TLS CA certificate
#   Defaults to '/etc/docker/ca.pem'
#
# [*tls_cert*]
#   Path to TLS certificate file
#   Defaults to '/etc/docker/cert.pem'
#
# [*tls_key*]
#   Path to TLS key file
#   Defaults to '/etc/docker/cert.key'
#
# [*ip_forward*]
#   Enables IP forwarding on the Docker host.
#   The default is true.
#
# [*iptables*]
#   Enable Docker's addition of iptables rules.
#   Default is true.
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#   The default is true.
#
# [*icc*]
#   Enable or disable Docker's unrestricted inter-container and Docker daemon host communication.
#   (Requires iptables=true to disable)
#   Default is undef. (Docker daemon's default is true)
#
# [*bip*]
#   Specify docker's network bridge IP, in CIDR notation.
#   Defaults to undefined.
#
# [*mtu*]
#   Docker network MTU.
#   Defaults to undefined.
#
# [*bridge*]
#   Attach containers to a pre-existing network bridge
#   use 'none' to disable container networking
#   Defaults to undefined.
#
# [*fixed_cidr*]
#   IPv4 subnet for fixed IPs
#   10.20.0.0/16
#   Defaults to undefined
#
# [*default_gateway*]
#   IPv4 address of the container default gateway;
#   this address must be part of the bridge subnet
#   (which is defined by bridge)
#   Defaults to undefined
#
# [*socket_bind*]
#   The unix socket to bind to. Defaults to
#   unix:///var/run/docker.sock.
#
# [*log_level*]
#   Set the logging level
#   Defaults to undef: docker defaults to info if no value specified
#   Valid values: debug, info, warn, error, fatal
#
# [*log_driver*]
#   Set the log driver.
#   Defaults to undef.
#   Docker default is json-file.
#   Valid values: none, json-file, syslog, journald, gelf, fluentd
#   Valid values description:
#     none     : Disables any logging for the container.
#                docker logs won't be available with this driver.
#     json-file: Default logging driver for Docker.
#                Writes JSON messages to file.
#     syslog   : Syslog logging driver for Docker.
#                Writes log messages to syslog.
#     journald : Journald logging driver for Docker.
#                Writes log messages to journald.
#     gelf     : Graylog Extended Log Format (GELF) logging driver for Docker.
#                Writes log messages to a GELF endpoint: Graylog or Logstash.
#     fluentd  : Fluentd logging driver for Docker.
#                Writes log messages to fluentd (forward input).
#     splunk   : Splunk logging driver for Docker.
#                Writes log messages to Splunk (HTTP Event Collector).
#
# [*log_opt*]
#   Set the log driver specific options
#   Defaults to undef
#   Valid values per log driver:
#     none     : undef
#     json-file:
#                max-size=[0-9+][k|m|g]
#                max-file=[0-9+]
#     syslog   :
#                syslog-address=[tcp|udp]://host:port
#                syslog-address=unix://path
#                syslog-facility=daemon|kern|user|mail|auth|
#                                syslog|lpr|news|uucp|cron|
#                                authpriv|ftp|
#                                local0|local1|local2|local3|
#                                local4|local5|local6|local7
#                syslog-tag="some_tag"
#     journald : undef
#     gelf     :
#                gelf-address=udp://host:port
#                gelf-tag="some_tag"
#     fluentd  :
#                fluentd-address=host:port
#                fluentd-tag={{.ID}} - short container id (12 characters)|
#                            {{.FullID}} - full container id
#                            {{.Name}} - container name
#     splunk   :
#                splunk-token=<splunk_http_event_collector_token>
#                splunk-url=https://your_splunk_instance:8088
#
# [*selinux_enabled*]
#   Enable selinux support. Default is false. SELinux does  not  presently
#   support  the  BTRFS storage driver.
#   Valid values: true, false
#
# [*use_upstream_package_source*]
#   Whether or not to use the upstream package source.
#   If you run your own package mirror, you may set this
#   to false.
#
# [*pin_upstream_package_source*]
#   Pin upstream package source; this option currently only has any effect on
#   apt-based distributions.  Set to false to remove pinning on the upstream
#   package repository.  See also "apt_source_pin_level".
#   Defaults to true
#
# [*apt_source_pin_level*]
#   What level to pin our source package repository to; this only is relevent
#   if you're on an apt-based system (Debian, Ubuntu, etc) and
#   $use_upstream_package_source is set to true.  Set this to false to disable
#   pinning, and undef to ensure the apt preferences file apt::source uses to
#   define pins is removed.
#   Defaults to 10
#
# [*package_source_location*]
#   If you're using an upstream package source, what is it's
#   location. Defaults to http://get.docker.com/ubuntu on Debian
#
# [*service_state*]
#   Whether you want to docker daemon to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to docker daemon to start up at boot
#   Defaults to true
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
#
# [*root_dir*]
#   Custom root directory for containers
#   Defaults to undefined
#
# [*manage_kernel*]
#   Attempt to install the correct Kernel required by docker
#   Defaults to true
#
# [*dns*]
#   Custom dns server address
#   Defaults to undefined
#
# [*dns_search*]
#   Custom dns search domains
#   Defaults to undefined
#
# [*socket_group*]
#   Group ownership of the unix control socket.
#   Defaults to undefined
#
# [*extra_parameters*]
#   Any extra parameters that should be passed to the docker daemon.
#   Defaults to undefined
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*proxy*]
#   Will set the http_proxy and https_proxy env variables in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*no_proxy*]
#   Will set the no_proxy variable in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
#
# [*manage_package*]
#   Won't install or define the docker package, useful if you want to use your own package
#   Defaults to true
#
# [*package_name*]
#   Specify custom package name
#   Default is set on a per system basis in docker::params
#
# [*service_name*]
#   Specify custom service name
#   Default is set on a per system basis in docker::params
#
# [*docker_command*]
#   Specify a custom docker command name
#   Default is set on a per system basis in docker::params
#
# [*daemon_command*]
#   Specify a custom docker command name
#   Default is 'dockerd'
#
# [*daemon_subcommand*]
#  **Deprecated** Use daemon_command
#  Specify a subcommand/flag for running docker as daemon
#  Default is set on a per system basis in docker::params
#
# [*docker_users*]
#   Specify an array of users to add to the docker group
#   Default is empty
#
# [*docker_group*]
#   Specify a string for the docker group
#   Default is OS and package specific
#
# [*daemon_environment_files*]
#   Specify additional environment files to add to the
#   service-overrides.conf
#
# [*repo_opt*]
#   Specify a string to pass as repository options (RedHat only)
#
#
class docker(
  $version                           = $docker::params::version,
  $ensure                            = $docker::params::ensure,
  $prerequired_packages              = $docker::params::prerequired_packages,
  $docker_cs                         = $docker::params::docker_cs,
  $package_cs_source_location        = $docker::params::package_cs_source_location,
  $package_cs_key_source             = $docker::params::package_cs_key_source,
  $tcp_bind                          = $docker::params::tcp_bind,
  $tls_enable                        = $docker::params::tls_enable,
  $tls_verify                        = $docker::params::tls_verify,
  $tls_cacert                        = $docker::params::tls_cacert,
  $tls_cert                          = $docker::params::tls_cert,
  $tls_key                           = $docker::params::tls_key,
  $ip_forward                        = $docker::params::ip_forward,
  $ip_masq                           = $docker::params::ip_masq,
  $bip                               = $docker::params::bip,
  $mtu                               = $docker::params::mtu,
  $iptables                          = $docker::params::iptables,
  $icc                               = $docker::params::icc,
  $socket_bind                       = $docker::params::socket_bind,
  $fixed_cidr                        = $docker::params::fixed_cidr,
  $bridge                            = $docker::params::bridge,
  $default_gateway                   = $docker::params::default_gateway,
  $log_level                         = $docker::params::log_level,
  $log_driver                        = $docker::params::log_driver,
  $log_opt                           = $docker::params::log_opt,
  $selinux_enabled                   = $docker::params::selinux_enabled,
  $use_upstream_package_source       = $docker::params::use_upstream_package_source,
  $pin_upstream_package_source       = $docker::params::pin_upstream_package_source,
  $apt_source_pin_level              = $docker::params::apt_source_pin_level,
  $package_source_location           = $docker::params::package_source_location,
  $package_release                   = $docker::params::package_release,
  $package_repos                     = $docker::params::package_repos,
  $package_key                       = $docker::params::package_key,
  $package_key_source                = $docker::params::package_key_source,
  $service_state                     = $docker::params::service_state,
  $service_enable                    = $docker::params::service_enable,
  $manage_service                    = $docker::params::manage_service,
  $root_dir                          = $docker::params::root_dir,
  $tmp_dir                           = $docker::params::tmp_dir,
  $manage_kernel                     = $docker::params::manage_kernel,
  $dns                               = $docker::params::dns,
  $dns_search                        = $docker::params::dns_search,
  $socket_group                      = $docker::params::socket_group,
  $labels                            = $docker::params::labels,
  $extra_parameters                  = undef,
  $shell_values                      = undef,
  $proxy                             = $docker::params::proxy,
  $no_proxy                          = $docker::params::no_proxy,
  $execdriver                        = $docker::params::execdriver,
  $manage_package                    = $docker::params::manage_package,
  $package_source                    = $docker::params::package_source,
  $manage_epel                       = $docker::params::manage_epel,
  $package_name                      = $docker::params::package_name,
  $service_name                      = $docker::params::service_name,
  $docker_command                    = $docker::params::docker_command,
  $daemon_command                    = $docker::params::daemon_command,
  $daemon_subcommand                 = $docker::params::daemon_subcommand,
  $docker_users                      = [],
  $docker_group                      = $docker::params::docker_group,
  $daemon_environment_files          = [],
  $repo_opt                          = $docker::params::repo_opt,
  $nowarn_kernel                     = $docker::params::nowarn_kernel,
  $service_provider                  = $docker::params::service_provider,
  $service_config                    = $docker::params::service_config,
  $service_config_template           = $docker::params::service_config_template,
  $service_overrides_template        = $docker::params::service_overrides_template,
  $service_hasstatus                 = $docker::params::service_hasstatus,
  $service_hasrestart                = $docker::params::service_hasrestart,
  $manage_storage                    = false,
  $storage_driver                    = undef,
  $provision_container_root_lv       = true,
  $root_fs_options                   = undef,
  $root_fs_type                      = 'xfs',
  $root_fs_mount_options             = 'defaults,nodev',
  $root_lv                           = 'data',
  $root_lv_size                      = '2G',
  $root_lv_initial_size              = '2G',
  $root_lv_size_is_minsize           = true,
  $root_mount_dir                    = '/var/lib/docker',
  $extra_storage_options             = undef,
  $devs                              = undef,
  $container_thinpool                = 'thinpool',
  $vg                                = undef,
  $root_size                         = '8G',
  $data_size                         = '40%FREE',
  $min_data_size                     = '2G',
  $pool_meta_size                    = '16M',
  $chunk_size                        = '512K',
  $growpart                          = false,
  $auto_extend_pool                  = 'yes',
  $pool_autoextend_threshold         = '60',
  $pool_autoextend_percent           = '20',
  $wipe_signatures                   = true,
  $exec_path = ['/usr/local/bin', '/usr/bin']
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux|Gentoo)$',
              'This module only works on Debian or Red Hat based systems or on Archlinux as on Gentoo.')
  validate_bool($manage_kernel)
  validate_bool($manage_package)
  validate_bool($docker_cs)
  validate_bool($manage_service)
  validate_array($docker_users)
  validate_array($daemon_environment_files)
  validate_array($log_opt)
  validate_bool($tls_enable)
  validate_bool($ip_forward)
  validate_bool($iptables)
  validate_bool($ip_masq)
  if $icc != undef {
    validate_bool($icc)
  }
  validate_string($bridge)
  validate_string($fixed_cidr)
  validate_string($default_gateway)
  validate_string($bip)

  if ($default_gateway) and (!$bridge) {
    fail('You must provide the $bridge parameter.')
  }

  if $log_level {
    validate_re($log_level, '^(debug|info|warn|error|fatal)$', 'log_level must be one of debug, info, warn, error or fatal')
  }

  if $log_driver {
    validate_re($log_driver, '^(none|json-file|syslog|journald|gelf|fluentd|splunk)$',
                'log_driver must be one of none, json-file, syslog, journald, gelf, fluentd or splunk')
  }

  if $selinux_enabled {
    validate_re($selinux_enabled, '^(true|false)$', 'selinux_enabled must be true or false')
  }

  if($tls_enable) {
    if(!$tcp_bind) {
        fail('You need to provide tcp bind parameter for TLS.')
    }
    validate_string($tls_cacert)
    validate_string($tls_cert)
    validate_string($tls_key)
  }

  class { 'docker::repos': }
  -> class { 'docker::container_storage': }
  -> class { 'docker::install': }
  -> class { 'docker::config': }
  ~> class { 'docker::service': }
  contain 'docker::repos'
  contain 'docker::container_storage'
  contain 'docker::install'
  contain 'docker::config'
  contain 'docker::service'

  Class['docker'] -> Docker::Registry <||> -> Docker::Image <||> -> Docker::Run <||>
  Class['docker'] -> Docker::Image <||> -> Docker::Run <||>
  Class['docker'] -> Docker::Run <||>
}

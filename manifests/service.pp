# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*ip_forward*]
#   This flag interacts with the IP forwarding setting on
#   your host system's kernel
#
# [*iptables*]
#   Enable Docker's addition of iptables rules
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
#
class docker::service (
  $service_name                      = $docker::service_name,
  $daemon_command                    = $docker::daemon_command,
  $tcp_bind                          = $docker::tcp_bind,
  $ip_forward                        = $docker::ip_forward,
  $iptables                          = $docker::iptables,
  $ip_masq                           = $docker::ip_masq,
  $icc                               = $docker::icc,
  $bridge                            = $docker::bridge,
  $fixed_cidr                        = $docker::fixed_cidr,
  $default_gateway                   = $docker::default_gateway,
  $socket_bind                       = $docker::socket_bind,
  $log_level                         = $docker::log_level,
  $log_driver                        = $docker::log_driver,
  $log_opt                           = $docker::log_opt,
  $selinux_enabled                   = $docker::selinux_enabled,
  $socket_group                      = $docker::socket_group,
  $labels                            = $docker::labels,
  $dns                               = $docker::dns,
  $dns_search                        = $docker::dns_search,
  $service_state                     = $docker::service_state,
  $service_enable                    = $docker::service_enable,
  $manage_service                    = $docker::manage_service,
  $root_dir                          = $docker::root_dir,
  $extra_parameters                  = $docker::extra_parameters,
  $shell_values                      = $docker::shell_values,
  $proxy                             = $docker::proxy,
  $no_proxy                          = $docker::no_proxy,
  $execdriver                        = $docker::execdriver,
  $bip                               = $docker::bip,
  $mtu                               = $docker::mtu,
  $tmp_dir                           = $docker::tmp_dir,
  $nowarn_kernel                     = $docker::nowarn_kernel,
  $service_provider                  = $docker::service_provider,
  $service_config                    = $docker::service_config,
  $service_config_template           = $docker::service_config_template,
  $service_overrides_template        = $docker::service_overrides_template,
  $service_hasstatus                 = $docker::service_hasstatus,
  $service_hasrestart                = $docker::service_hasrestart,
  $daemon_environment_files          = $docker::daemon_environment_files,
  $tls_enable                        = $docker::tls_enable,
  $tls_verify                        = $docker::tls_verify,
  $tls_cacert                        = $docker::tls_cacert,
  $tls_cert                          = $docker::tls_cert,
  $tls_key                           = $docker::tls_key,
  $manage_storage                    = $docker::manage_storage,
) {

  unless $::osfamily =~ /(Debian|RedHat|Archlinux|Gentoo)/ {
    fail('The docker::service class needs a Debian, RedHat, Archlinux or Gentoo based system.')
  }

  $dns_array = any2array($dns)
  $dns_search_array = any2array($dns_search)
  $extra_parameters_array = any2array($extra_parameters)
  $shell_values_array = any2array($shell_values)
  $tcp_bind_array = any2array($tcp_bind)

  if $service_config {
    $_service_config = $service_config
  } else {
    if $::osfamily == 'Debian' {
      $_service_config = "/etc/default/${service_name}"
    }
  }

  $_manage_service = $manage_service ? {
    true    => Service['docker'],
    default => [],
  }

  case $service_provider {
    'systemd': {
      file { '/etc/systemd/system/docker.service.d':
        ensure => directory,
      }

      if $service_overrides_template {
        file { '/etc/systemd/system/docker.service.d/service-overrides.conf':
          ensure  => present,
          content => template($service_overrides_template),
          notify  => Exec['docker-systemd-reload-before-service'],
          before  => $_manage_service,
        }
        exec { 'docker-systemd-reload-before-service':
          path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
          command     => 'systemctl daemon-reload > /dev/null',
          before      => $_manage_service,
          refreshonly => true,
        }
      }
    }
    'upstart': {
      file { '/etc/init.d/docker':
        ensure => 'link',
        target => '/lib/init/upstart-job',
        force  => true,
        notify => $_manage_service,
      }
    }
    default: {}
  }

  if $_service_config {
    file { $_service_config:
      ensure  => present,
      force   => true,
      content => template($service_config_template),
      notify  => $_manage_service,
    }
  }

  if $manage_storage {
    service {'docker-storage-setup':
      ensure => 'running',
      name   => 'docker-storage-setup',
      enable => true,
      before => Service['docker']
    }
  }

  if $manage_service {
    service { 'docker':
      ensure     => $service_state,
      name       => $service_name,
      enable     => $service_enable,
      hasstatus  => $service_hasstatus,
      hasrestart => $service_hasrestart,
      provider   => $service_provider,
    }
  }
}

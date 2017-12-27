# == Class: docker::config
#
# Configures users to be added to the docker group.
#
# Configures a selinux module to allow container access to the docker
# daemon's unix socket.
#
class docker::config (
  $selinux_dockersock_enabled = $docker::selinux_dockersock_enabled,
){

  docker::system_user { $docker::docker_users: }

  if $::osfamily == 'RedHat' and $selinux_dockersock_enabled {

    selinux::module { 'dockersock':
      ensure    => 'present',
      source_te => 'puppet:///modules/docker/dockersock.te',
      builder   => 'simple'
    }
  }
}

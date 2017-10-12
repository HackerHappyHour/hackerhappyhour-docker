# == Class: docker::repository
#
#
class docker::repository (
  $docker_repository,
  $manage_repos = $docker::manage_package_repository
) {

  if $manage_repos {
    case $facts['os']['family'] {
      'Debian': {
        include apt
        create_resources('apt::source', $docker_repository)
      }
      'RedHat': {
        create_resources('yumrepo', $docker_repository)
      }
      default: {}
    }
  }
}

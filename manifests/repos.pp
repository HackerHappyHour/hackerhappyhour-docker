# == Class: docker::repository
#
#
class docker::repository (
  $manage_repos = $docker::manage_package_repository,
  $docker_repository
) {

  case $::osfamily {
    'Debian': {
      include apt
      create_resources('apt::source', $docker_repo)
    }
    'RedHat': {
      create_resources('yumrepo', $docker_repo)
    }
  }
}

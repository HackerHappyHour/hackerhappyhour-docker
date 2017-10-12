# == Class: docker::repos
#
#
class docker::repos(
  $manage_repos = $docker::manage_package_repository,
  $location = $docker::package_source_location,
  $key_source = $docker::package_key_source
) {

  case $::osfamily {
    'Debian': {}
    'RedHat': {}
  }
}

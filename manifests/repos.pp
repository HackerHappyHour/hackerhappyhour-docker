# == Class: docker::repos
#
#
class docker::repos(
  $manage_css_repo = $docker::manage_css_repo,
  $css_name = $docker::css_name,
  $css_ensure = $docker::css_ensure,
  $css_baseurl = $docker::css_baseurl,
  $css_repo_enabled = $docker::css_repo_enabled,
  $css_sslverify = $docker::css_sslverify,
  $css_gpgcheck = $docker::css_gpgcheck,
  $css_repogpgcheck = $docker::css_repogpgcheck,
  $css_apt_location = $docker::css_apt_location,
  $css_apt_release = $docker::css_apt_release,
  $css_apt_repos = $docker::css_apt_repos){

  ensure_packages($docker::prerequired_packages)

  case $::osfamily {
    'Debian': {
      if ($docker::use_upstream_package_source) {
        if ($docker::docker_cs) {
          $location = $docker::package_cs_source_location
          $key_source = $docker::package_cs_key_source
          $package_key = $docker::package_cs_key
        } else {
          $location = $docker::package_source_location
          $key_source = $docker::package_key_source
          $package_key = $docker::package_key
        }
        ensure_packages(['debian-keyring', 'debian-archive-keyring'])
        apt::source { 'docker':
          location => $location,
          release  => $docker::package_release,
          repos    => $docker::package_repos,
          key      => {
            'id'     => $package_key,
            'server' => 'hkp://keyserver.ubuntu.com:80',
          },
          require  => [
            Package['debian-keyring'],
            Package['debian-archive-keyring'],
          ],
        }
        $url_split = split($location, '/')
        $repo_host = $url_split[2]
        $pin_ensure = $docker::pin_upstream_package_source ? {
            true    => 'present',
            default => 'absent',
        }
        apt::pin { 'docker':
          ensure   => $pin_ensure,
          origin   => $repo_host,
          priority => $docker::apt_source_pin_level,
        }
        if $docker::manage_package {
          include apt
          if $::operatingsystem == 'Debian' and $::lsbdistcodename == 'wheezy' {
            include apt::backports
          }
          Exec['apt_update'] -> Package[$docker::prerequired_packages]
          Apt::Source['docker'] -> Package['docker']
        }
        if $docker::manage_css_repo {
          apt::source {'container-storage-setup':
            comment  => 'Service to set up storage for Docker and other cntainer systems',
            location => $css_apt_location,
            release  => $css_apt_release,
            repos    => $css_apt_repos
          }
          Apt::Source['container-storage-setup'] -> Package['container-storage-setup']
        }

      }

    }
    'RedHat': {
      if $docker::manage_package {
        if ($docker::docker_cs) {
          $baseurl = $docker::package_cs_source_location
          $gpgkey = $docker::package_cs_key_source
        } else {
          $baseurl = $docker::package_source_location
          $gpgkey = $docker::package_key_source
        }
        if ($docker::manage_css_repo){

          yumrepo {'container-storage-setup':
            ensure        => $css_ensure,
            descr         => 'Service to set up storage for Docker and other container systems',
            name          => $css_name,
            baseurl       => $css_baseurl,
            enabled       => $css_repo_enabled,
            sslverify     => $css_sslverify,
            gpgcheck      => $css_gpgcheck,
            repo_gpgcheck => $css_repogpgcheck,
          }
          Yumrepo['container-storage-setup'] -> Package['container-storage-setup']
        }
        if ($docker::use_upstream_package_source) {
          yumrepo { 'docker':
            descr    => 'Docker',
            baseurl  => $baseurl,
            gpgkey   => $gpgkey,
            gpgcheck => true,
          }
          Yumrepo['docker'] -> Package['docker']
        }
        if ($::operatingsystem != 'Amazon') and ($::operatingsystem != 'Fedora') {
          if ($docker::manage_epel == true) {
            include 'epel'
            Class['epel'] -> Package['docker']
          }
        }
      }
    }
    default: {}
  }
}

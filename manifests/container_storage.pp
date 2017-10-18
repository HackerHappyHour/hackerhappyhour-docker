class docker::container_storage (
  $manage_storage = false,
  $storage_driver = undef,
  $extra_storage_options = undef,
  $devs = undef,
  $container_thinpool = 'container-thinpool',
  $vg = undef,
  $root_size = '8G',
  $data_size = '40%FREE',
  $min_data_size = '2G',
  $pool_meta_size = '16M',
  $chunk_size = '512K',
  $growpart = false,
  $auto_extend_pool = 'yes',
  $pool_autoextend_threshold = '60',
  $pool_autoextend_percent = '20',
  $wipe_signatures = true,
  $container_storage_setup_config_file = '/etc/sysconfig/docker-storage-setup',
  $container_storage_output_file = '/etc/sysconfig/docker-storage',
  $container_storage_setup_script = '/usr/local/bin/container-storage-setup.sh',
  $container_storage_setup_child_script = '/usr/local/bin/css-child-read-write.sh',
  $container_storage_setup_libcss_script = '/usr/local/bin/libcss.sh',
  $exec_path = ['/usr/local/bin', '/usr/bin']
){

  if $manage_storage {
    file {$container_storage_setup_script:
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/docker/container-storage-setup.sh'
    }

    file {$container_storage_setup_child_script:
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/docker/css-child-read-write.sh'
    }

    file {$container_storage_setup_libcss_script:
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/docker/libcss.sh'
    }

    file {$container_storage_setup_config_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('docker/storage/container-storage-setup.conf.epp', {
        'storage_driver'            => $storage_driver,
        'extra_storage_options'     => $extra_storage_options,
        'devs'                      => $devs,
        'container_thinpool'        => $container_thinpool,
        'vg'                        => $vg,
        'root_size'                 => $root_size,
        'data_size'                 => $data_size,
        'min_data_size'             => $min_data_size,
        'pool_meta_size'            => $pool_meta_size,
        'chunk_size'                => $chunk_size,
        'growpart'                  => $growpart,
        'auto_extend_pool'          => $auto_extend_pool,
        'pool_autoextend_threshold' => $pool_autoextend_threshold,
        'pool_autoextend_percent'   => $pool_autoextend_percent,
        'wipe_signatures'           => $wipe_signatures
        })
    }

    Exec{$container_storage_setup_script:
      command => "${container_storage_setup_script} ${container_storage_setup_config_file} ${container_storage_output_file}",
      path    => $exec_path,
      unless  => "test -f ${container_storage_output_file}",
      require => File[$container_storage_setup_script, $container_storage_setup_child_script, $container_storage_setup_config_file, $container_storage_setup_libcss_script]
    }
  }

}

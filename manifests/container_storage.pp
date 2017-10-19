class docker::container_storage (
  $manage_storage = false,
  $storage_driver = undef,
  $provision_container_root_lv = true,
  $root_fs_options = undef,
  $root_fs_type = 'xfs',
  $root_fs_mount_options = 'defaults,nodev',
  $root_lv = 'data',
  $root_lv_size = '2G',
  $root_lv_initial_size = '2G',
  $root_lv_size_is_minsize = true,
  $root_mount_dir = '/var/lib/docker',
  $extra_storage_options = undef,
  $devs = undef,
  $container_thinpool = 'thinpool',
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

  if $provision_container_root_lv {
    include lvm
    physical_volume{shell_split($devs):
      ensure => 'present',
      before => [Exec[$container_storage_setup_script], Volume_group[$vg]]
    }

    volume_group {$vg:
      ensure           => 'present',
      physical_volumes => $devs,
      before           => [Exec[$container_storage_setup_script],Logical_volume[$root_lv]]
    }

    logical_volume { $root_lv:
      ensure          => 'present',
      volume_group    => $vg,
      initial_size    => $root_lv_initial_size,
      size            => $root_lv_size,
      size_is_minsize => $root_lv_size_is_minsize,
      require         => Volume_group[$vg],
      before          => Exec[$container_storage_setup_script]
    }

    $root_fs = "/dev/mapper/${vg}-${root_lv}"
    filesystem { $root_fs:
      ensure       => 'present',
      fs_type      => $root_fs_type,
      options      => $root_fs_options,
      volume_group => $vg,
      before       => Exec[$container_storage_setup_script]
    }

    exec {$root_mount_dir:
      command => "mkdir -p ${root_mount_dir} && chmod 0755 ${root_mount_dir}",
      path    => ['/bin', '/usr/lib', '/usr/bin', '/sbin', '/usr/local/bin'],
      unless  => "test -d ${root_mount_dir}",
      before  => Exec[$container_storage_setup_script]
    }

    mount {$root_mount_dir:
      ensure   => 'mounted',
      fstype   => $root_fs_type,
      device   => $root_fs,
      options  => $root_fs_mount_options,
      dump     => '1',
      pass     => '2',
      remounts => true,
      atboot   => true,
      before   => [File[$root_mount_dir],Exec[$container_storage_setup_script]],
      require  => [Filesystem[$root_fs],Exec[$root_mount_dir]],
    }

    file {$root_mount_dir:
      ensure => 'directory',
      before => Exec[$container_storage_setup_script]
    }

  }

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
        }),
      before  => Exec[$container_storage_setup_script]
    }

    exec {$container_storage_setup_script:
      command => $container_storage_setup_script,
      path    => $exec_path,
      unless  => "test -e ${container_storage_output_file}",
      require => File[$container_storage_setup_script, $container_storage_setup_child_script, $container_storage_setup_config_file, $container_storage_setup_libcss_script]
    }
  }

}

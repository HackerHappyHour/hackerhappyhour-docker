class docker::container_storage (
  $manage_storage = $docker::manage_storage,
  $storage_driver = $docker::storage_driver,
  $provision_container_root_lv = $docker::provision_container_root_lv,
  $root_fs_options = $docker::root_fs_options,
  $root_fs_type = $docker::root_fs_type,
  $root_fs_mount_options = $docker::root_fs_mount_options,
  $root_lv = $docker::root_lv,
  $root_lv_size = $docker::root_lv_size,
  $root_lv_initial_size = $docker::root_lv_initial_size,
  $root_lv_size_is_minsize = $docker::root_lv_size_is_minsize,
  $root_mount_dir = $docker::root_mount_dir,
  $extra_storage_options = $docker::extra_storage_options,
  $devs = $docker::devs,
  $container_thinpool = $docker::container_thinpool,
  $vg = $docker::vg,
  $root_size = $docker::root_size,
  $data_size = $docker::data_size,
  $min_data_size = $docker::min_data_size,
  $pool_meta_size = $docker::pool_meta_size,
  $chunk_size = $docker::chunk_size,
  $growpart = $docker::growpart,
  $auto_extend_pool = $docker::auto_extend_pool,
  $pool_autoextend_threshold = $docker::pool_autoextend_threshold,
  $pool_autoextend_percent = $docker::pool_autoextend_percent,
  $wipe_signatures = $docker::wipe_signatures,
  $container_storage_setup_config_file = $docker::container_storage_setup_config_file,
  $container_storage_output_file = $docker::container_storage_output_file,
  $container_storage_setup_script = $docker::container_storage_setup_script,
  $container_storage_setup_child_script = $docker::container_storage_setup_child_script,
  $container_storage_setup_libcss_script = $docker::container_storage_setup_libcss_script,
  $exec_path = $docker::exec_path
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
      before       => Exec[$container_storage_setup_script],
      require      => Logical_volume[$root_lv]
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
      ensure  => 'directory',
      require => Mount[$root_mount_dir],
      before  => Exec[$container_storage_setup_script]
    }

  }

  if $manage_storage {

    if (!$provision_container_root_lv and $devs != undef){
      $create_devs = $devs
    } else {
      $create_devs = false
    }

    file {$container_storage_setup_config_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('docker/storage/container-storage-setup.conf.epp', {
        'storage_driver'            => $storage_driver,
        'extra_storage_options'     => $extra_storage_options,
        'devs'                      => $create_devs,
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
      command => 'container-storage-setup',
      path    => $exec_path,
      unless  => "test -e ${container_storage_output_file}",
      require => File[$container_storage_setup_config_file]
    }
  }

}

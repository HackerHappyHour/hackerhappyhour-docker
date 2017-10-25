class docker::container_storage (
  $manage_storage = $docker::manage_storage,
  $storage_driver = $docker::storage_driver,
  $container_thinpool = $docker::container_thinpool,
  $extra_storage_options = $docker::extra_storage_options,
  $vg = $docker::vg,
  $devs = $docker::devs,
  $growpart = $docker::growpart,
  $auto_extend_pool = $docker::auto_extend_pool,
  $pool_autoextend_threshold = $docker::pool_autoextend_threshold,
  $pool_autoextend_percent = $docker::pool_autoextend_percent,
  $chunk_size = $docker::chunk_size,
  $device_wait_timeout = $docker::device_wait_timeout,
  $wipe_signatures = $docker::wipe_signatures,
  $container_root_lv_name = $docker::container_root_lv_name,
  $container_root_lv_mount_path = $docker::container_root_lv_mount_path,
  $container_root_lv_size = $docker::container_root_lv_size,
  $root_size = $docker::root_size,
  $data_size = $docker::data_size,
  $min_data_size = $docker::min_data_size,
  $pool_meta_size = $docker::pool_meta_size,
  $container_storage_setup_config_file = $docker::container_storage_setup_config_file,
  $container_storage_setup_output_file = $docker::container_storage_setup_output_file,
  $exec_path = $docker::exec_path,
){

  if $manage_storage {

    if ($devs != undef){
      $create_devs = join($devs, ' ')
    } else {
      $create_devs = false
    }

    file {$container_storage_setup_config_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('docker/storage/container-storage-setup.conf.epp', {
        'storage_driver'               => $storage_driver,
        'container_thinpool'           => $container_thinpool,
        'extra_storage_options'        => $extra_storage_options,
        'devs'                         => $create_devs,
        'vg'                           => $vg,
        'growpart'                     => $growpart,
        'auto_extend_pool'             => $auto_extend_pool,
        'pool_autoextend_threshold'    => $pool_autoextend_threshold,
        'pool_autoextend_percent'      => $pool_autoextend_percent,
        'chunk_size'                   => $chunk_size,
        'device_wait_timeout'          => $device_wait_timeout,
        'wipe_signatures'              => $wipe_signatures,
        'container_root_lv_name'       => $container_root_lv_name,
        'container_root_lv_mount_path' => $container_root_lv_mount_path,
        'container_root_lv_size'       => $container_root_lv_size,
        'root_size'                    => $root_size,
        'data_size'                    => $data_size,
        'min_data_size'                => $min_data_size,
        'pool_meta_size'               => $pool_meta_size
        }),
      before  => Exec['container-storage-setup']
    }

      exec {'container-storage-setup':
        command     => 'container-storage-setup',
        refreshonly => true,
        path        => $exec_path,
        subscribe   => File[$container_storage_setup_config_file]
      }
  }

}

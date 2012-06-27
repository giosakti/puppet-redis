class redis::install($ensure=present,
                     $prefix_dir="/usr/local",
                     $version="2.4.14") {
  
  include redis::dependencies
  
  $redis_bin_dir = "${prefix_dir}/bin"
  $redis_src_dir = "${prefix_dir}/src/redis-${version}"

  if $ensure == 'present' {

    file { $redis_src_dir:
      ensure => "directory",
    }

    exec { "fetch redis ${version}": 
      command => "curl -sL https://github.com/antirez/redis/tarball/${version} | tar --strip-components 1 -xz",
      cwd => $redis_src_dir,
      creates => "${redis_src_dir}/Makefile",
      require => File[$redis_src_dir],
    }

    exec { "halt redis":
      command => "/etc/init.d/redis-server stop",
      require => File["/etc/init.d/redis-server"],
    }

    exec { "install redis ${version}":
      command => "make && make install PREFIX=${prefix_dir}",
      cwd => "${redis_src_dir}/src",
      unless => "test `redis-server --version | cut -d ' ' -f 4` = '${version}'",
      require => [Exec["fetch redis ${version}"], Package[$redis::dependencies::packages], Exec["halt redis"]]
    }

  } elsif $ensure == 'absent' {

    file { $redis_src_dir:
      ensure => $ensure,
      recurse => true,
      purge => true,
      force => true,
    }

    file { ["$redis_bin_dir/redis-benchmark",
            "$redis_bin_dir/redis-check-aof",
            "$redis_bin_dir/redis-check-dump",
            "$redis_bin_dir/redis-cli",
            "$redis_bin_dir/redis-server"]:
      ensure => $ensure,
    }

  }
}

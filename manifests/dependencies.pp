class redis::dependencies {
  $packages = ["build-essential", "curl"]

  if !defined(Package['build-essential'])     { package { 'build-essential':      ensure => installed } }
  if !defined(Package['curl'])                { package { 'curl':                 ensure => installed } }
}

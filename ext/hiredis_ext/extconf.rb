require 'mkmf'

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

hiredis_dir = File.expand_path(File.join(File.dirname(__FILE__), %w{.. .. vendor hiredis}))
unless File.directory?(hiredis_dir)
  STDERR.puts "vendor/hiredis missing, please checkout its submodule..."
  exit 1
end

BSD = Config::CONFIG['host_os'].downcase =~ /bsd/
GMAKE_CMD = Config::CONFIG['host_os'].downcase =~ /bsd|solaris/ ? "gmake" : "make"

# Make sure hiredis is built...
system("cd #{hiredis_dir} && #{GMAKE_CMD} static")

# Statically link to hiredis (mkmf can't do this for us)
$CFLAGS << " -I#{hiredis_dir}"
$CFLAGS << " -I/usr/local/include" if BSD
$LDFLAGS << " #{hiredis_dir}/libhiredis.a"
create_makefile('hiredis/ext/hiredis_ext')

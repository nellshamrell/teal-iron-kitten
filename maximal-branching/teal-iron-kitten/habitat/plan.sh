pkg_name=teal-iron-kitten
pkg_origin=smacfarlane
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
if [[ "${HAB_TOOLCHAIN}" == "glibc255" ]]; then 
  pkg_deps=(core/ruby24)
else
  pkg_deps=(core/ruby)
fi
pkg_build_deps=(core/sed)
pkg_bin_dirs=(bin)

pkg_supported_triplets=(x86_64-linux x86_64-linux-glibc255)
pkg_supported_toolchains=(linux linux_oldaf)

do_build() {
  cp -r $PLAN_CONTEXT/../../${pkg_name}/* $CACHE_PATH/
  cd $CACHE_PATH
  bundle install
  bundle install --path $CACHE_PATH/vendor --deployment --binstubs=${pkg_prefix}/bin
}

do_install() {
  cp -r $CACHE_PATH $pkg_prefix/app

  if [[ "${HAB_TOOLCHAIN}" == "glibc255" ]]; then
    ruby_pkg="core/ruby24"
  else
    ruby_pkg="core/ruby"
  fi

  shebang="#!$(pkg_path_for ${ruby_pkg})/bin/ruby"

  sed -i "s|^#!/usr/bin/env ruby|${shebang}|" $pkg_prefix/bin/rackup
}


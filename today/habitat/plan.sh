pkg_name=teal-iron-kitten
pkg_origin=smacfarlane
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_deps=(core/ruby)
pkg_build_deps=(core/sed)
pkg_bin_dirs=(bin)

do_build() {
  cp -r $PLAN_CONTEXT/../../${pkg_name}/* $CACHE_PATH/
  cd $CACHE_PATH
  bundle install
  bundle install --path $CACHE_PATH/vendor --deployment --binstubs=${pkg_prefix}/bin
}

do_install() {
  cp -r $CACHE_PATH $pkg_prefix/app
  shebang="#!$(pkg_path_for core/ruby)/bin/ruby"

  sed -i "s|^#!/usr/bin/env ruby|${shebang}|" $pkg_prefix/bin/rackup
}

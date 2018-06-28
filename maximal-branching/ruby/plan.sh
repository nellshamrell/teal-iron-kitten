pkg_name=ruby
pkg_origin=core
if [[ $pkg_target == "x86_64-linux-2" ]]; then 
  pkg_version=2.3.1
elif [[ $pkg_target == "arm-linux" ]]; then 
  pkg_version=2.4.2
else
  pkg_version=2.5.1
fi

pkg_description="A dynamic, open source programming language with a focus on \
  simplicity and productivity. It has an elegant syntax that is natural to \
  read and easy to write."
pkg_license=("Ruby")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://cache.ruby-lang.org/pub/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz
pkg_upstream_url=https://www.ruby-lang.org/en/
pkg_shasum=dac81822325b79c3ba9532b048c2123357d3310b2b40024202f360251d9829b1
if [[ $pkg_target == "x86_64-linux" ]]; then 
  pkg_deps=(core/glibc core/ncurses core/zlib core/libressl core/libyaml core/libffi core/readline)
else
  pkg_deps=(core/glibc core/ncurses core/zlib core/openssl core/libyaml core/libffi core/readline)
fi
pkg_build_deps=(core/coreutils core/diffutils core/patch core/make core/gcc core/sed)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/ruby)

if [[ $pkg_target == "arm-linux" ]]; then
  do_prepare() {
    export CFLAGS="${CFLAGS} -O2 -g -pipe"
    build_line "Setting CFLAGS='$CFLAGS'"
  }
else
  do_prepare() {
    export CFLAGS="${CFLAGS} -O3 -g -pipe"
    build_line "Setting CFLAGS='$CFLAGS'"
  }
fi

if [[ $pkg_target == "x86_64-linux" ]]; then 
  do_build() {
    ./configure \
      --prefix="$pkg_prefix" \
      --enable-shared \
      --disable-install-doc \
      --with-openssl-dir="$(pkg_path_for core/libressl)" \
      --with-libyaml-dir="$(pkg_path_for core/libyaml)"

    make
  }
else 
  do_build() {
    ./configure \
      --prefix="$pkg_prefix" \
      --enable-shared \
      --disable-install-doc \
      --with-openssl-dir="$(pkg_path_for core/openssl)" \
      --with-libyaml-dir="$(pkg_path_for core/libyaml)"

    make
  }
fi

do_check() {
  make test
}

do_install() {
  do_default_install
  gem update --system --no-document
  gem install rb-readline --no-document
}

pkg_name="kitchen-transport-rsync-ssh"
pkg_origin="guskovd"
pkg_version="1.4"

RUBY_VERSION=2.5.1

pkg_deps=(
    core/gawk
    core/bash
    core/hab
    core/git
    core/docker
    core/rsync
    core/ruby/$RUBY_VERSION
)

do_shell() {
    ruby_bundle_path=$HOME/.hab-shell/ruby/bundle/$RUBY_VERSION
    
    mkdir -p $ruby_bundle_path
    export BUNDLE_PATH=$ruby_bundle_path

    . ~/.bashrc

    export PATH="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/bin:$PATH"
}

do_setup() {
    pushd "$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" > /dev/null
    bundle install --binstubs
    popd > /dev/null

}

do_build() {
    return 0
}

do_install() {
    return 0
}

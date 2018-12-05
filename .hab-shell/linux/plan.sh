pkg_name="kitchen-transport-rsync-ssh"
pkg_origin="guskovd"
pkg_version="1.4"

pkg_hab_shell_interpreter="bash"

RUBY_VERSION=2.5.1

pkg_deps=(
    core/gawk
    core/bash
    core/hab
    core/git
    core/ruby/$RUBY_VERSION
)

do_shell() {
    ruby_bundle_path=$HOME/.hab-shell/ruby/bundle/$RUBY_VERSION
    
    mkdir -p $ruby_bundle_path
    export BUNDLE_PATH=$ruby_bundle_path

    . ~/.bashrc

    pushd "$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" > /dev/null
    bundle install --binstubs > /dev/null
    popd > /dev/null

    export PATH="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/bin:$PATH"
}

do_build() {
    return 0
}

do_install() {
    return 0
}

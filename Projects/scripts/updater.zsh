#!/usr/bin/env zsh

sudo -k
if ! sudo -v; then
	echo "Wrong password"
	exit 1
fi

_perr() {
	echo "\e[31m$1\e[0m"
}

_pwarn() {
	echo "\e[33m$1\e[0m"
}

_pok() {
	echo "\e[32m$1\e[0m"
}

sudo apt-file update || {
    _perr "Could not update apt-file database"
    exit 1
}


_update_neovim() {
    local neovim_dir="$HOME/Projects/src-builds/neovim"

    if [[ ! -d "$neovim_dir" ]]; then
        _pwarn "Neovim directory does not exist. Cloning from GitHub..."
        git clone "https://github.com/neovim/neovim" "$neovim_dir" || {
            _perr "Couldn't install neovim"
            return 1
        }
    fi

    pushd "$neovim_dir" || {
        _perr "Could not change to neovim directory"
        return 1
    }
    {
	make clean &&
	make distclean &&
	git pull --recurse-submodules --all &&
	cmake -S cmake.deps -B .deps -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang-19 -DCMAKE_C_FLAGS="-O3 -funroll-loops -fomit-frame-pointer -march=native -mtune=native -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -fstrict-flex-arrays=3 -fcf-protection -fstack-protector-strong -fstack-clash-protection -fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -ftrivial-auto-var-init=zero -fPIC -shared -Wl,-z,relro -Wl,-z,now -Wl,-z,nodlopen -Wl,-z,noexecstack" &&
	cmake --build .deps &&
	cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang-19 -DCMAKE_C_FLAGS="-O3 -funroll-loops -fomit-frame-pointer -march=native -mtune=native -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -fstrict-flex-arrays=3 -fcf-protection -fstack-protector-strong -fstack-clash-protection -fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -ftrivial-auto-var-init=zero -fPIE" &&
	cmake --build build &&
	pushd build &&
	cpack -G DEB &&
	sudo dpkg -i nvim-linux64.deb &&
	popd
    } || {
	    _perr "Could't install neovim"
	    return 1
    }
    popd
}
_update_neovim
unset _update_neovim

if ! command -v pnpm &> /dev/null; then
  if ! command curl -fsSL https://get.pnpm.io/install.sh | sh -; then
	  _perr "Error: Failed to install pnpm. Please check your network connection and try again"
	  exit 1
  else
	  sed -i '/^# pnpm$/,/^# pnpm end$/d' "${ZDOTDIR:-$HOME}/.zshrc"
  fi
fi

if ! pnpm add -g pnpm@latest; then
	_perr "Couldn't add pnpm"
	exit 1
fi
if ! pnpm up -g -L; then
	_perr "Couldn't update pnpm"
	exit 1
fi

if ! command -v pipx &> /dev/null; then
	_perr "Error: pipx not installed"
	exit 1
fi

if ! pipx upgrade-all --include-injected; then
	_perr "Couldn't upgrade pipx packages"
	exit 1
fi

if ! command -v opam &> /dev/null; then
	_perr "Error: opam not installed"
	exit 1
fi

{ opam update && opam upgrade } || {
	_perr "Couldn't upgrade opam packages"
	exit 1
}

if ! command -v mise &> /dev/null; then
	_perr "Error: mise not installed"
	exit 1
fi

if ! mise self-update; then
	_perr "Couldn't self-update mise"
	exit 1
fi

if ! mise upgrade; then
	_perr "Couldn't upgrade mise"
	exit 1
fi

if ! command -v rustup &> /dev/null; then
  if ! command mise use -g rust@nightly; then
	  _perr "Error: Failed to install rust. Please check your network connection and try again"
	  exit 1
  fi
fi

if ! rustup update; then
	_perr "Couldn't upgrade rustup"
	exit 1
fi

if ! cargo install-update -a -g; then
	_pwarn "cargo install-update was not there, probably no cargo package is there too!"
	if ! cargo install --git https://github.com/nabijaczleweli/cargo-update.git; then
	  _perr "Error: Failed to install cargo-update. Please check your network connection and try again"
	  exit 1
	fi
	if ! cargo install-update -a -g; then
		_perr "Couldn't upgrade cargo packages"
		exit 1
	fi
fi

if ! command -v deno &> /dev/null; then
  if ! command mise use -g deno@latest; then
	  _perr "Error: Failed to install deno. Please check your network connection and try again"
	  exit 1
  fi
fi

if ! deno upgrade; then
	_perr "Couldn't upgrade deno"
	exit 1
fi

if ! command -v micromamba &> /dev/null; then
  if ! "${SHELL}" <(curl -L micro.mamba.pm/install.sh); then
	  _perr "Error: Failed to install micromamba. Please check your network connection and try again"
	  exit 1
  fi
  _pwarn "micromamba was not there, probably no env is there too!"
fi

eval "$(micromamba shell hook --shell zsh)"

if ! micromamba self-update; then
	_perr "Couldn't upgrade micromamba"
	exit 1
fi

for env in $(micromamba env list | tail -n +4 | awk '{print $1}'); do
	   { micromamba activate "$env" && micromamba update --all --yes && micromamba deactivate } || {
		   _perr "Failed to upgrade $env"
			exit 1
		}
done

if command -v tldr &> /dev/null; then
	tldr --update
fi


_update_fzf() {
    local fzf_dir="$XDG_DATA_HOME/fzf"

    if [[ ! -d "$fzf_dir" ]]; then
        _pwarn "Fzf directory does not exist. Cloning from GitHub..."
        git clone "https://github.com/junegunn/fzf" "$fzf_dir" || {
            _perr "Couldn't install fzf"
            return 1
        }
    fi
    pushd "$fzf_dir" || {
        _perr "Could not change to fzf directory"
        return 1
    }
    [[ -f bin/fzf ]] && rm bin/fzf || {
	    _perr "Could not delete fzf binary"
	    return 1
    }
    ./install --bin || {
	    _perr "Could not install fzf binary"
	    return 1
    }
    popd
}
_update_fzf
unset _update_fzf

yes | mix archive.install hex phx_new || {
    _perr "Could not update mix packages"
    exit 1
}


flatpak update --assume-yes || {
    _perr "Could not update flatpak packages"
    exit 1
}

git -C $ZDOTDIR submodule update --remote --merge || {
    _perr "Could not update zsh plugins"
    exit 1
}

unset _pok
unset _perr
unset _pwarn

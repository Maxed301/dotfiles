#!/usr/bin/env bash
# Update the self-built desktop stack (things apt does NOT update) to the
# latest *release* tags:
#
#   hypr libs (/usr/local) -> Hyprland (/usr/local) -> hyprbars plugin
#   waybar (~/.local)  ghostty (~/.local)  hyprshot (~/.local/src)
#
# Usage:
#   update-desktop.sh            show installed vs latest (no changes)
#   update-desktop.sh --install  build + install everything that is outdated
#   update-desktop.sh --install --force hyprbars   rebuild one component anyway
#
# After a Hyprland update: log out and back in (Super+Shift+M).
#
# apt prerequisites: clang-19 g++-14 cmake meson ninja-build patchelf libeis-dev
#   libc++-19-dev libc++abi-19-dev
#   (and NOT libinput-dev / libdisplay-info-dev / libmuparser-dev / libre2-dev:
#    their /usr/lib .so links
#    shadow the newer /usr/local libs during CMake's library lookup)
set -euo pipefail

WORK="${XDG_CACHE_HOME:-$HOME/.cache}/desktop-build"
JOBS="$(nproc)"
# The hypr stack needs C++23/26 (<print>, string + string_view, ranges::starts_with).
# Ubuntu 24.04's GCC (<=14) can't do that, so everything is built with clang-19
# and LLVM's libc++ - like the original build. All hypr libs + Hyprland +
# plugins MUST use the same C++ library, never mix libc++ and libstdc++.
HYPR_CC="${HYPR_CC:-clang-19}"
HYPR_CXX="${HYPR_CXX:-clang++-19}"
INSTALL=0
FORCE=()
while [ $# -gt 0 ]; do
  case "$1" in
    --install) INSTALL=1 ;;
    --force) shift; FORCE+=("$1") ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

c_red=$'\e[31m'; c_grn=$'\e[32m'; c_dim=$'\e[2m'; c_off=$'\e[0m'
log() { printf '%s==>%s %s\n' "$c_red" "$c_off" "$*"; }

# latest X.Y[.Z] release tag of a git repo (ignores rc/beta/tip tags)
latest_tag() {
  git ls-remote --tags --refs "$1" 2>/dev/null \
    | sed 's|.*refs/tags/||' | { grep -E '^v?[0-9]+\.[0-9]+(\.[0-9]+)?$' || true; } \
    | sort -V | tail -1
}
strip_v() { sed -E 's/^v//; s/-.*//' <<<"$1"; }
# true if $2 is newer than $1
is_newer() { [ "$(strip_v "$1")" != "$(strip_v "$2")" ] &&
  [ "$(printf '%s\n%s\n' "$(strip_v "$1")" "$(strip_v "$2")" | sort -V | tail -1)" = "$(strip_v "$2")" ]; }
forced() { local x; for x in "${FORCE[@]:-}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

fresh_clone() { # repo tag dir
  rm -rf "$3"
  git -c advice.detachedHead=false clone -q --depth 1 --recursive --shallow-submodules -b "$2" "$1" "$3"
}

# Copy a DESTDIR staging tree into / file by file with unlink+create, never
# overwriting in place: a running Hyprland/waybar has these libraries mapped,
# and truncating a mapped .so crashes it (and with it the whole session).
# The running programs keep their old copy; the new one is used after relogin.
deploy_stage() { # stagedir
  sudo bash -c '
    cd "$1" && find . ! -type d -print0 | while IFS= read -r -d "" f; do
      dst="/${f#./}"; mkdir -p "$(dirname "$dst")"
      cp -P "$f" "$dst.new-$$" && mv -f "$dst.new-$$" "$dst"
    done' _ "$1"
  sudo ldconfig
}

cmake_install() { # srcdir [extra cmake args...]
  # prefer the newer libs in /usr/local (libinput, wayland, ...) over Ubuntu's
  # older copies in /usr/lib when resolving transitive dependencies
  LDFLAGS="-L/usr/local/lib/x86_64-linux-gnu -Wl,-rpath-link,/usr/local/lib/x86_64-linux-gnu ${LDFLAGS:-}" \
  CC="$HYPR_CC" CXX="$HYPR_CXX" cmake -S "$1" -B "$1/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_CXX_FLAGS=-stdlib=libc++ -DCMAKE_EXE_LINKER_FLAGS=-stdlib=libc++ \
    -DCMAKE_SHARED_LINKER_FLAGS=-stdlib=libc++ -Wno-dev "${@:2}" >/dev/null
  cmake --build "$1/build" -j "$JOBS"
  rm -rf "$1/stage"
  DESTDIR="$1/stage" cmake --install "$1/build" >/dev/null
  deploy_stage "$1/stage"
}

# ---------------------------------------------------------------------------
# installed-version probes
v_pc()       { pkg-config --modversion "$1" 2>/dev/null || echo 0; }
v_scanner()  { hyprwayland-scanner --version 2>/dev/null || echo 0; }
v_hyprland() { Hyprland --version 2>/dev/null | sed -nE 's/^Tag: (v[0-9.]+).*/\1/p' | head -1 || echo 0; }
v_waybar()   { waybar --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo 0; }
v_ghostty()  { ghostty --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 0; }
v_hyprshot() { git -C "$HOME/.local/src/hyprshot" describe --tags --abbrev=0 2>/dev/null || echo 0; }

# name | repo | installed-version command   (order = build order)
COMPONENTS=(
  "hyprwayland-scanner|https://github.com/hyprwm/hyprwayland-scanner|v_scanner"
  "hyprutils|https://github.com/hyprwm/hyprutils|v_pc hyprutils"
  "hyprlang|https://github.com/hyprwm/hyprlang|v_pc hyprlang"
  "hyprcursor|https://github.com/hyprwm/hyprcursor|v_pc hyprcursor"
  "hyprgraphics|https://github.com/hyprwm/hyprgraphics|v_pc hyprgraphics"
  "wayland-protocols|https://gitlab.freedesktop.org/wayland/wayland-protocols.git|v_pc wayland-protocols"
  "libdisplay-info|https://gitlab.freedesktop.org/emersion/libdisplay-info.git|v_pc libdisplay-info"
  "aquamarine|https://github.com/hyprwm/aquamarine|v_pc aquamarine"
  "hyprwire|https://github.com/hyprwm/hyprwire|v_pc hyprwire"
  "Hyprland|https://github.com/hyprwm/Hyprland|v_hyprland"
  "waybar|https://github.com/Alexays/Waybar|v_waybar"
  "ghostty|https://github.com/ghostty-org/ghostty|v_ghostty"
  "hyprshot|https://github.com/Gustash/hyprshot|v_hyprshot"
)

# ---------------------------------------------------------------------------
# builders
build_generic_cmake() { fresh_clone "$2" "$3" "$WORK/$1"; cmake_install "$WORK/$1"; }

build_Hyprland() {
  fresh_clone "$2" "$3" "$WORK/Hyprland"
  # Ubuntu's static glslang is built against libstdc++, so Hyprland links it
  # next to libc++ (the 0.55 build did the same). "-l:" because clang rewrites
  # a plain -lstdc++ into -lc++ when -stdlib=libc++ is set
  cmake_install "$WORK/Hyprland" -DCMAKE_CXX_STANDARD_LIBRARIES=-l:libstdc++.so.6
  build_hyprbars "$WORK/Hyprland"
}

build_hyprbars() { # [hyprland src dir]
  local hl_commit pin dir="$WORK/hyprland-plugins"
  hl_commit="$(Hyprland --version | sed -nE 's/.*at commit ([0-9a-f]{40}).*/\1/p' | head -1)"
  [ -n "${1:-}" ] && hl_commit="$(git -C "$1" rev-parse HEAD)"
  rm -rf "$dir"; git clone -q https://github.com/hyprwm/hyprland-plugins "$dir"
  # hyprpm.toml pins the plugin commit that matches each Hyprland release
  pin="$(grep -F "\"$hl_commit\"" "$dir/hyprpm.toml" | grep -oE '[0-9a-f]{40}' | tail -1 || true)"
  if [ -n "$pin" ]; then git -C "$dir" -c advice.detachedHead=false checkout -q "$pin"
  else echo "${c_dim}no hyprpm pin for $hl_commit, using plugins main${c_off}"; fi
  # plugins are loaded into Hyprland -> same compiler + C++ library (libc++)
  # Hyprland >= 0.56 headers need lua + C++26; command-line CXXFLAGS replaces
  # the Makefile's (incl. its -std=c++2b)
  make -C "$dir/hyprbars" -s CXX="$HYPR_CXX -stdlib=libc++ $(pkg-config --cflags lua)" \
    CXXFLAGS="-O2 -shared -fPIC -std=c++26 -Wno-c++11-narrowing"
  mkdir -p "$HOME/.local/lib/hyprland-plugins"
  # rename into place: the running Hyprland has the old plugin mapped
  cp "$dir/hyprbars/hyprbars.so" "$HOME/.local/lib/hyprland-plugins/hyprbars.so.new"
  mv -f "$HOME/.local/lib/hyprland-plugins/hyprbars.so.new" "$HOME/.local/lib/hyprland-plugins/hyprbars.so"
}

# meson projects that Ubuntu 24.04 ships too old (wayland-protocols,
# libdisplay-info) -> /usr/local. libdisplay-info gets a new soname, so the
# system copy used by GNOME etc. stays untouched.
build_meson_usrlocal() {
  fresh_clone "$2" "$3" "$WORK/$1"
  ( cd "$WORK/$1"
    meson setup build --prefix=/usr/local --buildtype=release -Dtests=false >/dev/null 2>&1 ||
      meson setup --wipe build --prefix=/usr/local --buildtype=release >/dev/null
    ninja -C build && rm -rf stage && DESTDIR="$PWD/stage" ninja -C build install >/dev/null )
  deploy_stage "$WORK/$1/stage"
}

build_waybar() {
  fresh_clone "$2" "$3" "$WORK/waybar"
  ( cd "$WORK/waybar"
    meson setup build --prefix="$HOME/.local" --buildtype=release --default-library=static \
      -Dman-pages=disabled -Dtests=disabled -Dcava=disabled -Dmpd=disabled \
      -Dsndio=disabled -Djack=disabled -Dgps=disabled >/dev/null
    ninja -C build && ninja -C build install >/dev/null )
}

build_ghostty() {
  local ver zigver zig dir="$WORK/ghostty"
  ver="$(strip_v "$3")"
  rm -rf "$dir"; mkdir -p "$dir"
  curl -fsSL "https://release.files.ghostty.org/$ver/ghostty-$ver.tar.gz" | tar xz -C "$dir" --strip-components=1
  zigver="$(sed -nE 's/.*minimum_zig_version = "([^"]+)".*/\1/p' "$dir/build.zig.zon")"
  zig="$HOME/.local/opt/zig-x86_64-linux-$zigver/zig"
  if [ ! -x "$zig" ]; then
    log "downloading zig $zigver"
    curl -fsSL "https://ziglang.org/download/$zigver/zig-x86_64-linux-$zigver.tar.xz" | tar xJ -C "$HOME/.local/opt"
  fi
  ( cd "$dir" && "$zig" build -p "$HOME/.local" -Doptimize=ReleaseFast \
      -fno-sys=gtk4-layer-shell -Dversion-string="$ver" )
  # bundled libgtk4-layer-shell lands in ~/.local/lib; don't keep the build-cache rpath
  patchelf --set-rpath '$ORIGIN/../lib:/usr/local/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu' "$HOME/.local/bin/ghostty"
}

build_hyprshot() {
  local dir="$HOME/.local/src/hyprshot"
  [ -d "$dir/.git" ] || git clone -q "$2" "$dir"
  git -C "$dir" fetch -q --tags
  git -C "$dir" -c advice.detachedHead=false checkout -q "$3"
  ln -sfn "$dir/hyprshot" "$HOME/.local/bin/hyprshot"
}

# ---------------------------------------------------------------------------
mkdir -p "$WORK"
# Everything above hyprutils links against it (and each other): once one of
# these is rebuilt, the rest must be rebuilt too, or Hyprland ends up loading
# two hyprutils/aquamarine versions at once.
CHAIN=" hyprutils hyprlang hyprcursor hyprgraphics aquamarine hyprwire Hyprland "
cascade=0
todo=()
printf '%-22s %-12s %-12s\n' component installed latest
for entry in "${COMPONENTS[@]}"; do
  IFS='|' read -r name repo probe <<<"$entry"
  have="$($probe)"; want="$(latest_tag "$repo")"
  if [ -z "$want" ]; then printf '%-22s %-12s %s\n' "$name" "$have" "${c_dim}(no tag found)${c_off}"; continue; fi
  if is_newer "$have" "$want" || forced "$name"; then
    printf '%-22s %-12s %s\n' "$name" "$have" "$c_grn$want  <- update$c_off"
    todo+=("$name|$repo|$want")
    [[ "$CHAIN" == *" $name "* ]] && cascade=1
  elif [ $cascade -eq 1 ] && [[ "$CHAIN" == *" $name "* ]]; then
    printf '%-22s %-12s %s\n' "$name" "$have" "$c_grn$want  <- rebuild (depends on updated lib)$c_off"
    todo+=("$name|$repo|$want")
  else
    printf '%-22s %-12s %s\n' "$name" "$have" "$c_dim$want$c_off"
  fi
done
if forced hyprbars; then todo+=("hyprbars||"); fi

[ ${#todo[@]} -eq 0 ] && { echo "everything is up to date"; exit 0; }
[ $INSTALL -eq 1 ] || { echo; echo "run with --install to build the updates"; exit 0; }

sudo -v
for entry in "${todo[@]}"; do
  IFS='|' read -r name repo tag <<<"$entry"
  log "building $name $tag"
  case "$name" in
    hyprbars) build_hyprbars ;;
    wayland-protocols|libdisplay-info) build_meson_usrlocal "$name" "$repo" "$tag" ;;
    Hyprland|waybar|ghostty|hyprshot) "build_$name" "$name" "$repo" "$tag" ;;
    *) build_generic_cmake "$name" "$repo" "$tag" ;;
  esac
done
log "done"
for entry in "${todo[@]}"; do
  [ "${entry%%|*}" = Hyprland ] && echo "Hyprland was updated: log out and back in (Super+Shift+M)."
done
exit 0

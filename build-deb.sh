#!/bin/bash
# Build the faah Debian source and binary packages.
#
# Runs dpkg-buildpackage locally if available, otherwise inside a
# debian:sid container (requires docker).  Artifacts land in dist/.
set -euo pipefail

cd "$(dirname "$0")"

PKG=faah
VERSION=$(dpkg-parsechangelog -S Version 2>/dev/null ||
	sed -n '1s/^[^(]*(\([^)]*\)).*/\1/p' debian/changelog)
UPSTREAM=${VERSION%-*}
BUILD_DIR=.build
DIST_DIR=dist
STAGE=$BUILD_DIR/$PKG-$UPSTREAM

build_local()
{
	rm -rf "$BUILD_DIR" "$DIST_DIR"
	mkdir -p "$STAGE" "$DIST_DIR"

	cp -a faah.in faah.mp3 faah.1 Makefile README.md LICENSE LICENSE.audio "$STAGE/"
	cp -a debian "$STAGE/debian"

	if tar --version 2>/dev/null | grep -q GNU; then
		tar --sort=name --mtime='2026-11-02 00:00Z' \
		    --owner=0 --group=0 --numeric-owner \
		    -C "$BUILD_DIR" -czf "$BUILD_DIR/${PKG}_${UPSTREAM}.orig.tar.gz" \
		    "$PKG-$UPSTREAM"
	else
		tar -C "$BUILD_DIR" -czf "$BUILD_DIR/${PKG}_${UPSTREAM}.orig.tar.gz" \
		    "$PKG-$UPSTREAM"
	fi

	(
		cd "$STAGE"
		dpkg-buildpackage -us -uc -sa
	)

	mv "$BUILD_DIR"/${PKG}_${VERSION}_*.deb \
	   "$BUILD_DIR"/${PKG}_${VERSION}.dsc \
	   "$BUILD_DIR"/${PKG}_${VERSION}.changes \
	   "$BUILD_DIR"/${PKG}_${VERSION}_*.buildinfo \
	   "$BUILD_DIR"/${PKG}_${UPSTREAM}.orig.tar.* \
	   "$BUILD_DIR"/${PKG}_${VERSION}.debian.tar.* \
	   "$DIST_DIR"/

	echo
	echo "Artifacts in $DIST_DIR:"
	ls -l "$DIST_DIR"
}

if [ "${1:-}" = "--in-container" ]; then
	build_local
	exit 0
fi

if command -v dpkg-buildpackage >/dev/null 2>&1; then
	build_local
	exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
	echo "error: need dpkg-buildpackage or docker to build" >&2
	exit 1
fi

echo "Building in debian:sid container..."
docker run --rm \
	-v "$PWD":/work \
	-w /work \
	-e HOST_UID="$(id -u)" \
	-e HOST_GID="$(id -g)" \
	debian:sid-slim \
	bash -c '
		set -e
		export DEBIAN_FRONTEND=noninteractive
		apt-get update -qq
		apt-get install -y -qq --no-install-recommends \
			build-essential debhelper devscripts lintian ca-certificates >/dev/null
		./build-deb.sh --in-container
		if [ -d dist ]; then
			lintian --display-info --info dist/*.changes || true
		fi
		chown -R "$HOST_UID:$HOST_GID" /work/.build /work/dist
	'

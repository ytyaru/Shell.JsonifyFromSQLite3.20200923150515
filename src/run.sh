#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# JSON文字列を作成する。SQLite3で。
# CreatedAt: 2020-09-23
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	. ./Jsonify.sh
#	unset KV
#	Jsonify
#	KV=
#	Jsonify
#	KV=a
#	Jsonify
#	export KV=a
#	Jsonify
	unset KV
	declare -A KV
	KV['Id']=100
	KV['Name']='Yamada'
	KV['height']='175.1'
	export KV
	Jsonify
}
Run

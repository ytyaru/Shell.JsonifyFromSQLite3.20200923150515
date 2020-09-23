#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# SQLite3でTSVからJSON文字列を作成する（3.33.0以降）。
# CreatedAt: 2020-09-23
#---------------------------------------------------------------------------
# JSON文字列を返す。連想配列にキーと値をセットしてから呼び出すこと。
#	unset KV
#	declare -A KV
#	KV['Age']=12
#	KV['Name']='Yamada'
Jsonify() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	. ./lib/Error.sh
#	[ -v KV ] || Throw '変数 KV が未定義です。連想配列としてJSONのキーと値をセットしてください。';
#	[ -z "${KV+UNDEF}" ] && Throw '変数 KV が未定義です。連想配列としてJSONのキーと値をセットしてください。';
#	[ 0 -eq ${#KV[*]} ] && Throw '変数 KV の要素がひとつもありません。連想配列としてJSONのキーと値をセットしてください。';
	JsonifyFromSQLite3
}
# SQLite3を使ってJSON文字列を返す。連想配列にキーと値をセットしてから呼び出すこと。
JsonifyFromSQLite3() {
	NOW_VER="$(sqlite3 -batch -interactive --version | tr ' ' '\t' | cut -f1)"
	OLD_VER="$(cat <(echo '3.33.0') <(echo "$NOW_VER") | sort -V)"
	[ "$NOW_VER" = "$OLD_VER" -a "$NOW_VER" != '3.33.0' ] && { Throw 'SQLite3のバージョンは3.33.0以上であるべきです。: https://www.sqlite.org/releaselog/3_33_0.html'; }
	TABLE_NAME=Parameters
	IsInt() { test 0 -eq $1 > /dev/null 2>&1 || expr $1 + 0 > /dev/null 2>&1; }
	IsFloat() { [[ "$1" =~ ^[0-9]+\.[0-9]+$ ]] && return 0 || return 1; }
	IsDate() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && return 0 || return 1; }
	IsTime() { [[ "$1" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] && return 0 || return 1; }
	IsDateTime() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}[:blank:][0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] && return 0 || return 1; }
	FIELDS=()
	for KEY in ${!KV[*]}; do
		TYPE='TEXT'
		IsInt "${KV["$KEY"]}" && TYPE='INT'
		IsFloat "${KV["$KEY"]}" && TYPE='REAL'
		IsDate "${KV["$KEY"]}" && TYPE='DATE'
		IsTime "${KV["$KEY"]}" && TYPE='NUMERIC'
		IsDateTime "${KV["$KEY"]}" && TYPE='DATETIME'
		FIELDS+=("    ${KEY} ${TYPE}")
	done
	SQL='create table '"$TABLE_NAME"'('$'\n'
	SQL+="$(echo -e "$(IFS=,; echo "${FIELDS[*]}")" | sed -r 's/ (INT|REAL|TEXT|NULL|BLOB|NUMERIC|INTEGER|DOUBLE|FLOAT|BOOLEAN|DATE|DATETIME),/ \1,\'$'\n/gi')"
	SQL+=$'\n'')'
	echo -e "$(IFS=$'\t'; echo "${KV[*]}")" | 
	sqlite3 :memory: "$SQL" \
	'.mode tabs' '.import /dev/stdin '"$TABLE_NAME" \
	'select * from sqlite_master' \
	'.mode json' 'select * from '"$TABLE_NAME" \
	| sed 's/^\[//' | sed 's/\]$//'
}


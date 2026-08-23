#!/bin/sh
set -eu

if [ "$#" -lt 2 ]; then
	echo "usage: $0 CONTRACT ROM.gbc..." >&2
	exit 2
fi

contract=$1
shift

case "$0" in
	*/*) script_dir=${0%/*} ;;
	*) script_dir=. ;;
esac
repo_root=$script_dir/..

case "$contract" in
	*/*) contract_dir=${contract%/*} ;;
	*) contract_dir=. ;;
esac
hidden_items_contract=$contract_dir/save_abi_hidden_items.txt

if [ ! -f "$contract" ]; then
	echo "save compatibility contract not found: $contract" >&2
	exit 2
fi
if [ ! -f "$hidden_items_contract" ]; then
	echo "hidden-item compatibility contract not found: $hidden_items_contract" >&2
	exit 2
fi

status=0
required_symbol_count=1547 # 1,543 stock symbols and 4 persistent fork aliases.
for rom in "$@"; do
	case "$rom" in
		*.gbc) symbols=${rom%.gbc}.sym ;;
		*)
			echo "expected a .gbc file: $rom" >&2
			status=1
			continue
			;;
	esac

	if [ ! -f "$rom" ]; then
		echo "ROM not found: $rom" >&2
		status=1
		continue
	fi

	if [ ! -f "$symbols" ]; then
		echo "ROM symbols not found: $symbols" >&2
		status=1
		continue
	fi

	if ! awk -v symbols_file="$symbols" -v required_count="$required_symbol_count" '
		function report(message) {
			errors++
			if (errors <= 20)
				print "save compatibility error: " message > "/dev/stderr"
		}

		FNR == NR {
			if (NF == 0 || $1 ~ /^;/)
				next
			if (NF != 2) {
				report("invalid contract row " FNR " in " FILENAME)
				next
			}
			if ($2 in expected) {
				report("duplicate contract symbol " $2)
				next
			}
			expected[$2] = tolower($1)
			order[++expected_count] = $2
			next
		}

		length($1) == 7 && index($1, ":") == 3 && NF >= 2 {
			actual[$2] = tolower($1)
			actual_count[$2]++
		}

		END {
			if (expected_count != required_count)
				report("contract contains " expected_count \
				       " symbols; expected " required_count)

			for (i = 1; i <= expected_count; i++) {
				symbol = order[i]
				if (!(symbol in actual))
					report(symbol " is missing from " symbols_file)
				else if (actual_count[symbol] != 1)
					report(symbol " appears more than once in " symbols_file)
				else if (actual[symbol] != expected[symbol])
					report(symbol " moved in " symbols_file \
					       " (expected " expected[symbol] ", got " actual[symbol] ")")
			}

			if (errors > 20)
				print "save compatibility error: ...and " errors - 20 \
				      " more" > "/dev/stderr"
			if (errors)
				exit 1

			print symbols_file ": " expected_count \
			      " protected save-layout symbols unchanged"
		}
	' "$contract" "$symbols"; then
		status=1
	fi

	cartridge_type=$(od -An -tx1 -j 327 -N 1 "$rom" | tr -d '[:space:]')
	ram_size=$(od -An -tx1 -j 329 -N 1 "$rom" | tr -d '[:space:]')
	if [ "$cartridge_type" != 13 ]; then
		echo "save compatibility error: $rom has cartridge type $cartridge_type; expected 13 (MBC3+RAM+BATTERY)" >&2
		status=1
	fi
	if [ "$ram_size" != 03 ]; then
		echo "save compatibility error: $rom has RAM size $ram_size; expected 03 (32 KiB)" >&2
		status=1
	fi
done

if ! awk '
	function report(message) {
		errors++
		if (errors <= 20)
			print "save compatibility error: " message > "/dev/stderr"
	}

	FNR == NR {
		if (NF == 0 || $1 ~ /^;/)
			next
		if (NF != 4 || ($1 != "hidden_item" && $1 != "hidden_coin")) {
			report("invalid hidden-item contract row " FNR " in " FILENAME)
			next
		}
		kind = $1
		row_index = ++expected_count[kind]
		expected[kind, row_index] = $1 " " $2 " " $3 " " $4
		next
	}

	$1 == "hidden_item" || $1 == "hidden_coin" {
		kind = $1
		for (field = 2; field <= 4; field++)
			gsub(/,/, "", $field)
		row_index = ++actual_count[kind]
		actual[kind, row_index] = $1 " " $2 " " $3 " " $4
	}

	END {
		if (expected_count["hidden_item"] != 54)
			report("hidden-item contract contains " expected_count["hidden_item"] \
			       " rows; expected 54")
		if (expected_count["hidden_coin"] != 12)
			report("hidden-coin contract contains " expected_count["hidden_coin"] \
			       " rows; expected 12")

		kinds[1] = "hidden_item"
		kinds[2] = "hidden_coin"
		for (kind_index = 1; kind_index <= 2; kind_index++) {
			kind = kinds[kind_index]
			for (row_index = 1; row_index <= expected_count[kind]; row_index++) {
				if (!((kind SUBSEP row_index) in actual))
					report(kind " row " row_index " is missing")
				else if (actual[kind, row_index] != expected[kind, row_index])
					report(kind " row " row_index " changed (expected " \
					       expected[kind, row_index] ", got " actual[kind, row_index] ")")
			}
		}

		if (errors > 20)
			print "save compatibility error: ...and " errors - 20 \
			      " more" > "/dev/stderr"
		if (errors)
			exit 1

		print "hidden-item and hidden-coin save indexes unchanged"
	}
' "$hidden_items_contract" "$repo_root/data/events/hidden_item_coords.asm" \
	"$repo_root/data/events/hidden_coins.asm"; then
	status=1
fi

exit "$status"

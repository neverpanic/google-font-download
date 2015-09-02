#!/usr/bin/env bash
# vim:noet:sts=4:ts=4:sw=4:tw=120

##
# Copyright (c) 2014-2015, Clemens Lang
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
# following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#    disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#    following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##

##
# With modifications by
#  - Chris Jung, campino2k.de, and
#  - Robert, github.com/rotx.
#  - Thomas Papamichail, https://gist.github.com/pointergr
##

##
# Upstream is at https://github.com/neverpanic/google-font-download. Patches are welcome.
##

# Ensure the bash version is new enough. If it isn't error out with a helpful error message rather than crashing later.
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
	echo "Error: This script needs Bash 4.x to run." >&2
	exit 1
fi

set -euo pipefail

# Set up defaults
css="font.css"
lang="latin"
format="all"
url="http://fonts.googleapis.com/css"

# Usage message
usage() {
	cols=$(tput cols) || cols=80
	fmt -w $(( cols - 8 )) >&2 <<-EOF
		USAGE
		  ${0:-google-font-download} [OPTION...] [FONT...]

		  google-font-download, a script to download a local copy of
		  Google's webfonts and generate a CSS file to use them.

		OPTIONS
		  -f FORMAT, --format=FORMAT
		    Download the specified set of webfont formats from Google's
		    servers. FORMAT is a comma-separated list of identifiers for
		    webfont formats. Supported identifiers are eot, woff, woff2,
		    svg, and ttf. Additionally, the special value \`all' expands
		    to all supported formats. The default is \`$format'. Note
		    that you may not really need all formats. In most cases,
		    WOFF is enough. See http://caniuse.com/#search=woff for
		    a current status.

		  -h, --help
		    Display this message and exit.

		  -l LANGSPEC, --languages=LANGSPEC
		    Download the specified subset of languages from Google's
		    webfonts. LANGSPEC is a comma-separated list of idenfitiers
		    for font subsets. Common identifiers are latin, latin-ext,
		    cyrillic, cyrillic-ext, greek, greek-ext, etc. An
		    undocumented language is \`all' which means the full
		    (non-subset) files are served. The default is \`$lang'.

		  -o OUTPUT, --output=OUTPUT
		    Write the generated CSS into OUTPUT. The file will be
		    overwritten and will be created if it doesn't exist. The
		    default is \`$css'.

		POSITIONAL ARGUMENTS
		  This script accepts an arbitrary number of font specs. A font
		  spec is any string that Google's servers will accept as
		  famility URL parameter. Note that your font spec should *not*
		  be URL-encoded and only one font weight is supported per font
		  specification. If you want to download multiple font weights
		  or styles, provide multiple font specs.

		  For example, to download Open Sans in
		   - light (300),
		   - normal (400),
		   - normal italic (400italic),
		   - bold (700), and
		   - bold italic (700italic),
		  run:
		    ${0:-google-font-download} "Open Sans:300" "Open Sans:400" \\
		        "Open Sans:400italic" "Open Sans:700" \\
		        "Open Sans:700italic"
	EOF
	exit 1
}

err_exit() {
	echo >&2 "${0:-google-font-download}: Error: $1"
	exit 2
}

misuse_exit() {
	echo >&2 "${0:-google-font-download}: Error: $1"
	echo >&2
	usage
}

# Check for modern getopt(1) that quotes correctly; see #1 for rationale
ret=0
modern_getopt=1
getopt -T >/dev/null || ret=$?
if [ $ret -ne 4 ]; then
	modern_getopt=0
fi

# Parse options
if [ $modern_getopt -eq 1 ]; then
	ret=0
	temp=$(getopt -o f:hl:o: --long format:,help,languages:,output -n "${0:-google-font-download}" -- "$@") || ret=$?
	if [ $ret -ne 0 ]; then
		echo >&2
		usage
	fi
else
	cols=$(tput cols) || cols=80
	fmt -w $(( cols - 8 )) >&2 <<-EOF
		Warning: Old getopt(1) detected.

		Your version of getopt(1) does not correctly deal with whitespace and does not support long options. You may
		have to quote any special character arguments twice. For example, to download the 'Open Sans' font, use $0
		"'Open Sans'". See https://github.com/neverpanic/google-font-download/issues/1 for more information.

		You should consider upgrading to a more modern version of getopt(1).

	EOF

	ret=0
	# shellcheck disable=SC2048,SC2086
	temp=$(getopt f:hl:o: $*) || ret=$?
	if [ $ret -ne 0 ]; then
		echo >&2
		usage
	fi
fi

# Process arguments
# For the non-modern getopt(1), the eval and quoting is a hack to allow users to manually specify values that have been
# quoted twice.
eval set -- "$temp"
while true; do
	case "$1" in
		-f|--format)
			format=$2
			shift 2
			;;
		-h|--help)
			usage
			exit 1
			;;
		-l|--languages)
			lang=$2
			shift 2
			;;
		-o|--output)
			css=$2
			shift 2
			;;
		--)
			shift
			break
			;;
	esac
done

# Validate font family input
declare -a families
families=()
for family do
	families+=("$family")
done
if [ ${#families[@]} -eq 0 ]; then
	misuse_exit "No font families given"
fi

# Validate font format input
declare -a formats
if [ "$format" = "all" ]; then
	# Deal with the special "all" value
	formats=("eot" "woff" "woff2" "svg" "ttf")
else
	IFS=', ' read -a formats <<< "$format"
	for f in "${formats[@]}"; do
		case "$f" in
			eot|woff|woff2|svg|ttf)
				;;
			*)
				err_exit "Unsupported font format \`${f}'"
				;;
		esac
	done
fi
if [ ${#formats[@]} -eq 0 ]; then
	misuse_exit "Empty list of font formats given"
fi

# Validate language input
if [ "$lang" = "" ]; then
	misuse_exit "Empty language given"
fi

# Sanity check on output file
if [ "$css" = "" ]; then
	misuse_exit "Output file is empty string"
elif [ "$css" = "-" ]; then
	# a single dash means output to stdout
	css=/dev/stdout
fi


# Check whether sed is GNU or BSD sed, or rather, which parameter enables extended regex support. Note that GNU sed does
# have -E as an undocumented compatibility option on some systems.
if [ "$(echo "test" | sed -E 's/([st]+)$/xx\1/' 2>/dev/null)" == "texxst" ]; then
	ESED="sed -E"
elif [ "$(echo "test" | sed -r 's/([st]+)$/xx\1/' 2>/dev/null)" == "texxst" ]; then
	ESED="sed -r"
else
	err_exit "$(which sed) seems to lack extended regex support with -E or -r"
fi

# Store the useragents we're going to use to trick Google's servers into serving us the correct CSS file.
declare -A useragent
# ShellCheck doesn't correctly notice our dynamic use of these variables.
# shellcheck disable=SC2154
useragent[eot]='Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)'
# shellcheck disable=SC2154
useragent[woff]='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0'
# shellcheck disable=SC2154
useragent[woff2]='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
# shellcheck disable=SC2154
useragent[svg]='Mozilla/4.0 (iPad; CPU OS 4_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/4.1 Mobile/9A405 Safari/7534.48.3'
# shellcheck disable=SC2154
useragent[ttf]='Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.54.16 (KHTML, like Gecko) Version/5.1.4 Safari/534.54.16'

# Clear the output file
>"$css"

# Loop over the fonts, and download them one-by-one
errors=0
for family in "${families[@]}"; do
	printf >&2 "Downloading %s..." "$family"

	# Test whether the chosen combination of font and language subset
	# exists; Google returns HTTP 400 if it doesn't
	ret=0
	css_string=$(curl -sSf --get --data-urlencode "family=$family" --data-urlencode "subset=$lang" "$url" 2>&1) || ret=$?
	if [ $ret -ne 0 ]; then
		errors=1
		printf >&2 " error: %s\n" "${css_string}"
		continue
	fi

	# Extract name, Windows-safe filename, font style and font weight from the font family name
	fontname=$(echo "$family" | awk -F : '{print $1}')
	fontnameescaped=$(echo "$family" | $ESED 's/( |:)/_/g')
	fontstyle=$(echo "$family" | awk -F : '{print $2}')
	fontweight=$(echo "$fontstyle" | $ESED 's/italic$//g')

	numfontweight=$(echo "$fontweight" | tr -Cd ',')
	if [ ${#numfontweight} -ge 1 ]; then
		errors=1
		printf >&2 "Font specification contains multiple weights; this is unsupported\n"
		continue
	fi

	printf >>"$css" "@font-face {\n"
	printf >>"$css" "\tfont-family: '%s';\n" "$fontname"

	# $fontstyle could be bolditalic, bold, italic, normal, or nothing.
	case "$fontstyle" in
		*italic)
			printf >>"$css" "\tfont-style: italic;\n"
			;;
		*)
			printf >>"$css" "\tfont-style: normal;\n"
			;;
	esac

	# Either bold, a number, or empty. If empty, default to "normal".
	printf >>"$css" "\tfont-weight: %s;\n" "${fontweight:-normal}"
	printf >>"$css" "\tsrc:\n"

	# Determine the local names for the given fonts so we can use a locally-installed font if available.
	css_src_string=$(echo "$css_string" | grep "src:")
	ret=0
	local_name=$(echo "$css_src_string" | grep -Eo "src: local\\('[^']+'\\)," | $ESED "s/^src: local\\('([^']+)'\\),$/\\1/g") || ret=$?
	if [ $ret -ne 0 ]; then
		errors=1
		printf >&2 "Failed to determine local font name\n"
	fi
	local_postscript_name=$(echo "$css_src_string" | grep -Eo ", local\\('[^']+'\\)," | $ESED "s/^, local\\('([^']+)'\\),$/\\1/g") || true

	# When the local font name couldn't be determined, still produce a valid CSS file
	if [ -n "$local_name" ]; then
		printf >>"$css" "\t\tlocal('%s'),\n" "$local_name"
	fi
	# Some fonts don't have a local PostScript name.
	if [ -n "$local_postscript_name" ]; then
		printf >>"$css" "\t\tlocal('%s'),\n" "$local_postscript_name"
	fi

	# For each requested font format, download the font file and print the corresponding CSS statements.
	for ((uaidx=0; uaidx < ${#formats[@]}; uaidx++)); do
		uakey=${formats[$uaidx]}
		if [ $uaidx -eq $(( ${#formats[@]} - 1 )) ]; then
			terminator=";"
		else
			terminator=","
		fi
		printf >&2 "%s " "$uakey"

		# Download Google's CSS and throw some regex at it to find the font's URL
		if [ "$uakey" != "svg" ]; then
			pattern="http:\\/\\/[^\\)]+\\.$uakey"
		else
			pattern="http:\\/\\/[^\\)]+"
		fi
		file=$(curl -sf -A "${useragent[$uakey]}" --get --data-urlencode "family=$family" --data-urlencode "subset=$lang" "$url" | grep -Eo "$pattern" | sort -u)
		printf >>"$css" "\t\t/* from %s */\n" "$file"
		if [ "$uakey" == "svg" ]; then
			# SVG fonts need the font after a hash symbol, so extract the correct name from Google's CSS
			svgname=$(echo "$file" | $ESED 's/^[^#]+#(.*)$/\1/g')
		fi
		# Actually download the font file
		curl -sfL "$file" -o "${fontnameescaped}.$uakey"

		# Generate the CSS statements required to include the downloaded file.
		case "$uakey" in
			eot)
				printf >>"$css" "\t\turl('%s?#iefix') format('embedded-opentype')%s\n" "${fontnameescaped}.$uakey" "${terminator}"
				;;
			woff)
				printf >>"$css" "\t\turl('%s') format('woff')%s\n" "${fontnameescaped}.$uakey" "${terminator}"
				;;
			woff2)
				printf >>"$css" "\t\turl('%s') format('woff2')%s\n" "${fontnameescaped}.$uakey" "${terminator}"
				;;
			ttf)
				printf >>"$css" "\t\turl('%s') format('truetype')%s\n" "${fontnameescaped}.$uakey" "${terminator}"
				;;
			svg)
				printf >>"$css" "\t\turl('%s#%s') format('svg')%s\n" "${fontnameescaped}.${uakey}" "$svgname" "${terminator}"
				;;
		esac
	done

	printf >>"$css" "}\n"
	printf >&2 "\n"
done

exit $errors

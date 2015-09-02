# google-font-download

This is a small shell script that allows you to download Google's web fonts to
your local file system. Additionally, a CSS file that uses your local copy of
the fonts is generated. You may want to use this if you want to avoid
requesting resources from 3rd party servers (for example for privacy reasons or
because you do not have a connection to the public internet).

## Requirements

To run this script, you will need:

 - Bash (>= 4.x)
 - curl
 - getopt, preferrably a version that preserves quoted whitespace and supports long options
 - tput
 - fmt
 - sed, in a version that has extended regex support using either `-E` (BSD) or `-r` (GNU)
 - awk
 - tr
 - grep

## License

The script is released under the 2-clause BSD license. The SPDX identifier of
this license is BSD-2-Clause. See the [`LICENSE`](LICENSE) file for
the terms.

## Usage

### Synopsis
  `google-font-download [OPTION...] [FONT...]`

### Options

<dl>
    <dt><code>-f FORMAT</code>, <code>--format=FORMAT</code></dt>
    <dd>Download the specified set of webfont formats from Google's servers.
        <code>FORMAT</code> is a comma-separated list of identifiers for
        webfont formats. Supported identifiers are <code>eot</code>,
        <code>woff</code>, <code>woff2</code>, <code>svg</code>, and
        <code>ttf</code>. Additionally, the special value <code>all</code>
        expands to all supported formats. The default is <code>all</code>. Note
        that you may not really need all formats. In most cases, WOFF is enough.
        See http://caniuse.com/#search=woff for a current status.</dd>
    <dt><code>-h</code>, <code>--help</code></dt>
    <dd>Display this message and exit.</dd>
    <dt><code>-l LANGSPEC</code>, <code>--languages=LANGSPEC</code></dt>
    <dd>Download the specified subset of languages from Google's webfonts.
        <code>LANGSPEC</code> is a comma-separated list of idenfitiers for font
        subsets. Common identifiers are <code>latin</code>,
        <code>latin-ext</code>, <code>cyrillic</code>,
        <code>cyrillic-ext</code>, <code>greek</code>, <code>greek-ext</code>,
        etc. An undocumented language is <code>all</code> which means the full
        (non-subset) files are served. The default is <code>latin</code>.</dd>
    <dt><code>-o OUTPUT</code>, <code>--output=OUTPUT</code></dt>
    <dd>Write the generated CSS into <code>OUTPUT</code>. The file will be
        overwritten and will be created if it doesn't exist. The default is
        <code>font.css</code>.</dd>
</dl>

### Positional Arguments
  This script accepts an arbitrary number of font specs. A font spec is any
  string that Google's servers will accept as famility URL parameter. Note that
  your font spec should *not* be URL-encoded and only one font weight is
  supported per font specification. If you want to download multiple font
  weights or styles, provide multiple font specs.

  For example, to download Open Sans in
   - light (300),
   - normal (400),
   - normal italic (400italic),
   - bold (700), and
   - bold italic (700italic),
  run:
```bash
google-font-download \
    "Open Sans:300" "Open Sans:400" "Open Sans:400italic" \
    "Open Sans:700" "Open Sans:700italic"
```

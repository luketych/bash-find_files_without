#!/opt/homebrew/bin/bash

set -euo pipefail  # This makes the script exit on errors and show failures


source ./find_files_without.sh


find_files_without \
	dev_null="true" \
	depth="3" \
	extensions="csv|toml" \
	directories="talon-gaze-ocr|talon_axkit" \
	substrings="LICENSE" \
	\
	filter_out_text_files="false" \
	filter_out_package_files="true" \
	filter_out_web_files="false"


echo "done"
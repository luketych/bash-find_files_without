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
	use_text_files="true" \
	use_package_files="false" \
	use_web_files="true"


echo "done"
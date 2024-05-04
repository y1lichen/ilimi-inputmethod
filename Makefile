SHELL := /bin/sh
.PHONY: format

format:
	@git ls-files --exclude-standard | grep -E '\.swift$$' | swiftlint --fix --autocorrect
	@swiftformat --swiftversion 5.7 ./

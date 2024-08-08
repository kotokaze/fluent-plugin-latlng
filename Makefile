all: build

build:
	@fluent-gem build ./fluent-plugin-latlng.gemspec

clean:
	@rm -i fluent-plugin-latlng-*.gem

uninstall:
	@fluent-gem uninstall fluent-plugin-latlng

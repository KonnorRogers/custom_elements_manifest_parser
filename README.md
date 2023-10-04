# CustomElementsManifestParser

The CustomElementsManifestParser is intended to be a way to parse + interact with JSON
generated from here: <https://github.com/open-wc/custom-elements-manifest>

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'custom_elements_manifest_parser'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
bundle add custom_elements_manifest_parser
```

## Usage

```ruby
require "json"

custom_elements_manifest = JSON.parse(File.read("custom-elements.json"))
parser = CustomElementsManifestParser.parse(custom_elements_manifest)

# Traversing through.
parser.manifest.modules.each do |mod|
  mod.path # => The file path to the JavaScript module.

  mod.exports.each do |export|
    # do something with exports
  end

  mod.declarations.each do |declaration|
    # do something with a declaration
  end
end

## Convenience Helpers

# Searches for the tagName of the custom elements
parser.find_by_tag_name("light-pen", "light-preview") # => declarations
parser.find_by_tag_name(["light-pen", "light-preview"]) # => declarations

# Searches for any declarations with {"customElement": true}
parser.find_custom_elements
```

## Extending

Because the schema is really a JSON file you can dump anything into, there does need to be some
room to extend.

### Replacing the Manifest

### Replacing the Parser

### Adding / Removing "visitable_nodes"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/custom_elements_manifest_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/custom_elements_manifest_parser/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CustomElementsManifestParser project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/custom_elements_manifest_parser/blob/main/CODE_OF_CONDUCT.md).

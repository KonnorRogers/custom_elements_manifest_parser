# CustomElementsManifestParser

The CustomElementsManifestParser is intended to be a way to parse + interact with JSON
generated from here: <https://github.com/open-wc/custom-elements-manifest>

## Why?

I wanted to generate some slots, attributes, etc for my custom elements in my [Bridgetown](https://www.bridgetownrb.com/) site, and I got bored and decided to build a parser as a fun academic exercise. The parser is based on the schema defined here:

<https://github.com/webcomponents/custom-elements-manifest/blob/main/schema.d.ts>

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
require "custom_elements_manifest_parser"

custom_elements_manifest = JSON.parse(File.read("custom-elements.json"))

# This is a shortcut for CustomElementsManifestParser::Parser.new(json).parse
parser = CustomElementsManifestParser.parse(custom_elements_manifest)

parser.manifest.schemaVersion # => [String]
parser.manifest.readme # => [String, nil]
parser.manifest.deprecated # => [String, Boolean, nil]

# Manual Traversal through.
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
parser.find_custom_elements("light-pen", "light-preview").each { |declaration| declaration }
parser.find_custom_elements(["light-pen", "light-preview"]).each { |declaration| declaration }

# Searches for all custom elements regardless of tagName
parser.find_custom_elements.each do |declaration|
  # Declarations store a "parent_module" to easily access the import path.
  declaration.parent_module.path

  # Get custom element "tagName", this may sometimes be nil.
  declaration.tagName

  # Get the name of the class
  declaration.name
end
```

## Extending

Because the schema is really a JSON file you can dump anything into, there does need to be some
room to extend because not all schemas are equal (as I discovered trying to parse Shoelace's manifest).

### Replacing the Parser

Subclass the parser and go to town!

```rb
class MyParser < CustomElementsManifestParser::Parser
  # Do your thing!
end

MyParser.new(json).parse
```

### Adding / Removing "visitable_nodes"

The parser has `@visitable_nodes` instance variable on it.

A `visitable_node` is any node which has a `"kind"` attached to it. Everything in the `CustomElementsManifestParser::Nodes`
module is considered a `visitable_node` (Except `Manifest` which is a special case)

### Replacing the Manifest

The manifest does not live inside of `visitable_nodes` and is instead of a top level attribute. To replace the manifest do the following:

```rb
require "custom_elements_manifest_parser"

class MyManifest < CustomElementsManifestParser::Nodes::Manifest
  attribute :package, CustomElementsManifestParser::Types::Strict::Hash
end

json = JSON.parse(File.read("custom-elements.json"))

# This doesn't actually run the parser. This sets up the manifest prior to parsing.
parser = CustomElementsManifestParser::Parser.new(json)

# Replace the manifest
parser.manifest = MyManifest

# Traverse the tree and "visit" each node
parser.parse
```

## Architecture

[Dry-Struct](https://dry-rb.org/gems/dry-struct/1.6/) and [Dry-Types](https://dry-rb.org/gems/dry-types/1.7/) are used for cursory data validation.

Perhaps in the future [Dry-Validation](https://github.com/dry-rb/dry-validation) will also be used for more complex scenarios.

### Visitable Nodes

Visitable nodes are nodes with a `#visit(parser:)` method that when called creates a new instance of
the node. (This is due to `DryStruct`'s immutability.) When a `#visit` call will need to mutate data structures inside,
it needs to create a hash and then call `#new`. Like so:

```rb
def visit(parser:)
  hash = {}
  hash[:thing] = serialize(thing)
  new(hash)
end
```

#### Adding a visitable node

Visitable Nodes are a hash keyed off of the `"kind"` of the Node.

```rb
require "custom_elements_manifest_parser"

# Wait to call `.parse` until we setup our visitable_nodes
parser = CustomElementsManifestParser::Parser.new(json)

parser.visitable_nodes["js"] = MyJsNode

# Erase it all!
parser.visitable_nodes = {}

# Probably won't do anything :shrug:, but you tried!
parser.parse
```

### Data Types

Data Types look a lot like `visitable_nodes`, but they don't have an actual `"kind"` within the `custom-elements.json` schema, but
instead are a best guess at how to serialize a data structure within a `visitable_node`.

(The only exception to the `"kind"` rule is the `Nodes::Manifest` class, but that's because that's the top level object so it has an implicit `"kind"`)

Data Types can be found in the `CustomElementsManifestParser::DataTypes` module and are attached to the `data_types` attribute
on the parser.

Data Types follow the same interface as `visitable_nodes`.

#### Adding a data type

```rb
require "custom_elements_manifest_parser"

# Wait to call `.parse` until we setup our visitable_nodes
parser = CustomElementsManifestParser::Parser.new(json)

parser.data_types[:source] = SourceSerializer

# Erase it all!
parser.data_types = {}

# This will probably error out because "visitable_nodes" expect to be able to serialize their children with data_types
parser.parse
```

### Shareable structs

Within the `CustomElementsManifestParser::Structs` module you'll find these structs get included by either `DataTypes` or
`Nodes` by using `attributes_from CustomStruct`. These structs should also implement a `def self.build_hash(parser:, struct:)` function that returns a hash that can then be merged by the parent structs.

```rb
require_relative "../base_struct.rb"

class ShareableStruct < BaseStruct
  def self.build_hash(parser:, struct:)
    hash = {}
    hash[:thing] = do_stuff
    hash
  end
end


require_relative "../base_struct.rb"

class MyStruct < BaseStruct
  attributes_from ShareableStruct

  def visit(parser:)
    hash = {}

    hash = hash.merge(ShareableStruct.build_hash(parser: parser, struct: self)

    new(hash)
  end
end
```

The reason we can call `new(hash)` is because `DryStruct` does some heavy lifting with tracking input changes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/custom_elements_manifest_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/custom_elements_manifest_parser/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CustomElementsManifestParser project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/custom_elements_manifest_parser/blob/main/CODE_OF_CONDUCT.md).

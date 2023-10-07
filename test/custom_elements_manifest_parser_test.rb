# frozen_string_literal: true

require "test_helper"
require "json"
# require_relative "../lib/custom_elements_manifest_parser.rb"

class CustomElementsManifestParserTest < Minitest::Test
  def setup
    @json = JSON.parse(File.read(File.expand_path("./fixtures/custom-elements-manifest.json", __dir__)))
  end

  def test_it_has_a_schema_version
    schemaVersion = ::CustomElementsManifestParser.parse(@json).manifest.schemaVersion

    assert_equal schemaVersion, "1.0.0"
  end

  def test_it_has_a_readme
    readme = ::CustomElementsManifestParser.parse(@json).manifest.readme

    assert_equal readme, ""
  end

  def test_it_has_modules
    modules = ::CustomElementsManifestParser.parse(@json).manifest.modules

    assert modules.length > 0
  end

  class CustomManifest < CustomElementsManifestParser::Nodes::Manifest
    attribute :package, CustomElementsManifestParser::Types::Strict::Hash
  end

  class CustomEvent < CustomElementsManifestParser::DataTypes::Event
    attribute :eventName, CustomElementsManifestParser::Types::Strict::String
    attribute :reactName, CustomElementsManifestParser::Types::Strict::String
  end

  def test_it_should_allow_a_custom_manifest_and_nodes
    @json = JSON.parse(File.read(File.expand_path("./fixtures/shoelace-custom-elements-manifest.json", __dir__)))

    # The parser creates a manifest, but never calls anything #visit to start the chain of parsing.
    parser = ::CustomElementsManifestParser::Parser.new(@json)

    # Replace current manifest with the new manifest.
    parser.manifest = CustomManifest.new(@json)

    parser.data_types[:event] = CustomEvent

    # Nothing gets parsed until `.parse` is called.
    parser.parse

    refute_nil parser.manifest.package
  end

  def test_it_has_first_module_correct
    first_module = @json["modules"][0]

    manifest = ::CustomElementsManifestParser.parse(@json).manifest

    first_parsed_module = manifest.modules[0]

    assert_equal first_module["kind"], first_parsed_module.kind
    assert_equal first_module["path"], first_parsed_module.path
    assert_equal first_module["declarations"].length, first_parsed_module.declarations.length
  end

  def test_it_should_find_all_custom_elements
    parser = ::CustomElementsManifestParser.parse(@json)

    manifest = parser.manifest

    custom_elements = []

    manifest.modules.flatten.each do |mod|
      mod.declarations.flatten.each do |dec|
        custom_elements << dec if dec.respond_to?(:customElement) && dec.customElement == true
      end
    end

    assert_equal custom_elements.length, 3

    custom_elements.each do |dec|
      # Should be able to find the parent JS module.
      assert dec.parent_module.instance_of?(::CustomElementsManifestParser::Nodes::JavaScriptModule)
      assert dec.parent_module.path.instance_of?(String)
    end

    # Using the shortcut
    assert_equal parser.find_custom_elements.length, 3
  end

  def test_it_should_find_custom_elements_by_tag_name
    parser = ::CustomElementsManifestParser.parse(@json)

    custom_elements = parser.find_by_tag_names(["blah"])
    assert custom_elements.instance_of?(Hash)
    assert_equal custom_elements.keys.length, 0

    custom_elements = parser.find_by_tag_names(["light-preview"])
    assert_equal custom_elements.keys.length, 1

    custom_elements = parser.find_by_tag_names("light-preview", "light-pen", "blah")
    assert_equal custom_elements.keys.length, 2

    custom_elements = parser.find_all_tag_names
    assert_equal custom_elements.keys.length, 3
  end
end

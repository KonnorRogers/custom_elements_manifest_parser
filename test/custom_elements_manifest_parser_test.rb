# frozen_string_literal: true

require "test_helper"
require "json"

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

  class CustomManifest < ::CustomElementsManifestParser::Nodes::Manifest
    attr_accessor :package

    def initialize(arg = nil, **kwargs)
      hash = if arg.is_a?(Hash)
               arg
             else
               kwargs
             end

      hash = hash.transform_keys(&:to_sym)
      @package = hash[:package]
      super(**hash)
    end
  end

  def test_it_should_allow_a_custom_manifest
    @json = JSON.parse(File.read(File.expand_path("./fixtures/shoelace-custom-elements-manifest.json", __dir__)))

    parser = ::CustomElementsManifestParser::Parser.new(@json)
    parser.manifest = CustomManifest.new(**@json.transform_keys(&:to_sym))
    parser.parse

    refute_nil parser.package
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
    manifest = ::CustomElementsManifestParser.parse(@json).manifest

    custom_elements = []

    manifest.modules.flatten.each do |mod|
      mod.declarations.flatten.each do |dec|
        custom_elements << dec if dec.respond_to?(:customElement) && dec.customElement == true
      end
    end

    # custom_elements = parser.find_by { |node| node.respond_to?(:customElement) && node.customElement == true }
    assert_equal custom_elements.length, 3
  end
end

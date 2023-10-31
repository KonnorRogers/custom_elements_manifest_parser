# frozen_string_literal: true

# Requires all files
# Dir["#{__dir__}/custom_elements_manifest_parser/**/*.rb"].each { |file| require file }

$LOAD_PATH.unshift __dir__

require "#{__dir__}/custom_elements_manifest_parser/types.rb"
require "#{__dir__}/custom_elements_manifest_parser/parser.rb"
require "#{__dir__}/custom_elements_manifest_parser/version.rb"

# Top level parser
module CustomElementsManifestParser
  # Shortuct for `CustomElementsManifestParser::Parser.new().parse()`
  # @return [CustomElementsManifestParser::Parser]
  def self.parse(hash)
    Parser.new(hash).parse
  end
end

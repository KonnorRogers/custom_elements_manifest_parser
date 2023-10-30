# frozen_string_literal: true

# Requires all files
# @!parse
Dir["#{__dir__}/custom_elements_manifest_parser/**/*.rb"].each { |file| require file }


#
# Top level parser
module CustomElementsManifestParser
  autoload :Parser, "custom_elements_manifest_parser/parser"
  # Shortuct for `CustomElementsManifestParser::Parser.new().parse()`
  # @return [CustomElementsManifestParser::Parser]
  def self.parse(hash)
    Parser.new(hash).parse
  end
end

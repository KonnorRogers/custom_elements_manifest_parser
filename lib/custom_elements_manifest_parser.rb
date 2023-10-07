# frozen_string_literal: true

#
# Top level parser
module CustomElementsManifestParser
  Dir["#{__dir__}/custom_elements_manifest_parser/**/*.rb"].each { |file| require file }

  # Shortuct for `CustomElementsManifestParser::Parser.new().parse()`
  def self.parse(hash)
    Parser.new(hash).parse
  end
end

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Gets passed an href to an absolute URL to the source.
    class SourceReference < BaseStruct
      # @!attribute href
      #   @return [String] - An absolute URL to the source (ie. a GitHub URL).
      attribute :href, Types::Strict::String

      def visit(parser:)
        self
      end
    end
  end
end

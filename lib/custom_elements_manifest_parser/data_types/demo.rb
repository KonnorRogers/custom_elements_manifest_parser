require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Links to a demo of the element
    class Demo < BaseStruct
      # @!attribute url
      #    @return [String] -
      #       Relative URL of the demo if it's published with the package. Absolute URL
      #       if it's hosted.
      attribute :url, Types::Strict::String

      # @!attribute description
      #    @return [String, nil] - A markdown description of the demo.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute source
      #    @return [SourceReference, nil]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:source] = parser.data_types[:source].new(source).visit(parser: parser) if source
        new(hash)
      end
    end
  end
end

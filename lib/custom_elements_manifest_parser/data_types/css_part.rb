
require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # The name + description of a CSS Part
    class CssPart < BaseStruct
      # @!attribute name
      #    @return [String] - Name of the CSS part
      attribute :name, Types::Strict::String

      # @!attribute summary
      #    @return [nil, String] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [nil, String] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #     @return [nil, Boolean, String] -
      #        Whether the CSS shadow part is deprecated.
      #        If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

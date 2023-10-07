require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents events on a custom element
    class Event < BaseStruct
      # @!attribute name
      #   @return [String] - Name of the event
      attribute :name, Types::Strict::String

      # @!attribute type
      #    @return [Type] - The type of the event object that's fired.
      attribute :type, Types::Nominal::Any.optional.meta(required: false)

      # @param summary [nil, String] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [nil, String] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute inheritedFrom
      #    @return [nil, Reference]
      attribute :inheritedFrom, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute deprecated
      #   @return [nil, Boolean, String]
      #      Whether the event is deprecated.
      #      If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:type] = parser.data_types[:type].new(type).visit(parser: parser) if type
        new(hash)
      end
    end
  end
end

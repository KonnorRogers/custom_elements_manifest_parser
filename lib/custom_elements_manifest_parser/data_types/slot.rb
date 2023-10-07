require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents slots for a custom element
    class Slot < BaseStruct
      # @!attribute name
      #    @return [String] - The slot name, or the empty string for an unnamed slot.
      attribute :name, Types::Strict::String

      # @!attribute summary
      #    @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [String, nil] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #    @return [nil, Boolean, String] -
      #       Whether the slot is deprecated.
      #       If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

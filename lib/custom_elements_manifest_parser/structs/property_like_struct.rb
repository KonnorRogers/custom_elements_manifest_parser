require_relative "../types.rb"
require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module Structs
    # The common interface of variables, class fields, and function
    # parameters.
    class PropertyLikeStruct < BaseStruct
      # @!attribute name
      #   @return [String] - Name of the property
      attribute :name, Types::Strict::String

      # @!attribute summary
      #    @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #   @return [String, nil] - A markdown description of the field.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute type
      #   @return [nil, Type] - The type serializer IE: "Object", "String", etc.
      attribute :type, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute default
      #    @return [String, nil] - Default value
      attribute :default, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #   @return [nil, Boolean, String] -
      #     Whether the property is deprecated.
      #     If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::Bool.optional | Types::Strict::String.optional.meta(required: false)

      # @!attribute readonly
      #   @return [nil, Boolean] - Whether the property is read-only.
      attribute :readonly, Types::Strict::Bool.optional.meta(required: false)

      def self.build_hash(parser:, struct:)
        hash = {}
        hash[:type] = parser.data_types[:type].new(struct.type).visit(parser: parser) if struct.type
        hash
      end
    end
  end
end


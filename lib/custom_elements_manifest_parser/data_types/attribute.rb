require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents an "attribute" on a custom element.
    class Attribute < BaseStruct
      # @param name [String] - The name of the attribute you place on the element.
      attribute :name, Types::Strict::String

      # @!attribute summary
      #    @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [String, nil] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute inheritedFrom
      #    @return [Reference, nil] - Reference to where it inherited its attribute
      attribute :inheritedFrom, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute type
      #    @return [Type, nil] - The type that the attribute will be serialized/deserialized as.
      attribute :type, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute default
      #    @return [String, nil] -
      #       The default value of the attribute, if any.
      #       As attributes are always strings, this is the actual value, not a human
      #       readable description.
      attribute :default, Types::Strict::String.optional.meta(required: false)

      # @!attribute fieldName
      #    @return [String, nil] - The name of the field this attribute is associated with, if any.
      attribute :fieldName, Types::Strict::String.optional.meta(required: false)

      # @!attribute resolveInitializer
      #    @return [ResolveInitializer, nil]
      attribute :resolveInitializer, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute deprecated
      #    @return [nil, Boolean, String] -
      #       Whether the attribute is deprecated.
      #       If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:inheritedFrom] = parser.data_types[:inheritedFrom].new(inheritedFrom).visit(parser: parser) unless inheritedFrom.nil?
        hash[:type] = parser.data_types[:type].new(type).visit(parser: parser) unless type.nil?
        hash[:resolveInitializer] = parser.data_types[:resolve_initializer].new(resolveInitializer).visit(parser: parser) unless resolveInitializer.nil?
        new(hash)
      end
    end
  end
end

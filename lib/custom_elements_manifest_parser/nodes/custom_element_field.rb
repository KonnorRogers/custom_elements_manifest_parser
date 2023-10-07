require_relative "./class_field.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # Additional metadata for fields on custom elements.
    # This is equivalent to "ClassField"
    class CustomElementField < ClassField
      # @!attribute attribute
      #   @return [String, nil] -
      #     The corresponding attribute name if there is one.
      #     If this property is defined, the attribute must be listed in the classes'
      #     `attributes` array.
      attribute :attribute, Types::Strict::String.optional.meta(required: false)

      # @!attribute reflects
      #   @return [Boolean, nil] -
      #     If the property reflects to an attribute.
      #     If this is true, the `attribute` property must be defined.
      attribute :reflects, Types::Strict::Bool.optional.meta(required: false)
    end
  end
end

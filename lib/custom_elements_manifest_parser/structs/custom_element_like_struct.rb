require_relative "./class_like_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Structs
    # The additional fields that a custom element adds to classes and mixins.
    class CustomElementLikeStruct < BaseStruct
      # @!parse include Structs::ClassLikeStruct
      attributes_from ClassLikeStruct

      # @!attribute customElement
      #   @return [True] - Distinguishes a regular JavaScript class from a custom element class
      attribute :customElement, Types::Strict::True

      # @!attribute tagName
      #   @return [String, nil] -
      #     An optional tag name that should be specified if this is a
      #     self-registering element.
      #
      #     Self-registering elements must also include a CustomElementExport
      #     in the module's exports.
      attribute :tagName, Types::Strict::String.optional.meta(required: false)

      # @!attribute attributes
      #   @return [Array<Attribute>, nil] - The attributes that this element is known to understand.
      attribute :attributes, Types::Strict::Array.optional.meta(required: false)

      # @param demos [Array<Demo>, nil]
      attribute :demos, Types::Strict::Array.optional.meta(required: false)

      # @!attribute cssProperties
      #    @return [Array<CssCustomProperty>, nil]
      attribute :cssProperties, Types::Strict::Array.optional.meta(required: false)

      # @!attribute cssParts
      #    @return [Array<CssPart>, nil] - Array of CSS Parts
      attribute :cssParts, Types::Strict::Array.optional.meta(required: false)

      # @!attribute slots
      #    @return [Array<Slot>, nil] - The shadow dom content slots that this element accepts.
      attribute :slots, Types::Strict::Array.optional.meta(required: false)

      # @!attribute events
      #    @return [Array<Event>, nil] - The events that this element fires.
      attribute :events, Types::Strict::Array.optional.meta(required: false)

      def self.build_hash(parser:, struct:)
        hash = {}

        # This is a special case because DryStruct reserves the `attributes` namespace.
        hash[:attributes] = struct.attributes[:attributes].map { |attr| parser.data_types[:attribute].new(attr).visit(parser: parser) } unless struct.attributes[:attributes].nil?

        hash[:cssProperties] = struct.cssProperties.map { |css_custom_property| parser.data_types[:css_custom_property].new(css_custom_property).visit(parser: parser) } unless struct.cssProperties.nil?

        hash[:cssParts] = struct.cssParts.map { |css_part| parser.data_types[:css_part].new(css_part).visit(parser: parser) } unless struct.cssParts.nil?
        hash[:demos] = struct.demos.map { |demo| parser.data_types[:demo].new(demo).visit(parser: parser) } unless struct.demos.nil?
        hash[:slots] = struct.slots.map { |slot| parser.data_types[:slot].new(slot).visit(parser: parser) } unless struct.slots.nil?
        hash[:events] = struct.events.map { |event| parser.data_types[:event].new(event).visit(parser: parser) } unless struct.events.nil?

        hash
      end
    end
  end
end

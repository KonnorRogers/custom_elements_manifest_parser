require_relative "../structs/declarable_node_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    #
    # A global custom element defintion, ie the result of a
    # `customElements.define()` call.
    #
    # This is represented as an export because a definition makes the element
    # available outside of the module it's defined it.
    #
    class CustomElementExport < BaseStruct
      # @return ["custom-element-definition"]
      def self.kind; "custom-element-definition"; end

      # @!attribute kind
      #    @return ["custom-element-definition"]
      attribute :kind, Types.Value("custom-element-definition")

      attributes_from Structs::DeclarableNodeStruct

      # @!attribute name
      #    @return [String] - The tag name of the custom element
      attribute :name, Types::Strict::String

      # @!attribute declaration
      #   @return [Reference]
      #     A reference to the class or other declaration that implements the
      #     custom element.
      attribute :declaration, Types::Nominal::Any

      # @param deprecated [boolean, string, nil]
      #  Whether the custom-element export is deprecated.
      #  For example, a future version will not register the custom element in this file.
      #  If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::Bool.optional | Types::Strict::String.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:declaration] = parser.data_types[:declaration].new(declaration).visit(parser: parser)
        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self)
        )
        new(hash)
      end
    end
  end
end

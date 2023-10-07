require_relative "../structs/declarable_node_struct.rb"
require_relative "../structs/custom_element_like_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # This is equivalent to CustomElementDeclaration.
    class ClassDeclaration < BaseStruct
      # @return ["class"]
      def self.kind; 'class'; end

      # @!attribute
      #    @return ["class"]
      attribute :kind, Types.Value("class")

      attributes_from Structs::DeclarableNodeStruct
      attributes_from Structs::CustomElementLikeStruct

      def visit(parser:)
        hash = {}

        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self),
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self)
        )

        new(hash)
      end
    end
  end
end

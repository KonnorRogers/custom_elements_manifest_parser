require_relative "../structs/declarable_node_struct.rb"
require_relative "../structs/property_like_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # Documents a variable
    class VariableDeclaration < BaseStruct
      include Mixins::HasParentModule

      # @!parse include Structs::DeclarableNodeStruct
      attributes_from Structs::DeclarableNodeStruct

      # @!parse include Structs::PropertyLikeStruct
      attributes_from Structs::PropertyLikeStruct

      # @return ["variable"]
      def self.kind; "variable"; end

      # @!attribute kind
      #   @return ["variable"]
      attribute :kind, Types.Value("variable")

      # @!attribute source
      #   @return [Nodes::SourceReference, nil]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:source] = parser.data_types[:source].new(source).visit(parser: parser) unless source.nil?

        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self),
          Structs::PropertyLikeStruct.build_hash(parser: parser, struct: self),
        )

        new(hash)
      end
    end
  end
end

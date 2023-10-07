require_relative "../structs/declarable_node_struct.rb"
require_relative "../structs/function_like_struct.rb"

require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module Nodes
    # Documents a function
    class FunctionDeclaration < BaseStruct
      attributes_from Structs::DeclarableNodeStruct
      attributes_from Structs::FunctionLikeStruct

      def self.kind; "function"; end

      # @!attribute kind
      #   @return ["function"]
      attribute :kind, Types.Value("function")

      # @!attribute source
      #   @return [SourceReference, nil]
      attribute :source, Types::Strict::String.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:source] = parser.data_types[:source].new(source).visit(parser: parser) unless source.nil?

        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self),
          Structs::FunctionLikeStruct.build_hash(parser: parser, struct: self)
        )
        new(hash)
      end
    end
  end
end

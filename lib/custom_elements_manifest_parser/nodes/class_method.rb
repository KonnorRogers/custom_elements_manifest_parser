require_relative "../structs/declarable_node_struct.rb"
require_relative "../structs/function_like_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # Documents a method attached to a class
    class ClassMethod < BaseStruct
      include Mixins::HasParentModule

      # @!parse Structs::FunctionLikeStruct
      attributes_from Structs::FunctionLikeStruct

      # @!parse Structs::DeclarableNodeStruct
      attributes_from Structs::DeclarableNodeStruct

      # @return ["method"]
      def self.kind; 'method'; end

      # @!attribute kind
      #   @return ["method"]
      attribute :kind, Types.Value("method")

      # @!attribute static
      #   @return [Boolean, nil]
      attribute :static, Types::Strict::Bool.optional.meta(required: false)

      # @!attribute privacy
      #   @return [Types.privacy, nil]
      attribute :privacy, Types.privacy.optional.meta(required: false)

      # @!attribute inheritedFrom
      #   @return [Reference, nil]
      attribute :inheritedFrom, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute source
      #   @return [SourceReference, nil]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:inheritedFrom] = parser.data_types[:inherited_from].new(inheritedFrom).visit(parser: parser) unless inheritedFrom.nil?
        hash[:source] = parser.data_types[:source].new(source).visit(parser: parser) unless source.nil?

        hash = hash.merge(
          Structs::FunctionLikeStruct.build_hash(parser: parser, struct: self),
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self)
        )

        new(hash)
      end
    end
  end
end

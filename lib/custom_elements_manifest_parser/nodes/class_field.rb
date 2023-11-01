require_relative "../structs/property_like_struct.rb"
require_relative "../structs/declarable_node_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # Documents a class property. This does not get used directly. Instead, it gets extended by CustomElementField.
    class ClassField < BaseStruct
      # @return ["field"]
      def self.kind; "field"; end

      # @!attribute kind
      #    @return ['field']
      attribute :kind, Types.Value("field")

      # @!attribute privacy
      #    @return [Boolean, nil]
      attribute :static, Types::Strict::Bool.optional.meta(required: false)

      # @!attribute inheritedFrom
      #    @return [Reference, nil]
      attribute :inheritedFrom, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute source
      #    @return [SourceReference, nil]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      include Mixins::HasParentModule

      # @!parse include Structs::DeclarableNodeStruct
      attributes_from Structs::DeclarableNodeStruct

      # @!parse include Structs::PropertyLikeStruct
      attributes_from Structs::PropertyLikeStruct

      def visit(parser:)
        hash = {}
        hash[:inheritedFrom] = parser.data_types[:inherited_from].new(inheritedFrom).visit(parser: parser) unless inheritedFrom.nil?
        hash[:source] = parser.data_types[:source].new(source).visit(parser: parser) unless source.nil?

        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self),
          Structs::PropertyLikeStruct.build_hash(parser: parser, struct: self)
        )

        new(hash)
      end
    end
  end
end

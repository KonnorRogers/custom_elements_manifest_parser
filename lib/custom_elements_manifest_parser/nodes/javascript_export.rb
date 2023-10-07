require_relative "../structs/declarable_node_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # A JavaScript export!
    class JavaScriptExport < BaseStruct
      # @!parse include Structs::DeclarableNodeStruct
      attributes_from Structs::DeclarableNodeStruct

      # @!attribute kind
      #   @return ["js"]
      attribute :kind, Types.Value("js")

      # @return ["js"]
      def self.kind; "js"; end

      # @!attribute name
      #    @return [String] -
      #       The name of the exported symbol.
      #
      #       JavaScript has a number of ways to export objects which determine the
      #       correct name to use.
      #
      #       - Default exports must use the name "default".
      #       - Named exports use the name that is exported. If the export is renamed
      #         with the "as" clause, use the exported name.
      #       - Aggregating exports (`* from`) should use the name `*`
      attribute :name, Types::Strict::String

      # @!attribute declaration
      #   @return [Reference] -
      #     A reference to the exported declaration.
      #
      #     In the case of aggregating exports, the reference's `module` field must be
      #     defined and the `name` field must be `"*"`.
      attribute :declaration, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute deprecated
      #    @return [nil, boolean, string] -
      #       Whether the export is deprecated. For example, the name of the export was changed.
      #       If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:declaration] = parser.data_types[:declaration].new(declaration).visit(parser: parser) if declaration

        hash = hash.merge(
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self)
        )

        new(hash)
      end
    end
  end
end

require_relative "../types.rb"
require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents a JSDoc, Closure, or TypeScript type.
    class Type < BaseStruct
      # @param text [String] -
      #   The full string representation of the type, in whatever type syntax is
      #   used, such as JSDoc, Closure, or TypeScript.
      attribute :text, Types::Strict::String

      # @!attribute references
      #     @return [nil, Array<TypeReference> -
      #        An array of references to the types in the type string.
      #        These references have optional indices into the type string so that tools
      #        can understand the references in the type string independently of the type
      #        system and syntax. For example, a documentation viewer could display the
      #        type `Array<FooElement | BarElement>` with cross-references to `FooElement`
      #        and `BarElement` without understanding arrays, generics, or union types.
      attribute :references, Types::Strict::Array.optional.meta(required: false)

      # @!attribute source
      #     @return [nil, SourceReference]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:references] = references.map { |reference| parser.data_types[:type_reference].new(reference).visit(parser: parser) } unless references.nil?
        new(hash)
      end
    end
  end
end

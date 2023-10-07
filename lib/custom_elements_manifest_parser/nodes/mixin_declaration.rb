require_relative "../structs/function_like_struct.rb"
require_relative "../structs/declarable_node_struct.rb"
require_relative "../structs/custom_element_like_struct.rb"

require_relative "../types.rb"
require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module Nodes
    # A description of a class mixin.
    #
    # Mixins are functions which generate a new subclass of a given superclass.
    # This interfaces describes the class and custom element features that
    # are added by the mixin. As such, it extends the CustomElement interface and
    # ClassLike interface.
    #
    # Since mixins are functions, it also extends the FunctionLike interface. This
    # means a mixin is callable, and has parameters and a return type.
    #
    # The return type is often hard or impossible to accurately describe in type
    # systems like TypeScript. It requires generics and an `extends` operator
    # that TypeScript lacks. Therefore it's recommended that the return type is
    # left empty. The most common form of a mixin function takes a single
    # argument, so consumers of this interface should assume that the return type
    # is the single argument subclassed by this declaration.
    #
    # A mixin should not have a superclass. If a mixins composes other mixins,
    # they should be listed in the `mixins` field.
    #
    # See <https://justinfagnani.com/2015/12/21/real-mixins-with-javascript-classes/>
    # for more information on the classmixin pattern in JavaScript.
    #
    # This JavaScript mixin declaration:
    # ```javascript
    # const MyMixin = (base) => class extends base {
    #   foo() { ... }
    # }
    # ```
    #
    # Is described by this JSON:
    # ```json
    # {
    #   "kind": "mixin",
    #   "name": "MyMixin",
    #   "parameters": [
    #     {
    #       "name": "base",
    #     }
    #   ],
    #   "members": [
    #     {
    #       "kind": "method",
    #       "name": "foo",
    #     }
    #   ]
    # }
    # ```
    class MixinDeclaration < BaseStruct
      # @!parse Structs::CustomElementLikeStruct
      attributes_from Structs::CustomElementLikeStruct

      # @!parse Structs::FunctionLikeStruct
      Structs::FunctionLikeStruct.schema.each do |attr|
        names = Structs::CustomElementLikeStruct.schema.keys.map { |obj| obj.name }

        next if names.include?(attr.name)

        attribute attr.name, attr.type
      end

      # @!parse Structs::FunctionLikeStruct
      attributes_from Structs::DeclarableNodeStruct

      # @!attribute kind
      #    @return ["mixin"]
      attribute :kind, Types.Value("mixin")

      # @return ["mixin"]
      def self.kind; 'mixin'; end

      def visit(parser:)
        hash = {}

        hash = hash.merge(
          # Structs::FunctionLikeStruct.build_hash(parser: parser, struct: self),
          Structs::CustomElementLikeStruct.build_hash(parser: parser, struct: self),
          Structs::DeclarableNodeStruct.build_hash(parser: parser, struct: self),
        )

        new(hash)
      end
    end
  end
end

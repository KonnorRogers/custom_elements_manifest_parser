require_relative "../types.rb"
require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module Structs
    # The common interface of classes and mixins.
    class ClassLikeStruct < BaseStruct
      # @!attribute name
      #    @return [String] - Name of the class
      attribute :name, Types::Strict::String

      # @!attribute summary
      #   @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #   @return [String, nil] - A markdown description of the class.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute superclass
      #   @return [Reference, nil] -
      #     The superclass of this class.
      #
      #     If this class is defined with mixin applications, the prototype chain
      #     includes the mixin applications and the true superclass is computed
      #     from them.
      #
      #     Any class mixins applied in the extends clause of this class.
      attribute :superclass, Types::Nominal::Any.optional.meta(required: false)

      # @param mixins [Array<Reference>, nil] -
      #   If mixins are applied in the class definition, then the true superclass
      #   of this class is the result of applying mixins in order to the superclass.
      #
      #   Mixins must be listed in order of their application to the superclass or
      #   previous mixin application. This means that the innermost mixin is listed
      #   first. This may read backwards from the common order in JavaScript, but
      #   matches the order of language used to describe mixin application, like
      #   "S with A, B".
      #
      #   @example
      #
      #   ```javascript
      #   class T extends B(A(S)) {}
      #   ```
      #
      #   is described by:
      #   ```json
      #   {
      #     "kind": "class",
      #     "superclass": {
      #       "name": "S"
      #     },
      #     "mixins": [
      #       {
      #         "name": "A"
      #       },
      #       {
      #         "name": "B"
      #       },
      #     ]
      #   }
      #   ```
      #
      attribute :mixins, Types::Strict::Array.optional.meta(required: false)

      # @!attribute members
      #   @return [Array<ClassField, ClassMethod>, nil]
      attribute :members, Types::Strict::Array.optional.meta(required: false)

      # @!attribute source
      #   @return [SourceReference, nil]
      attribute :source, Types::Nominal::Any.optional.meta(required: false)

      # @!attribute deprecated
      #   @return [nil, boolean, string]
      #     Whether the class or mixin is deprecated.
      #     If the value is a string, it's the reason for the deprecation.
      attribute? :deprecated, Types::Strict::Bool | Types::Strict::String.optional.meta(required: false)

      def self.build_hash(parser:, struct:)
        hash = {}
        hash[:superclass] = struct.parser.data_types[:superclass].new(superclass).visit(parser: parser) unless struct.superclass.nil?
        hash[:mixins] = struct.mixins.map { |mixin| parser.data_types[:mixin].new(mixin).visit(parser: parser) } unless struct.mixins.nil?
        hash[:source] = struct.parser.data_types[:source].new(source).visit(parser: parser) unless struct.source.nil?

        hash[:members] = struct.members.map { |member| parser.visit_node(member) } unless struct.members.nil?
        hash
      end
    end
  end
end

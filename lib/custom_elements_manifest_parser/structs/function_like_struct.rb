require_relative "../types.rb"
require_relative "../base_struct.rb"

module CustomElementsManifestParser
  module Structs
    # An interface for functions / methods.
    class FunctionLikeStruct < BaseStruct
      # @!attribute name
      #    @return [String, nil] - Name of the function
      attribute :name, Types::Strict::String.optional.meta(required: false)

      # @!attribute summary
      #   @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [String, nil] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #   @return [Boolean, String, nil]
      #     Whether the function is deprecated.
      #     If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      # @param parameters [nil, Array<Parameter>]
      attribute :parameters, Types::Strict::Array.optional | Types::Strict::Nil.optional.meta(required: false)

      # @param return [nil, FunctionReturnType]
      attribute :return, Types::Nominal::Any.optional.meta(required: false)

      def self.build_hash(parser:, struct:)
        hash = {}
        hash[:parameters] = struct.parameters.map { |parameter| parser.data_types[:parameter].new(parameter).visit(parser: parser) } if struct.parameters
        hash[:return] = parser.data_types[:function_return_type].new(struct.return).visit(parser: parser) if struct.return
        hash
      end
    end
  end
end

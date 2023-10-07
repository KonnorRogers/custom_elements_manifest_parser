require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Abstract class for documenting a FunctionReturnType
    class FunctionReturnType < BaseStruct
      # @!attribute type
      #   @return [Type, nil] - The type of the function return
      attribute :type, Types::Strict::String | Types::Strict::Hash.optional.meta(required: false)

      # @!attribute summary
      #   @return [String, nil] Summary of the function return
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #   @return [String, nil] Description of the function return
      attribute :description, Types::Strict::String.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

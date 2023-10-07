require_relative "../structs/property_like_struct.rb"

require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents a parameter on a function
    class Parameter < BaseStruct
      attributes_from Structs::PropertyLikeStruct

      # @!attribute optional
      #    @return [Boolean, nil] - Whether the parameter is optional. Undefined implies non-optional.
      attribute :optional, Types::Strict::Bool.optional.meta(required: false)

      # @!attribute rest
      #    @return [Boolean, nil] -
      #       Whether the parameter is a rest parameter. Only the last parameter may be a rest parameter.
      #       Undefined implies single parameter.
      attribute :rest, Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        hash = {}

        hash = hash.merge(
          Structs::PropertyLikeStruct.build_hash(parser: parser, struct: self)
        )
        new(hash)
      end
    end
  end
end

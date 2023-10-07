require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # This shouldn't be here, but was thrown up by CEM.
    class ResolveInitializer < BaseStruct
      # @return [String, nil]
      attribute :module, Types::Strict::String.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

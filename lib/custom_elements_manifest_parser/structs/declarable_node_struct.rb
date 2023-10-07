require_relative "../types.rb"
require_relative "../base_struct.rb"

# DeclarableNode is a Node that has a parent JavaScript module.
module CustomElementsManifestParser
  module Structs
    class DeclarableNodeStruct < BaseStruct
      # @!attribute parent_module
      #   @return [JavaScriptModule, nil] -
      #     A convenience helper so you don't need to manually traverse the manifest and always go top -> bottom.
      #     By using this you can grab the "path" and "exports" of a custom element.
      attribute? :parent_module, Types::Nominal::Any

      def self.build_hash(parser:, struct:)
        {}
      end
    end
  end
end

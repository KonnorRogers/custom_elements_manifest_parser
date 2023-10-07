require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # top level of a custom elements manifest. This technically isn't a "ParseableNode". its a top level "root" of a custom-elements.json.
    class Manifest < BaseStruct
      # @!attribute schemaVersion
      #   @return [String] - Version of the schema.
      attribute :schemaVersion, Types::Strict::String

      # @!attribute modules
      #   @return [Array<Nodes::JavaScriptModule>] - An array of the modules this package contains..
      attribute :modules, Types::Strict::Array

      # @!attribute readme
      #   @return [String, nil] - The Markdown to use for the main readme of this package.
      attribute :readme, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #   @return [String, Boolean, nil] - if nil or false, not deprecated. If true, deprecated. If string, why it's deprecated.
      attribute :deprecated, Types::Bool.optional | Types::String.optional.meta(required: false)

      def visit(parser:)
        hash = {}

        hash[:modules] = modules.map do |mod|
          parser.visit_node(mod)
        end

        hash[:modules]
        new(hash)
      end
    end
  end
end

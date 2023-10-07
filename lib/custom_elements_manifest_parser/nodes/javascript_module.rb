require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module Nodes
    # Document a JS module
    class JavaScriptModule < BaseStruct
      # @!attribute kind
      #    @return ["javascript-module"]
      attribute :kind, Types.Value("javascript-module")

      # @return ["javascript-module"]
      def self.kind; "javascript-module"; end

      # @!attribute path
      #   @return [String] -
      #     Path to the javascript file needed to be imported.
      #     (not the path for example to a typescript file.)
      attribute :path, Types::Strict::String

      # @!attribute summary
      #   @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute declarations
      #    @return[nil, Array<
      #      Nodes::ClassDeclaration,
      #      Nodes::FunctionDeclaration,
      #      Nodes::MixinDeclaration,
      #      Nodes::VariableDeclaration>] -
      #        The declarations of a module.
      #        For documentation purposes, all declarations that are reachable from
      #        exports should be described here. Ie, functions and objects that may be
      #        properties of exported objects, or passed as arguments to functions.
      attribute :declarations, Types::Strict::Array.optional.meta(required: false)

      # @!attribute exports
      #   @return [nil, Array<CustomElementExport, JavaScriptExport>] -
      #     The exports of a module. This includes JavaScript exports and
      #     custom element definitions.
      attribute :exports, Types::Strict::Array.optional.meta(required: false)

      # @!attribute deprecated
      #    @return [String, nil, Boolean] -
      #       Whether the module is deprecated.
      #       If the value is a string, it's the reason for the deprecation.
      attribute? :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        hash = {}
        hash[:declarations] = declarations.map { |declaration| parser.visit_node(declaration.merge(parent_module: self)) } unless declarations.nil?
        hash[:exports] = exports.map { |export| parser.visit_node(export.merge(parent_module: self)) } unless exports.nil?

        new(hash)
      end
    end
  end
end

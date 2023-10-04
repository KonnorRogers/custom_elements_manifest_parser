# frozen_string_literal: true

require_relative "custom_elements_manifest_parser/version"
require_relative "custom_elements_manifest_parser/nodes"

# Top level parser
module CustomElementsManifestParser
  # Shortuct for `CustomElementsManifestParser::Parser.new().parse()`
  def self.parse(arg = nil, **kwargs)
    hash = if arg.is_a?(Hash)
             arg
           else
             kwargs
           end

    Parser.new(**hash.transform_keys(&:to_sym)).parse
  end

  # @return [Hash{"public", "private", "protected" => "public", "private", "protected"}]
  PRIVACY = {
    public: 'public',
    private: 'private',
    protected: 'protected'
  }.freeze

  # Top level interface that users will interact with when reading custom elements JSON.
  # @example
  #   CustomElementsSchema::Parser.new(JSON.parse("custom-elements.json"))
  #
  class Parser
    attr_accessor :visitable_nodes
    attr_accessor :manifest

    def initialize(arg = nil, **kwargs)
      hash = if arg.is_a?(Hash)
               arg
             else
               kwargs
             end

      @visitable_nodes = {}
      @visitable_nodes[Nodes::JavaScriptModule.kind] = Nodes::JavaScriptModule
      @visitable_nodes[Nodes::CustomElementField.kind] = Nodes::CustomElementField
      @visitable_nodes[Nodes::JavaScriptExport.kind] = Nodes::JavaScriptExport
      @visitable_nodes[Nodes::CustomElementExport.kind] = Nodes::CustomElementExport
      @visitable_nodes[Nodes::ClassMethod.kind] = Nodes::ClassMethod

      # Top level declarations
      @visitable_nodes[Nodes::ClassDeclaration.kind] = Nodes::ClassDeclaration
      @visitable_nodes[Nodes::FunctionDeclaration.kind] = Nodes::FunctionDeclaration
      @visitable_nodes[Nodes::VariableDeclaration.kind] = Nodes::VariableDeclaration

      ## This is equivalent to MixinDeclaration | CustomElementDeclaration | CustomElementMixinDeclaration;
      @visitable_nodes[Nodes::MixinDeclaration.kind] = Nodes::MixinDeclaration

      # @return [Nodes::Manifest]
      @manifest = Nodes::Manifest.new(**hash.transform_keys(&:to_sym))
    end

    # Builds the fully parsed tree
    # @return [Package]
    def parse
      manifest.visit(parser: self)
      self
    end

    # def array_fields
    #   [
    #     "declarations",
    #     "exports",
    #     "members",
    #     "mixins",
    #     "attributes",
    #     "events",
    #     "slots",
    #     "cssParts",
    #     "cssProperties",
    #     "demos",
    #     "parameters",
    #     "references",
    #     "modules",
    #   ]
    # end

    # Hash{String, symbol => unknown}
    def visit_node(node)
      kind = node["kind"] || node[:kind]
      @visitable_nodes[kind].new(**node.transform_keys(&:to_sym)).visit(parser: self)
    end
  end
end

# frozen_string_literal: true

require_relative "custom_elements_manifest_parser/version"
require_relative "custom_elements_manifest_parser/nodes"
require "set"

module CustomElementsManifestParser
  # Shortuct for `CustomElementsManifestParser::Parser.new().parse()`
  def self.parse(**kwargs)
    hash = kwargs.transform_keys(&:to_sym)
    Parser.new(**hash).parse
  end

  # @return [Hash{"public", "private", "protected" => "public", "private", "protected"}]
  PRIVACY = {
    public: 'public',
    private: 'private',
    protected: 'protected'
  }.freeze

  # Top level interface that users will interact with when reading custom elements JSON.
  # @example
  #   CustomElementsSchema::Parser.new(**JSON.parse("custom-elements.json"))
  #
  class Parser < Nodes::Package
    attr_accessor :visitable_nodes

    def initialize(**kwargs)
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

      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
    end

    # Caches a version of tree. We can re-parse anytime by calling #parse directly.
    def tree
      @tree ||= parse
    end

    # Builds the fully parsed tree
    def parse
      @tree = visit(parser: self)
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

    def find_by(&block)
      ary = []

      tree.modules.flatten.each do |node|
        ary << node if block.call(node) == true
      end

      ary.to_set.to_a
    end

    # Hash{String, symbol => unknown}
    def visit_node(node)
      kind = node["kind"] || node[:kind]
      @visitable_nodes[kind].new(**node.transform_keys(&:to_sym)).visit(parser: self)
    end

    # def find_by_kind(kind)
    #   modules
    # end
  end
end

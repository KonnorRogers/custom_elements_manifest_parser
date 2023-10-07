require_relative "./base_struct.rb"
require_relative "./types.rb"

module CustomElementsManifestParser
  Dir["#{__dir__}/**/*.rb"].each { |file| require_relative file if file != __FILE__ }

  # Top level interface that users will interact with when reading custom elements JSON.
  # @example
  #   ::CustomElementsManifestParser::Parser.new(JSON.parse("custom-elements.json"))
  #
  class Parser
    attr_accessor :visitable_nodes, :manifest, :data_types

    # @param hash [Hash{String => any}]
    def initialize(hash)
      type_check = Types::Strict::Hash
      type_check[hash]

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

      # data_types are different from @visitable_nodes. They serialize data, but do not represent a physical node in the Custom Elements JSON.
      @data_types = {
        attribute: DataTypes::Attribute,
        css_part: DataTypes::CssPart,
        css_custom_property: DataTypes::CssCustomProperty,
        demo: DataTypes::Demo,
        declaration: DataTypes::Reference,
        event: DataTypes::Event,
        function_return_type: DataTypes::FunctionReturnType,
        mixin: DataTypes::Reference,
        parameter: DataTypes::Parameter,
        superclass: DataTypes::Reference,
        source: DataTypes::SourceReference,
        slot: DataTypes::Slot,
        type: DataTypes::Type,
        type_reference: DataTypes::TypeReference,
        inheritedFrom: DataTypes::Reference,
        resolve_initializer: DataTypes::ResolveInitializer,
        reference: DataTypes::Reference
      }

      # @return [Nodes::Manifest]
      @manifest = Nodes::Manifest.new(hash)
    end

    # Builds the fully parsed tree
    # @return [Package]
    def parse
      @manifest = manifest.visit(parser: self)
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
      @visitable_nodes[kind].new(node).visit(parser: self)
    end
  end
end

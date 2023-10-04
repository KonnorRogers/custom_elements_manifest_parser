module CustomElementsManifestParser
  # The error to raise when the Node "kind" does not match the static node type.
  class MismatchedNodeTypeError < StandardError
    def initialize(node_kind, node_kind_compare)
      msg = "Expected to find a '#{node_kind}' but got '#{node_kind_compare}'"
      super(msg)
    end
  end

  # Checks if the NodeType matches the Classes' "kind"
  module ParseableNode
    def initialize(*args, **kwargs, &block)
      super(*args, **kwargs, &block)
      raise MismatchedNodeTypeError.new(self.class.kind, kind) if kind != self.class.kind
    end

    def visit(parser:)
      super(parser: parser)
      self
    end
  end

  # A reference to an export of a module.
  #
  # All references are required to be publically accessible, so the canonical
  # representation of a reference is the export it's available from.
  #
  # `package` should generally refer to an npm package name. If `package` is
  # undefined then the reference is local to this package. If `module` is
  # undefined the reference is local to the containing module.
  #
  # References to global symbols like `Array`, `HTMLElement`, or `Event` should
  # use a `package` name of `"global:"`.
  #
  class Reference
    attr_accessor :name, :package, :module

    # We use kwargs here because "module" is a reserved keyword.
    # @param name [String] - Name of the reference
    # @param package [String, nil] - Name of the package
    # @param kwargs [Hash<"module", String, nil>]
    def initialize(name:, package: nil, **kwargs)
      @name = name
      @package = package

      hash = kwargs.transform_keys(&:to_sym)
      @module = hash[:module]
    end
  end

  # The common interface of classes and mixins.
  module ClassLike
    attr_accessor :name,
                  :summary,
                  :description,
                  :superclass,
                  :mixins,
                  :members,
                  :source,
                  :deprecated

    # @param name [String] - Name of the class
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description of the class.
    # @param superclass [Reference, nil] -
    #   The superclass of this class.
    #
    #   If this class is defined with mixin applications, the prototype chain
    #   includes the mixin applications and the true superclass is computed
    #   from them.
    #
    #   Any class mixins applied in the extends clause of this class.
    #
    # @param mixins [Array<Reference>, nil] -
    #   If mixins are applied in the class definition, then the true superclass
    #   of this class is the result of applying mixins in order to the superclass.
    #
    #   Mixins must be listed in order of their application to the superclass or
    #   previous mixin application. This means that the innermost mixin is listed
    #   first. This may read backwards from the common order in JavaScript, but
    #   matches the order of language used to describe mixin application, like
    #   "S with A, B".
    #
    #   @example
    #
    #   ```javascript
    #   class T extends B(A(S)) {}
    #   ```
    #
    #   is described by:
    #   ```json
    #   {
    #     "kind": "class",
    #     "superclass": {
    #       "name": "S"
    #     },
    #     "mixins": [
    #       {
    #         "name": "A"
    #       },
    #       {
    #         "name": "B"
    #       },
    #     ]
    #   }
    #   ```
    #
    # @param members [Array<ClassField, ClassMethod>, nil]
    # @param source [SourceReference, nil]
    #
    #
    # @param deprecated [nil, boolean, string]
    #   Whether the class or mixin is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    def initialize(
      name:,
      summary: nil,
      description: nil,
      superclass: nil,
      mixins: nil,
      members: nil,
      source: nil,
      deprecated: nil,
      **kwargs
    )
      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
      @name = name
      @summary = summary
      @description = description
      @superclass = superclass
      @superclass = Reference.new(**superclass.transform_keys(&:to_sym)) unless superclass.nil?

      @mixins = mixins
      @mixins = mixins.map { |mixin| Reference.new(**mixin.transform_keys(&:to_sym)) } unless mixins.nil?

      @members = members # transformed in visit.

      @source = source
      @source = SourceReference.new(**source.transform_keys(&:to_sym)) unless @source.nil?

      @deprecated = deprecated
    end

    def visit(parser:)
      super(parser: parser)

      @members = members.map { |member| parser.visit_node(**member) } unless @members.nil?
      self
    end
  end

  # The additional fields that a custom element adds to classes and mixins.
  module CustomElementLike
    def self.included(klass)
      klass.class_eval do
        include ClassLike
      end
    end

    attr_accessor :customElement,
                  :tagName,
                  :attributes,
                  :demos,
                  :cssProperties,
                  :cssParts,
                  :slots,
                  :events

    # @param tagName [String, nil] -
    #   An optional tag name that should be specified if this is a
    #   self-registering element.
    #
    #   Self-registering elements must also include a CustomElementExport
    #   in the module's exports.
    #
    # @param attributes [Array<Attribute>, nil] - The attributes that this element is known to understand.
    # @param events [Array<Event>, nil] - The events that this element fires.
    # @param slots [Array<Slot>, nil] - The shadow dom content slots that this element accepts.
    # @param cssParts [Array<CssPart>, nil]
    # @param cssProperties [Array<CssCustomProperty>, nil]
    # @param demos [Array<Demo>, nil]
    # @param customElement [true] -
    #   Distinguishes a regular JavaScript class from a
    #   custom element class
    def initialize(
      customElement:,
      tagName: nil,
      attributes: nil,
      demos: nil,
      cssProperties: nil,
      cssParts: nil,
      slots: nil,
      events: nil,
      **kwargs
    )
      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
      @customElement = customElement

      if @customElement != true
        raise "Attempted to parse as a customElement, but 'customElement' had the following value: #{@customElement}, expected: true"
      end

      @tagName = tagName

      @attributes = attributes
      @attributes = attributes.map { |attr| Attribute.new(**attr.transform_keys(&:to_sym))  } unless @attributes.nil?

      @demos = demos
      @demos = demos.map { |demo| Demo.new(**demo.transform_keys(&:to_sym)) } unless @demos.nil?

      @cssProperties = cssProperties
      @cssProperties = cssProperties.map { |css_custom_property| CssCustomProperty.new(**css_custom_property.transform_keys(&:to_sym)) } unless @cssProperties.nil?

      @cssParts = cssParts
      @cssParts = cssParts.map { |css_part| CssPart.new(**css_part.transform_keys(&:to_sym)) } unless @cssParts.nil?

      @slots = slots
      @slots = slots.map { |slot| Slot.new(**slot.transform_keys(&:to_sym)) } unless @slots.nil?

      @events = events
      @events = events.map { |event| Event.new(**event.transform_keys(&:to_sym)) } unless @events.nil?
    end
  end

  # A reference that is associated with a type string and optionally a range
  # within the string.
  #
  # Start and end must both be present or not present. If they're present, they
  # are indices into the associated type string. If they are missing, the entire
  # type string is the symbol referenced and the name should match the type
  # string.
  class TypeReference < Reference
    attr_accessor :start, :end

    # @param start [Number, nil]
    # @param end [Number, nil]
    def initialize(
      start: nil,
      **kwargs
    )
      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
      @start = start

      # Needs to be serialized this way to avoid Ruby keyword shenanigans.
      @end = hash[:end] || nil
    end
  end

  # The common interface of variables, class fields, and function
  # parameters.
  module PropertyLike
    attr_accessor :name,
                  :summary,
                  :description,
                  :type,
                  :default,
                  :deprecated,
                  :readonly

    # @param name [String]
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description of the field.
    # @param type [Type, nil] - The type serializer IE: "Object", "String", etc.
    # @param default [String, nil]
    # @param deprecated [nil, Boolean, String] -
    #   Whether the property is deprecated.
    #   If the value is a string, it's the reason for the deprecation.    #
    # @param readonly [nil, Boolean] - Whether the property is read-only.
    def initialize(
      name:,
      summary: nil,
      description: nil,
      type: nil,
      default: nil,
      deprecated: nil,
      readonly: nil,
      **kwargs
    )
      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
      @name = name
      @summary = summary
      @description = description
      @type = type
      @default = default
      @deprecated = deprecated
      @readonly = readonly
    end
  end


  # An interface for functions / methods.
  module FunctionLike
    attr_accessor :name,
                  :summary,
                  :description,
                  :deprecated,
                  :parameters,
                  :return
    # @param name [String, nil] - Name of the function
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description.
    # @param deprecated [Boolean, String, nil]
    #   Whether the function is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    # @param parameters [nil, Array<Parameter>]
    # @param return [nil, FunctionReturnType]
    def initialize(
      name: nil,
      summary: nil,
      description: nil,
      deprecated: nil,
      parameters: nil,
      **kwargs
    )
      hash = kwargs.transform_keys(&:to_sym)
      super(**hash)
      @name = name
      @summary = summary
      @description = description
      @deprecated = deprecated
      @parameters = parameters

      # Workaround for "return" keyword.
      @return = hash[:return] || nil
    end
  end


  # Gets passed an href to an absolute URL to the source.
  class SourceReference
    attr_accessor :href

    # @param href [String] - An absolute URL to the source (ie. a GitHub URL).
    def initialize(href:)
      @href = href
    end
  end

  # Documents an "attribute" on a custom element.
  class Attribute
    attr_accessor :name,
                  :summary,
                  :description,
                  :inheritedFrom,
                  :type,
                  :default,
                  :fieldName,
                  :resolveInitializer,
                  :deprecated

    # @param name [String] - The name of the attribute you place on the element.
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description.
    # @param inheritedFrom [Reference, nil] - Reference to where it inherited its attribute
    # @param type [Type, nil] - The type that the attribute will be serialized/deserialized as.
    # @param default [String, nil] -
    #   The default value of the attribute, if any.
    #   As attributes are always strings, this is the actual value, not a human
    #   readable description.
    # @param fieldName [String, nil] - The name of the field this attribute is associated with, if any.
    # @param deprecated [nil, Boolean, String] -
    #   Whether the attribute is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    #
    # @param resolveInitializer [ResolveInitializer, nil]
    #
    def initialize(
      name:,
      summary: nil,
      description: nil,
      inheritedFrom: nil,
      type: nil,
      default: nil,
      fieldName: nil,
      deprecated: nil,
      resolveInitializer: nil
    )
      @name = name
      @summary = summary
      @description = description
      @inheritedFrom = inheritedFrom
      @inheritedFrom = Reference.new(**inheritedFrom.transform_keys(&:to_sym)) unless @inheritedFrom.nil?

      @type = type
      @type = Type.new(**type.transform_keys(&:to_sym)) unless type.nil?

      @default = default
      @fieldName = fieldName
      @deprecated = deprecated

      @resolveInitializer = resolveInitializer
      @resolveInitializer = ResolveInitializer.new(**resolveInitializer.transform_keys(&:to_sym)) unless @resolveInitializer.nil?
    end
  end

  class ResolveInitializer
    # @return [String, nil]
    attr_accessor :module

    def initialize(**kwargs)
      @module = kwargs[:module]
    end
  end

  # Documents events on a custom element
  class Event
    attr_accessor :name,
                  :type,
                  :summary,
                  :description,
                  :deprecated

    # @param name [String]
    # @param summary [nil, String] - A markdown summary suitable for display in a listing.
    # @param description [nil, String] - A markdown description.
    # @param type [Type] - The type of the event object that's fired.
    # @param inheritedFrom [nil, Reference]
    # @param deprecated [nil, Boolean, String]
    #    Whether the event is deprecated.
    #    If the value is a string, it's the reason for the deprecation.
    def initialize(
      name:,
      type:,
      summary: nil,
      description: nil,
      deprecated: nil
    )
      @name = name
      @type = type
      @type = Type.new(**type.transform_keys(&:to_sym))
      @summary = summary
      @description = description
      @deprecated = deprecated
    end
  end

  # Documents slots for a custom element
  class Slot
    attr_accessor :name,
                  :summary,
                  :description,
                  :deprecated

    # @param name [String] - The slot name, or the empty string for an unnamed slot.
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description.
    # @param deprecated [nil, boolean, string] -
    #   Whether the slot is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    def initialize(
      name:,
      summary: nil,
      description: nil,
      deprecated: nil
    )
      @name = name
      @summary = summary
      @description = description
      @deprecated = deprecated
    end
  end

  # The name + description of a CSS Part
  class CssPart
    attr_accessor :name,
                  :summary,
                  :description,
                  :deprecated
    # @param name [String] - Name of the CSS part
    # @param summary [nil, String] - A markdown summary suitable for display in a listing.
    # @param description [nil, String] - A markdown description.
    # @param deprecated [nil, Boolean, String] -
    #   Whether the CSS shadow part is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    def initialize(
      name:,
      summary: nil,
      description: nil,
      deprecated: nil
    )
      @name = name
      @summary = summary
      @description = description
      @deprecated = deprecated
    end
  end

  # Documents a JSDoc, Closure, or TypeScript type.
  class Type
    attr_accessor :text,
                  :references,
                  :source

    # @param text [String] -
    #   The full string representation of the type, in whatever type syntax is
    #   used, such as JSDoc, Closure, or TypeScript.
    #
    # @param references [nil, Array<TypeReference> -
    #   An array of references to the types in the type string.
    #   These references have optional indices into the type string so that tools
    #   can understand the references in the type string independently of the type
    #   system and syntax. For example, a documentation viewer could display the
    #   type `Array<FooElement | BarElement>` with cross-references to `FooElement`
    #   and `BarElement` without understanding arrays, generics, or union types.
    #
    # @param source [nil, SourceReference]
    def initialize(
      text:,
      references: nil,
      source: nil
    )
      @text = text

      @references = references
      @references = references.map { |reference| Reference.new(**reference.transform_keys(&:to_sym)) } unless references.nil?

      @source = source
    end
  end

  # Documents a CSS Custom Property such as +var(--my-custom-props)+
  class CssCustomProperty
    attr_accessor :name,
                  :syntax,
                  :summary,
                  :description,
                  :deprecated

    # @param name [String] - The name of the property, including leading `--`.
    # @param syntax [String, nil] -
    #   The expected syntax of the defined property. Defaults to "*".
    #
    #   The syntax must be a valid CSS [syntax string](https://developer.mozilla.org/en-US/docs/Web/CSS/@property/syntax)
    #   as defined in the CSS Properties and Values API.
    #
    #   Examples:
    #
    #   "<color>": accepts a color
    #   "<length> | <percentage>": accepts lengths or percentages but not calc expressions with a combination of the two
    #   "small | medium | large": accepts one of these values set as custom idents.
    #   "*": any valid token
    # @param default [String, nil] - The default initial value
    # @param summary [String, nil] - A markdown summary suitable for display in a listing.
    # @param description [String, nil] - A markdown description.
    #
    #
    # @param deprecated [nil, Boolean, String] -
    #   Whether the CSS custom property is deprecated.
    #   If the value is a string, it's the reason for the deprecation.
    def initialize(
      name:,
      syntax: nil,
      summary: nil,
      description: nil,
      deprecated: nil
    )
      @name = name
      @syntax = syntax
      @summary = summary
      @description = description
      @deprecated = deprecated
    end
  end

  # Documents a class property
  class ClassField
    include PropertyLike
    include ParseableNode

    # @return ["field"]
    def self.kind; "field"; end

    attr_accessor :kind,
                  :static,
                  :privacy,
                  :inheritedFrom,
                  :source

    # @param kind ['field']
    # @param static [Boolean, nil]
    # @param privacy ["protected", "public", "private", nil]
    # @param inheritedFrom [Reference, nil]
    # @param source [SourceReference, nil]
    def initialize(
      kind:,
      static: nil,
      privacy: nil,
      inheritedFrom: nil,
      source: nil
    )
      @kind = kind
      @static = static
      @privacy = privacy
      @inheritedFrom = inheritedFrom
      @source = source
    end

    def visit(parser:)
      @inheritedFrom = Reference.new(**@inheritedFrom.transform_keys(&:to_sym)) unless @inheritedFrom.nil?
      @source = SourceReference.new(**@source.transform_keys(&:to_sym)) unless @source.nil?
      self
    end
  end

  # Links to a demo of the element
  class Demo
    attr_accessor :url,
                  :description,
                  :source

    # @param description [String, nil] - A markdown description of the demo.
    # @param url [String] -
    #   Relative URL of the demo if it's published with the package. Absolute URL
    #   if it's hosted.
    # @param source [SourceReference, nil]
    def initialize(
      url:,
      description: nil,
      source: nil
    )
      @url = url
      @description = description
      @source = source
    end
  end

  # @abstract
  # We could subclass OpenStruct here if we really wanted.
  # This simulates a hash for easy documentation.
  class HashLike
    # Documentation for the +a+ key
    # attr_accessor :a

    # Documentation for the +b+ key
    # attr_accessor :b

    # Hash-like interface to access keys in the +[]+ syntax.
    def [](key) self.send(key) end

    # Hash-like interface to access keys in the +[]=+ syntax.
    def []=(key, value) self.send("#{key}=", value) end
  end

  # @abstract
  # Abstract class for documenting a FunctionReturnType
  class FunctionReturnType < HashLike
    # @return [Type, nil]
    attr_accessor :type

    # @return [String, nil]
    attr_accessor :summary

    # @return [String, nil]
    attr_accessor :description
  end

  class Parameter
    include PropertyLike

    attr_accessor :optional, :rest

    # @param optional [Boolean, nil] - Whether the parameter is optional. Undefined implies non-optional.
    # @param rest [Boolean, nil] -
    #   Whether the parameter is a rest parameter. Only the last parameter may be a rest parameter.
    #   Undefined implies single parameter.
    def initialize(optional: nil, rest: nil, **kwargs)
      @optional = optional
      @rest = rest
    end
  end

  module Nodes
    # top level of a custom elements manifest.
    class Package
      attr_accessor :schemaVersion, :deprecated, :readme, :modules

      # @param schemaVersion [String] - Version of the schema.
      # @param readme [String, nil] - The Markdown to use for the main readme of this package.
      # @param modules [Array<JavaScriptModule>] - An array of the modules this package contains.
      # @param deprecated [String, nil, Boolean] - If nil or false, not deprecated.
      #   If true, deprecated. If it has a string, it should be the reason the package was deprecated.
      #
      def initialize(schemaVersion:, readme: nil, modules: [], deprecated: nil)
        @schemaVersion = schemaVersion
        @readme = readme
        @deprecated = deprecated
        @modules = modules
      end

      def visit(parser:)
        @modules = @modules.map do |mod|
          parser.visit_node(mod)
        end
        self
      end
    end

    # A description of a class mixin.
    #
    # Mixins are functions which generate a new subclass of a given superclass.
    # This interfaces describes the class and custom element features that
    # are added by the mixin. As such, it extends the CustomElement interface and
    # ClassLike interface.
    #
    # Since mixins are functions, it also extends the FunctionLike interface. This
    # means a mixin is callable, and has parameters and a return type.
    #
    # The return type is often hard or impossible to accurately describe in type
    # systems like TypeScript. It requires generics and an `extends` operator
    # that TypeScript lacks. Therefore it's recommended that the return type is
    # left empty. The most common form of a mixin function takes a single
    # argument, so consumers of this interface should assume that the return type
    # is the single argument subclassed by this declaration.
    #
    # A mixin should not have a superclass. If a mixins composes other mixins,
    # they should be listed in the `mixins` field.
    #
    # See [this article]{@link https://justinfagnani.com/2015/12/21/real-mixins-with-javascript-classes/}
    # for more information on the classmixin pattern in JavaScript.
    #
    # @example
    #
    # This JavaScript mixin declaration:
    # ```javascript
    # const MyMixin = (base) => class extends base {
    #   foo() { ... }
    # }
    # ```
    #
    # Is described by this JSON:
    # ```json
    # {
    #   "kind": "mixin",
    #   "name": "MyMixin",
    #   "parameters": [
    #     {
    #       "name": "base",
    #     }
    #   ],
    #   "members": [
    #     {
    #       "kind": "method",
    #       "name": "foo",
    #     }
    #   ]
    # }
    # ```
    class MixinDeclaration
      include ParseableNode
      include FunctionLike
      include CustomElementLike

      attr_accessor :kind

      # @return ["mixin"]
      def self.kind; 'mixin'; end

      def initialize(kind:, **_kwargs)
        @kind = kind
      end
    end

    # Additional metadata for fields on custom elements.
    class CustomElementField < ClassField
      attr_accessor :attribute,
                    :reflects

      # @param attribute [String, nil] -
      #   The corresponding attribute name if there is one.
      #
      #   If this property is defined, the attribute must be listed in the classes'
      #     `attributes` array.
      #
      # @param reflects [Boolean, nil] -
      #   If the property reflects to an attribute.
      #   If this is true, the `attribute` property must be defined.
      def initialize(
        attribute: nil,
        reflects: nil,
        **kwargs
      )
        hash = kwargs.transform_keys(&:to_sym)
        super(**hash)
        @attribute = attribute
        @reflects = reflects
      end
    end


    # A JavaScript module!
    class JavaScriptModule
      include ParseableNode

      # @return ["javascript-module"]
      def self.kind; "javascript-module"; end

      attr_accessor :kind,
                    :path,
                    :summary,
                    :declarations,
                    :exports,
                    :deprecated

      # @param path [String] -
      #   Path to the javascript file needed to be imported.
      #   (not the path for example to a typescript file.)
      #
      # @param summary [String, nil] - A markdown summary suitable for display in a listing.
      #
      # @param declarations [nil, Array<
      #   ClassDeclaration,
      #   FunctionDeclaration,
      #   MixinDeclaration,
      #   VariableDeclaration>] -
      #     The declarations of a module.
      #     For documentation purposes, all declarations that are reachable from
      #     exports should be described here. Ie, functions and objects that may be
      #     properties of exported objects, or passed as arguments to functions.
      #
      # @param exports [nil, Array<CustomElementExport, JavaScriptExport>] -
      #   The exports of a module. This includes JavaScript exports and
      #   custom element definitions.
      #
      # @param deprecated [String, nil, Boolean] -
      #   Whether the module is deprecated.
      #   If the value is a string, it's the reason for the deprecation.
      #
      # @param kind ["javascript-module"] - The type of node
      def initialize(path: nil, kind:, summary: nil, declarations: nil, exports: nil, deprecated: nil)
        @kind = kind
        @path = path
        @summary = summary

        @declarations = declarations
        @exports = exports

        @deprecated = deprecated
      end

      def visit(parser:)
        @declarations = @declarations.map { |declaration| parser.visit_node(**declaration) } unless @declarations.nil?
        @exports = @exports.map { |export| parser.visit_node(**export) } unless @exports.nil?
        self
      end
    end

    # A JavaScript export!
    class JavaScriptExport
      include ParseableNode

      # @return ["js"]
      def self.kind; "js"; end

      # @param name [String] -
      #   The name of the exported symbol.
      #
      #   JavaScript has a number of ways to export objects which determine the
      #   correct name to use.
      #
      #   - Default exports must use the name "default".
      #   - Named exports use the name that is exported. If the export is renamed
      #     with the "as" clause, use the exported name.
      #   - Aggregating exports (`* from`) should use the name `*`
      # @param declaration [Reference] -
      #   A reference to the exported declaration.
      #
      #   In the case of aggregating exports, the reference's `module` field must be
      #   defined and the `name` field must be `"*"`.
      #
      # @param deprecated [nil, boolean, string] -
      #   Whether the export is deprecated. For example, the name of the export was changed.
      #   If the value is a string, it's the reason for the deprecation.
      #
      # @param kind ["js"] - The type of node
      def initialize(name:, kind:, declaration:, deprecated: nil)
        @name = name
        @declaration = declaration
        @declaration = Reference.new(**declaration.transform_keys(&:to_sym))
        @deprecated = deprecated
        @kind = kind
      end

      def visit(parser:)
        self
      end
    end


    #
    # A global custom element defintion, ie the result of a
    # `customElements.define()` call.
    #
    # This is represented as an export because a definition makes the element
    # available outside of the module it's defined it.
    #
    class CustomElementExport
      include ParseableNode

      attr_accessor :kind,
                    :name,
                    :declaration,
                    :deprecated

      # @return ["custom-element-definition"]
      def self.kind; "custom-element-definition"; end

      # @param name [String] - The tag name of the custom element
      # @param deprecated [boolean, string, nil]
      #  Whether the custom-element export is deprecated.
      #  For example, a future version will not register the custom element in this file.
      #  If the value is a string, it's the reason for the deprecation.
      #
      # @param declaration [Reference]
      #   A reference to the class or other declaration that implements the
      #   custom element.
      #
      # @param kind ["custom-element-definition"]
      def initialize(kind:, name:, declaration:, deprecated: nil)
        @kind = kind
        @name = name
        @declaration = declaration
        @deprecated = deprecated
      end

      def visit(parser:)
        @declaration = Reference.new(**@declaration.transform_keys(&:to_sym))
        self
      end
    end

    class ClassMethod
      include FunctionLike
      include ParseableNode

      attr_accessor :kind,
                    :static,
                    :privacy,
                    :inheritedFrom,
                    :source

      # @return ["method"]
      def self.kind; 'method'; end

      # @param kind ["method"]
      # @param static [Boolean, nil]
      # @param privacy ["public", "private", "protected", nil]
      # @param inheritedFrom [Reference, nil]
      # @param source [SourceReference, nil]
      def initialize(
        kind:,
        static: nil,
        privacy: nil,
        inheritedFrom: nil,
        source: nil,
        **_kwargs
      )
        @kind = kind
        @static = static
        @privacy = privacy
        @inheritedFrom = inheritedFrom
        @source = source
      end

      def visit(parser:)
        @inheritedFrom = Reference.new(**@inheritedFrom.transform_keys(&:to_sym)) unless @inheritedFrom.nil?
        @source = SourceReference.new(**@source.transform_keys(&:to_sym)) unless @source.nil?
        self
      end
    end

    # This is equivalent to CustomElementDeclaration.
    class ClassDeclaration
      prepend ParseableNode
      prepend CustomElementLike

      attr_accessor :kind

      # @return ["class"]
      def self.kind; 'class'; end

      # @param kind ["class"]
      def initialize(kind:, **_kwargs)
        @kind = kind
      end

      def visit(parser:)
        self
      end
    end

    class VariableDeclaration
      include ParseableNode
      include PropertyLike

      attr_accessor :kind, :source

      # @return ["variable"]
      def self.kind; "variable"; end

      # @param kind ["variable"]
      # @param source [SourceReference, nil]
      def initialize(kind:, source: nil, **_kwargs)
        @kind = kind
        @source = source
      end

      def visit(parser:)
        @source = SourceReference.new(**source.transform_keys(&:to_sym)) unless source.nil?
        self
      end
    end

    class FunctionDeclaration
      include ParseableNode
      include FunctionLike

      attr_accessor :kind, :source

      def self.kind; "function"; end

      # @param kind ["function"]
      # @param source [SourceReference, nil]
      def initialize(kind:, source: nil, **_kwargs)
        @kind = kind
        @source = source
      end

      def visit(parser:)
        @source = SourceReference.new(**source.transform_keys(&:to_sym)) unless source.nil?
        self
      end
    end
  end
end

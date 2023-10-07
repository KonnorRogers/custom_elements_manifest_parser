require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
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
    class Reference < BaseStruct
      # @!attribute name
      #    @return [String] - Name of the reference
      attribute :name, Types::Strict::String

      # @!attribute package
      #    @return [String, nil] - Name of the package
      attribute :package, Types::Strict::String.optional.meta(required: false)

      # @!attribute module
      #    @return [String, nil]
      attribute :module, Types::Strict::String.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

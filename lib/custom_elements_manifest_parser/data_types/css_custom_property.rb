require_relative "../base_struct.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # Documents a CssCustomProperty
    class CssCustomProperty < BaseStruct
      # @!attribute name
      #   @return [String] - The name of the property, including leading `--`.
      attribute :name, Types::Strict::String

      # @!attribute syntax
      #    @return [String, nil] -
      #       The expected syntax of the defined property. Defaults to "*".
      #       The syntax must be a valid CSS [syntax string](https://developer.mozilla.org/en-US/docs/Web/CSS/@property/syntax)
      #       as defined in the CSS Properties and Values API.
      #       Examples:
      #       "<color>": accepts a color
      #       "<length> | <percentage>": accepts lengths or percentages but not calc expressions with a combination of the two
      #       "small | medium | large": accepts one of these values set as custom idents.
      #       "*": any valid token
      attribute :syntax, Types::Strict::String.optional.meta(required: false)

      # @!attribute summary
      #    @return [String, nil] - A markdown summary suitable for display in a listing.
      attribute :summary, Types::Strict::String.optional.meta(required: false)

      # @!attribute description
      #    @return [String, nil] - A markdown description.
      attribute :description, Types::Strict::String.optional.meta(required: false)

      # @!attribute default
      #    @return [String, nil] - The default initial value
      attribute :default, Types::Strict::String.optional.meta(required: false)

      # @!attribute deprecated
      #    @return [nil, Boolean, String] -
      #       Whether the CSS custom property is deprecated.
      #       If the value is a string, it's the reason for the deprecation.
      attribute :deprecated, Types::Strict::String.optional | Types::Strict::Bool.optional.meta(required: false)

      def visit(parser:)
        self
      end
    end
  end
end

require_relative "./reference.rb"
require_relative "../types.rb"

module CustomElementsManifestParser
  module DataTypes
    # A reference that is associated with a type string and optionally a range
    # within the string.
    #
    # Start and end must both be present or not present. If they're present, they
    # are indices into the associated type string. If they are missing, the entire
    # type string is the symbol referenced and the name should match the type
    # string.
    class TypeReference < Reference
      # @param start [Integer, nil]
      attribute :start, Types::Strict::Integer.optional.meta(required: false)

      # @!attribute end
      #    @return [Integer, nil]
      attribute :end, Types::Strict::Integer.optional.meta(required: false)
    end
  end
end

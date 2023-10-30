require "dry-types"

module CustomElementsManifestParser
  # Dry types
  module Types
    # @ignore
    include Dry.Types

    # @return [Types::String.enum("private", "protected", "public"]
    def self.privacy
      Types::String.enum("private", "protected", "public")
    end
  end
end

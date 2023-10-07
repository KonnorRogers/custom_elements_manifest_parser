require "dry-struct"

module CustomElementsManifestParser
  # BaseStruct for data
  class BaseStruct < ::Dry::Struct
    transform_keys(&:to_sym)

    schema.strict
  end
end

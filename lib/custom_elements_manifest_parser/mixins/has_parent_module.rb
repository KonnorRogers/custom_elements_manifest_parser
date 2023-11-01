module CustomElementsManifestParser
  module Mixins
    # Any "DeclarableNodeStruct", has a "_parent_module"
    module HasParentModule
      def parent_module
        return parser.visit_node(_parent_module) if parser

        nil
      end
    end
  end
end

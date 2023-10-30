require_relative "lib/custom_elements_manifest_parser/version"

Gem::Specification.new do |spec|
  spec.name = "custom_elements_manifest_parser"
  spec.version = CustomElementsManifestParser::VERSION
  spec.authors = ["konnorrogers"]
  spec.email = ["konnor5456@gmail.com"]

  spec.summary = "A parser to easily iterate through a custom-elements.json file"
  spec.description = "A parser to easily iterate through a custom-elements.json file"
  spec.homepage = "https://github.com/konnorrogers/custom_elements_manifest_parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/konnorrogers/custom_elements_manifest_parser"
  spec.metadata["changelog_uri"] = "https://github.com/konnorrogers/custom_elements_manifest_parser/tree/main/CHANGELOG.md"
  spec.metadata["yard.run"] = "yri"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "dry-struct", "~> 1.0"
  spec.add_dependency "dry-types", "~> 1.0"
  spec.add_dependency "dry-validation", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end

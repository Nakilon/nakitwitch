Gem::Specification.new do |spec|
  spec.name         = "nakitwitch"
  spec.version      = "0.0.0"
  spec.summary      = "common Twitch API routines"

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/nakitwitch"}

  spec.add_dependency "nethttputils"
  spec.add_dependency "nakischema"

  spec.files        = %w{ LICENSE nakitwitch.gemspec lib/nakitwitch.rb }
end

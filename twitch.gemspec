Gem::Specification.new do |spec|
  spec.name         = "twitch"
  spec.version      = "0.0.0"
  spec.summary      = "simple Twitch API wrapper/boilerplate"

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/twitch"}

  spec.add_dependency "nethttputils"

  spec.files        = %w{ LICENSE twitch.gemspec lib/twitch.rb }
end

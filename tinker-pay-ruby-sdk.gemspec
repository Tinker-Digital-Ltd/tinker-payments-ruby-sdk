# frozen_string_literal: true

require_relative 'lib/tinker/version'

Gem::Specification.new do |spec|
  spec.name          = 'tinker-pay-ruby-sdk'
  spec.version       = Tinker::VERSION
  spec.authors       = ['Tinker', 'Edgar Alochi']
  spec.email         = ['create@tinker.co.ke', 'edgar@tinker.co.ke']

  spec.summary       = 'Official Ruby SDK for Tinker Payments API'
  spec.description   = 'Official Ruby SDK for Tinker Payments API'
  spec.homepage      = 'https://payments.tinker.co.ke'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/tinker/payments-ruby-sdk'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'base64', '~> 0.1'
end


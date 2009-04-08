# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitterdispatch}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2009-04-07}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "lib/twitter_dispatch", "lib/twitter_dispatch/dispatcher.rb", "lib/twitter_dispatch/proxy", "lib/twitter_dispatch/proxy/basic.rb", "lib/twitter_dispatch/proxy/none.rb", "lib/twitter_dispatch/proxy/oauth.rb", "lib/twitter_dispatch/proxy/shared.rb", "lib/twitterdispatch.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/twitter_dispatch", "spec/twitter_dispatch/proxy", "spec/twitter_dispatch/proxy/basic_spec.rb", "spec/twitter_dispatch/proxy/oauth_spec.rb", "spec/twitter_dispatch/proxy/shared_spec.rb", "spec/twitter_dispatch_spec.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mbleigh/twitterdispatch}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{twitterdispatch}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple Twitter API wrapper that gets out of your way and lets you access things directly.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Sip
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.action_controller.raise_on_missing_callback_actions = false
  end
end

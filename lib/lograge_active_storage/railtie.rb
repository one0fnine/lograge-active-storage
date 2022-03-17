# frozen_string_literal: true

require "rails/railtie"
require "lograge_active_storage/ordered_options"

module LogrageActiveStorage
  class Railtie < Rails::Railtie
    config.lograge.active_storage = LogrageActiveStorage::OrderedOptions.new
    config.lograge.active_storage.enabled = false
    config.lograge.active_storage.ignore_events = []

    config.after_initialize do |app|
      LogrageActiveStorage.setup(app) if app.config.lograge.active_storage.enabled
    end
  end
end

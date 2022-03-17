# frozen_string_literal: true

require "lograge_active_storage/version"
require "lograge_active_storage/log_subscribers/base"
require "lograge_active_storage/log_subscribers/active_storage"
require "lograge_active_storage/railtie"
require "active_storage/log_subscriber"

module LogrageActiveStorage
  module_function

  mattr_accessor :logger, :ignore_events

  # Custom options that will be appended to log line
  #
  # Currently supported formats are:
  #  - Hash
  #  - Any object that responds to call and returns a hash
  #
  mattr_writer :custom_options
  self.custom_options = nil

  def custom_options(event)
    if @@custom_options.respond_to?(:call)
      @@custom_options.call(event)
    else
      @@custom_options
    end
  end

  def remove_existing_log_subscriptions
    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      next unless subscriber.is_a?(ActiveStorage::LogSubscriber)

      unsubscribe(:active_storage, subscriber)
    end
  end

  def unsubscribe(component, subscriber)
    events = subscriber.public_methods(false).reject { |method| method.to_s == "call" }
    events.each do |event|
      ActiveSupport::Notifications.notifier
        .listeners_for("#{event}.#{component}").each do |listener|
          next unless listener.instance_variable_get("@delegate") == subscriber

          ActiveSupport::Notifications.unsubscribe listener
        end
    end
  end

  def setup(app)
    LogrageActiveStorage.remove_existing_log_subscriptions
    LogrageActiveStorage::LogSubscribers::ActiveStorage.attach_to :active_storage
    LogrageActiveStorage.logger = app.config.lograge.active_storage.logger
    LogrageActiveStorage.custom_options = app.config.lograge.active_storage.custom_options
    LogrageActiveStorage.ignore_events = app.config.lograge.active_storage.ignore_events
  end
end

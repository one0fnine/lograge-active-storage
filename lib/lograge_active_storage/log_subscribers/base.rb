# frozen_string_literal: true

require "active_support/log_subscriber"

module LogrageActiveStorage
  module LogSubscribers
    class Base < ActiveSupport::LogSubscriber
      protected

      def processing_data(event, data)
        return if event_ignore?(event.name)

        data.merge!(custom_options(event))
        logger.send(Lograge.log_level, Lograge.formatter.call(data))
      end

      def initial_data(event)
        payload = event.payload

        {
          service: payload[:service],
          key: payload[:key],
          duration: "#{event.duration.round(1)}ms"
        }
      end

      private

      def event_ignore?(name)
        !!LogrageActiveStorage.ignore_events.index(name.split(".").first)
      end

      def logger
        LogrageActiveStorage.logger.presence || Lograge.logger.presence || super
      end

      def custom_options(event)
        LogrageActiveStorage.custom_options(event) || {}
      end
    end
  end
end

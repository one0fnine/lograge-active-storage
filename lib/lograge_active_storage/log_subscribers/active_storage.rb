# frozen_string_literal: true

module LogrageActiveStorage
  module LogSubscribers
    class ActiveStorage < Base
      def service_upload(event)
        payload = event.payload

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :uploaded
            data[:checksum] = payload[:checksum]
            data.compact!
          }
      end

      def service_download(event)
        processing_data event, initial_data(event).tap { |data| data[:status] = :downloaded }
      end
      alias_method :service_streaming_download, :service_download

      def service_delete(event)
        processing_data event, initial_data(event).tap { |data| data[:status] = :deleted }
      end

      def service_delete_prefixed(event)
        payload = event.payload

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :deleted
            data[:checksum] = payload[:checksum]
            data[:prefix] = payload[:prefix]

            data.compact!
          }
      end

      def service_exist(event)
        payload = event.payload

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :checked
            data[:existed] = payload[:exist] ? "yes" : "no"
          }
      end

      def service_url(event)
        payload = event.payload

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :generated
            data[:url] = payload[:url]
          }
      end

      def service_mirror(event)
        payload = event.payload

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :mirrored
            data[:checksum] = payload[:checksum]
            data.compact!
          }
      end
    end
  end
end

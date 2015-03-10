# Toplevel Pubnub module
module Pubnub
  # Holds publish functionality
  class Publish < SingleEvent
    include Celluloid

    private

    def path
      '/' + [
        'publish',
        @publish_key,
        @subscribe_key,
        (@auth_key.blank? ? '0' : @secret_key),
        @channel,
        '0',
        Formatter.format_message(@message, @cipher_key)
      ].join('/')
    end

    def timetoken(parsed_response)
      parsed_response[2]
    rescue
      nil
    end

    def response_message(parsed_response)
      parsed_response[1]
    rescue
      nil
    end

    def format_envelopes(response)
      parsed_response, error = Formatter.parse_json(response.body)

      error = response if parsed_response && response.code != '200'

      envelopes = if error
                    [error_envelope(parsed_response, error)]
                  else
                    [valid_envelope(parsed_response)]
                  end

      add_common_data_to_envelopes(envelopes, response)
    end

    def valid_envelope(parsed_response)
      Envelope.new(
          parsed_response:  parsed_response,
          message:          @message,
          channel:          @channel.first,
          response_message: response_message(parsed_response),
          timetoken:        timetoken(parsed_response)
      )
    end

    def error_envelope(parsed_response, error)
      ErrorEnvelope.new(
          error:            error,
          response_message: response_message(parsed_response),
          channel:          @channel.first,
          timetoken:        timetoken(parsed_response)
      )
    end
  end
end

# frozen_string_literal: true

# require 'net/http'
require 'httpclient'
require 'uri'
require 'json'
require 'base64'
require 'hmac'
require 'hmac-sha1'

require_relative 'result'

module Woos
  module Map
    class InvalidResponseException < StandardError; end
    class InvalidPremierConfigurationException < StandardError; end
    class ZeroResultsException < InvalidResponseException; end

    class API
      STATUS_OK = 'OK'
      STATUS_ZERO_RESULTS = 'ZERO_RESULTS'

      class << self
        def query(service, args = {})
          args = args.merge(Woos::Map.default_params[service]) if Woos::Map.default_params[service]
          url = url(service, args)
          response(url)
        end

        private

        def decode_url_safe_base_64(value)
          Base64.decode64(value.tr('-_', '+/'))
        end

        def encode_url_safe_base_64(value)
          Base64.encode64(value).tr('+/', '-_')
        end

        def add_digital_signature(url)
          parsed_url = url.is_a?(URI) ? url : URI.parse(url)
          url_to_sign = parsed_url.path + '?' + parsed_url.query

          # Decode the private key
          raw_key = decode_url_safe_base_64(Woos::Map.client_secret)

          # create a signature using the private key and the URL
          sha1 = HMAC::SHA1.new(raw_key)
          sha1 << url_to_sign
          raw_sig = sha1.digest

          # encode the signature into base64 for url use form.
          signature = encode_url_safe_base_64(raw_sig)

          # prepend the server and append the signature.
          "#{parsed_url.scheme}://#{parsed_url.host}#{url_to_sign}&signature=#{signature}".strip
        end

        def response(url)
          begin
            result = Woos::Map::Result.new JSON.parse(HTTPClient.new.get_content(url))
            result.status = STATUS_OK
          rescue StandardError => e
            Woos::Map.logger.error e.message.to_s
            raise InvalidResponseException, "unknown error: #{e.message}"
          end
          handle_result_status(result.status)
          result
        end

        def handle_result_status(status)
          raise ZeroResultsException, "Woos did not return any results: #{status}" if status == STATUS_ZERO_RESULTS
          raise InvalidResponseException, "Woos returned an error status: #{status}" if status != STATUS_OK
        end

        def url_with_api_key(service, args = {})
          base_url(service, args.merge(private_key: Woos::Map.api_key))
        end

        def url_with_digital_signature(service, args = {})
          url = base_url(service, args.merge(client: Woos::Map.client_id))
          add_digital_signature(url)
        end

        def url(service, args = {})
          if Woos::Map.authentication_mode == Woos::Map::Configuration::API_KEY
            url_with_api_key(service, args)
          elsif Woos::Map.authentication_mode == Woos::Map::Configuration::DIGITAL_SIGNATURE
            url_with_digital_signature(service, args)
          end
        end

        def base_url(service, args = {})
          url = URI.parse("#{Woos::Map.end_point}#{Woos::Map.send(service)}/#{Woos::Map.format}#{query_string(args)}")
          Woos::Map.logger.debug("url before possible signing: #{url}")
          url.to_s
        end

        def query_string(args = {})
          '?' + URI.encode_www_form(args) unless args.empty?
        end
      end
    end
  end
end

# frozen_string_literal: true

require File.expand_path('../spec_helper', __dir__)

describe Woos::Map::API do
  it 'should raise a custom exception when the query fails by net' do
    HTTPClient.any_instance.unstub(:get_content)

    Woos::Map.end_point = 'http://unknown.tld/'
    expect { Woos::Map.distance('Amsterdam', 'Deventer') }.to raise_error(Woos::Map::InvalidResponseException)
    Woos::Map.end_point = 'http://unknown-domain-asdasdasdas123123zxcasd.com/'
    expect { Woos::Map.distance('Amsterdam', 'Deventer') }.to raise_error(Woos::Map::InvalidResponseException)
    Woos::Map.end_point = 'http://www.google.com/404'
    expect { Woos::Map.distance('Amsterdam', 'Deventer') }.to raise_error(Woos::Map::InvalidResponseException)
  end

  it 'should raise a custom exception when the query fails by Woos' do
    stub_response('over_query_limit.json')
    expect { Woos::Map.distance('Amsterdam', 'Deventer') }.to raise_error(Woos::Map::InvalidResponseException)
  end

  it 'should raise a custom exception when there are no results' do
    stub_response('zero-results.json')
    expect { Woos::Map.distance('Blah blah', 'Jalala') }.to raise_error(Woos::Map::ZeroResultsException)
  end

  it 'should raise a custom exception that is rescue-able' do
    stub_response('zero-results.json')
    begin
      Woos::Map.distance('Blah blah', 'Jalala')
    rescue StandardError => e
      @error = e
    ensure
      expect(@error).not_to be_nil
      expect(@error).to be_a_kind_of StandardError
    end
  end

  describe 'authentication' do
    context 'with digital signature' do
      before do
        Woos::Map.configure do |config|
          config.authentication_mode = Woos::Map::Configuration::DIGITAL_SIGNATURE
          config.client_id = 'clientID'
          config.client_secret = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
        end
      end

      xit 'should sign the url parameters when a client id and premier key is set' do
        stub_response(
          'place_details.json',
          'https://api.woosmap.com/geocode/json?address=New+York&client=clientID&signature=chaRF2hTJKOScPr-RQCEhZbSzIE='
        )
        # http://code.google.com/apis/maps/documentation/webservices/index.html#URLSigning

        # Example:
        # Private Key: vNIXE0xscrmjlyV-12Nj_BvUPaw=
        # Signature: chaRF2hTJKOScPr-RQCEhZbSzIE=
        # Client ID: clientID
        # URL: http://maps.googleapis.com/maps/api/geocode/json?address=New+York&client=clientID
        Woos::Map::API.query(:geocode_service, address: 'New York')
      end
    end

    context 'with api key' do
      before do
        Woos::Map.configure do |config|
          config.authentication_mode = Woos::Map::Configuration::API_KEY
          config.api_key = 'api_key123'
        end
      end

      it 'should sign the url parameters when a client id and premier key is set' do
        stub_response(
          'place_details.json',
          'https://api.woosmap.com/geocode/json?address=New+York&private_key=api_key123'
        )
        Woos::Map::API.query(:geocode_service, address: 'New York')
      end
    end
  end
end

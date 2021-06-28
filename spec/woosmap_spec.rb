# frozen_string_literal: true

require File.expand_path('spec_helper', __dir__)

describe Woos::Map do
  describe 'Directions' do
    before(:each) do
      stub_response('amsterdam-deventer-en.json')
    end

    it 'should be able to calculate a route' do
      route = Woos::Map.route('Science Park, Amsterdam', 'Deventer')
      expect(route.class).to eq(Woos::Map::Route)
      expect(route.distance.text).to eq('104 km')
      expect(route.duration.text).to eq('1 hour 12 mins')
      expect(route.distance.value).to eq(103_712)
      expect(route.duration.value).to eq(4337)
    end

    it 'should be able to calculate the distance' do
      expect(Woos::Map.distance('Science Park, Amsterdam', 'Deventer')).to eq('104 km')
    end

    it 'should be able to calculate the duration' do
      expect(Woos::Map.duration('Science Park, Amsterdam', 'Deventer')).to eq('1 hour 12 mins')
    end
  end

  describe 'Places' do
    before(:each) do
      stub_response('deventer-en.json')
    end

    it 'should find a list of places for a keyword' do
      place = Woos::Map.places('Deventer').first
      expect(place.class).to eq(Woos::Map::Place)
      expect(place.text).to eq('Deventer, Netherlands')
      expect(place.html).to eq('<strong>Deventer</strong>, Netherlands')
    end
  end

  describe 'Geocoder' do
    it 'should lookup a latlong for an address' do
      stub_response('geocoder/science-park-400-amsterdam-en.json')

      location = Woos::Map.geocode('Science Park 400, Amsterdam').first
      expect(location.class).to eq(Woos::Map::Location)
      expect(location.address).to eq('Science Park Amsterdam 400, University of Amsterdam, 1098 XH Amsterdam, The Netherlands')
      expect(location.latitude).to eq(52.3564490)
      expect(location.longitude).to eq(4.95568890)

      expect(location.lat_lng).to eq([52.3564490, 4.95568890])
    end

    it 'should extract all components for an address' do
      stub_response('geocoder/science-park-400-amsterdam-en.json')

      location = Woos::Map.geocode('Science Park 400, Amsterdam').first
      components = location.components
      expect(components['administrative_area_level_1']).to eq(['Noord-Holland'])
      expect(components['administrative_area_level_2']).to eq(['Government of Amsterdam'])
      expect(components['country']).to eq(['The Netherlands'])
      expect(components['establishment']).to eq(['University of Amsterdam'])
      expect(components['locality']).to eq(['Amsterdam'])
      expect(components['political']).to eq(
        ['Middenmeer', 'Watergraafsmeer', 'Amsterdam', 'Government of Amsterdam', 'Noord-Holland', 'The Netherlands']
      )
      expect(components['postal_code']).to eq(['1098 XH'])
      expect(components['route']).to eq(['Science Park Amsterdam'])
      expect(components['street_number']).to eq(['400'])
      expect(components['sublocality']).to eq(%w[Middenmeer Watergraafsmeer])
    end

    it 'should handle multiple location for an address' do
      stub_response('geocoder/amsterdam-en.json')

      locations = Woos::Map.geocode('Amsterdam')
      expect(locations).to have(2).items
      location = locations.last
      expect(location.address).to eq('Amsterdam, NY, USA')
      expect(location.latitude).to eq(42.93868560)
      expect(location.longitude).to eq(-74.18818580)
    end

    it 'should accept languages other than en' do
      stub_response('geocoder/science-park-400-amsterdam-nl.json')

      location = Woos::Map.geocode('Science Park 400, Amsterdam', :nl).first
      expect(location.address).to eq('Science Park 400, Amsterdam, 1098 XH Amsterdam, Nederland')
    end

    it 'should return an empty array when an address could not be geocoded' do
      stub_response('zero-results.json')

      expect(Woos::Map.geocode('Amsterdam')).to eq([])
    end
  end

  describe '.end_point=' do
    it 'should set the end_point' do
      Woos::Map.end_point = 'http://maps.google.com/'
      expect(Woos::Map.end_point).to eq('http://maps.google.com/')
    end
  end

  describe '.options' do
    it 'should return a hash with the current settings' do
      Woos::Map.end_point = 'test end point'
      Woos::Map.options == { end_point: 'test end point' }
    end
  end

  describe '.configure' do
    it 'has constants for the authentication methods' do
      expect(Woos::Map::Configuration::API_KEY).to eq 'api_key'
      expect(Woos::Map::Configuration::DIGITAL_SIGNATURE).to eq 'digital_signature'
    end

    context 'api key configuration' do
      it 'is be possible to set configuration with an api key' do
        Woos::Map.configure do |config|
          config.authentication_mode = Woos::Map::Configuration::API_KEY
          config.api_key = 'xxxxxxxxxxx'
        end

        expect(Woos::Map.authentication_mode).to eq(Woos::Map::Configuration::API_KEY)
        expect(Woos::Map.api_key).to eq('xxxxxxxxxxx')
      end

      it 'fails when no api key is provided' do
        expect do
          Woos::Map.configure do |config|
            config.authentication_mode = Woos::Map::Configuration::API_KEY
          end
        end.to raise_error(Woos::Map::InvalidConfigurationError)
      end
    end

    context 'digital signature configuration' do
      it 'is be possible to set configuration with an api key' do
        Woos::Map.configure do |config|
          config.authentication_mode = Woos::Map::Configuration::DIGITAL_SIGNATURE
          config.client_id = 'xxxxxxxxxxx'
          config.client_secret = 'xxxxxxxxxxx'
        end

        expect(Woos::Map.authentication_mode).to eq(Woos::Map::Configuration::DIGITAL_SIGNATURE)
        expect(Woos::Map.client_id).to eq('xxxxxxxxxxx')
        expect(Woos::Map.client_secret).to eq('xxxxxxxxxxx')
      end

      it 'fails when no client id is provided' do
        expect do
          Woos::Map.configure do |config|
            config.authentication_mode = Woos::Map::Configuration::DIGITAL_SIGNATURE
            config.client_secret = 'xxxxxxxxxxx'
          end
        end.to raise_error(Woos::Map::InvalidConfigurationError)
      end

      it 'fails when no client secret is provided' do
        expect do
          Woos::Map.configure do |config|
            config.authentication_mode = Woos::Map::Configuration::DIGITAL_SIGNATURE
            config.client_id = 'xxxxxxxxxxx'
          end
        end.to raise_error(Woos::Map::InvalidConfigurationError)
      end
    end

    context 'with invalid authentication mode' do
      it 'raises an invalid configuration exception' do
        expect do
          Woos::Map.configure do |config|
            config.authentication_mode = 'hack'
            config.client_secret = 'xxxxxxxxxxx'
          end
        end.to raise_error(Woos::Map::InvalidConfigurationError)
      end
    end

    Woos::Map::Configuration::VALID_OPTIONS_KEYS.reject { |x| x == :authentication_mode }.each do |key|
      it "should set the #{key}" do
        Woos::Map.configure do |config|
          config.authentication_mode = Woos::Map::Configuration::API_KEY
          config.api_key = 'xxxxxxxxxxx'
          config.send("#{key}=", key)
          expect(Woos::Map.send(key)).to eq(key)
        end
      end
    end
  end
end

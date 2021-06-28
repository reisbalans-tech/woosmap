# frozen_string_literal: true

require File.expand_path('woosmap/configuration', __dir__)
require File.expand_path('woosmap/logger', __dir__)
require File.expand_path('woosmap/route', __dir__)
require File.expand_path('woosmap/place', __dir__)
require File.expand_path('woosmap/location', __dir__)
require File.expand_path('woosmap/distance_matrix', __dir__)

module Woos
  module Map
    extend Configuration
    extend Logger

    def self.route(from, to, options = {})
      Route.new(from, to, options_with_defaults(options))
    end

    def self.distance(from, to, options = {})
      Route.new(from, to, options_with_defaults(options)).distance.text
    end

    def self.duration(from, to, options = {})
      Route.new(from, to, options_with_defaults(options)).duration.text
    end

    def self.places(keyword, language = default_language)
      Place.find(keyword, language)
    end

    def self.place(place_id, language = default_language)
      PlaceDetails.find(place_id, language)
    end

    def self.distance_matrix(from, to, options = {})
      DistanceMatrix.new(from, to, options_with_defaults(options))
    end

    def self.geocode(address, language = default_language)
      Location.find(address, language)
    rescue ZeroResultsException
      []
    end

    class << self
      protected

      def options_with_defaults(options)
        { language: default_language }.merge(options)
      end
    end
  end
end

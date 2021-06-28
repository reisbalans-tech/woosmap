# frozen_string_literal: true

require File.expand_path('../spec_helper', __dir__)

describe Woos::Map::DistanceMatrix do
  describe '.find' do
    subject { Woos::Map::DistanceMatrix.new('Amsterdam', 'Utrecht') }

    context ':nl' do
      before { stub_response('distance-matrix.json') }

      its(:distance) { should eq 53_744 }
      its(:duration) { should eq 3237 }
    end

    context ':nl and zero results' do
      before { stub_response('distance-matrix-zero-results.json') }

      it 'raises Woos::Map::ZeroResultsException' do

        expect { subject.distance }.to raise_error(Woos::Map::ZeroResultsException)
        expect { subject.duration }.to raise_error(Woos::Map::ZeroResultsException)

      end
    end
  end
end

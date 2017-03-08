require 'rails_helper'

RSpec.describe Attraction, type: :model do
  let(:attraction) { create(:attraction) }

  it "show next localization type" do
    expect(Attraction.next_type('continent')).to eq 'country'
    expect(Attraction.next_type('municipality')).to eq 'city'
  end
end

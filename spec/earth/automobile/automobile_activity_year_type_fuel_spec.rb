require 'spec_helper'
require 'earth/automobile/automobile_activity_year_type_fuel'

describe AutomobileActivityYearTypeFuel do
  before :all do
    Earth.init :automobile, :load_data_miner => true
    require 'earth/acronyms'
  end
  
  describe 'import', :data_miner => true do
    it 'should import data' do
      AAYTF.run_data_miner!
    end
  end
  
  describe 'verify', :sanity => true do
    it { AAYTF.count.should == 120 }
    it { AAYTF.where(:distance => nil).count.should == 0 }
    it { AAYTF.where("fuel_group != 'alternative' AND fuel_consumption IS NULL").count.should == 0 }
  end
  
  describe '.latest' do
    it { AAYTF.latest.should == AAYTF.where(:activity_year => 2009) }
  end
end
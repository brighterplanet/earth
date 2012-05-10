require 'spec_helper'
require 'earth/electricity/electric_utility'

describe ElectricUtility do
  describe 'Electric utility data', :data_miner => true do
    before :all do
      Earth.init :electricity, :load_data_miner => true, :skip_parent_associations => :true
      ElectricUtility.run_data_miner!
    end
    
    it 'should include all U.S. utilities' do
      ElectricUtility.count.should == 3266
    end

    it 'should include, specifically, MG&E' do
      ElectricUtility.find(11479).name.should == 'Madison Gas & Electric Co'
    end

    it 'should include aliases' do
      ElectricUtility.find(14328).alias.should == 'PG&E'
    end

    it 'should reveal which utilities have implemented the Green Button program' do
      assert ElectricUtility.find(14328).green_button_implementer?
    end

    it 'should reveal which utilities have committed to the Green Button program' do
      assert ElectricUtility.find(14940).green_button_committer?
    end

    after :all do
      ElectricUtility.delete_all
    end    
  end
end
require 'spec_helper'
require 'earth/industry/naics_2002_sic_1987_concordance'

describe Naics2002Sic1987Concordance do
  describe 'verify imported data', :sanity => true do
    it 'should have all the data' do
      Naics2002Sic1987Concordance.count.should == 2164
    end
    
    it "extracts a paranthetical note from a description" do
      Naics2002Sic1987Concordance.extract_note("Wood Household Furniture, Except Upholstered (wood box spring frames(parts))").
        should == "wood box spring frames(parts)"
    end
  end
  
  describe "relationships" do
    before do
      require 'earth/industry/naics_2002'
      require 'earth/industry/sic_1987'
    end
    
    it "belongs to :naics_2002" do
      Naics2002Sic1987Concordance.find_by_naics_2002_code("111150").
        naics_2002.should == Naics2002.find("111150")
    end
    
    it "belongs to :sic_1987" do
      Naics2002Sic1987Concordance.find_by_sic_1987_code("0119").
        sic_1987.should == Sic1987.find("0119")
    end
  end
end

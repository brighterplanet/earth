class IoSector < ActiveRecord::Base
  set_primary_key :io_code
  
  has_many :industies,     :through => :industries_io_sectors
  has_many :product_lines, :through => :product_lines_io_sectors
  
  data_miner do
    tap "Brighter Planet's input-output sector data", TAPS_SERVER
  end
end

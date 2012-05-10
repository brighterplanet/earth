ElectricMarket.class_eval do
  data_miner do
    import 'IOU markets', :url => 'http://en.openei.org/datasets/files/899/pub/iou_zipcodes.csv' do
      key 'FIXME' # dunno how to do this
      store 'zip_code', :field_name => 'zip'
      store 'electric_utility_eia_id', :field_name => 'compid'
    end
    import 'Non-IOU markets', :url => 'http://en.openei.org/datasets/files/899/pub/non-iou_zipcodes.csv' do
      key 'FIXME' # dunno how to do this
      store 'zip_code', :field_name => 'zip'
      store 'electric_utility_eia_id', :field_name => 'compid'
    end
  end
end
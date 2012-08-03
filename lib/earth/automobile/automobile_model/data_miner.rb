require 'earth/automobile/automobile_make_model_year_variant'

AutomobileModel.class_eval do
  data_miner do
    process "Ensure AutomobileMakeModelYearVariant is populated" do
      AutomobileMakeModelYearVariant.run_data_miner!
    end
    
    process "Derive model names from AutomobileMakeModelYearVariant" do
      ::Earth::Utils.insert_ignore(
        :src => AutomobileMakeModelYearVariant,
        :dest => AutomobileModel,
        :cols => { :model_name => :name }
      )
    end
  end
end

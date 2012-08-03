require 'earth/automobile/automobile_activity_year_type_fuel'
require 'earth/fuel/greenhouse_gas'
require 'earth/hospitality/commercial_building_energy_consumption_survey_response'
require 'earth/locality/country'
require 'earth/locality/egrid_subregion'
require 'earth/locality/electricity_mix'
require 'earth/rail/rail_company'
require 'earth/rail/rail_fuel'

Country.class_eval do
  data_miner do
    # http://www.iso.org/iso/list-en1-semic-3.txt
    # http://unstats.un.org/unsd/methods/m49/m49alpha.htm
    import "OpenGeoCode.org's Country Codes to Country Names list",
           :url => 'http://opengeocode.org/download/countrynames.txt',
           :format => :delimited,
           :delimiter => '; ',
           :headers => false,
           :skip => 22 do
      key 'iso_3166_code', :field_number => 0
      store 'iso_3166_alpha_3_code', :field_number => 1
      store 'iso_3166_numeric_code', :field_number => 2
      store 'name', :field_number => 5 # romanized version with utf-8 characters
    end
    
    import "heating and cooling degree day data from WRI CAIT",
           :url => "file://#{Earth::DATA_DIR}/locality/wri_hdd_cdd_data.csv",
           :select => proc { |record| record['country'] != 'European Union (27)' },
           :errata => { :url => "file://#{Earth::ERRATA_DIR}/country/wri_errata.csv" } do
      key 'name', :field_name => 'country'
      store 'heating_degree_days', :units => :degrees_celsius
      store 'cooling_degree_days', :units => :degrees_celsius
    end
    
    process "set Montenegro's heating and cooling degree days to the same as Serbia's" do
      serbia = Country.find 'RS'
      Country.find('ME').update_attributes!(
        :heating_degree_days => serbia.heating_degree_days,
        :heating_degree_days_units => serbia.heating_degree_days_units,
        :cooling_degree_days => serbia.cooling_degree_days,
        :cooling_degree_days_units => serbia.cooling_degree_days_units
      )
    end
    
    # AUTOMOBILE
    import "automobile-related data for the US",
           :url => "file://#{Earth::DATA_DIR}/locality/us_auto_data.csv" do
      key 'iso_3166_code'
      store 'automobile_urbanity'
      store 'automobile_city_speed',    :from_units => :miles_per_hour, :to_units => :kilometres_per_hour
      store 'automobile_highway_speed', :from_units => :miles_per_hour, :to_units => :kilometres_per_hour
      store 'automobile_trip_distance', :from_units => :miles, :to_units => :kilometres
    end
    
    process "Ensure AutomobileActivityYearTypeFuel is populated" do
      AutomobileActivityYearTypeFuel.run_data_miner!
    end
    
    process "Derive US average automobile fuel efficiency from AutomobileActivityYearTypeFuel" do
      max_year = AutomobileActivityYearTypeFuel.maximum(:activity_year)
      fuel_years = AutomobileActivityYearTypeFuel.where("activity_year = #{max_year} AND fuel_consumption IS NOT NULL")
      where(:iso_3166_code => 'US').update_all(
        :automobile_fuel_efficiency => (fuel_years.sum(:distance).to_f / fuel_years.sum(:fuel_consumption)),
        :automobile_fuel_efficiency_units => (fuel_years.first.distance_units + '_per_' + fuel_years.first.fuel_consumption_units.singularize)
      )
    end
    
    # DEPRECATED - eventually cut all elec stuff (replaced by ElectricityMix)
    # ELECTRICITY
    process "Ensure GreehouseGas is populated" do
      GreenhouseGas.run_data_miner!
    end
    
    import "national average electricity emission factors from Brander et al. (2011)",
           :url => "file://#{Earth::DATA_DIR}/locality/national_electricity_efs.csv" do
      key 'iso_3166_code', :field_name => 'country_iso_3166_code'
      store 'electricity_co2_emission_factor', :field_name => 'co2_emission_factor', :units_field_name => 'co2_emission_factor_units'
      store 'electricity_ch4_emission_factor', :synthesize => proc { |row| row['ch4_emission_factor'].to_f * GreenhouseGas[:ch4].global_warming_potential }, :units => 'kilograms_co2e_per_kilowatt_hour'
      store 'electricity_n2o_emission_factor', :synthesize => proc { |row| row['n2o_emission_factor'].to_f * GreenhouseGas[:n2o].global_warming_potential }, :units => 'kilograms_co2e_per_kilowatt_hour'
      store 'electricity_loss_factor', :field_name => 'loss_factor'
    end
    
    process "Ensure EgridSubregion is populated" do
      EgridSubregion.run_data_miner!
    end
    
    process "Derive average US electricity data from EgridSubregion" do
      united_states.update_attributes!(
        :electricity_co2_emission_factor =>       EgridSubregion.fallback.co2_emission_factor,
        :electricity_co2_emission_factor_units => EgridSubregion.fallback.co2_emission_factor_units,
        :electricity_ch4_emission_factor =>       EgridSubregion.fallback.ch4_emission_factor,
        :electricity_ch4_emission_factor_units => EgridSubregion.fallback.ch4_emission_factor_units,
        :electricity_n2o_emission_factor =>       EgridSubregion.fallback.n2o_emission_factor,
        :electricity_n2o_emission_factor_units => EgridSubregion.fallback.n2o_emission_factor_units,
        :electricity_loss_factor =>               EgridSubregion.fallback.egrid_region.loss_factor
      )
    end
    
    process "Calculate combined electricity emission factor" do
      where('electricity_co2_emission_factor IS NOT NULL').update_all(%{
        electricity_emission_factor = electricity_co2_emission_factor + electricity_ch4_emission_factor + electricity_n2o_emission_factor,
        electricity_emission_factor_units = 'kilograms_co2e_per_kilowatt_hour'
      })
    end
    
    process "Ensure ElectricityMix is data mined because it's like a belongs_to association" do
      ElectricityMix.run_data_miner!
    end
    
    # FLIGHT
    import "country-specific flight route inefficiency factors derived from Kettunen et al. (2005)",
           :url => "file://#{Earth::DATA_DIR}/locality/country_flight_data.csv" do
      key   'iso_3166_code'
      store 'flight_route_inefficiency_factor'
    end
    
    # HOSPITALITY
    process "Define US average lodging occupancy rate" do
      united_states.update_attributes! :lodging_occupancy_rate => 0.601 # per http://www.pwc.com/us/en/press-releases/2012/pwc-us-lodging-industry-forecast.jhtml
    end
    
    process "Ensure CommercialBuildingEnergyConsumptionSurveyResponse is populated" do
      CommercialBuildingEnergyConsumptionSurveyResponse.run_data_miner!
    end
    
    process "Derive US average hotel characteristics from CommercialBuildingEnergyConsumptionSurveyResponse" do
      lodgings = CommercialBuildingEnergyConsumptionSurveyResponse.lodging_records
      
      united_states.update_attributes!(
        :lodging_natural_gas_intensity         => lodgings.weighted_average(:natural_gas_per_room_night),
        :lodging_fuel_oil_intensity            => lodgings.weighted_average(:fuel_oil_per_room_night),
        :lodging_electricity_intensity         => lodgings.weighted_average(:electricity_per_room_night),
        :lodging_district_heat_intensity       => lodgings.weighted_average(:district_heat_per_room_night),
        :lodging_natural_gas_intensity_units   => lodgings.first.natural_gas_per_room_night_units,
        :lodging_fuel_oil_intensity_units      => lodgings.first.fuel_oil_per_room_night_units,
        :lodging_electricity_intensity_units   => lodgings.first.electricity_per_room_night_units,
        :lodging_district_heat_intensity_units => lodgings.first.district_heat_per_room_night_units
      )
    end
    
    # RAIL
    process "Ensure RailCompany and RailFuel are populated" do
      RailCompany.run_data_miner!
      RailFuel.run_data_miner!
    end
    
    process "Calculate rail passengers, trip distance, and speed from RailCompany" do
      safe_find_each do |country|
        if (rail_companies = country.rail_companies).any?
          country.update_attributes!(
            :rail_passengers          => rail_companies.sum(:passengers),
            :rail_trip_distance       => rail_companies.weighted_average(:trip_distance, :weighted_by => :passengers),
            :rail_speed               => rail_companies.weighted_average(:speed, :weighted_by => :passengers),
            :rail_trip_distance_units => ('kilometres' if country.rail_trip_distance.present?),
            :rail_speed_units         => ('kilometres_per_hour' if country.rail_speed.present?)
          )
        end
      end
    end
    
    import "european rail fuel and emission data derived from the UIC",
           :url => 'https://docs.google.com/spreadsheet/pub?key=0AoQJbWqPrREqdDczWnlPN2VtX1RmU0EtOVBYRFo4REE&output=csv' do
      key 'iso_3166_code'
      store 'rail_trip_electricity_intensity', :units_field_name => 'rail_trip_electricity_intensity_units'
      store 'rail_trip_diesel_intensity',      :units_field_name => 'rail_trip_diesel_intensity_units'
      store 'rail_trip_co2_emission_factor',   :units_field_name => 'rail_trip_co2_emission_factor_units' 
    end
    
    process "Unit conversion for European rail diesel intensity" do
      diesel = RailFuel.find_by_name("diesel")
      where(:rail_trip_diesel_intensity_units => 'grams_per_passenger_kilometre').update_all(%{
        rail_trip_diesel_intensity = 1.0 * rail_trip_diesel_intensity / 1000.0 / #{diesel.density},
        rail_trip_diesel_intensity_units = 'litres_per_passenger_kilometre'
      })
    end
    
    process "Unit conversion for European rail co2 emission factor" do
      where(:rail_trip_co2_emission_factor_units => 'grams_per_passenger_kilometre').update_all(%{
        rail_trip_co2_emission_factor = 1.0 * rail_trip_co2_emission_factor / 1000.0,
        rail_trip_co2_emission_factor_units = 'kilograms_per_passenger_kilometre'
      })
    end
    
    process "Derive US rail fuel and emission data from RailCompany" do
      rail_companies = united_states.rail_companies
      united_states.update_attributes!(
        :rail_trip_electricity_intensity       => rail_companies.weighted_average(:electricity_intensity, :weighted_by => :passengers),
        :rail_trip_diesel_intensity            => rail_companies.weighted_average(:diesel_intensity, :weighted_by => :passengers),
        :rail_trip_co2_emission_factor         => rail_companies.weighted_average(:co2_emission_factor, :weighted_by => :passengers),
        :rail_trip_electricity_intensity_units => 'kilowatt_hours_per_passenger_kilometre',
        :rail_trip_diesel_intensity_units      => 'litres_per_passenger_kilometre',
        :rail_trip_co2_emission_factor_units   => 'kilograms_per_passenger_kilometre'
      )
    end
  end
end

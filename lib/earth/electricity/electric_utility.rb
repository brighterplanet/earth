class ElectricUtility < ActiveRecord::Base
  self.primary_key = "eia_id"
  
  belongs_to :state, :foreign_key => 'state_postal_abbreviation'
  
  col :eia_id, :type => :integer
  col :name
  col :alias
  col :state_postal_abbreviation
  col :nerc_abbreviation
  col :green_button_implementer, :type => :boolean
  col :green_button_committer, :type => :boolean
end

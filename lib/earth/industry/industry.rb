require 'earth/model'

require 'earth/industry/industry_product_line'
require 'earth/industry/industry_sector'
require 'earth/industry/merchant_category_industry'
require 'earth/industry/product_line'
require 'earth/industry/sector'

# TODO replace this with NAICS 2002?
class Industry < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE industries
  (
     naics_code  CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     description CHARACTER VARYING(255)
  );

EOS

  self.primary_key = "naics_code"
  
  has_many :merchant_category_industries, :foreign_key => 'naics_code'
  
  has_many :industry_product_lines, :foreign_key => 'naics_code'
  has_many :product_lines, :through => :industry_product_lines
  
  has_many :industry_sectors, :foreign_key => 'naics_code'
  has_many :sectors, :through => :industry_sectors
  
  
  class << self
    def format_naics_code(input)
      "%d" % input.to_i
    end
  end
  
  def trade_industry?
    prefix = naics_code.to_s[0,2]
    %w{42 44 45}.include?(prefix)
  end

  warn_unless_size 2341
end

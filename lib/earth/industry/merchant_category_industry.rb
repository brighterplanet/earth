class MerchantCategoryIndustry < ActiveRecord::Base
  TABLE_STRUCTURE = <<-EOS
CREATE TABLE "merchant_category_industries"
  (
     "row_hash"   CHARACTER VARYING(255) NOT NULL,
     "mcc"        CHARACTER VARYING(255),
     "ratio"      FLOAT,
     "naics_code" CHARACTER VARYING(255)
  );
ALTER TABLE "merchant_category_industries" ADD PRIMARY KEY ("row_hash")
EOS

  self.primary_key = "row_hash"
  
  belongs_to :merchant_category, :foreign_key => 'mcc'
  belongs_to :industry,          :foreign_key => 'naics_code'

end

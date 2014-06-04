class CreateTranslationsFactors < ActiveRecord::Migration
  def up
    Factor.create_translation_table!({ :helps => :text })
  end

  def down
    Factor.drop_translation_table!
  end
end

class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :title, :limit => 100, :null => false
      t.string :code, :limit => 3, :null => false
      t.string :locale, :limit => 6, :null => false

      t.timestamps
    end
    Language.create :title => 'English', :code => 'eng', :locale => 'eng-US'
    Language.create :title => 'Tibetan', :code => 'bod', :locale => 'bod-CN'
    Language.create :title => 'Dzongkha', :code => 'dzo', :locale => 'dzo-BT'
    Language.create :title => 'Nepali', :code => 'nep', :locale => 'nep-NP'
    Language.create :title => 'Jerung', :code => 'jee', :locale => 'jee-NP'
    Language.create :title => 'Wambule', :code => 'wme', :locale => 'wme-NP'
    Language.create :title => 'Thangmi', :code => 'thf', :locale => 'thf-NP'
    Language.create :title => 'Sanskrit', :code => 'san', :locale => 'san-IN'    
  end

  def self.down
    drop_table :languages
  end
end

class AddDataToLanguages < ActiveRecord::Migration
  def self.up
      Language.create :title => 'Chinese', :code => 'zho', :locale => 'zho-CN'
      Language.create :title => 'Japanese', :code => 'jpn', :locale => 'jpn-JP'
      Language.create :title => 'German', :code => 'deu', :locale => 'deu-DE'
      Language.create :title => 'Spanish', :code => 'spa', :locale => 'spa-ES'
      Language.create :title => 'French', :code => 'fra', :locale => 'fra-FR'
      Language.create :title => 'Italian', :code => 'ita', :locale => 'ita-IT'
      Language.create :title => 'Russian', :code => 'rus', :locale => 'rus-RU'
  end

  def self.down
    l = Language.find(:first, :conditions => { :title => "Chinese" })
    if !l.nil? then
      l.delete
    end  
    l = Language.find(:first, :conditions => { :title => "Japanese" })
    if !l.nil? then
      l.delete
    end
    l = Language.find(:first, :conditions => { :title => "German" })
    if !l.nil? then
      l.delete
    end
    l = Language.find(:first, :conditions => { :title => "Spanish" })
    if !l.nil? then
      l.delete
    end
    l = Language.find(:first, :conditions => { :title => "French" })
    if !l.nil? then
      l.delete
    end
    l = Language.find(:first, :conditions => { :title => "Italian" })
    if !l.nil? then
      l.delete
    end
    l = Language.find(:first, :conditions => { :title => "Russian" })
    if !l.nil? then
      l.delete
    end

  end
end

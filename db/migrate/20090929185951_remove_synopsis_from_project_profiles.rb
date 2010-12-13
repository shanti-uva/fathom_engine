class RemoveSynopsisFromProjectProfiles < ActiveRecord::Migration
  def self.up
    ProjectProfile.find(:all, :conditions => 'synopsis IS NOT NULL').each do |p| 
      if !p.synopsis.blank?
        if p.overview.blank?
          ProjectProfile.update(p.id, :overview => '<p>' + p.synopsis + '</p>')
        else
          ProjectProfile.update(p.id, :overview => '<p>' + p.synopsis + '</p>' + p.overview)
        end
      end
    end
    remove_column :project_profiles, :synopsis
  end

  def self.down
    add_column :project_profiles, :synopsis, :text
  end
end

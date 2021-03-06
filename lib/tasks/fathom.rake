require 'ftools'

namespace :fathom do
  
  desc "Update the installed Cat4 Wordpress theme"
  task :update_theme do
    copy_dir(Rails.root.join('wordpress', 'cat4'), "#{Rails.root}/public/wp/wp-content/themes/cat4" )
  end
  
  desc "Install Cat4 Wordpress theme"
  task :install_theme do    
    # install php files
    Dir.mkdir("#{Rails.root}/public/wp/wp-content/themes/cat4")
    copy_dir( "#{Rails.root}/wordpress/cat4", "#{Rails.root}/public/wp/wp-content/themes/cat4" );
    
    # set up sym links
    File.symlink( "../../../../stylesheets", "#{Rails.root}/public/wp/wp-content/themes/cat4/css" )
    File.symlink( "../../../../images",  "#{Rails.root}/public/wp/wp-content/themes/cat4/images" )
    File.symlink( "../../../../javascripts", "#{Rails.root}/public/wp/wp-content/themes/cat4/js" )
    
    # install plugin
    Dir.mkdir("#{Rails.root}/public/wp/wp-content/plugins/wp-pagenavi")
    copy_dir( "#{Rails.root}/wordpress/wp-pagenavi", "#{Rails.root}/public/wp/wp-content/plugins/wp-pagenavi" )      
  end
    
  def copy_dir( start_dir, dest_dir )
     puts "Copying the contents of #{start_dir} to #{dest_dir}..."
     Dir.new(start_dir).each { |file|
       unless file =~ /\A\./
         start_file = "#{start_dir}/#{file}"
         dest_file = "#{dest_dir}/#{file}"  
         File.copy("#{start_dir}/#{file}", "#{dest_dir}/#{file}")
       end     
     }    
  end
end
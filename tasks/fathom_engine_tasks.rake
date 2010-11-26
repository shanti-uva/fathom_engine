# desc "Explaining what the task does"
# task :fathom_engine do
#   # Task goes here
# end

require 'config/environment'
namespace :fathom do
    namespace :import do
      lsp_description = "Task used to import LSP list to People.\n" +
      "Takes a CSV where first row are the column names. The following column names are accepted and interpreted:\n" +
      "person_profiles.first_name, person_profiles.last_name, department_school, area_group,\n" +
      "computing_id, phone, lsp_pro"
      
      desc lsp_description
      task :lsp_import do |t|
        #require File.join(File.dirname(__FILE__), "../lib/lsp_importation.rb")
        filename = ENV['FILENAME']
        organizationId = ENV['ORGANIZATIONID']
        if filename.blank?
          puts lsp_description
        else
          LspImportation.do_lsp_importation(filename,organizationId)
        end
      end
      
    end
end
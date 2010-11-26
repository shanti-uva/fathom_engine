def log(msg)
  puts "** #{msg}"
end

namespace :dhp do
  
  desc 'Adds a preset list of disciplines. Use "reset=true" to delete the current disciplines before adding the new ones.'
  task :add_disciplines=>:environment do
    Discipline.all.each{|d|d.destroy} if ENV['reset']=='true'
    names=['Anthropology', 'Archaeology', 'Architectural History', 'Art History', 'Buddhist Studies', 'Classics', 'Economics',
      'Environmental Sciences', 'French Studies', 'Germanic Studies', 'Geography', 'Linguistics', 'Music', 'Philosophy',
      'Psychology', 'Slavic Studies', 'Sociology', 'Tibetan Studies'
    ]
    names.each do |n|
      if Discipline.find_by_name(n)
        log "Already found #{n}"
      else
        log "Creating #{n}"
        Discipline.create(:name=>n)
      end
    end
  end
  
end
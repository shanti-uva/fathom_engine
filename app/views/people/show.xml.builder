xml.person(:id => @person.id, :name => @person.full_name) do

  @person.projects.each do |proj|
    xml.adjacencies(:nodeTo => proj.id)
  end
  
end

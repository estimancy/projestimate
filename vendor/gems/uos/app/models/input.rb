class Input < ActiveRecord::Base
  belongs_to :module_project

  def self.export(mp, pbs)
    @inputs = Input.where(module_project_id: mp, pbs_project_element_id: pbs).all
    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
      csv << ['id', 'Name', 'Technology', 'UO', 'Complexity', 'Size Low', 'Size Most Likely', 'Size High', 'Weight', 'Gross Low', 'Gross Most Likely', 'Gross High' ]
      @inputs.each do |i|
        csv << ["#{i.id}", "#{i.name}", "#{i.technology_id}", "#{i.unit_of_work_id}", "#{i.complexity_id}",
                "#{i.size_low}", "#{i.size_most_likely}", "#{i.size_high}",
                "#{i.weight}",
                "#{i.gross_low}", "#{i.gross_most_likely}", "#{i.gross_high}"]
      end
    end
    csv_string.encode(I18n.t(:general_csv_encoding))
  end

  def self.import(file, sep, encoding)
    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"
    error_count = 0
    CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "#{encoding}:utf-8") do |csv|
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          begin
            @ware = Input.find(row[0])
            @ware.update_attribute('name', row[1])
            @ware.update_attribute('technology_id', row[2])
            @ware.update_attribute('unit_of_work_id', row[3])
            @ware.update_attribute('complexity_id', row[4])
            @ware.update_attribute('size_low', row[5])
            @ware.update_attribute('size_most_likely', row[6])
            @ware.update_attribute('size_high', row[7])
            @ware.update_attribute('weight', row[8])
            @ware.update_attribute('gross_low', row[9])
            @ware.update_attribute('gross_most_likely', row[10])
            @ware.update_attribute('gross_high', row[11])
          rescue
            error_count = error_count + 1
          end
        end
      end
    end
    error_count
  end


end
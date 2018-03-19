require 'FileUtils'
require 'mysql2' 
require 'filewatcher'
require 'facets'
require 'YAML'

#The list of common delimiters we can
COMMON_DELIMITERS = ['","',"\"\t\"","|"]

config = YAML::load_file("../config/database.yml")["development"]
@client = Mysql2::Client.new(config)


def checkin_files
  Dir.glob("*.{csv,txt}") do |item|
    
    file = File.open(item, "r")

    first_line = File.open(item, &:readline)

    delimiter = sniff_delimiter(item, first_line)

    columns = first_line.split(delimiter)

    extension = File.extname(item)
    abs_path = File.absolute_path(item).chomp(item)

    contents_table_name = item.chomp(extension)

    log_to_db(item, extension, abs_path, file.count, File.mtime(item), file.size, contents_table_name, first_line, delimiter, 'filewatcher')

    create_string = "CREATE TABLE #{contents_table_name} ("

    columns.each do |column|
      if columns.last != column
        create_string << "#{column} varchar(255) DEFAULT NULL, "
      else 
        create_string << "#{column} varchar(255) DEFAULT NULL) "
      end 
    end

    statement = @client.prepare(create_string)
    statement.execute  

    import_string = "mysqlimport --user=root --password= --compress --host=localhost --port=3306 --fields-terminated-by='#{delimiter}' --fields-escaped-by='' --lines-terminated-by='\n' --local --verbose --delete --ignore-lines=1 cds_master_dev #{item}"

    system (import_string)

    puts "Data imported"
    
    move_file_to_processed(item)
  end
end

def sniff_delimiter(path, first_line)
  return nil unless first_line
  snif = {}
  COMMON_DELIMITERS.each {|delim|snif[delim]=first_line.count(delim)}
  snif = snif.sort {|a,b| b[1]<=>a[1]}
  snif.size > 0 ? snif[0][0].tr('"', '') : nil
end

def log_to_db(p_item_name,p_extension, p_abs_path, p_file_count, p_file_mod_date, p_file_size,p_contents_table_name, p_first_line, p_delimiter, p_created_by)
  statement = @client.prepare("INSERT INTO `cds_master_dev`.`file_checkin` (name, extension, size, type, absolute_path, line_count, checkin_date, modified_date, contents_table_name, header_row, delimiter, created_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")
  statement.execute(p_item_name,p_extension,p_file_size,"File", p_abs_path, p_file_count, DateTime.now, p_file_mod_date, p_contents_table_name, p_first_line, p_delimiter, p_created_by)
end

def verify_file_checkin(file)
  statement = @client.prepare("SELECT file_contents FROM file_checkin WHERE name = ?")
  db_contents = statement.execute(file)
  
  file = File.open(file, "r")
  file_contents = file.read

  if db_contents == file_contents
  	puts "Yes!"
  	move_file_to_processed(file)
  else
  	puts "No. They are not the same"
  	checkin_files
  end
end

def move_file_to_processed(file_name)
	FileUtils.move file_name, '../readyforprocessing'
end

def move_file_to_exceptions(file_name)
	FileUtils.move file_name, '../exceptions'
end

puts "Watching incoming folder..."

Filewatcher.new(['.', '*']).watch do |filename, event|
  if event.to_s == "created"
    if filename.include?(' ')
      File.rename(filename, filename.squish.underscore)
    else 
      File.rename(filename, filename.downcase)
    end

    checkin_files	

  else 
  	puts "File #{filename} has been checked in"
  end 
end



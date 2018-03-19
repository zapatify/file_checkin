# file_checkin 

Simple, lightweight Ruby script to bulk import data using MySQL bulk import.   It dynamically reads the incoming file, parses it, creates a table and uploads all the data to it.  

## Dependent gems
* `require 'FileUtils'`
* `require 'mysql2'`
* `require 'filewatcher'`
* `require 'facets'`
* `require 'yaml'`

## Usage

Run the `incoming\checkin.rb` from the terminal window

```console
ruby checkin.rb
```

It can also optionally be run as a daemon. 

## Operation

The script watches the `/incoming` directory for file additions. When a file is added to the directory, it is checked to see if there are spaces in the file name. 

If spaces are detected, the file is renamed to one without spaces. This is done for the sake of the table name.  

Next, the file type is checked against the ones to be parsed. Currently only `.csv` & `.txt` are parsed (more can be added).  

The file is then read and parsed using the header row, and logged to the `cds_master_dev`.`file_checkin` (scripts/create_file_checkin.sql) table.  The following metadata is captured for each file:
```
name
extension
size
type
absolute_path
line_count
checkin_date
modified_date
contents_table_name
header_row 
delimiter
created_by
```

Once the header row is read and the columns retrieved, the CREATE table sql command string is created and the table is created using varchar(255) for the columns, and the file name as the table name.  (e.g. File: bioiq_importdata_20110101.csv, then table name: bioiq_importdata_20110101)  

Once the table is created, the bulk load script is prepared and the data is loaded into the table. 

## Summary
If you place a file called "ingestion_file_1000.cv" (which contains a header row), the file will be read/parsed, the metadata captured and logged to a table called `cds_master_dev`.`file_checkin` (scripts/create_file_checkin.sql), a table created called "ingestion_file_1000", and the data from that file loaded into that table.  

The data loads extremely quickly and is available in a table rather than a flat file.  


### TODO List

* Move `checkin.rb` to `lib` folder and edit folder references in Filewatcher
* Add exception for table that already exists
* Add exception for missing header row



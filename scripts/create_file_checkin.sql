CREATE TABLE `file_checkin` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `extension` varchar(30) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `type` varchar(200) DEFAULT NULL,
  `absolute_path` varchar(500) DEFAULT NULL,
  `line_count` int(11) DEFAULT NULL,
  `checkin_date` datetime DEFAULT NULL,
  `modified_date` datetime DEFAULT NULL,
  `contents_table_name` varchar(200) DEFAULT NULL,
  `header_row` varchar(4000) DEFAULT NULL,
  `delimiter` varchar(10) DEFAULT NULL,
  `created_by` varchar(200) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(200) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Aug 16 16:23:38 2011
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `application`;

--
-- Table: `application`
--
CREATE TABLE `application` (
  `id` integer NOT NULL auto_increment,
  `function` enum('checksum', 'media_image', 'virus_check') NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `application_function_name` (`function`, `name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `audit_trail`;

--
-- Table: `audit_trail`
--
CREATE TABLE `audit_trail` (
  `id` integer NOT NULL auto_increment,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `authority_name`;

--
-- Table: `authority_name`
--
CREATE TABLE `authority_name` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `dc_type`;

--
-- Table: `dc_type`
--
CREATE TABLE `dc_type` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `dc_type_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `documentation`;

--
-- Table: `documentation`
--
CREATE TABLE `documentation` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(3) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `documentation_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `file_extension`;

--
-- Table: `file_extension`
--
CREATE TABLE `file_extension` (
  `id` integer NOT NULL auto_increment,
  `extension` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `format`;

--
-- Table: `format`
--
CREATE TABLE `format` (
  `id` integer NOT NULL auto_increment,
  `class` enum('container', 'bound_volume', 'three_dimensional_object', 'audio_visual_media', 'document', 'physical_image', 'digital_object', 'browsing_object') NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `format_class_name` (`class`, `name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `function`;

--
-- Table: `function`
--
CREATE TABLE `function` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `geographic_term`;

--
-- Table: `geographic_term`
--
CREATE TABLE `geographic_term` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_restrictions`;

--
-- Table: `item_restrictions`
--
CREATE TABLE `item_restrictions` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `object_set_object`;

--
-- Table: `object_set_object`
--
CREATE TABLE `object_set_object` (
  `object_set` integer NOT NULL DEFAULT 0,
  `object` integer NOT NULL DEFAULT 0,
  INDEX `object_set_object_idx_object` (`object`),
  INDEX `object_set_object_idx_object_set` (`object_set`),
  PRIMARY KEY (`object_set`, `object`),
  CONSTRAINT `object_set_object_fk_object` FOREIGN KEY (`object`) REFERENCES `object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `object_set_object_fk_object_set` FOREIGN KEY (`object_set`) REFERENCES `object_set` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `processing_status`;

--
-- Table: `processing_status`
--
CREATE TABLE `processing_status` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(10) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `processing_status_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `publication_status`;

--
-- Table: `publication_status`
--
CREATE TABLE `publication_status` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `publication_status_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_relationship_type`;

--
-- Table: `record_context_relationship_type`
--
CREATE TABLE `record_context_relationship_type` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `record_context_relationship_type_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_type`;

--
-- Table: `record_context_type`
--
CREATE TABLE `record_context_type` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `record_context_type_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `relationship_predicate`;

--
-- Table: `relationship_predicate`
--
CREATE TABLE `relationship_predicate` (
  `id` tinyint NOT NULL auto_increment,
  `predicate` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `relationship_predicate_predicate` (`predicate`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `roles`;

--
-- Table: `roles`
--
CREATE TABLE `roles` (
  `id` integer NOT NULL auto_increment,
  `role` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `stabilization_procedure`;

--
-- Table: `stabilization_procedure`
--
CREATE TABLE `stabilization_procedure` (
  `id` tinyint NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255),
  PRIMARY KEY (`id`),
  UNIQUE `stabilization_procedure_code` (`code`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `staff`;

--
-- Table: `staff`
--
CREATE TABLE `staff` (
  `id` integer NOT NULL auto_increment,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `topic_term`;

--
-- Table: `topic_term`
--
CREATE TABLE `topic_term` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `unit_type`;

--
-- Table: `unit_type`
--
CREATE TABLE `unit_type` (
  `id` tinyint NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `volume` decimal(5, 2),
  PRIMARY KEY (`id`),
  UNIQUE `unit_type_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location`;

--
-- Table: `location`
--
CREATE TABLE `location` (
  `id` integer NOT NULL auto_increment,
  `barcode` varchar(255) NOT NULL,
  `unit_type` tinyint NOT NULL,
  INDEX `location_idx_unit_type` (`unit_type`),
  PRIMARY KEY (`id`),
  UNIQUE `location_barcode` (`barcode`),
  CONSTRAINT `location_fk_unit_type` FOREIGN KEY (`unit_type`) REFERENCES `unit_type` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `object`;

--
-- Table: `object`
--
CREATE TABLE `object` (
  `id` integer NOT NULL auto_increment,
  `parent` integer,
  `number` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `audit_trail` integer NOT NULL,
  INDEX `object_idx_audit_trail` (`audit_trail`),
  INDEX `object_idx_parent` (`parent`),
  PRIMARY KEY (`id`),
  UNIQUE `object_number` (`number`),
  CONSTRAINT `object_fk_audit_trail` FOREIGN KEY (`audit_trail`) REFERENCES `audit_trail` (`id`),
  CONSTRAINT `object_fk_parent` FOREIGN KEY (`parent`) REFERENCES `object` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `staff` integer,
  INDEX `user_idx_staff` (`staff`),
  PRIMARY KEY (`id`),
  CONSTRAINT `user_fk_staff` FOREIGN KEY (`staff`) REFERENCES `staff` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user_roles`;

--
-- Table: `user_roles`
--
CREATE TABLE `user_roles` (
  `user_id` integer NOT NULL DEFAULT 0,
  `role_id` integer NOT NULL DEFAULT 0,
  INDEX `user_roles_idx_role_id` (`role_id`),
  PRIMARY KEY (`user_id`, `role_id`),
  CONSTRAINT `user_roles_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location_collection_number`;

--
-- Table: `location_collection_number`
--
CREATE TABLE `location_collection_number` (
  `id` integer NOT NULL auto_increment,
  `location` integer NOT NULL,
  `number` varchar(255) NOT NULL,
  INDEX `location_collection_number_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `location_collection_number_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location_series_number`;

--
-- Table: `location_series_number`
--
CREATE TABLE `location_series_number` (
  `id` integer NOT NULL auto_increment,
  `location` integer NOT NULL,
  `number` varchar(255) NOT NULL,
  INDEX `location_series_number_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `location_series_number_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location_title`;

--
-- Table: `location_title`
--
CREATE TABLE `location_title` (
  `id` integer NOT NULL auto_increment,
  `location` integer NOT NULL,
  `title` varchar(255) NOT NULL,
  INDEX `location_title_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `location_title_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `log`;

--
-- Table: `log`
--
CREATE TABLE `log` (
  `id` integer NOT NULL auto_increment,
  `audit_trail` integer NOT NULL,
  `action` enum('create', 'update', 'export') NOT NULL,
  `timestamp` datetime NOT NULL,
  `staff` integer NOT NULL,
  INDEX `log_idx_audit_trail` (`audit_trail`),
  INDEX `log_idx_staff` (`staff`),
  PRIMARY KEY (`id`),
  CONSTRAINT `log_fk_audit_trail` FOREIGN KEY (`audit_trail`) REFERENCES `audit_trail` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_fk_staff` FOREIGN KEY (`staff`) REFERENCES `staff` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `object_set`;

--
-- Table: `object_set`
--
CREATE TABLE `object_set` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `owner` integer NOT NULL,
  INDEX `object_set_idx_owner` (`owner`),
  PRIMARY KEY (`id`),
  CONSTRAINT `object_set_fk_owner` FOREIGN KEY (`owner`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `series`;

--
-- Table: `series`
--
CREATE TABLE `series` (
  `id` integer NOT NULL,
  `bulk_date_from` varchar(10),
  `bulk_date_to` varchar(10),
  `description` text,
  `arrangement` text,
  `notes` text,
  INDEX (`id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `series_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection_relationship`;

--
-- Table: `collection_relationship`
--
CREATE TABLE `collection_relationship` (
  `id` integer NOT NULL auto_increment,
  `collection` integer NOT NULL,
  `predicate` tinyint NOT NULL,
  `pid` varchar(255) NOT NULL,
  INDEX `collection_relationship_idx_collection` (`collection`),
  INDEX `collection_relationship_idx_predicate` (`predicate`),
  PRIMARY KEY (`id`),
  CONSTRAINT `collection_relationship_fk_collection` FOREIGN KEY (`collection`) REFERENCES `object` (`id`),
  CONSTRAINT `collection_relationship_fk_predicate` FOREIGN KEY (`predicate`) REFERENCES `relationship_predicate` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item`;

--
-- Table: `item`
--
CREATE TABLE `item` (
  `id` integer NOT NULL,
  `circa` enum('0','1') NOT NULL DEFAULT '0',
  `date_from` varchar(10) NOT NULL,
  `date_to` varchar(10),
  `restrictions` tinyint,
  `accession_number` varchar(255),
  `dc_type` tinyint NOT NULL,
  `description` text,
  `volume` varchar(255),
  `issue` varchar(255),
  `abstract` text,
  `citation` text,
  INDEX `item_idx_dc_type` (`dc_type`),
  INDEX `item_idx_restrictions` (`restrictions`),
  INDEX (`id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `item_fk_dc_type` FOREIGN KEY (`dc_type`) REFERENCES `dc_type` (`id`),
  CONSTRAINT `item_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`),
  CONSTRAINT `item_fk_restrictions` FOREIGN KEY (`restrictions`) REFERENCES `item_restrictions` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context`;

--
-- Table: `record_context`
--
CREATE TABLE `record_context` (
  `id` integer NOT NULL auto_increment,
  `record_id` varchar(255) NOT NULL,
  `publication_status` tinyint,
  `name_entry` varchar(255) NOT NULL,
  `rc_type` tinyint NOT NULL,
  `date_from` varchar(10),
  `date_to` varchar(10),
  `circa` enum('0','1') NOT NULL DEFAULT '0',
  `ongoing` enum('0','1') NOT NULL DEFAULT '0',
  `abstract` text,
  `history` text,
  `structure_notes` text,
  `context` text,
  `function` integer,
  `audit_trail` integer NOT NULL,
  INDEX `record_context_idx_audit_trail` (`audit_trail`),
  INDEX `record_context_idx_function` (`function`),
  INDEX `record_context_idx_publication_status` (`publication_status`),
  INDEX `record_context_idx_rc_type` (`rc_type`),
  PRIMARY KEY (`id`),
  UNIQUE `record_context_name_entry` (`name_entry`),
  UNIQUE `record_context_record_id` (`record_id`),
  CONSTRAINT `record_context_fk_audit_trail` FOREIGN KEY (`audit_trail`) REFERENCES `audit_trail` (`id`),
  CONSTRAINT `record_context_fk_function` FOREIGN KEY (`function`) REFERENCES `function` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `record_context_fk_publication_status` FOREIGN KEY (`publication_status`) REFERENCES `publication_status` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `record_context_fk_rc_type` FOREIGN KEY (`rc_type`) REFERENCES `record_context_type` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection`;

--
-- Table: `collection`
--
CREATE TABLE `collection` (
  `id` integer NOT NULL,
  `bulk_date_from` varchar(10),
  `bulk_date_to` varchar(10),
  `scope` text,
  `organization` text,
  `history` text,
  `documentation` tinyint NOT NULL,
  `processing_notes` text,
  `notes` text,
  `processing_status` tinyint NOT NULL,
  `permanent_url` text,
  `pid` varchar(255),
  `publication_status` tinyint NOT NULL DEFAULT 1,
  INDEX `collection_idx_documentation` (`documentation`),
  INDEX `collection_idx_processing_status` (`processing_status`),
  INDEX `collection_idx_publication_status` (`publication_status`),
  INDEX (`id`),
  PRIMARY KEY (`id`),
  UNIQUE `collection_pid` (`pid`),
  CONSTRAINT `collection_fk_documentation` FOREIGN KEY (`documentation`) REFERENCES `documentation` (`id`),
  CONSTRAINT `collection_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`),
  CONSTRAINT `collection_fk_processing_status` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `collection_fk_publication_status` FOREIGN KEY (`publication_status`) REFERENCES `publication_status` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_group`;

--
-- Table: `item_group`
--
CREATE TABLE `item_group` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  INDEX `item_group_idx_item` (`item`),
  PRIMARY KEY (`id`),
  CONSTRAINT `item_group_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_alternate_name`;

--
-- Table: `record_context_alternate_name`
--
CREATE TABLE `record_context_alternate_name` (
  `id` integer NOT NULL auto_increment,
  `record_context` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  INDEX `record_context_alternate_name_idx_record_context` (`record_context`),
  PRIMARY KEY (`id`),
  CONSTRAINT `record_context_alternate_name_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_occupation`;

--
-- Table: `record_context_occupation`
--
CREATE TABLE `record_context_occupation` (
  `id` integer NOT NULL auto_increment,
  `record_context` integer NOT NULL,
  `date_from` varchar(10) NOT NULL,
  `date_to` varchar(10),
  INDEX `record_context_occupation_idx_record_context` (`record_context`),
  PRIMARY KEY (`id`),
  CONSTRAINT `record_context_occupation_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_source`;

--
-- Table: `record_context_source`
--
CREATE TABLE `record_context_source` (
  `id` integer NOT NULL auto_increment,
  `record_context` integer NOT NULL,
  `source` varchar(255) NOT NULL,
  INDEX `record_context_source_idx_record_context` (`record_context`),
  PRIMARY KEY (`id`),
  CONSTRAINT `record_context_source_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `browsing_object`;

--
-- Table: `browsing_object`
--
CREATE TABLE `browsing_object` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `format` integer,
  `pid` varchar(255),
  `thumbnail_pid` varchar(255),
  INDEX `browsing_object_idx_format` (`format`),
  INDEX `browsing_object_idx_item` (`item`),
  PRIMARY KEY (`id`),
  CONSTRAINT `browsing_object_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `browsing_object_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection_language`;

--
-- Table: `collection_language`
--
CREATE TABLE `collection_language` (
  `collection` integer NOT NULL,
  `language` char(3) NOT NULL,
  INDEX `collection_language_idx_collection` (`collection`),
  PRIMARY KEY (`collection`, `language`),
  CONSTRAINT `collection_language_fk_collection` FOREIGN KEY (`collection`) REFERENCES `collection` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection_material`;

--
-- Table: `collection_material`
--
CREATE TABLE `collection_material` (
  `id` integer NOT NULL auto_increment,
  `collection` integer NOT NULL,
  `material` varchar(255) NOT NULL,
  INDEX `collection_material_idx_collection` (`collection`),
  PRIMARY KEY (`id`),
  CONSTRAINT `collection_material_fk_collection` FOREIGN KEY (`collection`) REFERENCES `collection` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection_subject`;

--
-- Table: `collection_subject`
--
CREATE TABLE `collection_subject` (
  `id` integer NOT NULL auto_increment,
  `collection` integer NOT NULL,
  `subject` varchar(255) NOT NULL,
  INDEX `collection_subject_idx_collection` (`collection`),
  PRIMARY KEY (`id`),
  CONSTRAINT `collection_subject_fk_collection` FOREIGN KEY (`collection`) REFERENCES `collection` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_authority_name`;

--
-- Table: `item_authority_name`
--
CREATE TABLE `item_authority_name` (
  `item` integer NOT NULL,
  `role` enum('creator', 'personal_name', 'corporate_name') NOT NULL,
  `name` integer NOT NULL,
  INDEX `item_authority_name_idx_item` (`item`),
  INDEX `item_authority_name_idx_name` (`name`),
  PRIMARY KEY (`item`, `role`, `name`),
  CONSTRAINT `item_authority_name_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_authority_name_fk_name` FOREIGN KEY (`name`) REFERENCES `authority_name` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_geographic_term`;

--
-- Table: `item_geographic_term`
--
CREATE TABLE `item_geographic_term` (
  `item` integer NOT NULL,
  `term` integer NOT NULL,
  INDEX `item_geographic_term_idx_item` (`item`),
  INDEX `item_geographic_term_idx_term` (`term`),
  PRIMARY KEY (`item`, `term`),
  CONSTRAINT `item_geographic_term_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_geographic_term_fk_term` FOREIGN KEY (`term`) REFERENCES `geographic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_topic_term`;

--
-- Table: `item_topic_term`
--
CREATE TABLE `item_topic_term` (
  `item` integer NOT NULL,
  `term` integer NOT NULL,
  INDEX `item_topic_term_idx_item` (`item`),
  INDEX `item_topic_term_idx_term` (`term`),
  PRIMARY KEY (`item`, `term`),
  CONSTRAINT `item_topic_term_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_topic_term_fk_term` FOREIGN KEY (`term`) REFERENCES `topic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `occupation_title`;

--
-- Table: `occupation_title`
--
CREATE TABLE `occupation_title` (
  `id` integer NOT NULL auto_increment,
  `occupation` integer NOT NULL,
  `title` varchar(255) NOT NULL,
  INDEX `occupation_title_idx_occupation` (`occupation`),
  PRIMARY KEY (`id`),
  CONSTRAINT `occupation_title_fk_occupation` FOREIGN KEY (`occupation`) REFERENCES `record_context_occupation` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context_relationship`;

--
-- Table: `record_context_relationship`
--
CREATE TABLE `record_context_relationship` (
  `id` integer NOT NULL auto_increment,
  `record_context` integer NOT NULL,
  `type` tinyint NOT NULL,
  `related_entity` integer NOT NULL,
  `date_from` varchar(10),
  `date_to` varchar(10),
  INDEX `record_context_relationship_idx_record_context` (`record_context`),
  INDEX `record_context_relationship_idx_related_entity` (`related_entity`),
  INDEX `record_context_relationship_idx_type` (`type`),
  PRIMARY KEY (`id`),
  CONSTRAINT `record_context_relationship_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `record_context_relationship_fk_related_entity` FOREIGN KEY (`related_entity`) REFERENCES `record_context` (`id`),
  CONSTRAINT `record_context_relationship_fk_type` FOREIGN KEY (`type`) REFERENCES `record_context_relationship_type` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `document`;

--
-- Table: `document`
--
CREATE TABLE `document` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `dimensions` varchar(255),
  `rights` text,
  INDEX `document_idx_format` (`format`),
  INDEX `document_idx_item` (`item`),
  INDEX `document_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `document_fk_format` FOREIGN KEY (`format`) REFERENCES `document` (`id`),
  CONSTRAINT `document_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `document_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `file_folder`;

--
-- Table: `file_folder`
--
CREATE TABLE `file_folder` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `notes` text,
  INDEX `file_folder_idx_item` (`item`),
  INDEX `file_folder_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `file_folder_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `file_folder_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `audio_visual_media`;

--
-- Table: `audio_visual_media`
--
CREATE TABLE `audio_visual_media` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `notes` text,
  `rights` text,
  INDEX `audio_visual_media_idx_format` (`format`),
  INDEX `audio_visual_media_idx_item` (`item`),
  INDEX `audio_visual_media_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `audio_visual_media_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `audio_visual_media_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `audio_visual_media_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `bound_volume`;

--
-- Table: `bound_volume`
--
CREATE TABLE `bound_volume` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `notes` text,
  `rights` text,
  INDEX `bound_volume_idx_format` (`format`),
  INDEX `bound_volume_idx_item` (`item`),
  INDEX `bound_volume_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `bound_volume_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bound_volume_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bound_volume_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `browsing_object_relationship`;

--
-- Table: `browsing_object_relationship`
--
CREATE TABLE `browsing_object_relationship` (
  `id` integer NOT NULL auto_increment,
  `browsing_object` integer NOT NULL,
  `predicate` tinyint NOT NULL,
  `pid` varchar(255) NOT NULL,
  INDEX `browsing_object_relationship_idx_browsing_object` (`browsing_object`),
  INDEX `browsing_object_relationship_idx_predicate` (`predicate`),
  PRIMARY KEY (`id`),
  CONSTRAINT `browsing_object_relationship_fk_browsing_object` FOREIGN KEY (`browsing_object`) REFERENCES `browsing_object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `browsing_object_relationship_fk_predicate` FOREIGN KEY (`predicate`) REFERENCES `relationship_predicate` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `container`;

--
-- Table: `container`
--
CREATE TABLE `container` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `notes` text,
  INDEX `container_idx_format` (`format`),
  INDEX `container_idx_item` (`item`),
  INDEX `container_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `container_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `container_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `container_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `physical_image`;

--
-- Table: `physical_image`
--
CREATE TABLE `physical_image` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `dimensions` varchar(255),
  `rights` text,
  INDEX `physical_image_idx_format` (`format`),
  INDEX `physical_image_idx_item` (`item`),
  INDEX `physical_image_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `physical_image_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `physical_image_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `physical_image_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `three_dimensional_object`;

--
-- Table: `three_dimensional_object`
--
CREATE TABLE `three_dimensional_object` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `notes` text,
  `rights` text,
  INDEX `three_dimensional_object_idx_format` (`format`),
  INDEX `three_dimensional_object_idx_item` (`item`),
  INDEX `three_dimensional_object_idx_location` (`location`),
  PRIMARY KEY (`id`),
  CONSTRAINT `three_dimensional_object_fk_format` FOREIGN KEY (`format`) REFERENCES `format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `three_dimensional_object_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `three_dimensional_object_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `collection_record_context`;

--
-- Table: `collection_record_context`
--
CREATE TABLE `collection_record_context` (
  `collection` integer NOT NULL,
  `is_primary` enum('0','1') NOT NULL,
  `record_context` integer NOT NULL,
  INDEX `collection_record_context_idx_collection` (`collection`),
  INDEX `collection_record_context_idx_record_context` (`record_context`),
  PRIMARY KEY (`collection`, `is_primary`, `record_context`),
  CONSTRAINT `collection_record_context_fk_collection` FOREIGN KEY (`collection`) REFERENCES `collection` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `collection_record_context_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `digital_object`;

--
-- Table: `digital_object`
--
CREATE TABLE `digital_object` (
  `id` integer NOT NULL auto_increment,
  `item` integer NOT NULL,
  `location` integer NOT NULL,
  `format` integer,
  `pid` varchar(255) NOT NULL,
  `permanent_url` varchar(255),
  `notes` text,
  `rights` text,
  `checksum` varchar(255),
  `file_extension` integer,
  `original_filename` varchar(255),
  `toc` text,
  `stabilized_by` integer,
  `stabilization_date` varchar(10),
  `stabilization_procedure` tinyint,
  `stabilization_notes` text,
  `checksum_app` integer,
  `media_app` integer,
  `virus_app` integer,
  `file_creation_date` varchar(10),
  INDEX `digital_object_idx_checksum_app` (`checksum_app`),
  INDEX `digital_object_idx_file_extension` (`file_extension`),
  INDEX `digital_object_idx_format` (`format`),
  INDEX `digital_object_idx_item` (`item`),
  INDEX `digital_object_idx_location` (`location`),
  INDEX `digital_object_idx_media_app` (`media_app`),
  INDEX `digital_object_idx_stabilization_procedure` (`stabilization_procedure`),
  INDEX `digital_object_idx_stabilized_by` (`stabilized_by`),
  INDEX `digital_object_idx_virus_app` (`virus_app`),
  PRIMARY KEY (`id`),
  CONSTRAINT `digital_object_fk_checksum_app` FOREIGN KEY (`checksum_app`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_fk_file_extension` FOREIGN KEY (`file_extension`) REFERENCES `file_extension` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_fk_format` FOREIGN KEY (`format`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `digital_object_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`id`),
  CONSTRAINT `digital_object_fk_media_app` FOREIGN KEY (`media_app`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_fk_stabilization_procedure` FOREIGN KEY (`stabilization_procedure`) REFERENCES `stabilization_procedure` (`id`),
  CONSTRAINT `digital_object_fk_stabilized_by` FOREIGN KEY (`stabilized_by`) REFERENCES `staff` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_fk_virus_app` FOREIGN KEY (`virus_app`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `digital_object_application`;

--
-- Table: `digital_object_application`
--
CREATE TABLE `digital_object_application` (
  `id` integer NOT NULL auto_increment,
  `digital_object` integer NOT NULL,
  `application` varchar(255) NOT NULL,
  INDEX `digital_object_application_idx_digital_object` (`digital_object`),
  PRIMARY KEY (`id`),
  CONSTRAINT `digital_object_application_fk_digital_object` FOREIGN KEY (`digital_object`) REFERENCES `digital_object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `digital_object_relationship`;

--
-- Table: `digital_object_relationship`
--
CREATE TABLE `digital_object_relationship` (
  `id` integer NOT NULL auto_increment,
  `digital_object` integer NOT NULL,
  `predicate` tinyint NOT NULL,
  `pid` varchar(255) NOT NULL,
  INDEX `digital_object_relationship_idx_digital_object` (`digital_object`),
  INDEX `digital_object_relationship_idx_predicate` (`predicate`),
  PRIMARY KEY (`id`),
  CONSTRAINT `digital_object_relationship_fk_digital_object` FOREIGN KEY (`digital_object`) REFERENCES `digital_object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `digital_object_relationship_fk_predicate` FOREIGN KEY (`predicate`) REFERENCES `relationship_predicate` (`id`)
) ENGINE=InnoDB;

SET foreign_key_checks=1;


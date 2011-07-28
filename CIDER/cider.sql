-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Jul 28 13:09:05 2011
-- 
SET foreign_key_checks=0;

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
  PRIMARY KEY (`id`)
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

DROP TABLE IF EXISTS `log`;

--
-- Table: `log`
--
CREATE TABLE `log` (
  `id` integer NOT NULL auto_increment,
  `action` char(16) NOT NULL,
  `timestamp` datetime NOT NULL,
  `user` integer NOT NULL,
  `object` integer NOT NULL,
  INDEX `log_idx_object` (`object`),
  INDEX `log_idx_user` (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `log_fk_object` FOREIGN KEY (`object`) REFERENCES `object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `log_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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
  INDEX `object_idx_parent` (`parent`),
  PRIMARY KEY (`id`),
  UNIQUE `object_number` (`number`),
  CONSTRAINT `object_fk_parent` FOREIGN KEY (`parent`) REFERENCES `object` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `object_set`;

--
-- Table: `object_set`
--
CREATE TABLE `object_set` (
  `id` integer NOT NULL auto_increment,
  `name` char(255),
  `owner` integer,
  INDEX `object_set_idx_owner` (`owner`),
  PRIMARY KEY (`id`),
  CONSTRAINT `object_set_fk_owner` FOREIGN KEY (`owner`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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

DROP TABLE IF EXISTS `record_context`;

--
-- Table: `record_context`
--
CREATE TABLE `record_context` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;

--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL auto_increment,
  `username` char(64),
  `password` char(64) NOT NULL,
  PRIMARY KEY (`id`)
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
  CONSTRAINT `collection_fk_processing_status` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`),
  CONSTRAINT `collection_fk_publication_status` FOREIGN KEY (`publication_status`) REFERENCES `publication_status` (`id`)
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
  `geographic_term` integer NOT NULL,
  INDEX `item_geographic_term_idx_geographic_term` (`geographic_term`),
  INDEX `item_geographic_term_idx_item` (`item`),
  PRIMARY KEY (`item`, `geographic_term`),
  CONSTRAINT `item_geographic_term_fk_geographic_term` FOREIGN KEY (`geographic_term`) REFERENCES `geographic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_geographic_term_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_topic_term`;

--
-- Table: `item_topic_term`
--
CREATE TABLE `item_topic_term` (
  `item` integer NOT NULL,
  `topic_term` integer NOT NULL,
  INDEX `item_topic_term_idx_item` (`item`),
  INDEX `item_topic_term_idx_topic_term` (`topic_term`),
  PRIMARY KEY (`item`, `topic_term`),
  CONSTRAINT `item_topic_term_fk_item` FOREIGN KEY (`item`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_topic_term_fk_topic_term` FOREIGN KEY (`topic_term`) REFERENCES `topic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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

SET foreign_key_checks=1;


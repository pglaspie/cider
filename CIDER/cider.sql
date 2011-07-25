-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Jul 25 18:45:46 2011
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
  CONSTRAINT `collection_material_fk_collection` FOREIGN KEY (`collection`) REFERENCES `object` (`id`)
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

DROP TABLE IF EXISTS `item_format`;

--
-- Table: `item_format`
--
CREATE TABLE `item_format` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_restrictions`;

--
-- Table: `item_restrictions`
--
CREATE TABLE `item_restrictions` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `item_type`;

--
-- Table: `item_type`
--
CREATE TABLE `item_type` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location_collection_number`;

--
-- Table: `location_collection_number`
--
CREATE TABLE `location_collection_number` (
  `id` integer NOT NULL auto_increment,
  `location` char(16) NOT NULL,
  `number` char(255) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `location_series_number`;

--
-- Table: `location_series_number`
--
CREATE TABLE `location_series_number` (
  `id` integer NOT NULL auto_increment,
  `location` char(16) NOT NULL,
  `number` char(255) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `location_title`;

--
-- Table: `location_title`
--
CREATE TABLE `location_title` (
  `id` integer NOT NULL auto_increment,
  `location` char(16) NOT NULL,
  `title` text NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `location_unit_type`;

--
-- Table: `location_unit_type`
--
CREATE TABLE `location_unit_type` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `volume` decimal(5, 2),
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
  `number` char(255) NOT NULL,
  `title` char(255) NOT NULL,
  INDEX `object_idx_parent` (`parent`),
  PRIMARY KEY (`id`),
  UNIQUE `object_number` (`number`),
  CONSTRAINT `object_fk_parent` FOREIGN KEY (`parent`) REFERENCES `object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
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
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `record_context`;

--
-- Table: `record_context`
--
CREATE TABLE `record_context` (
  `id` integer NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `relationship_predicate`;

--
-- Table: `relationship_predicate`
--
CREATE TABLE `relationship_predicate` (
  `id` integer NOT NULL auto_increment,
  `predicate` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
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

DROP TABLE IF EXISTS `collection`;

--
-- Table: `collection`
--
CREATE TABLE `collection` (
  `id` integer NOT NULL,
  `bulk_date_from` varchar(10),
  `bulk_date_to` varchar(10),
  `record_context` integer,
  `history` text,
  `scope` text,
  `organization` text,
  `notes` text,
  `language` char(3) NOT NULL DEFAULT 'eng',
  `processing_status` tinyint NOT NULL,
  `processing_notes` text,
  `has_physical_documentation` enum('0', '1') NOT NULL,
  `permanent_url` text,
  `pid` varchar(255),
  `publication_status` varchar(16),
  INDEX `collection_idx_processing_status` (`processing_status`),
  INDEX `collection_idx_record_context` (`record_context`),
  INDEX (`id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `collection_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`) ON DELETE CASCADE,
  CONSTRAINT `collection_fk_processing_status` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `collection_fk_record_context` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location`;

--
-- Table: `location`
--
CREATE TABLE `location` (
  `barcode` char(16) NOT NULL,
  `unit_type` integer NOT NULL,
  INDEX `location_idx_unit_type` (`unit_type`),
  PRIMARY KEY (`barcode`),
  CONSTRAINT `location_fk_unit_type` FOREIGN KEY (`unit_type`) REFERENCES `location_unit_type` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `series`;

--
-- Table: `series`
--
CREATE TABLE `series` (
  `id` integer NOT NULL,
  `bulk_date_from` varchar(10),
  `bulk_date_to` varchar(10),
  `description` text NOT NULL,
  `arrangement` varchar(255),
  `notes` text,
  INDEX (`id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `series_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`) ON DELETE CASCADE
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
  `predicate` integer NOT NULL,
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
  `creator` integer,
  `circa` enum('0','1') NOT NULL DEFAULT '0',
  `date_from` varchar(10) NOT NULL,
  `date_to` varchar(10),
  `restrictions` integer,
  `accession_by` char(255),
  `accession_date` varchar(10),
  `accession_procedure` text,
  `accession_number` char(128),
  `location` char(16),
  `dc_type` integer NOT NULL,
  `format` integer,
  `personal_name` integer,
  `corporate_name` integer,
  `topic_term` integer,
  `geographic_term` integer,
  `notes` text,
  `checksum` char(64),
  `original_filename` char(255),
  `file_creation_date` varchar(10),
  `stabilization_by` char(255),
  `stabilization_date` varchar(10),
  `stabilization_procedure` text,
  `stabilization_notes` text,
  `virus_app` char(128),
  `checksum_app` char(128),
  `media_app` char(128),
  `other_app` char(128),
  `toc` text,
  `rsa` text,
  `technical_metadata` text,
  `lc_class` char(255),
  `file_extension` char(16),
  INDEX `item_idx_corporate_name` (`corporate_name`),
  INDEX `item_idx_creator` (`creator`),
  INDEX `item_idx_dc_type` (`dc_type`),
  INDEX `item_idx_format` (`format`),
  INDEX `item_idx_geographic_term` (`geographic_term`),
  INDEX `item_idx_location` (`location`),
  INDEX `item_idx_personal_name` (`personal_name`),
  INDEX `item_idx_restrictions` (`restrictions`),
  INDEX `item_idx_topic_term` (`topic_term`),
  INDEX (`id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `item_fk_corporate_name` FOREIGN KEY (`corporate_name`) REFERENCES `authority_name` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_creator` FOREIGN KEY (`creator`) REFERENCES `authority_name` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_dc_type` FOREIGN KEY (`dc_type`) REFERENCES `item_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_format` FOREIGN KEY (`format`) REFERENCES `item_format` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_geographic_term` FOREIGN KEY (`geographic_term`) REFERENCES `geographic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_location` FOREIGN KEY (`location`) REFERENCES `location` (`barcode`),
  CONSTRAINT `item_fk_id` FOREIGN KEY (`id`) REFERENCES `object` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_fk_personal_name` FOREIGN KEY (`personal_name`) REFERENCES `authority_name` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_restrictions` FOREIGN KEY (`restrictions`) REFERENCES `item_restrictions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_fk_topic_term` FOREIGN KEY (`topic_term`) REFERENCES `topic_term` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;


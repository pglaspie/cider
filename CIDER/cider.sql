-- MySQL dump 10.13  Distrib 5.1.54, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: cider
-- ------------------------------------------------------
-- Server version	5.1.54-1ubuntu4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `authority_name`
--

DROP TABLE IF EXISTS `authority_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authority_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_format`
--

DROP TABLE IF EXISTS `item_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_format` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_type`
--

DROP TABLE IF EXISTS `item_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` char(16) NOT NULL,
  `timestamp` datetime NOT NULL,
  `user` int(11) NOT NULL,
  `object` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  KEY `object` (`object`),
  CONSTRAINT `log_ibfk_2` FOREIGN KEY (`object`) REFERENCES `object` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object`
--

DROP TABLE IF EXISTS `object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date_from` date DEFAULT NULL,
  `date_to` date DEFAULT NULL,
  `bulk_date_from` date DEFAULT NULL,
  `bulk_date_to` date DEFAULT NULL,
  `record_context` int(11) DEFAULT NULL,
  `history` text,
  `scope` char(255) DEFAULT NULL,
  `organization` char(255) DEFAULT NULL,
  `processing_status` tinyint(4) DEFAULT NULL,
  `has_physical_documentation` enum('0','1') DEFAULT NULL,
  `processing_notes` text,
  `volume_count` int(11) DEFAULT NULL,
  `volume_extent` int(11) DEFAULT NULL,
  `volume_unit` char(16) DEFAULT NULL,
  `description` text,
  `location` char(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `format` int(11) DEFAULT NULL,
  `funder` char(128) DEFAULT NULL,
  `handle` char(128) DEFAULT NULL,
  `checksum` char(64) DEFAULT NULL,
  `original_filename` char(255) DEFAULT NULL,
  `accession_by` char(255) DEFAULT NULL,
  `accession_date` date DEFAULT NULL,
  `accession_procedure` text,
  `accession_number` char(128) DEFAULT NULL,
  `stabilization_by` char(255) DEFAULT NULL,
  `stabilization_date` date DEFAULT NULL,
  `stabilization_procedure` text,
  `stabilization_notes` text,
  `virus_app` char(128) DEFAULT NULL,
  `checksum_app` char(128) DEFAULT NULL,
  `media_app` char(128) DEFAULT NULL,
  `other_app` char(128) DEFAULT NULL,
  `toc` text,
  `rsa` text,
  `technical_metadata` text,
  `file_creation_date` date DEFAULT NULL,
  `lc_class` char(255) DEFAULT NULL,
  `file_extension` char(16) DEFAULT NULL,
  `parent` int(11) DEFAULT NULL,
  `number` char(255) NOT NULL,
  `title` char(255) NOT NULL,
  `personal_name` int(11) DEFAULT NULL,
  `corporate_name` int(11) DEFAULT NULL,
  `topic_term` int(11) DEFAULT NULL,
  `geographic_term` int(11) DEFAULT NULL,
  `notes` text,
  `circa` tinyint(1) NOT NULL DEFAULT '0',
  `language` char(3) NOT NULL DEFAULT 'eng',
  PRIMARY KEY (`id`),
  KEY `parent` (`parent`),
  KEY `personal_name` (`personal_name`),
  KEY `corporate_name` (`corporate_name`),
  KEY `topic_term` (`topic_term`),
  KEY `geographic_term` (`geographic_term`),
  KEY `type` (`type`),
  KEY `format` (`format`),
  KEY `processing_status` (`processing_status`),
  KEY `record_creator` (`record_context`),
  CONSTRAINT `object_ibfk_1` FOREIGN KEY (`parent`) REFERENCES `object` (`id`),
  CONSTRAINT `object_ibfk_11` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`),
  CONSTRAINT `object_ibfk_12` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`),
  CONSTRAINT `object_ibfk_2` FOREIGN KEY (`personal_name`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_3` FOREIGN KEY (`corporate_name`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_4` FOREIGN KEY (`topic_term`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_5` FOREIGN KEY (`geographic_term`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_6` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`),
  CONSTRAINT `object_ibfk_8` FOREIGN KEY (`type`) REFERENCES `item_type` (`id`),
  CONSTRAINT `object_ibfk_9` FOREIGN KEY (`format`) REFERENCES `item_format` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object_set`
--

DROP TABLE IF EXISTS `object_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(255) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  CONSTRAINT `object_set_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object_set_object`
--

DROP TABLE IF EXISTS `object_set_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_set_object` (
  `object_set` int(11) NOT NULL DEFAULT '0',
  `object` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`object_set`,`object`),
  KEY `object` (`object`),
  CONSTRAINT `object_set_object_ibfk_1` FOREIGN KEY (`object_set`) REFERENCES `object_set` (`id`),
  CONSTRAINT `object_set_object_ibfk_2` FOREIGN KEY (`object`) REFERENCES `object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `processing_status`
--

DROP TABLE IF EXISTS `processing_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processing_status` (
  `id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `name` char(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `record_context`
--

DROP TABLE IF EXISTS `record_context`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `record_context` (
  `id` int(11) NOT NULL,
  `name` char(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_collection`
--

DROP TABLE IF EXISTS `related_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object` int(11) NOT NULL,
  `name` char(255) DEFAULT NULL,
  `custodian` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `object` (`object`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restriction`
--

DROP TABLE IF EXISTS `restriction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `restriction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restriction_object`
--

DROP TABLE IF EXISTS `restriction_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `restriction_object` (
  `restriction` int(11) NOT NULL DEFAULT '0',
  `object` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`restriction`,`object`),
  KEY `object` (`object`),
  CONSTRAINT `restriction_object_ibfk_1` FOREIGN KEY (`restriction`) REFERENCES `restriction` (`id`),
  CONSTRAINT `restriction_object_ibfk_2` FOREIGN KEY (`object`) REFERENCES `object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` char(64) DEFAULT NULL,
  `password` char(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-05-06 11:09:02

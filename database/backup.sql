-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: school_db
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `academic_sessions`
--

DROP TABLE IF EXISTS `academic_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `academic_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_session_active` (`is_active`),
  KEY `idx_as_org` (`organization_id`),
  KEY `idx_as_campus` (`campus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `academic_sessions`
--

LOCK TABLES `academic_sessions` WRITE;
/*!40000 ALTER TABLE `academic_sessions` DISABLE KEYS */;
INSERT INTO `academic_sessions` VALUES (1,1,NULL,'2025/2026',1,'2026-05-13 10:56:19');
/*!40000 ALTER TABLE `academic_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `idx_act_org` (`organization_id`),
  KEY `idx_act_campus` (`campus_id`),
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
INSERT INTO `activities` VALUES (1,1,NULL,NULL,'Sport Day','Wednesday','10:00:00','12:00:00',1,'2026-05-13 10:56:19');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `affective_scores`
--

DROP TABLE IF EXISTS `affective_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `affective_scores` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `trait_id` int unsigned NOT NULL,
  `score` enum('A','B','C','D','E') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'B',
  `remark` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_affective` (`student_id`,`term_id`,`trait_id`),
  KEY `term_id` (`term_id`),
  KEY `trait_id` (`trait_id`),
  KEY `recorded_by` (`recorded_by`),
  CONSTRAINT `affective_scores_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `affective_scores_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`),
  CONSTRAINT `affective_scores_ibfk_3` FOREIGN KEY (`trait_id`) REFERENCES `affective_traits` (`id`) ON DELETE CASCADE,
  CONSTRAINT `affective_scores_ibfk_4` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `affective_scores`
--

LOCK TABLES `affective_scores` WRITE;
/*!40000 ALTER TABLE `affective_scores` DISABLE KEYS */;
/*!40000 ALTER TABLE `affective_scores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `affective_traits`
--

DROP TABLE IF EXISTS `affective_traits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `affective_traits` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('affective','psychomotor') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `affective_traits`
--

LOCK TABLES `affective_traits` WRITE;
/*!40000 ALTER TABLE `affective_traits` DISABLE KEYS */;
INSERT INTO `affective_traits` VALUES (1,'Punctuality','affective',1),(2,'Neatness','affective',1),(3,'Honesty','affective',1),(4,'Leadership','affective',1),(5,'Cooperation','affective',1),(6,'Politeness','affective',1),(7,'Handwriting','psychomotor',1),(8,'Sports & Games','psychomotor',1),(9,'Art & Craft','psychomotor',1),(10,'Verbal Fluency','psychomotor',1);
/*!40000 ALTER TABLE `affective_traits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alumni`
--

DROP TABLE IF EXISTS `alumni`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alumni` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `final_class_id` int unsigned DEFAULT NULL,
  `graduation_session_id` int unsigned DEFAULT NULL,
  `reason` enum('graduated','transferred','withdrawn','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'graduated',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `archived_by` int unsigned DEFAULT NULL,
  `archived_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_student` (`student_id`),
  KEY `final_class_id` (`final_class_id`),
  KEY `graduation_session_id` (`graduation_session_id`),
  KEY `archived_by` (`archived_by`),
  CONSTRAINT `alumni_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `alumni_ibfk_2` FOREIGN KEY (`final_class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `alumni_ibfk_3` FOREIGN KEY (`graduation_session_id`) REFERENCES `academic_sessions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `alumni_ibfk_4` FOREIGN KEY (`archived_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumni`
--

LOCK TABLES `alumni` WRITE;
/*!40000 ALTER TABLE `alumni` DISABLE KEYS */;
INSERT INTO `alumni` VALUES (2,1,1,NULL,'transferred','No thing',1,'2026-07-15 18:35:55',NULL,NULL);
/*!40000 ALTER TABLE `alumni` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_tokens`
--

DROP TABLE IF EXISTS `api_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token_hash` (`token_hash`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `api_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_tokens`
--

LOCK TABLES `api_tokens` WRITE;
/*!40000 ALTER TABLE `api_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignment_submissions`
--

DROP TABLE IF EXISTS `assignment_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignment_submissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `assignment_id` int unsigned NOT NULL,
  `student_id` int unsigned NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `score` tinyint unsigned DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_submission` (`assignment_id`,`student_id`),
  KEY `student_id` (`student_id`),
  KEY `idx_asub_asgn` (`assignment_id`,`student_id`),
  KEY `idx_asub_org` (`organization_id`),
  KEY `idx_asub_campus` (`campus_id`),
  KEY `idx_asub_section` (`section_id`),
  CONSTRAINT `assignment_submissions_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment_submissions`
--

LOCK TABLES `assignment_submissions` WRITE;
/*!40000 ALTER TABLE `assignment_submissions` DISABLE KEYS */;
INSERT INTO `assignment_submissions` VALUES (1,1,NULL,2,1,164,'sub_6a1727308aeb1.jpg',NULL,'2026-05-27 17:17:36',NULL,NULL);
/*!40000 ALTER TABLE `assignment_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `teacher_id` int unsigned NOT NULL,
  `class_id` int unsigned NOT NULL,
  `subject_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `max_score` tinyint unsigned DEFAULT '10',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `term_id` (`term_id`),
  KEY `idx_asgn_class` (`class_id`),
  KEY `idx_asgn_teacher` (`teacher_id`),
  KEY `idx_assign_org` (`organization_id`),
  KEY `idx_assign_campus` (`campus_id`),
  KEY `idx_assign_section` (`section_id`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_4` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` VALUES (1,1,NULL,2,2,1,15,1,'EDV','QWERYTYUI',NULL,'2026-05-27',10,'2026-05-27 17:16:44',NULL,NULL);
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `class_id` int unsigned DEFAULT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent','late','excused') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `marked_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_attendance` (`user_id`,`date`),
  KEY `marked_by` (`marked_by`),
  KEY `idx_att_date` (`date`),
  KEY `idx_att_class_date` (`class_id`,`date`),
  KEY `idx_att_user_date` (`user_id`,`date`),
  KEY `idx_att_org` (`organization_id`),
  KEY `idx_att_campus` (`campus_id`),
  KEY `idx_att_section` (`section_id`),
  KEY `idx_att_cb` (`created_by`),
  KEY `idx_att_ub` (`updated_by`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (2,1,NULL,2,6,1,'2026-05-27','present',2,'2026-05-27 15:48:39',NULL,NULL),(3,1,NULL,1,15,1,'2026-05-27','absent',2,'2026-05-27 15:48:39',NULL,NULL),(4,1,NULL,1,8,1,'2026-05-27','present',2,'2026-05-27 15:48:39',NULL,NULL),(5,1,NULL,2,21,1,'2026-05-27','present',2,'2026-05-27 15:48:39',NULL,NULL),(6,1,NULL,2,18,1,'2026-05-27','late',2,'2026-05-27 15:48:39',NULL,NULL),(7,1,NULL,2,20,1,'2026-05-27','present',2,'2026-05-27 15:48:39',NULL,NULL),(8,1,NULL,2,22,1,'2026-05-27','excused',2,'2026-05-27 15:48:39',NULL,NULL),(9,1,NULL,2,19,1,'2026-05-27','present',2,'2026-05-27 15:48:39',NULL,NULL),(10,1,NULL,NULL,173,1,'2026-05-27','present',2,'2026-05-27 17:08:26',NULL,NULL),(21,1,NULL,1,24,2,'2026-06-14','present',17,'2026-06-14 17:42:15',NULL,NULL),(22,1,NULL,1,25,2,'2026-06-14','present',17,'2026-06-14 17:42:15',NULL,NULL),(23,1,NULL,1,27,2,'2026-06-14','present',17,'2026-06-14 17:42:15',NULL,NULL),(24,1,NULL,1,23,2,'2026-06-14','present',17,'2026-06-14 17:42:15',NULL,NULL),(25,1,NULL,1,26,2,'2026-06-14','present',17,'2026-06-14 17:42:15',NULL,NULL),(26,1,NULL,1,24,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(27,1,NULL,1,25,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(28,1,NULL,1,27,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(29,1,NULL,1,23,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(30,1,NULL,1,26,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(31,1,NULL,1,184,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL),(32,1,NULL,1,185,2,'2026-06-24','present',17,'2026-06-24 14:57:26',NULL,NULL);
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_sessions`
--

DROP TABLE IF EXISTS `attendance_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int unsigned NOT NULL,
  `date` date NOT NULL,
  `token` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_by` int unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token` (`token`),
  KEY `idx_class_date` (`class_id`,`date`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `attendance_sessions_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_sessions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_sessions`
--

LOCK TABLES `attendance_sessions` WRITE;
/*!40000 ALTER TABLE `attendance_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_tokens`
--

DROP TABLE IF EXISTS `attendance_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int unsigned NOT NULL,
  `token` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `attendance_tokens_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_tokens`
--

LOCK TABLES `attendance_tokens` WRITE;
/*!40000 ALTER TABLE `attendance_tokens` DISABLE KEYS */;
INSERT INTO `attendance_tokens` VALUES (1,3,'d5facf4a477745f6d186f2715f752791','2026-06-18 14:02:37'),(2,3,'36a39765ba11ebbf1025a7634ca34c3c','2026-06-21 11:54:16');
/*!40000 ALTER TABLE `attendance_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `action` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payload` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_created` (`created_at`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1263 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'login','auth',NULL,'::1','2026-05-13 11:01:57'),(2,1,'login','auth',NULL,'::1','2026-05-13 11:15:38'),(3,1,'logout','auth',NULL,'::1','2026-05-13 12:41:48'),(4,2,'login','auth',NULL,'::1','2026-05-13 12:41:59'),(5,2,'logout','auth',NULL,'::1','2026-05-13 12:58:55'),(6,1,'login','auth',NULL,'::1','2026-05-13 13:00:57'),(7,1,'logout','auth',NULL,'::1','2026-05-13 13:03:31'),(8,2,'login','auth',NULL,'::1','2026-05-13 13:03:41'),(9,2,'login','auth',NULL,'::1','2026-05-13 13:27:24'),(10,2,'logout','auth',NULL,'::1','2026-05-13 13:27:36'),(11,1,'login','auth',NULL,'::1','2026-05-13 13:27:54'),(12,1,'login','auth',NULL,'::1','2026-05-13 15:25:30'),(13,2,'login','auth',NULL,'::1','2026-05-13 15:26:57'),(14,3,'login','auth',NULL,'127.0.0.1','2026-05-13 15:46:12'),(15,3,'login','auth',NULL,'127.0.0.1','2026-05-13 17:17:17'),(16,1,'login','auth',NULL,'::1','2026-05-13 18:10:21'),(17,2,'login','auth',NULL,'::1','2026-05-13 18:10:51'),(18,1,'login','auth',NULL,'::1','2026-05-14 09:49:26'),(19,2,'login','auth',NULL,'::1','2026-05-14 10:36:51'),(20,2,'logout','auth',NULL,'::1','2026-05-14 10:51:28'),(21,2,'login','auth',NULL,'::1','2026-05-14 10:51:32'),(22,1,'logout','auth',NULL,'::1','2026-05-14 10:51:52'),(23,2,'login','auth',NULL,'::1','2026-05-14 10:52:00'),(24,2,'logout','auth',NULL,'::1','2026-05-14 10:52:19'),(25,1,'login','auth',NULL,'::1','2026-05-14 10:52:30'),(26,2,'login','auth',NULL,'::1','2026-05-14 12:50:39'),(27,1,'login','auth',NULL,'::1','2026-05-14 12:51:18'),(28,3,'login','auth',NULL,'127.0.0.1','2026-05-14 13:35:15'),(29,1,'login','auth',NULL,'::1','2026-05-14 14:43:49'),(30,1,'login','auth',NULL,'::1','2026-05-14 14:43:54'),(31,2,'login','auth',NULL,'::1','2026-05-14 14:44:08'),(32,2,'login','auth',NULL,'::1','2026-05-14 15:16:14'),(33,3,'login','auth',NULL,'127.0.0.1','2026-05-15 19:17:18'),(34,1,'login','auth',NULL,'::1','2026-05-15 19:18:11'),(35,1,'login','auth',NULL,'::1','2026-05-17 10:01:50'),(36,1,'login','auth',NULL,'::1','2026-05-17 10:28:05'),(37,1,'login','auth',NULL,'::1','2026-05-17 10:39:27'),(38,1,'login','auth',NULL,'::1','2026-05-17 10:43:16'),(39,1,'logout','auth',NULL,'::1','2026-05-17 10:48:22'),(40,1,'login','auth',NULL,'::1','2026-05-17 10:48:35'),(41,1,'login','auth',NULL,'::1','2026-05-17 10:50:16'),(42,1,'login','auth',NULL,'::1','2026-05-24 12:59:02'),(43,1,'login','auth',NULL,'::1','2026-05-24 12:59:07'),(44,1,'logout','auth',NULL,'::1','2026-05-24 12:59:07'),(45,1,'login','auth',NULL,'::1','2026-05-24 12:59:31'),(46,1,'login','auth',NULL,'::1','2026-05-24 12:59:36'),(47,1,'login','auth',NULL,'::1','2026-05-24 12:59:40'),(48,1,'login','auth',NULL,'::1','2026-05-24 12:59:44'),(49,1,'login','auth',NULL,'::1','2026-05-24 12:59:52'),(50,1,'login','auth',NULL,'::1','2026-05-24 12:59:57'),(51,1,'login','auth',NULL,'::1','2026-05-24 13:00:02'),(52,1,'login','auth',NULL,'::1','2026-05-24 13:00:06'),(53,1,'login','auth',NULL,'::1','2026-05-24 13:00:12'),(54,1,'login','auth',NULL,'::1','2026-05-24 13:00:16'),(55,1,'login','auth',NULL,'::1','2026-05-24 13:00:21'),(56,1,'login','auth',NULL,'::1','2026-05-24 13:01:07'),(57,1,'login','auth',NULL,'::1','2026-05-24 13:01:12'),(58,1,'login','auth',NULL,'::1','2026-05-24 13:01:17'),(59,1,'login','auth',NULL,'::1','2026-05-24 13:01:23'),(60,1,'login','auth',NULL,'::1','2026-05-24 13:01:27'),(61,1,'login','auth',NULL,'::1','2026-05-24 13:01:31'),(62,1,'login','auth',NULL,'::1','2026-05-24 13:01:36'),(63,1,'login','auth',NULL,'::1','2026-05-24 13:01:40'),(64,1,'login','auth',NULL,'::1','2026-05-24 13:01:44'),(65,1,'login','auth',NULL,'::1','2026-05-24 13:01:49'),(66,1,'login','auth',NULL,'::1','2026-05-24 13:01:53'),(67,1,'login','auth',NULL,'::1','2026-05-24 13:01:58'),(68,1,'login','auth',NULL,'::1','2026-05-24 13:02:06'),(69,1,'login','auth',NULL,'::1','2026-05-24 13:02:10'),(70,1,'login','auth',NULL,'::1','2026-05-24 13:02:35'),(71,1,'login','auth',NULL,'::1','2026-05-24 13:02:39'),(72,1,'login','auth',NULL,'::1','2026-05-24 13:02:43'),(73,1,'login','auth',NULL,'::1','2026-05-24 13:02:47'),(74,1,'login','auth',NULL,'::1','2026-05-24 13:02:51'),(75,1,'login','auth',NULL,'::1','2026-05-24 13:02:54'),(76,1,'login','auth',NULL,'::1','2026-05-24 13:02:57'),(77,1,'login','auth',NULL,'::1','2026-05-24 13:03:01'),(78,1,'login','auth',NULL,'::1','2026-05-24 13:03:05'),(79,1,'login','auth',NULL,'::1','2026-05-24 13:03:08'),(80,1,'login','auth',NULL,'::1','2026-05-24 13:03:12'),(81,1,'login','auth',NULL,'::1','2026-05-24 13:03:16'),(82,1,'login','auth',NULL,'::1','2026-05-24 13:03:19'),(83,1,'login','auth',NULL,'::1','2026-05-24 13:03:28'),(84,1,'login','auth',NULL,'::1','2026-05-24 13:03:32'),(85,1,'login','auth',NULL,'::1','2026-05-24 13:03:35'),(86,1,'login','auth',NULL,'::1','2026-05-24 13:03:39'),(87,1,'login','auth',NULL,'::1','2026-05-24 13:05:35'),(88,1,'login','auth',NULL,'::1','2026-05-24 13:19:31'),(89,1,'login','auth',NULL,'::1','2026-05-24 13:19:38'),(90,1,'login','auth',NULL,'::1','2026-05-24 13:21:30'),(91,1,'login','auth',NULL,'::1','2026-05-24 13:21:34'),(92,1,'login','auth',NULL,'::1','2026-05-24 13:24:46'),(93,1,'login','auth',NULL,'::1','2026-05-24 13:25:52'),(94,1,'login','auth',NULL,'::1','2026-05-24 13:27:06'),(95,1,'login','auth',NULL,'::1','2026-05-24 13:37:37'),(96,1,'login','auth',NULL,'::1','2026-05-24 13:38:51'),(97,1,'login','auth',NULL,'::1','2026-05-24 14:52:20'),(98,1,'login','auth',NULL,'::1','2026-05-24 15:02:54'),(99,1,'logout','auth',NULL,'::1','2026-05-24 15:12:55'),(100,1,'login','auth',NULL,'::1','2026-05-24 15:14:01'),(101,1,'logout','auth',NULL,'::1','2026-05-24 15:14:34'),(102,5,'login','auth',NULL,'::1','2026-05-24 15:14:51'),(103,1,'login','auth',NULL,'::1','2026-05-24 18:10:00'),(104,1,'logout','auth',NULL,'::1','2026-05-24 18:10:56'),(105,5,'login','auth',NULL,'::1','2026-05-24 18:11:06'),(106,1,'login','auth',NULL,'::1','2026-05-24 18:30:05'),(107,1,'logout','auth',NULL,'::1','2026-05-24 18:30:28'),(108,1,'login','auth',NULL,'::1','2026-05-24 18:31:48'),(109,1,'logout','auth',NULL,'::1','2026-05-24 18:32:19'),(110,5,'login','auth',NULL,'::1','2026-05-24 18:32:52'),(111,5,'logout','auth',NULL,'::1','2026-05-24 18:45:00'),(112,1,'login','auth',NULL,'::1','2026-05-24 18:45:24'),(113,1,'login','auth',NULL,'::1','2026-05-26 09:31:39'),(114,7,'login','auth',NULL,'127.0.0.1','2026-05-26 09:40:04'),(115,1,'login','auth',NULL,'127.0.0.1','2026-05-26 10:34:34'),(116,1,'Updated ID 1 in users','profile','{\"changes\": {\"bio\": {\"new\": \"Giver Never Lack\", \"old\": null}, \"city\": {\"new\": \"Kano\", \"old\": null}, \"phone\": {\"new\": \"09020439378\", \"old\": null}, \"avatar\": {\"new\": \"avatar_1_1779796831.jpg\", \"old\": null}, \"gender\": {\"new\": \"male\", \"old\": null}, \"country\": {\"new\": \"Nigeria\", \"old\": null}, \"username\": {\"new\": \"Mai mota\", \"old\": null}, \"last_name\": {\"new\": \"Yababa\", \"old\": \"Admin\"}, \"first_name\": {\"new\": \"Abubakar\", \"old\": \"Super\"}, \"date_of_birth\": {\"new\": \"2024-04-02\", \"old\": null}}, \"target_id\": 1}','127.0.0.1','2026-05-26 12:00:31'),(117,1,'Updated ID 1 in users','profile','{\"changes\": {\"bio\": {\"new\": \"Test bio\", \"old\": \"Giver Never Lack\"}, \"city\": {\"new\": \"Lagos\", \"old\": \"Kano\"}, \"phone\": {\"new\": \"12345\", \"old\": \"09020439378\"}, \"gender\": {\"new\": null, \"old\": \"male\"}, \"username\": {\"new\": \"admin_test\", \"old\": \"Mai mota\"}, \"last_name\": {\"new\": \"Admin\", \"old\": \"Yababa\"}, \"first_name\": {\"new\": \"Super\", \"old\": \"Abubakar\"}, \"date_of_birth\": {\"new\": null, \"old\": \"2024-04-02\"}}, \"target_id\": 1}',NULL,'2026-05-26 12:04:39'),(118,1,'Updated ID 1 in users','profile','{\"changes\": {\"bio\": {\"new\": \"Testing\", \"old\": \"Test bio\"}, \"city\": {\"new\": \"Kano\", \"old\": \"Lagos\"}, \"phone\": {\"new\": \"09020439378\", \"old\": \"12345\"}, \"avatar\": {\"new\": \"avatar_1_1779797867.jpg\", \"old\": \"avatar_1_1779796831.jpg\"}, \"gender\": {\"new\": \"male\", \"old\": null}, \"username\": {\"new\": \"Mai mota\", \"old\": \"admin_test\"}, \"last_name\": {\"new\": \"Yababa\", \"old\": \"Admin\"}, \"first_name\": {\"new\": \"Abubakar\", \"old\": \"Super\"}, \"date_of_birth\": {\"new\": \"2026-05-22\", \"old\": null}}, \"target_id\": 1}','127.0.0.1','2026-05-26 12:17:47'),(119,1,'logout','auth',NULL,'127.0.0.1','2026-05-26 13:06:23'),(120,6,'logout','auth',NULL,'127.0.0.1','2026-05-26 13:07:19'),(121,1,'Updated role settings for ID 2','roles','{\"is_active\": 1, \"is_public\": 1, \"display_name\": \"Principal\", \"vacancy_open\": 0, \"required_fields\": \"[\\\"section_id\\\",\\\"qualification\\\",\\\"department\\\",\\\"gender\\\",\\\"dob\\\"]\"}','127.0.0.1','2026-05-26 13:13:11'),(122,1,'Updated role settings for ID 2','roles','{\"is_active\": 1, \"is_public\": 1, \"display_name\": \"Principal\", \"vacancy_open\": 1, \"required_fields\": \"[\\\"section_id\\\",\\\"qualification\\\",\\\"department\\\",\\\"gender\\\",\\\"dob\\\"]\"}','127.0.0.1','2026-05-26 13:13:53'),(123,1,'Updated role settings for ID 6','roles','{\"is_active\": 1, \"is_public\": 0, \"display_name\": \"Parent\", \"vacancy_open\": 1, \"required_fields\": \"[]\"}','127.0.0.1','2026-05-26 13:26:49'),(124,1,'Updated role settings for ID 6','roles','{\"is_active\": 1, \"is_public\": 1, \"display_name\": \"Parent\", \"vacancy_open\": 1, \"required_fields\": \"[\\\"parent_name\\\",\\\"parent_phone\\\"]\"}','127.0.0.1','2026-05-26 13:27:32'),(125,1,'Settings updated: tab=notifications','settings',NULL,'127.0.0.1','2026-05-26 14:15:11'),(126,12,'login','auth',NULL,'127.0.0.1','2026-05-26 14:18:37'),(127,12,'logout','auth',NULL,'127.0.0.1','2026-05-26 14:18:49'),(128,12,'login','auth',NULL,'127.0.0.1','2026-05-26 14:18:53'),(129,12,'logout','auth',NULL,'127.0.0.1','2026-05-26 14:19:14'),(130,1,'login','auth',NULL,'127.0.0.1','2026-05-26 14:45:51'),(131,1,'Settings updated: tab=notifications','settings',NULL,'127.0.0.1','2026-05-26 14:46:49'),(132,1,'Settings updated: tab=notifications','settings',NULL,'127.0.0.1','2026-05-26 14:47:14'),(133,1,'login','auth',NULL,'::1','2026-05-26 15:41:38'),(134,1,'login','auth',NULL,'127.0.0.1','2026-05-27 12:38:32'),(135,2,'login','auth',NULL,'::1','2026-05-27 13:22:34'),(136,1,'Created new user manually','users','{\"email\": \"mm@gmail.com\", \"role_id\": 20, \"user_id\": 17}','127.0.0.1','2026-05-27 14:00:50'),(137,1,'logout','auth',NULL,'127.0.0.1','2026-05-27 14:01:18'),(138,17,'login','auth',NULL,'127.0.0.1','2026-05-27 14:01:25'),(139,17,'logout','auth',NULL,'127.0.0.1','2026-05-27 14:08:12'),(140,1,'login','auth',NULL,'127.0.0.1','2026-05-27 14:08:19'),(141,17,'login','auth',NULL,'::1','2026-05-27 14:14:45'),(142,17,'logout','auth',NULL,'::1','2026-05-27 14:46:15'),(143,17,'login','auth',NULL,'::1','2026-05-27 14:46:41'),(144,2,'login','auth',NULL,'::1','2026-05-27 14:47:34'),(145,17,'logout','auth',NULL,'::1','2026-05-27 14:52:28'),(146,17,'login','auth',NULL,'::1','2026-05-27 14:52:36'),(147,17,'logout','auth',NULL,'::1','2026-05-27 15:09:56'),(148,17,'login','auth',NULL,'::1','2026-05-27 15:10:40'),(149,2,'logout','auth',NULL,'::1','2026-05-27 15:40:23'),(150,2,'login','auth',NULL,'::1','2026-05-27 15:40:27'),(151,1,'login','auth',NULL,'127.0.0.1','2026-05-27 16:05:32'),(152,1,'logout','auth',NULL,'127.0.0.1','2026-05-27 16:05:59'),(153,1,'login','auth',NULL,'127.0.0.1','2026-05-27 16:06:46'),(154,5,'login','auth',NULL,'127.0.0.1','2026-05-27 16:07:26'),(155,2,'login','auth',NULL,'::1','2026-05-27 16:44:13'),(156,17,'login','auth',NULL,'::1','2026-05-27 16:48:13'),(157,17,'logout','auth',NULL,'::1','2026-05-27 16:56:34'),(158,173,'login','auth',NULL,'::1','2026-05-27 16:56:46'),(159,5,'login','auth',NULL,'127.0.0.1','2026-05-31 09:02:30'),(160,5,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:02:44'),(161,2,'login','auth',NULL,'::1','2026-05-31 09:04:02'),(162,2,'logout','auth',NULL,'::1','2026-05-31 09:04:30'),(163,173,'login','auth',NULL,'::1','2026-05-31 09:04:45'),(164,1,'login','auth',NULL,'127.0.0.1','2026-05-31 09:12:29'),(165,1,'login','auth',NULL,'::1','2026-05-31 09:19:04'),(166,1,'login','auth',NULL,'::1','2026-05-31 09:19:09'),(167,1,'logout','auth',NULL,'::1','2026-05-31 09:19:10'),(168,1,'login','auth',NULL,'::1','2026-05-31 09:19:15'),(169,1,'login','auth',NULL,'::1','2026-05-31 09:19:19'),(170,1,'login','auth',NULL,'::1','2026-05-31 09:19:23'),(171,1,'login','auth',NULL,'::1','2026-05-31 09:19:27'),(172,1,'login','auth',NULL,'::1','2026-05-31 09:19:33'),(173,1,'Settings updated: tab=school','settings',NULL,'::1','2026-05-31 09:19:35'),(174,1,'login','auth',NULL,'::1','2026-05-31 09:19:38'),(175,1,'login','auth',NULL,'::1','2026-05-31 09:19:43'),(176,1,'login','auth',NULL,'::1','2026-05-31 09:19:48'),(177,1,'login','auth',NULL,'::1','2026-05-31 09:20:00'),(178,1,'login','auth',NULL,'::1','2026-05-31 09:20:15'),(179,1,'login','auth',NULL,'::1','2026-05-31 09:20:20'),(180,1,'login','auth',NULL,'::1','2026-05-31 09:20:26'),(181,1,'login','auth',NULL,'::1','2026-05-31 09:20:31'),(182,1,'login','auth',NULL,'::1','2026-05-31 09:20:35'),(183,1,'login','auth',NULL,'::1','2026-05-31 09:20:40'),(184,1,'login','auth',NULL,'::1','2026-05-31 09:20:44'),(185,1,'login','auth',NULL,'::1','2026-05-31 09:20:49'),(186,1,'login','auth',NULL,'::1','2026-05-31 09:20:54'),(187,1,'login','auth',NULL,'::1','2026-05-31 09:20:58'),(188,1,'login','auth',NULL,'::1','2026-05-31 09:21:03'),(189,1,'login','auth',NULL,'::1','2026-05-31 09:21:07'),(190,1,'login','auth',NULL,'::1','2026-05-31 09:21:11'),(191,1,'login','auth',NULL,'::1','2026-05-31 09:21:15'),(192,1,'login','auth',NULL,'::1','2026-05-31 09:21:20'),(193,1,'login','auth',NULL,'::1','2026-05-31 09:21:24'),(194,1,'login','auth',NULL,'::1','2026-05-31 09:21:29'),(195,1,'login','auth',NULL,'::1','2026-05-31 09:21:34'),(196,1,'login','auth',NULL,'::1','2026-05-31 09:21:39'),(197,1,'login','auth',NULL,'::1','2026-05-31 09:21:44'),(198,1,'login','auth',NULL,'::1','2026-05-31 09:21:48'),(199,1,'login','auth',NULL,'::1','2026-05-31 09:21:53'),(200,1,'login','auth',NULL,'::1','2026-05-31 09:21:57'),(201,1,'login','auth',NULL,'::1','2026-05-31 09:22:02'),(202,1,'login','auth',NULL,'::1','2026-05-31 09:22:07'),(203,1,'login','auth',NULL,'::1','2026-05-31 09:22:11'),(204,1,'login','auth',NULL,'::1','2026-05-31 09:22:15'),(205,1,'login','auth',NULL,'::1','2026-05-31 09:22:25'),(206,1,'login','auth',NULL,'::1','2026-05-31 09:22:29'),(207,1,'login','auth',NULL,'::1','2026-05-31 09:22:33'),(208,1,'login','auth',NULL,'::1','2026-05-31 09:22:38'),(209,1,'login','auth',NULL,'::1','2026-05-31 09:22:43'),(210,1,'login','auth',NULL,'::1','2026-05-31 09:22:50'),(211,1,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:27:26'),(212,17,'login','auth',NULL,'127.0.0.1','2026-05-31 09:27:39'),(213,17,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:30:32'),(214,17,'login','auth',NULL,'127.0.0.1','2026-05-31 09:31:10'),(215,17,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:31:15'),(216,5,'login','auth',NULL,'127.0.0.1','2026-05-31 09:31:21'),(217,5,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:42:07'),(218,1,'login','auth',NULL,'127.0.0.1','2026-05-31 09:42:10'),(219,1,'Created new user manually','users','{\"email\": \"auta@gmail.com\", \"role_id\": 4, \"user_id\": 175}','127.0.0.1','2026-05-31 09:45:40'),(220,1,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:45:51'),(221,175,'login','auth',NULL,'127.0.0.1','2026-05-31 09:45:58'),(222,175,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:46:54'),(223,5,'login','auth',NULL,'127.0.0.1','2026-05-31 09:47:01'),(224,5,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:47:04'),(225,17,'login','auth',NULL,'127.0.0.1','2026-05-31 09:47:11'),(226,17,'logout','auth',NULL,'127.0.0.1','2026-05-31 09:47:44'),(227,17,'login','auth',NULL,'192.168.100.18','2026-05-31 10:10:07'),(228,1,'login','auth',NULL,'127.0.0.1','2026-05-31 16:17:06'),(229,178,'login','auth',NULL,'192.168.100.18','2026-05-31 16:47:56'),(230,NULL,'logout','auth',NULL,'::1','2026-05-31 16:54:59'),(231,1,'login','auth',NULL,'::1','2026-05-31 16:55:13'),(232,1,'logout','auth',NULL,'127.0.0.1','2026-05-31 16:55:26'),(233,178,'logout','auth',NULL,'192.168.100.18','2026-05-31 16:55:48'),(234,178,'login','auth',NULL,'192.168.100.18','2026-05-31 16:57:26'),(235,178,'logout','auth',NULL,'192.168.100.18','2026-05-31 16:57:40'),(236,1,'login','auth',NULL,'127.0.0.1','2026-05-31 17:03:38'),(237,1,'Updated ID 179 in users','users','{\"changes\": {\"role_id\": {\"new\": null, \"old\": 7}, \"section_id\": {\"new\": null, \"old\": 2}, \"password_hash\": {\"new\": \"$2y$10$vbduaN7SCHrrxFX5tUWbnuYobI/LqCF10TKIYHFjEoBGEFPbAr3oa\", \"old\": \"$2y$10$fQHXRcuA5fv/iEFKTjbrzef6tDkWvEM50N.x3a1WYnIpfMBTDua3i\"}}, \"target_id\": 179}','::1','2026-05-31 17:05:37'),(238,179,'login','auth',NULL,'192.168.100.18','2026-05-31 17:06:37'),(239,179,'logout','auth',NULL,'192.168.100.18','2026-05-31 17:19:55'),(240,180,'login','auth',NULL,'192.168.100.18','2026-05-31 17:20:41'),(241,180,'logout','auth',NULL,'192.168.100.18','2026-05-31 17:23:19'),(242,180,'login','auth',NULL,'192.168.100.18','2026-05-31 17:23:26'),(243,1,'logout','auth',NULL,'127.0.0.1','2026-05-31 17:28:37'),(244,17,'login','auth',NULL,'127.0.0.1','2026-05-31 17:28:48'),(245,17,'logout','auth',NULL,'127.0.0.1','2026-05-31 17:37:43'),(246,17,'login','auth',NULL,'127.0.0.1','2026-05-31 17:37:48'),(247,180,'login','auth',NULL,'192.168.100.18','2026-05-31 18:31:51'),(248,180,'logout','auth',NULL,'192.168.100.18','2026-05-31 18:34:25'),(249,158,'login','auth',NULL,'192.168.100.18','2026-05-31 18:34:28'),(250,1,'Settings updated: tab=school','settings',NULL,'::1','2026-05-31 18:39:39'),(251,158,'logout','auth',NULL,'192.168.100.18','2026-05-31 18:41:19'),(252,1,'Settings updated: tab=school','settings',NULL,'::1','2026-05-31 18:41:47'),(253,5,'login','auth',NULL,'127.0.0.1','2026-06-14 17:04:22'),(254,5,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:04:49'),(255,175,'login','auth',NULL,'127.0.0.1','2026-06-14 17:05:05'),(256,175,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:06:46'),(257,6,'login','auth',NULL,'127.0.0.1','2026-06-14 17:07:04'),(258,6,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:07:11'),(259,8,'login','auth',NULL,'127.0.0.1','2026-06-14 17:07:20'),(260,8,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:07:24'),(261,17,'login','auth',NULL,'127.0.0.1','2026-06-14 17:07:41'),(262,17,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:33:21'),(263,1,'login','auth',NULL,'127.0.0.1','2026-06-14 17:34:55'),(264,1,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:36:34'),(265,5,'login','auth',NULL,'127.0.0.1','2026-06-14 17:36:38'),(266,5,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:37:10'),(267,6,'login','auth',NULL,'127.0.0.1','2026-06-14 17:37:34'),(268,6,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:37:39'),(269,8,'login','auth',NULL,'127.0.0.1','2026-06-14 17:37:48'),(270,8,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:38:12'),(271,17,'login','auth',NULL,'127.0.0.1','2026-06-14 17:38:17'),(272,17,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:40:18'),(273,24,'login','auth',NULL,'127.0.0.1','2026-06-14 17:40:23'),(274,24,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:41:16'),(275,17,'login','auth',NULL,'127.0.0.1','2026-06-14 17:41:43'),(276,17,'logout','auth',NULL,'127.0.0.1','2026-06-14 17:47:20'),(277,17,'login','auth',NULL,'127.0.0.1','2026-06-14 17:47:27'),(278,1,'login','auth',NULL,'127.0.0.1','2026-06-15 10:07:44'),(279,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-15 10:08:04'),(280,1,'logout','auth',NULL,'127.0.0.1','2026-06-15 10:13:19'),(281,24,'login','auth',NULL,'127.0.0.1','2026-06-15 10:16:57'),(282,1,'login','auth',NULL,'::1','2026-06-15 14:21:49'),(283,1,'login','auth',NULL,'::1','2026-06-15 14:21:54'),(284,1,'logout','auth',NULL,'::1','2026-06-15 14:21:56'),(285,1,'login','auth',NULL,'::1','2026-06-15 14:22:03'),(286,1,'login','auth',NULL,'::1','2026-06-15 14:22:08'),(287,1,'login','auth',NULL,'::1','2026-06-15 14:22:13'),(288,1,'login','auth',NULL,'::1','2026-06-15 14:22:20'),(289,1,'login','auth',NULL,'::1','2026-06-15 14:22:26'),(290,1,'Settings updated: tab=school','settings',NULL,'::1','2026-06-15 14:22:28'),(291,1,'login','auth',NULL,'::1','2026-06-15 14:22:32'),(292,1,'login','auth',NULL,'::1','2026-06-15 14:22:37'),(293,1,'login','auth',NULL,'::1','2026-06-15 14:22:43'),(294,1,'login','auth',NULL,'::1','2026-06-15 14:22:49'),(295,1,'login','auth',NULL,'::1','2026-06-15 14:22:55'),(296,1,'login','auth',NULL,'::1','2026-06-15 14:23:00'),(297,1,'login','auth',NULL,'::1','2026-06-15 14:23:07'),(298,1,'login','auth',NULL,'::1','2026-06-15 14:23:12'),(299,1,'login','auth',NULL,'::1','2026-06-15 14:23:17'),(300,1,'login','auth',NULL,'::1','2026-06-15 14:23:22'),(301,1,'login','auth',NULL,'::1','2026-06-15 14:23:28'),(302,1,'login','auth',NULL,'::1','2026-06-15 14:23:34'),(303,1,'login','auth',NULL,'::1','2026-06-15 14:23:39'),(304,1,'login','auth',NULL,'::1','2026-06-15 14:23:44'),(305,1,'login','auth',NULL,'::1','2026-06-15 14:23:49'),(306,1,'login','auth',NULL,'::1','2026-06-15 14:23:53'),(307,1,'login','auth',NULL,'::1','2026-06-15 14:23:59'),(308,1,'login','auth',NULL,'::1','2026-06-15 14:24:03'),(309,1,'login','auth',NULL,'::1','2026-06-15 14:24:08'),(310,1,'login','auth',NULL,'::1','2026-06-15 14:24:13'),(311,1,'login','auth',NULL,'::1','2026-06-15 14:24:17'),(312,1,'login','auth',NULL,'::1','2026-06-15 14:24:25'),(313,1,'login','auth',NULL,'::1','2026-06-15 14:24:30'),(314,1,'login','auth',NULL,'::1','2026-06-15 14:24:35'),(315,1,'login','auth',NULL,'::1','2026-06-15 14:24:41'),(316,1,'login','auth',NULL,'::1','2026-06-15 14:24:46'),(317,1,'login','auth',NULL,'::1','2026-06-15 14:24:52'),(318,1,'login','auth',NULL,'::1','2026-06-15 14:24:56'),(319,1,'login','auth',NULL,'::1','2026-06-15 14:25:01'),(320,1,'login','auth',NULL,'::1','2026-06-15 14:25:07'),(321,1,'login','auth',NULL,'::1','2026-06-15 14:25:13'),(322,1,'login','auth',NULL,'::1','2026-06-15 14:25:24'),(323,1,'login','auth',NULL,'::1','2026-06-15 14:25:29'),(324,1,'login','auth',NULL,'::1','2026-06-15 14:25:34'),(325,1,'login','auth',NULL,'::1','2026-06-15 14:25:39'),(326,1,'login','auth',NULL,'::1','2026-06-15 14:25:44'),(327,1,'login','auth',NULL,'::1','2026-06-15 14:25:49'),(328,1,'login','auth',NULL,'127.0.0.1','2026-06-15 15:40:41'),(329,1,'logout','auth',NULL,'127.0.0.1','2026-06-15 15:48:14'),(330,17,'login','auth',NULL,'127.0.0.1','2026-06-15 15:48:55'),(331,17,'logout','auth',NULL,'127.0.0.1','2026-06-15 15:49:01'),(332,1,'login','auth',NULL,'127.0.0.1','2026-06-15 15:49:15'),(333,17,'login','auth',NULL,'127.0.0.1','2026-06-16 09:10:26'),(334,17,'logout','auth',NULL,'127.0.0.1','2026-06-16 09:10:39'),(335,1,'login','auth',NULL,'127.0.0.1','2026-06-16 09:10:56'),(336,1,'login','auth',NULL,'127.0.0.1','2026-06-16 10:46:12'),(337,1,'login','auth',NULL,'127.0.0.1','2026-06-16 15:41:53'),(338,1,'login','auth',NULL,'127.0.0.1','2026-06-16 15:53:08'),(339,1,'login','auth',NULL,'127.0.0.1','2026-06-18 12:30:37'),(340,1,'logout','auth',NULL,'127.0.0.1','2026-06-18 12:33:00'),(341,17,'login','auth',NULL,'127.0.0.1','2026-06-18 12:33:08'),(342,1,'login','auth',NULL,'127.0.0.1','2026-06-21 10:23:38'),(343,1,'logout','auth',NULL,'127.0.0.1','2026-06-21 11:38:26'),(344,1,'login','auth',NULL,'127.0.0.1','2026-06-21 11:39:13'),(345,1,'logout','auth',NULL,'127.0.0.1','2026-06-21 11:47:16'),(346,1,'login','auth',NULL,'127.0.0.1','2026-06-21 11:47:26'),(347,1,'Created new user manually','users','{\"email\": \"fh@gmail.com\", \"user_id\": 181, \"role_ids\": [\"25\"]}','127.0.0.1','2026-06-21 11:53:23'),(348,1,'logout','auth',NULL,'127.0.0.1','2026-06-21 11:56:42'),(349,181,'login','auth',NULL,'127.0.0.1','2026-06-21 11:56:49'),(350,181,'logout','auth',NULL,'127.0.0.1','2026-06-21 12:06:18'),(351,1,'login','auth',NULL,'127.0.0.1','2026-06-21 12:06:23'),(352,1,'logout','auth',NULL,'127.0.0.1','2026-06-21 12:08:25'),(353,24,'login','auth',NULL,'127.0.0.1','2026-06-21 12:08:30'),(354,24,'logout','auth',NULL,'127.0.0.1','2026-06-21 12:08:40'),(355,5,'login','auth',NULL,'127.0.0.1','2026-06-21 12:08:46'),(356,5,'logout','auth',NULL,'127.0.0.1','2026-06-21 12:08:51'),(357,6,'login','auth',NULL,'127.0.0.1','2026-06-21 12:08:58'),(358,6,'logout','auth',NULL,'127.0.0.1','2026-06-21 12:09:20'),(359,181,'login','auth',NULL,'127.0.0.1','2026-06-21 12:09:25'),(360,1,'login','auth',NULL,'::1','2026-06-21 14:57:22'),(361,1,'login','auth',NULL,'::1','2026-06-21 14:57:28'),(362,1,'logout','auth',NULL,'::1','2026-06-21 14:57:30'),(363,1,'login','auth',NULL,'::1','2026-06-21 14:58:01'),(364,1,'login','auth',NULL,'::1','2026-06-21 14:58:08'),(365,1,'login','auth',NULL,'::1','2026-06-21 14:58:13'),(366,1,'logout','auth',NULL,'::1','2026-06-21 14:58:15'),(367,1,'login','auth',NULL,'::1','2026-06-21 14:58:20'),(368,1,'login','auth',NULL,'::1','2026-06-21 14:58:26'),(369,1,'login','auth',NULL,'::1','2026-06-21 14:58:30'),(370,1,'login','auth',NULL,'::1','2026-06-21 14:58:35'),(371,1,'login','auth',NULL,'::1','2026-06-21 14:58:48'),(372,1,'Settings updated: tab=school','settings',NULL,'::1','2026-06-21 14:58:51'),(373,1,'login','auth',NULL,'::1','2026-06-21 14:58:55'),(374,1,'login','auth',NULL,'::1','2026-06-21 14:59:00'),(375,1,'login','auth',NULL,'::1','2026-06-21 14:59:08'),(376,1,'login','auth',NULL,'::1','2026-06-21 14:59:15'),(377,1,'login','auth',NULL,'::1','2026-06-21 14:59:22'),(378,1,'login','auth',NULL,'::1','2026-06-21 14:59:28'),(379,1,'login','auth',NULL,'::1','2026-06-21 14:59:35'),(380,1,'login','auth',NULL,'::1','2026-06-21 14:59:40'),(381,1,'login','auth',NULL,'::1','2026-06-21 14:59:46'),(382,1,'login','auth',NULL,'::1','2026-06-21 14:59:51'),(383,1,'login','auth',NULL,'::1','2026-06-21 14:59:59'),(384,1,'login','auth',NULL,'::1','2026-06-21 15:00:04'),(385,1,'login','auth',NULL,'::1','2026-06-21 15:00:15'),(386,1,'login','auth',NULL,'::1','2026-06-21 15:00:20'),(387,1,'login','auth',NULL,'::1','2026-06-21 15:00:26'),(388,1,'login','auth',NULL,'::1','2026-06-21 15:00:33'),(389,1,'login','auth',NULL,'::1','2026-06-21 15:00:41'),(390,1,'login','auth',NULL,'::1','2026-06-21 15:00:46'),(391,1,'login','auth',NULL,'::1','2026-06-21 15:00:50'),(392,1,'login','auth',NULL,'::1','2026-06-21 15:00:55'),(393,1,'login','auth',NULL,'::1','2026-06-21 15:00:59'),(394,1,'login','auth',NULL,'::1','2026-06-21 15:01:04'),(395,1,'login','auth',NULL,'::1','2026-06-21 15:01:08'),(396,1,'login','auth',NULL,'::1','2026-06-21 15:01:12'),(397,1,'login','auth',NULL,'::1','2026-06-21 15:01:16'),(398,1,'login','auth',NULL,'::1','2026-06-21 15:01:20'),(399,1,'login','auth',NULL,'::1','2026-06-21 15:01:24'),(400,1,'login','auth',NULL,'::1','2026-06-21 15:01:29'),(401,1,'login','auth',NULL,'::1','2026-06-21 15:01:33'),(402,1,'login','auth',NULL,'::1','2026-06-21 15:01:37'),(403,1,'login','auth',NULL,'::1','2026-06-21 15:01:42'),(404,1,'login','auth',NULL,'::1','2026-06-21 15:01:52'),(405,1,'login','auth',NULL,'::1','2026-06-21 15:01:56'),(406,1,'login','auth',NULL,'::1','2026-06-21 15:02:01'),(407,1,'login','auth',NULL,'::1','2026-06-21 15:02:07'),(408,1,'login','auth',NULL,'::1','2026-06-21 15:02:12'),(409,1,'login','auth',NULL,'::1','2026-06-21 15:02:16'),(410,181,'login','auth',NULL,'127.0.0.1','2026-06-21 15:02:46'),(411,1,'login','auth',NULL,'127.0.0.1','2026-06-24 10:59:06'),(412,1,'login','auth',NULL,'::1','2026-06-24 12:23:07'),(413,1,'login','auth',NULL,'::1','2026-06-24 12:23:11'),(414,1,'login','auth',NULL,'::1','2026-06-24 12:23:12'),(415,1,'login','auth',NULL,'::1','2026-06-24 12:23:17'),(416,1,'login','auth',NULL,'::1','2026-06-24 12:23:21'),(417,1,'login','auth',NULL,'::1','2026-06-24 12:23:31'),(418,1,'login','auth',NULL,'::1','2026-06-24 12:23:43'),(419,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 12:25:29'),(420,1,'login','auth',NULL,'127.0.0.1','2026-06-24 12:27:01'),(421,1,'login','auth',NULL,'::1','2026-06-24 12:30:37'),(422,1,'login','auth',NULL,'::1','2026-06-24 12:30:43'),(423,1,'login','auth',NULL,'::1','2026-06-24 12:30:56'),(424,1,'login','auth',NULL,'::1','2026-06-24 12:31:27'),(425,1,'login','auth',NULL,'::1','2026-06-24 12:31:39'),(426,1,'login','auth',NULL,'::1','2026-06-24 12:38:10'),(427,1,'Updated ID 1 in users','profile','{\"changes\": {\"bio\": {\"new\": null, \"old\": \"Testing\"}, \"city\": {\"new\": null, \"old\": \"Kano\"}, \"phone\": {\"new\": null, \"old\": \"09020439378\"}, \"gender\": {\"new\": null, \"old\": \"male\"}, \"country\": {\"new\": null, \"old\": \"Nigeria\"}, \"username\": {\"new\": null, \"old\": \"Mai mota\"}, \"last_name\": {\"new\": \"Admin\", \"old\": \"Yababa\"}, \"first_name\": {\"new\": \"Super\", \"old\": \"Abubakar\"}, \"date_of_birth\": {\"new\": null, \"old\": \"2026-05-22\"}}, \"target_id\": 1}','::1','2026-06-24 12:38:20'),(428,1,'login','auth',NULL,'192.168.100.12','2026-06-24 12:52:33'),(429,181,'login','auth',NULL,'127.0.0.1','2026-06-24 13:32:48'),(430,181,'logout','auth',NULL,'127.0.0.1','2026-06-24 13:33:03'),(431,1,'login','auth',NULL,'127.0.0.1','2026-06-24 13:33:11'),(432,182,'login','auth',NULL,'192.168.100.32','2026-06-24 13:35:22'),(433,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 13:39:32'),(434,6,'login','auth',NULL,'127.0.0.1','2026-06-24 13:39:46'),(435,6,'logout','auth',NULL,'127.0.0.1','2026-06-24 13:39:50'),(436,8,'login','auth',NULL,'127.0.0.1','2026-06-24 13:40:00'),(437,8,'logout','auth',NULL,'127.0.0.1','2026-06-24 13:40:09'),(438,1,'login','auth',NULL,'127.0.0.1','2026-06-24 13:46:33'),(439,182,'logout','auth',NULL,'192.168.100.32','2026-06-24 13:48:32'),(440,183,'login','auth',NULL,'192.168.100.32','2026-06-24 13:51:53'),(441,183,'logout','auth',NULL,'192.168.100.32','2026-06-24 14:48:21'),(442,183,'login','auth',NULL,'192.168.100.32','2026-06-24 14:49:25'),(443,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 14:50:15'),(444,17,'login','auth',NULL,'127.0.0.1','2026-06-24 14:50:25'),(445,183,'logout','auth',NULL,'192.168.100.32','2026-06-24 14:58:02'),(446,185,'login','auth',NULL,'192.168.100.32','2026-06-24 14:59:46'),(447,1,'login','auth',NULL,'127.0.0.1','2026-06-24 16:18:40'),(448,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 16:39:57'),(449,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 16:51:26'),(450,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 16:51:37'),(451,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 16:51:53'),(452,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 16:52:10'),(453,1,'login','auth',NULL,'127.0.0.1','2026-06-24 16:52:31'),(454,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 16:52:58'),(455,1,'login','auth',NULL,'127.0.0.1','2026-06-24 16:53:04'),(456,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 17:01:59'),(457,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 17:02:40'),(458,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 17:03:04'),(459,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-06-24 17:03:55'),(460,1,'logout','auth',NULL,'127.0.0.1','2026-06-24 17:05:04'),(461,181,'login','auth',NULL,'127.0.0.1','2026-06-24 17:05:10'),(462,182,'login','auth',NULL,'192.168.100.32','2026-06-24 17:07:38'),(463,182,'logout','auth',NULL,'192.168.100.32','2026-06-24 17:08:06'),(464,185,'login','auth',NULL,'192.168.100.32','2026-06-24 17:08:20'),(465,181,'login','auth',NULL,'127.0.0.1','2026-06-24 17:42:17'),(466,181,'logout','auth',NULL,'127.0.0.1','2026-06-24 18:08:13'),(467,24,'login','auth',NULL,'127.0.0.1','2026-06-24 18:08:19'),(468,181,'login','auth',NULL,'127.0.0.1','2026-06-29 20:23:58'),(469,181,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:26:34'),(470,1,'login','auth',NULL,'127.0.0.1','2026-06-29 20:26:52'),(471,1,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:29:18'),(472,5,'login','auth',NULL,'127.0.0.1','2026-06-29 20:29:25'),(473,5,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:29:33'),(474,17,'login','auth',NULL,'127.0.0.1','2026-06-29 20:30:22'),(475,17,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:30:33'),(476,6,'login','auth',NULL,'127.0.0.1','2026-06-29 20:30:47'),(477,6,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:31:09'),(478,175,'login','auth',NULL,'127.0.0.1','2026-06-29 20:31:46'),(479,175,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:31:53'),(480,5,'login','auth',NULL,'127.0.0.1','2026-06-29 20:31:58'),(481,5,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:34:34'),(482,3,'login','auth',NULL,'127.0.0.1','2026-06-29 20:34:48'),(483,3,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:35:39'),(484,6,'login','auth',NULL,'127.0.0.1','2026-06-29 20:36:06'),(485,6,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:36:13'),(486,1,'login','auth',NULL,'127.0.0.1','2026-06-29 20:37:00'),(487,1,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:45:35'),(488,1,'login','auth',NULL,'127.0.0.1','2026-06-29 20:45:53'),(489,1,'logout','auth',NULL,'127.0.0.1','2026-06-29 20:45:58'),(490,181,'login','auth',NULL,'127.0.0.1','2026-06-29 20:46:05'),(491,1,'login','auth',NULL,'127.0.0.1','2026-06-30 15:47:33'),(492,1,'login','auth',NULL,'::1','2026-06-30 18:02:39'),(493,1,'login','auth',NULL,'::1','2026-06-30 18:02:44'),(494,1,'logout','auth',NULL,'::1','2026-06-30 18:02:46'),(495,1,'login','auth',NULL,'::1','2026-06-30 18:03:03'),(496,1,'login','auth',NULL,'::1','2026-06-30 18:03:09'),(497,1,'login','auth',NULL,'::1','2026-06-30 18:03:15'),(498,1,'logout','auth',NULL,'::1','2026-06-30 18:03:17'),(499,1,'login','auth',NULL,'::1','2026-06-30 18:03:22'),(500,1,'login','auth',NULL,'::1','2026-06-30 18:03:27'),(501,1,'login','auth',NULL,'::1','2026-06-30 18:03:32'),(502,1,'login','auth',NULL,'::1','2026-06-30 18:03:37'),(503,1,'login','auth',NULL,'::1','2026-06-30 18:03:44'),(504,1,'Settings updated: tab=school','settings',NULL,'::1','2026-06-30 18:03:46'),(505,1,'login','auth',NULL,'::1','2026-06-30 18:03:52'),(506,1,'login','auth',NULL,'::1','2026-06-30 18:03:57'),(507,1,'login','auth',NULL,'::1','2026-06-30 18:04:02'),(508,1,'login','auth',NULL,'::1','2026-06-30 18:04:09'),(509,1,'login','auth',NULL,'::1','2026-06-30 18:04:16'),(510,1,'login','auth',NULL,'::1','2026-06-30 18:04:21'),(511,1,'login','auth',NULL,'::1','2026-06-30 18:04:27'),(512,1,'login','auth',NULL,'::1','2026-06-30 18:04:33'),(513,1,'login','auth',NULL,'::1','2026-06-30 18:04:38'),(514,1,'login','auth',NULL,'::1','2026-06-30 18:04:43'),(515,1,'login','auth',NULL,'::1','2026-06-30 18:04:48'),(516,1,'login','auth',NULL,'::1','2026-06-30 18:04:53'),(517,1,'login','auth',NULL,'::1','2026-06-30 18:04:58'),(518,1,'login','auth',NULL,'::1','2026-06-30 18:05:03'),(519,1,'login','auth',NULL,'::1','2026-06-30 18:05:07'),(520,1,'login','auth',NULL,'::1','2026-06-30 18:05:12'),(521,1,'login','auth',NULL,'::1','2026-06-30 18:05:17'),(522,1,'login','auth',NULL,'::1','2026-06-30 18:05:23'),(523,1,'login','auth',NULL,'::1','2026-06-30 18:05:27'),(524,1,'login','auth',NULL,'::1','2026-06-30 18:05:32'),(525,1,'login','auth',NULL,'::1','2026-06-30 18:05:36'),(526,1,'login','auth',NULL,'::1','2026-06-30 18:05:41'),(527,1,'login','auth',NULL,'::1','2026-06-30 18:05:46'),(528,1,'login','auth',NULL,'::1','2026-06-30 18:05:51'),(529,181,'login','auth',NULL,'127.0.0.1','2026-06-30 18:06:07'),(530,1,'login','auth',NULL,'::1','2026-06-30 18:06:11'),(531,1,'login','auth',NULL,'::1','2026-06-30 18:06:18'),(532,1,'login','auth',NULL,'::1','2026-06-30 18:06:23'),(533,1,'logout','auth',NULL,'::1','2026-06-30 18:06:24'),(534,1,'login','auth',NULL,'::1','2026-06-30 18:06:30'),(535,1,'login','auth',NULL,'::1','2026-06-30 18:06:39'),(536,1,'login','auth',NULL,'::1','2026-06-30 18:06:48'),(537,1,'login','auth',NULL,'::1','2026-06-30 18:06:54'),(538,1,'login','auth',NULL,'::1','2026-06-30 18:07:03'),(539,1,'Settings updated: tab=school','settings',NULL,'::1','2026-06-30 18:07:06'),(540,1,'login','auth',NULL,'::1','2026-06-30 18:07:12'),(541,1,'login','auth',NULL,'::1','2026-06-30 18:07:17'),(542,1,'login','auth',NULL,'::1','2026-06-30 18:07:23'),(543,1,'login','auth',NULL,'::1','2026-06-30 18:07:29'),(544,1,'login','auth',NULL,'::1','2026-06-30 18:07:36'),(545,1,'login','auth',NULL,'::1','2026-06-30 18:07:42'),(546,1,'login','auth',NULL,'::1','2026-06-30 18:07:50'),(547,1,'login','auth',NULL,'::1','2026-06-30 18:07:55'),(548,1,'login','auth',NULL,'::1','2026-06-30 18:08:00'),(549,1,'login','auth',NULL,'::1','2026-06-30 18:08:05'),(550,1,'login','auth',NULL,'::1','2026-06-30 18:08:11'),(551,1,'login','auth',NULL,'::1','2026-06-30 18:08:16'),(552,1,'login','auth',NULL,'::1','2026-06-30 18:08:22'),(553,1,'login','auth',NULL,'::1','2026-06-30 18:08:27'),(554,1,'login','auth',NULL,'::1','2026-06-30 18:08:31'),(555,1,'login','auth',NULL,'::1','2026-06-30 18:08:36'),(556,1,'login','auth',NULL,'::1','2026-06-30 18:08:41'),(557,1,'login','auth',NULL,'::1','2026-06-30 18:08:46'),(558,1,'login','auth',NULL,'::1','2026-06-30 18:08:50'),(559,1,'login','auth',NULL,'::1','2026-06-30 18:08:56'),(560,1,'login','auth',NULL,'::1','2026-06-30 18:09:00'),(561,1,'login','auth',NULL,'::1','2026-06-30 18:09:19'),(562,1,'login','auth',NULL,'::1','2026-06-30 18:09:29'),(563,1,'login','auth',NULL,'::1','2026-06-30 18:09:34'),(564,1,'logout','auth',NULL,'::1','2026-06-30 18:09:36'),(565,1,'login','auth',NULL,'::1','2026-06-30 18:09:42'),(566,1,'login','auth',NULL,'::1','2026-06-30 18:09:47'),(567,1,'login','auth',NULL,'::1','2026-06-30 18:09:54'),(568,1,'login','auth',NULL,'::1','2026-06-30 18:10:00'),(569,1,'login','auth',NULL,'::1','2026-06-30 18:10:09'),(570,1,'Settings updated: tab=school','settings',NULL,'::1','2026-06-30 18:10:11'),(571,1,'login','auth',NULL,'::1','2026-06-30 18:10:18'),(572,1,'login','auth',NULL,'::1','2026-06-30 18:10:24'),(573,1,'login','auth',NULL,'::1','2026-06-30 18:10:30'),(574,1,'login','auth',NULL,'::1','2026-06-30 18:10:36'),(575,1,'login','auth',NULL,'::1','2026-06-30 18:10:43'),(576,1,'login','auth',NULL,'::1','2026-06-30 18:10:49'),(577,1,'login','auth',NULL,'::1','2026-06-30 18:10:55'),(578,1,'login','auth',NULL,'::1','2026-06-30 18:11:00'),(579,1,'login','auth',NULL,'::1','2026-06-30 18:11:06'),(580,1,'login','auth',NULL,'::1','2026-06-30 18:11:11'),(581,1,'login','auth',NULL,'::1','2026-06-30 18:11:16'),(582,1,'login','auth',NULL,'::1','2026-06-30 18:11:20'),(583,1,'login','auth',NULL,'::1','2026-06-30 18:11:25'),(584,1,'login','auth',NULL,'::1','2026-06-30 18:11:31'),(585,1,'login','auth',NULL,'::1','2026-06-30 18:11:37'),(586,1,'login','auth',NULL,'::1','2026-06-30 18:11:45'),(587,1,'login','auth',NULL,'::1','2026-06-30 18:11:51'),(588,1,'login','auth',NULL,'::1','2026-06-30 18:11:56'),(589,1,'login','auth',NULL,'::1','2026-06-30 18:12:01'),(590,1,'login','auth',NULL,'::1','2026-06-30 18:12:05'),(591,1,'login','auth',NULL,'::1','2026-06-30 18:12:29'),(592,1,'login','auth',NULL,'::1','2026-06-30 18:12:34'),(593,1,'logout','auth',NULL,'::1','2026-06-30 18:12:35'),(594,1,'login','auth',NULL,'::1','2026-06-30 18:12:41'),(595,1,'login','auth',NULL,'::1','2026-06-30 18:12:46'),(596,1,'login','auth',NULL,'::1','2026-06-30 18:12:50'),(597,1,'login','auth',NULL,'::1','2026-06-30 18:12:55'),(598,1,'login','auth',NULL,'::1','2026-06-30 18:13:01'),(599,1,'login','auth',NULL,'::1','2026-06-30 18:13:08'),(600,1,'login','auth',NULL,'::1','2026-06-30 18:13:13'),(601,5,'login','auth',NULL,'127.0.0.1','2026-07-02 09:38:44'),(602,5,'logout','auth',NULL,'127.0.0.1','2026-07-02 09:40:52'),(603,14,'login','auth',NULL,'127.0.0.1','2026-07-02 09:40:58'),(604,14,'logout','auth',NULL,'127.0.0.1','2026-07-02 09:41:54'),(605,1,'login','auth',NULL,'::1','2026-07-10 12:00:10'),(606,1,'login','auth',NULL,'::1','2026-07-10 12:00:50'),(607,1,'Recorded payment','finance','{\"amount\": 500, \"fee_id\": 1, \"receipt\": \"RCP-6A50DF0C1A96D\", \"student_id\": 1}','::1','2026-07-10 12:01:16'),(608,1,'Created expense','finance','{\"id\": 1, \"amount\": 1500, \"description\": \"Office supplies test\"}','::1','2026-07-10 12:01:39'),(609,1,'Approved expense','finance','{\"id\": 1}','::1','2026-07-10 12:01:40'),(610,1,'Marked expense paid','finance','{\"id\": 1, \"amount\": \"1500.00\"}','::1','2026-07-10 12:01:40'),(611,1,'login','auth',NULL,'::1','2026-07-10 12:02:40'),(612,1,'login','auth',NULL,'::1','2026-07-10 12:02:45'),(613,1,'login','auth',NULL,'::1','2026-07-10 12:02:49'),(614,1,'login','auth',NULL,'::1','2026-07-10 12:03:06'),(615,1,'login','auth',NULL,'::1','2026-07-10 12:03:11'),(616,1,'login','auth',NULL,'::1','2026-07-10 12:03:14'),(617,1,'logout','auth',NULL,'::1','2026-07-10 12:03:15'),(618,1,'login','auth',NULL,'::1','2026-07-10 12:03:19'),(619,1,'login','auth',NULL,'::1','2026-07-10 12:03:23'),(620,1,'login','auth',NULL,'::1','2026-07-10 12:03:27'),(621,1,'login','auth',NULL,'::1','2026-07-10 12:03:31'),(622,1,'login','auth',NULL,'::1','2026-07-10 12:03:35'),(623,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 12:03:37'),(624,1,'login','auth',NULL,'::1','2026-07-10 12:03:41'),(625,1,'login','auth',NULL,'::1','2026-07-10 12:03:45'),(626,1,'login','auth',NULL,'::1','2026-07-10 12:03:50'),(627,1,'login','auth',NULL,'::1','2026-07-10 12:03:54'),(628,1,'login','auth',NULL,'::1','2026-07-10 12:03:59'),(629,1,'login','auth',NULL,'::1','2026-07-10 12:04:02'),(630,1,'login','auth',NULL,'::1','2026-07-10 12:04:07'),(631,1,'login','auth',NULL,'::1','2026-07-10 12:04:11'),(632,1,'login','auth',NULL,'::1','2026-07-10 12:04:15'),(633,1,'login','auth',NULL,'::1','2026-07-10 12:04:18'),(634,1,'login','auth',NULL,'::1','2026-07-10 12:04:22'),(635,1,'login','auth',NULL,'::1','2026-07-10 12:04:26'),(636,1,'login','auth',NULL,'::1','2026-07-10 12:04:30'),(637,1,'login','auth',NULL,'::1','2026-07-10 12:04:33'),(638,1,'login','auth',NULL,'::1','2026-07-10 12:04:37'),(639,1,'login','auth',NULL,'::1','2026-07-10 12:04:40'),(640,1,'login','auth',NULL,'::1','2026-07-10 12:04:44'),(641,1,'login','auth',NULL,'::1','2026-07-10 12:04:47'),(642,1,'login','auth',NULL,'::1','2026-07-10 12:04:50'),(643,1,'login','auth',NULL,'::1','2026-07-10 12:04:54'),(644,1,'login','auth',NULL,'::1','2026-07-10 12:04:58'),(645,1,'login','auth',NULL,'::1','2026-07-10 12:05:01'),(646,1,'login','auth',NULL,'::1','2026-07-10 12:05:27'),(647,1,'login','auth',NULL,'::1','2026-07-10 12:05:32'),(648,1,'login','auth',NULL,'::1','2026-07-10 12:05:35'),(649,1,'login','auth',NULL,'::1','2026-07-10 12:05:38'),(650,1,'login','auth',NULL,'::1','2026-07-10 12:05:42'),(651,1,'login','auth',NULL,'::1','2026-07-10 12:05:45'),(652,1,'login','auth',NULL,'::1','2026-07-10 12:05:49'),(653,1,'login','auth',NULL,'::1','2026-07-10 12:05:51'),(654,1,'login','auth',NULL,'::1','2026-07-10 12:05:55'),(655,1,'login','auth',NULL,'::1','2026-07-10 12:06:02'),(656,1,'login','auth',NULL,'::1','2026-07-10 12:06:06'),(657,1,'login','auth',NULL,'::1','2026-07-10 12:06:08'),(658,1,'login','auth',NULL,'::1','2026-07-10 12:06:12'),(659,1,'login','auth',NULL,'::1','2026-07-10 12:06:15'),(660,1,'login','auth',NULL,'::1','2026-07-10 12:06:18'),(661,1,'login','auth',NULL,'::1','2026-07-10 12:06:59'),(662,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 12:07:01'),(663,1,'login','auth',NULL,'::1','2026-07-10 12:07:05'),(664,1,'login','auth',NULL,'::1','2026-07-10 12:33:12'),(665,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 12:33:29'),(666,1,'login','auth',NULL,'::1','2026-07-10 12:34:44'),(667,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 12:34:46'),(668,1,'login','auth',NULL,'::1','2026-07-10 12:34:58'),(669,1,'login','auth',NULL,'::1','2026-07-10 12:35:03'),(670,1,'login','auth',NULL,'::1','2026-07-10 12:35:07'),(671,1,'logout','auth',NULL,'::1','2026-07-10 12:35:08'),(672,1,'login','auth',NULL,'::1','2026-07-10 12:35:12'),(673,1,'login','auth',NULL,'::1','2026-07-10 12:35:15'),(674,1,'login','auth',NULL,'::1','2026-07-10 12:35:19'),(675,1,'login','auth',NULL,'::1','2026-07-10 12:35:22'),(676,1,'login','auth',NULL,'::1','2026-07-10 12:35:27'),(677,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 12:35:29'),(678,1,'login','auth',NULL,'::1','2026-07-10 12:35:31'),(679,1,'login','auth',NULL,'::1','2026-07-10 12:35:35'),(680,1,'login','auth',NULL,'::1','2026-07-10 12:35:39'),(681,1,'login','auth',NULL,'::1','2026-07-10 12:35:44'),(682,1,'login','auth',NULL,'::1','2026-07-10 12:35:49'),(683,1,'login','auth',NULL,'::1','2026-07-10 12:35:53'),(684,1,'login','auth',NULL,'::1','2026-07-10 12:35:57'),(685,1,'login','auth',NULL,'::1','2026-07-10 12:36:01'),(686,1,'login','auth',NULL,'::1','2026-07-10 12:36:05'),(687,1,'login','auth',NULL,'::1','2026-07-10 12:36:08'),(688,1,'login','auth',NULL,'::1','2026-07-10 12:36:12'),(689,1,'login','auth',NULL,'::1','2026-07-10 12:36:16'),(690,1,'login','auth',NULL,'::1','2026-07-10 12:36:19'),(691,1,'login','auth',NULL,'::1','2026-07-10 12:36:23'),(692,1,'login','auth',NULL,'::1','2026-07-10 12:36:26'),(693,1,'login','auth',NULL,'::1','2026-07-10 12:36:29'),(694,1,'login','auth',NULL,'::1','2026-07-10 12:36:33'),(695,1,'login','auth',NULL,'::1','2026-07-10 12:36:36'),(696,1,'login','auth',NULL,'::1','2026-07-10 12:36:39'),(697,1,'login','auth',NULL,'::1','2026-07-10 12:36:43'),(698,1,'login','auth',NULL,'::1','2026-07-10 12:36:46'),(699,1,'login','auth',NULL,'::1','2026-07-10 12:36:50'),(700,1,'login','auth',NULL,'::1','2026-07-10 12:36:53'),(701,1,'login','auth',NULL,'::1','2026-07-10 12:36:57'),(702,1,'login','auth',NULL,'::1','2026-07-10 12:37:00'),(703,1,'login','auth',NULL,'::1','2026-07-10 12:37:04'),(704,1,'login','auth',NULL,'::1','2026-07-10 12:37:07'),(705,1,'login','auth',NULL,'::1','2026-07-10 12:37:10'),(706,1,'login','auth',NULL,'::1','2026-07-10 12:37:14'),(707,1,'login','auth',NULL,'::1','2026-07-10 12:37:17'),(708,1,'login','auth',NULL,'::1','2026-07-10 12:37:20'),(709,1,'login','auth',NULL,'::1','2026-07-10 12:37:27'),(710,1,'login','auth',NULL,'::1','2026-07-10 12:37:31'),(711,1,'login','auth',NULL,'::1','2026-07-10 12:37:34'),(712,1,'login','auth',NULL,'::1','2026-07-10 12:37:38'),(713,1,'login','auth',NULL,'::1','2026-07-10 12:37:41'),(714,1,'login','auth',NULL,'::1','2026-07-10 12:37:45'),(715,1,'login','auth',NULL,'::1','2026-07-10 13:07:23'),(716,1,'Copied fee structure','finance','{\"copied\": 1, \"skipped\": 0, \"to_term\": 2, \"from_term\": 1}','::1','2026-07-10 13:09:19'),(717,1,'Copied fee structure','finance','{\"copied\": 0, \"skipped\": 1, \"to_term\": 2, \"from_term\": 1}','::1','2026-07-10 13:09:20'),(718,NULL,'Sent fee reminder (auto)','finance','{\"email\": \"p6@school.com\", \"balance\": 1500, \"term_id\": 1, \"student_id\": 1}',NULL,'2026-07-10 13:09:31'),(719,NULL,'Sent fee reminder (auto)','finance','{\"email\": \"p8@school.com\", \"balance\": 2000, \"term_id\": 1, \"student_id\": 2}',NULL,'2026-07-10 13:09:34'),(720,NULL,'Sent fee reminder (auto)','finance','{\"email\": \"amakamak3070@gmail.com\", \"balance\": 2000, \"term_id\": 1, \"student_id\": 6}',NULL,'2026-07-10 13:09:38'),(721,NULL,'Sent fee reminder (auto)','finance','{\"email\": \"adamlabaranadam@gmail.com\", \"balance\": 2000, \"term_id\": 1, \"student_id\": 8}',NULL,'2026-07-10 13:09:41'),(722,1,'Sent fee reminder','finance','{\"email\": \"p6@school.com\", \"balance\": 1500, \"term_id\": 1, \"student_id\": 1}','::1','2026-07-10 13:10:08'),(723,181,'login','auth',NULL,'127.0.0.1','2026-07-10 13:19:48'),(724,181,'logout','auth',NULL,'127.0.0.1','2026-07-10 13:23:08'),(725,17,'login','auth',NULL,'127.0.0.1','2026-07-10 13:23:20'),(726,17,'logout','auth',NULL,'127.0.0.1','2026-07-10 13:23:27'),(727,5,'login','auth',NULL,'127.0.0.1','2026-07-10 13:23:40'),(728,5,'logout','auth',NULL,'127.0.0.1','2026-07-10 13:23:47'),(729,175,'login','auth',NULL,'127.0.0.1','2026-07-10 13:25:06'),(730,175,'logout','auth',NULL,'127.0.0.1','2026-07-10 13:25:11'),(731,6,'login','auth',NULL,'127.0.0.1','2026-07-10 13:25:30'),(732,6,'logout','auth',NULL,'127.0.0.1','2026-07-10 13:25:35'),(733,3,'login','auth',NULL,'127.0.0.1','2026-07-10 13:26:11'),(734,1,'login','auth',NULL,'::1','2026-07-10 14:50:46'),(735,1,'login','auth',NULL,'::1','2026-07-10 14:50:53'),(736,1,'login','auth',NULL,'::1','2026-07-10 14:50:57'),(737,1,'logout','auth',NULL,'::1','2026-07-10 14:50:59'),(738,1,'login','auth',NULL,'::1','2026-07-10 14:51:05'),(739,1,'login','auth',NULL,'::1','2026-07-10 14:51:09'),(740,1,'login','auth',NULL,'::1','2026-07-10 14:51:14'),(741,1,'login','auth',NULL,'::1','2026-07-10 14:51:18'),(742,1,'login','auth',NULL,'::1','2026-07-10 14:51:26'),(743,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 14:51:28'),(744,1,'login','auth',NULL,'::1','2026-07-10 14:51:31'),(745,1,'login','auth',NULL,'::1','2026-07-10 14:51:36'),(746,1,'login','auth',NULL,'::1','2026-07-10 14:51:41'),(747,1,'login','auth',NULL,'::1','2026-07-10 14:51:47'),(748,1,'login','auth',NULL,'::1','2026-07-10 14:51:53'),(749,1,'login','auth',NULL,'::1','2026-07-10 14:51:57'),(750,1,'login','auth',NULL,'::1','2026-07-10 14:52:03'),(751,1,'login','auth',NULL,'::1','2026-07-10 14:52:08'),(752,1,'login','auth',NULL,'::1','2026-07-10 14:52:13'),(753,1,'login','auth',NULL,'::1','2026-07-10 14:52:18'),(754,1,'login','auth',NULL,'::1','2026-07-10 14:52:22'),(755,1,'login','auth',NULL,'::1','2026-07-10 14:52:27'),(756,1,'login','auth',NULL,'::1','2026-07-10 14:52:32'),(757,1,'login','auth',NULL,'::1','2026-07-10 14:52:36'),(758,1,'login','auth',NULL,'::1','2026-07-10 14:52:41'),(759,1,'login','auth',NULL,'::1','2026-07-10 14:52:45'),(760,1,'login','auth',NULL,'::1','2026-07-10 14:52:49'),(761,1,'login','auth',NULL,'::1','2026-07-10 14:52:53'),(762,1,'login','auth',NULL,'::1','2026-07-10 14:52:57'),(763,1,'login','auth',NULL,'::1','2026-07-10 14:53:01'),(764,1,'login','auth',NULL,'::1','2026-07-10 14:53:05'),(765,1,'login','auth',NULL,'::1','2026-07-10 14:53:09'),(766,1,'login','auth',NULL,'::1','2026-07-10 14:53:12'),(767,1,'login','auth',NULL,'::1','2026-07-10 14:53:16'),(768,1,'login','auth',NULL,'::1','2026-07-10 14:53:20'),(769,1,'login','auth',NULL,'::1','2026-07-10 14:53:24'),(770,1,'login','auth',NULL,'::1','2026-07-10 14:53:29'),(771,1,'login','auth',NULL,'::1','2026-07-10 14:53:33'),(772,1,'login','auth',NULL,'::1','2026-07-10 14:53:36'),(773,1,'login','auth',NULL,'::1','2026-07-10 14:53:40'),(774,1,'login','auth',NULL,'::1','2026-07-10 14:53:44'),(775,1,'login','auth',NULL,'::1','2026-07-10 14:53:53'),(776,1,'login','auth',NULL,'::1','2026-07-10 14:53:56'),(777,1,'login','auth',NULL,'::1','2026-07-10 14:54:00'),(778,1,'login','auth',NULL,'::1','2026-07-10 14:54:05'),(779,1,'login','auth',NULL,'::1','2026-07-10 14:54:09'),(780,1,'login','auth',NULL,'::1','2026-07-10 14:54:13'),(781,181,'login','auth',NULL,'127.0.0.1','2026-07-10 14:59:22'),(782,181,'logout','auth',NULL,'127.0.0.1','2026-07-10 14:59:29'),(783,175,'login','auth',NULL,'127.0.0.1','2026-07-10 14:59:40'),(784,175,'logout','auth',NULL,'127.0.0.1','2026-07-10 14:59:44'),(785,12,'login','auth',NULL,'127.0.0.1','2026-07-10 14:59:51'),(786,12,'logout','auth',NULL,'127.0.0.1','2026-07-10 14:59:55'),(787,3,'login','auth',NULL,'127.0.0.1','2026-07-10 15:00:39'),(788,181,'login','auth',NULL,'127.0.0.1','2026-07-10 15:01:19'),(789,1,'login','auth',NULL,'::1','2026-07-10 19:54:56'),(790,1,'Saved fee adjustment','finance','{\"kind\": \"scholarship\", \"value\": 50, \"fee_id\": 1, \"reason\": \"Test scholarship\", \"student_id\": 1, \"adjust_type\": \"percent\"}','::1','2026-07-10 19:54:57'),(791,NULL,'Applied late payment penalties (auto)','finance','{\"pct\": 5, \"count\": 10, \"total\": 950, \"term_id\": 1}',NULL,'2026-07-10 19:55:53'),(792,1,'Added salary deduction','finance','{\"dtype\": \"tax\", \"label\": \"PAYE July\", \"amount\": 5000, \"salary_id\": 4}','::1','2026-07-10 19:56:22'),(793,1,'Added salary deduction','finance','{\"dtype\": \"pension\", \"label\": \"Pension July\", \"amount\": 3000, \"salary_id\": 4}','::1','2026-07-10 19:56:22'),(794,1,'Posted manual journal entry','finance','{\"date\": \"2026-07-10\", \"debit\": \"5060\", \"amount\": 500, \"credit\": \"1010\", \"description\": \"Test bank charges\"}','::1','2026-07-10 19:56:53'),(795,1,'Recorded payment','finance','{\"amount\": 500, \"fee_id\": 1, \"receipt\": \"RCP-6A514E8626B3B\", \"student_id\": 2}','::1','2026-07-10 19:56:54'),(796,1,'Refunded payment','finance','{\"amount\": 500, \"reason\": \"Test refund\", \"refund_id\": 4, \"payment_id\": 3}','::1','2026-07-10 19:56:54'),(797,1,'Generated payroll month','finance','{\"to\": \"Test August 2026\", \"from\": \"Test July 2026\", \"created\": 1}','::1','2026-07-10 19:57:57'),(798,1,'login','auth',NULL,'::1','2026-07-10 19:59:14'),(799,1,'login','auth',NULL,'::1','2026-07-10 19:59:21'),(800,1,'login','auth',NULL,'::1','2026-07-10 19:59:27'),(801,1,'logout','auth',NULL,'::1','2026-07-10 19:59:29'),(802,1,'login','auth',NULL,'::1','2026-07-10 19:59:35'),(803,1,'login','auth',NULL,'::1','2026-07-10 19:59:41'),(804,1,'login','auth',NULL,'::1','2026-07-10 19:59:47'),(805,1,'login','auth',NULL,'::1','2026-07-10 19:59:52'),(806,1,'login','auth',NULL,'::1','2026-07-10 20:00:00'),(807,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 20:00:03'),(808,1,'login','auth',NULL,'::1','2026-07-10 20:00:07'),(809,1,'login','auth',NULL,'::1','2026-07-10 20:00:13'),(810,1,'login','auth',NULL,'::1','2026-07-10 20:00:21'),(811,1,'login','auth',NULL,'::1','2026-07-10 20:00:28'),(812,1,'login','auth',NULL,'::1','2026-07-10 20:00:37'),(813,1,'login','auth',NULL,'::1','2026-07-10 20:00:43'),(814,1,'login','auth',NULL,'::1','2026-07-10 20:00:49'),(815,1,'login','auth',NULL,'::1','2026-07-10 20:00:56'),(816,1,'login','auth',NULL,'::1','2026-07-10 20:01:03'),(817,1,'login','auth',NULL,'::1','2026-07-10 20:01:09'),(818,1,'login','auth',NULL,'::1','2026-07-10 20:01:14'),(819,1,'login','auth',NULL,'::1','2026-07-10 20:01:20'),(820,1,'login','auth',NULL,'::1','2026-07-10 20:01:25'),(821,1,'login','auth',NULL,'::1','2026-07-10 20:01:30'),(822,1,'login','auth',NULL,'::1','2026-07-10 20:01:35'),(823,1,'login','auth',NULL,'::1','2026-07-10 20:01:40'),(824,1,'login','auth',NULL,'::1','2026-07-10 20:01:46'),(825,1,'login','auth',NULL,'::1','2026-07-10 20:01:51'),(826,1,'login','auth',NULL,'::1','2026-07-10 20:01:56'),(827,1,'login','auth',NULL,'::1','2026-07-10 20:02:01'),(828,1,'login','auth',NULL,'::1','2026-07-10 20:02:06'),(829,1,'login','auth',NULL,'::1','2026-07-10 20:02:12'),(830,1,'login','auth',NULL,'::1','2026-07-10 20:02:17'),(831,1,'login','auth',NULL,'::1','2026-07-10 20:02:22'),(832,1,'login','auth',NULL,'::1','2026-07-10 20:02:27'),(833,1,'login','auth',NULL,'::1','2026-07-10 20:02:31'),(834,1,'login','auth',NULL,'::1','2026-07-10 20:02:38'),(835,1,'login','auth',NULL,'::1','2026-07-10 20:02:46'),(836,1,'login','auth',NULL,'::1','2026-07-10 20:02:52'),(837,1,'login','auth',NULL,'::1','2026-07-10 20:02:57'),(838,1,'login','auth',NULL,'::1','2026-07-10 20:03:03'),(839,1,'login','auth',NULL,'::1','2026-07-10 20:03:14'),(840,1,'login','auth',NULL,'::1','2026-07-10 20:03:19'),(841,1,'login','auth',NULL,'::1','2026-07-10 20:03:24'),(842,1,'login','auth',NULL,'::1','2026-07-10 20:03:30'),(843,1,'login','auth',NULL,'::1','2026-07-10 20:03:35'),(844,1,'login','auth',NULL,'::1','2026-07-10 20:03:41'),(845,1,'login','auth',NULL,'::1','2026-07-10 20:36:28'),(846,1,'login','auth',NULL,'::1','2026-07-10 20:36:48'),(847,1,'login','auth',NULL,'::1','2026-07-10 20:36:54'),(848,1,'login','auth',NULL,'::1','2026-07-10 20:36:59'),(849,1,'login','auth',NULL,'::1','2026-07-10 20:59:28'),(850,1,'Linked guardian to student','students','{\"student_id\": 9}','::1','2026-07-10 20:59:42'),(851,1,'Linked guardian to student','students','{\"student_id\": 10}','::1','2026-07-10 20:59:59'),(852,1,'Student admitted: user_id=187','students',NULL,'::1','2026-07-10 21:00:16'),(853,1,'Linked guardian at admission','students','{\"student_id\": 171}','::1','2026-07-10 21:00:17'),(854,1,'login','auth',NULL,'::1','2026-07-10 21:00:36'),(855,1,'login','auth',NULL,'::1','2026-07-10 21:00:43'),(856,1,'login','auth',NULL,'::1','2026-07-10 21:00:48'),(857,1,'login','auth',NULL,'::1','2026-07-10 21:00:55'),(858,1,'login','auth',NULL,'::1','2026-07-10 21:01:01'),(859,1,'login','auth',NULL,'::1','2026-07-10 21:01:09'),(860,1,'login','auth',NULL,'::1','2026-07-10 21:01:14'),(861,1,'login','auth',NULL,'::1','2026-07-10 21:05:36'),(862,1,'login','auth',NULL,'::1','2026-07-10 21:05:47'),(863,1,'login','auth',NULL,'::1','2026-07-10 21:05:53'),(864,1,'logout','auth',NULL,'::1','2026-07-10 21:05:55'),(865,1,'login','auth',NULL,'::1','2026-07-10 21:06:01'),(866,1,'login','auth',NULL,'::1','2026-07-10 21:06:07'),(867,1,'login','auth',NULL,'::1','2026-07-10 21:06:13'),(868,1,'login','auth',NULL,'::1','2026-07-10 21:06:20'),(869,1,'login','auth',NULL,'::1','2026-07-10 21:06:31'),(870,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 21:06:33'),(871,1,'login','auth',NULL,'::1','2026-07-10 21:06:40'),(872,1,'login','auth',NULL,'::1','2026-07-10 21:06:45'),(873,1,'login','auth',NULL,'::1','2026-07-10 21:06:52'),(874,1,'login','auth',NULL,'::1','2026-07-10 21:07:00'),(875,1,'login','auth',NULL,'::1','2026-07-10 21:07:09'),(876,1,'login','auth',NULL,'::1','2026-07-10 21:07:18'),(877,1,'login','auth',NULL,'::1','2026-07-10 21:07:29'),(878,1,'login','auth',NULL,'::1','2026-07-10 21:07:35'),(879,1,'login','auth',NULL,'::1','2026-07-10 21:07:41'),(880,1,'login','auth',NULL,'::1','2026-07-10 21:07:46'),(881,1,'login','auth',NULL,'::1','2026-07-10 21:07:52'),(882,1,'login','auth',NULL,'::1','2026-07-10 21:07:57'),(883,1,'login','auth',NULL,'::1','2026-07-10 21:08:03'),(884,1,'login','auth',NULL,'::1','2026-07-10 21:08:09'),(885,1,'login','auth',NULL,'::1','2026-07-10 21:08:14'),(886,1,'login','auth',NULL,'::1','2026-07-10 21:08:19'),(887,1,'login','auth',NULL,'::1','2026-07-10 21:08:24'),(888,1,'login','auth',NULL,'::1','2026-07-10 21:08:30'),(889,1,'login','auth',NULL,'::1','2026-07-10 21:08:35'),(890,1,'login','auth',NULL,'::1','2026-07-10 21:08:40'),(891,1,'login','auth',NULL,'::1','2026-07-10 21:08:45'),(892,1,'login','auth',NULL,'::1','2026-07-10 21:11:55'),(893,1,'login','auth',NULL,'::1','2026-07-10 21:12:01'),(894,1,'login','auth',NULL,'::1','2026-07-10 21:12:16'),(895,1,'login','auth',NULL,'::1','2026-07-10 21:12:21'),(896,1,'login','auth',NULL,'::1','2026-07-10 21:12:26'),(897,1,'login','auth',NULL,'::1','2026-07-10 21:12:33'),(898,1,'login','auth',NULL,'::1','2026-07-10 21:12:39'),(899,1,'login','auth',NULL,'::1','2026-07-10 21:12:45'),(900,1,'login','auth',NULL,'::1','2026-07-10 21:13:45'),(901,1,'login','auth',NULL,'::1','2026-07-10 21:13:52'),(902,1,'login','auth',NULL,'::1','2026-07-10 21:13:59'),(903,1,'logout','auth',NULL,'::1','2026-07-10 21:14:01'),(904,1,'login','auth',NULL,'::1','2026-07-10 21:14:09'),(905,1,'login','auth',NULL,'::1','2026-07-10 21:14:15'),(906,1,'login','auth',NULL,'::1','2026-07-10 21:14:22'),(907,1,'login','auth',NULL,'::1','2026-07-10 21:14:30'),(908,1,'login','auth',NULL,'::1','2026-07-10 21:14:38'),(909,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 21:14:41'),(910,1,'login','auth',NULL,'::1','2026-07-10 21:14:45'),(911,1,'login','auth',NULL,'::1','2026-07-10 21:14:51'),(912,1,'login','auth',NULL,'::1','2026-07-10 21:14:58'),(913,1,'login','auth',NULL,'::1','2026-07-10 21:15:05'),(914,1,'login','auth',NULL,'::1','2026-07-10 21:15:12'),(915,1,'login','auth',NULL,'::1','2026-07-10 21:15:19'),(916,1,'login','auth',NULL,'::1','2026-07-10 21:15:27'),(917,1,'login','auth',NULL,'::1','2026-07-10 21:15:33'),(918,1,'login','auth',NULL,'::1','2026-07-10 21:15:40'),(919,1,'login','auth',NULL,'::1','2026-07-10 21:15:47'),(920,1,'login','auth',NULL,'::1','2026-07-10 21:15:54'),(921,1,'login','auth',NULL,'::1','2026-07-10 21:16:00'),(922,1,'login','auth',NULL,'::1','2026-07-10 21:16:06'),(923,1,'login','auth',NULL,'::1','2026-07-10 21:16:11'),(924,1,'login','auth',NULL,'::1','2026-07-10 21:16:17'),(925,1,'login','auth',NULL,'::1','2026-07-10 21:16:22'),(926,1,'login','auth',NULL,'::1','2026-07-10 21:16:28'),(927,1,'login','auth',NULL,'::1','2026-07-10 21:16:33'),(928,1,'login','auth',NULL,'::1','2026-07-10 21:16:39'),(929,1,'login','auth',NULL,'::1','2026-07-10 21:16:44'),(930,1,'login','auth',NULL,'::1','2026-07-10 21:16:49'),(931,1,'login','auth',NULL,'::1','2026-07-10 21:16:54'),(932,1,'login','auth',NULL,'::1','2026-07-10 21:17:00'),(933,1,'login','auth',NULL,'::1','2026-07-10 21:17:04'),(934,1,'login','auth',NULL,'::1','2026-07-10 21:17:11'),(935,1,'login','auth',NULL,'::1','2026-07-10 21:17:17'),(936,1,'login','auth',NULL,'::1','2026-07-10 21:17:22'),(937,1,'login','auth',NULL,'::1','2026-07-10 21:17:27'),(938,1,'login','auth',NULL,'::1','2026-07-10 21:17:33'),(939,1,'login','auth',NULL,'::1','2026-07-10 21:17:37'),(940,1,'login','auth',NULL,'::1','2026-07-10 21:17:43'),(941,1,'login','auth',NULL,'::1','2026-07-10 21:17:54'),(942,1,'login','auth',NULL,'::1','2026-07-10 21:18:00'),(943,1,'login','auth',NULL,'::1','2026-07-10 21:18:05'),(944,1,'login','auth',NULL,'::1','2026-07-10 21:18:11'),(945,1,'login','auth',NULL,'::1','2026-07-10 21:18:17'),(946,1,'login','auth',NULL,'::1','2026-07-10 21:18:32'),(947,1,'login','auth',NULL,'::1','2026-07-10 21:36:27'),(948,NULL,'login','auth',NULL,'::1','2026-07-10 21:38:08'),(949,1,'login','auth',NULL,'::1','2026-07-10 21:43:44'),(950,1,'login','auth',NULL,'::1','2026-07-10 21:43:50'),(951,1,'login','auth',NULL,'::1','2026-07-10 21:43:56'),(952,1,'logout','auth',NULL,'::1','2026-07-10 21:43:57'),(953,1,'login','auth',NULL,'::1','2026-07-10 21:44:04'),(954,1,'login','auth',NULL,'::1','2026-07-10 21:44:09'),(955,1,'login','auth',NULL,'::1','2026-07-10 21:44:14'),(956,1,'login','auth',NULL,'::1','2026-07-10 21:44:18'),(957,1,'login','auth',NULL,'::1','2026-07-10 21:44:27'),(958,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 21:44:29'),(959,1,'login','auth',NULL,'::1','2026-07-10 21:44:33'),(960,1,'login','auth',NULL,'::1','2026-07-10 21:44:39'),(961,1,'login','auth',NULL,'::1','2026-07-10 21:44:44'),(962,1,'login','auth',NULL,'::1','2026-07-10 21:44:50'),(963,1,'login','auth',NULL,'::1','2026-07-10 21:44:59'),(964,1,'login','auth',NULL,'::1','2026-07-10 21:45:05'),(965,1,'login','auth',NULL,'::1','2026-07-10 21:45:11'),(966,1,'login','auth',NULL,'::1','2026-07-10 21:45:16'),(967,1,'login','auth',NULL,'::1','2026-07-10 21:45:22'),(968,1,'login','auth',NULL,'::1','2026-07-10 21:45:27'),(969,1,'login','auth',NULL,'::1','2026-07-10 21:45:32'),(970,1,'login','auth',NULL,'::1','2026-07-10 21:45:38'),(971,1,'login','auth',NULL,'::1','2026-07-10 21:45:42'),(972,1,'login','auth',NULL,'::1','2026-07-10 21:45:50'),(973,1,'login','auth',NULL,'::1','2026-07-10 21:45:55'),(974,1,'login','auth',NULL,'::1','2026-07-10 21:46:03'),(975,1,'login','auth',NULL,'::1','2026-07-10 21:46:07'),(976,1,'login','auth',NULL,'::1','2026-07-10 21:46:12'),(977,1,'login','auth',NULL,'::1','2026-07-10 21:46:17'),(978,1,'login','auth',NULL,'::1','2026-07-10 21:46:22'),(979,1,'login','auth',NULL,'::1','2026-07-10 21:46:27'),(980,1,'login','auth',NULL,'::1','2026-07-10 21:46:32'),(981,1,'login','auth',NULL,'::1','2026-07-10 21:46:37'),(982,1,'login','auth',NULL,'::1','2026-07-10 21:46:41'),(983,1,'login','auth',NULL,'::1','2026-07-10 21:46:46'),(984,1,'login','auth',NULL,'::1','2026-07-10 21:46:51'),(985,1,'login','auth',NULL,'::1','2026-07-10 21:46:56'),(986,1,'login','auth',NULL,'::1','2026-07-10 21:47:02'),(987,1,'login','auth',NULL,'::1','2026-07-10 21:47:07'),(988,1,'login','auth',NULL,'::1','2026-07-10 21:47:12'),(989,1,'login','auth',NULL,'::1','2026-07-10 21:47:17'),(990,1,'login','auth',NULL,'::1','2026-07-10 21:47:28'),(991,1,'login','auth',NULL,'::1','2026-07-10 21:47:33'),(992,1,'login','auth',NULL,'::1','2026-07-10 21:47:38'),(993,1,'login','auth',NULL,'::1','2026-07-10 21:47:44'),(994,1,'login','auth',NULL,'::1','2026-07-10 21:47:49'),(995,1,'login','auth',NULL,'::1','2026-07-10 21:47:53'),(996,1,'login','auth',NULL,'::1','2026-07-10 21:57:16'),(997,1,'login','auth',NULL,'::1','2026-07-10 22:00:13'),(998,181,'login','auth',NULL,'127.0.0.1','2026-07-10 22:01:25'),(999,1,'login','auth',NULL,'::1','2026-07-10 22:01:35'),(1000,1,'login','auth',NULL,'::1','2026-07-10 22:04:13'),(1001,1,'login','auth',NULL,'::1','2026-07-10 22:04:43'),(1002,181,'Created new user manually','users','{\"email\": \"acct@gmail.com\", \"user_id\": 190, \"role_ids\": [\"5\"]}','127.0.0.1','2026-07-10 22:04:53'),(1003,181,'logout','auth',NULL,'127.0.0.1','2026-07-10 22:05:27'),(1004,190,'login','auth',NULL,'127.0.0.1','2026-07-10 22:05:32'),(1005,1,'login','auth',NULL,'::1','2026-07-10 22:06:11'),(1006,1,'login','auth',NULL,'::1','2026-07-10 22:09:34'),(1007,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 22:09:38'),(1008,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 22:09:39'),(1009,1,'login','auth',NULL,'::1','2026-07-10 22:10:25'),(1010,1,'login','auth',NULL,'::1','2026-07-10 22:10:33'),(1011,1,'login','auth',NULL,'::1','2026-07-10 22:10:40'),(1012,1,'logout','auth',NULL,'::1','2026-07-10 22:10:42'),(1013,1,'login','auth',NULL,'::1','2026-07-10 22:10:53'),(1014,1,'login','auth',NULL,'::1','2026-07-10 22:10:59'),(1015,1,'login','auth',NULL,'::1','2026-07-10 22:11:07'),(1016,1,'login','auth',NULL,'::1','2026-07-10 22:11:21'),(1017,1,'login','auth',NULL,'::1','2026-07-10 22:11:29'),(1018,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 22:11:31'),(1019,1,'login','auth',NULL,'::1','2026-07-10 22:11:35'),(1020,1,'login','auth',NULL,'::1','2026-07-10 22:11:41'),(1021,1,'login','auth',NULL,'::1','2026-07-10 22:11:48'),(1022,1,'login','auth',NULL,'::1','2026-07-10 22:11:54'),(1023,1,'login','auth',NULL,'::1','2026-07-10 22:12:02'),(1024,1,'login','auth',NULL,'::1','2026-07-10 22:12:09'),(1025,1,'login','auth',NULL,'::1','2026-07-10 22:12:16'),(1026,1,'login','auth',NULL,'::1','2026-07-10 22:12:29'),(1027,1,'login','auth',NULL,'::1','2026-07-10 22:12:35'),(1028,1,'login','auth',NULL,'::1','2026-07-10 22:12:40'),(1029,1,'login','auth',NULL,'::1','2026-07-10 22:12:46'),(1030,1,'login','auth',NULL,'::1','2026-07-10 22:12:51'),(1031,1,'login','auth',NULL,'::1','2026-07-10 22:12:58'),(1032,1,'login','auth',NULL,'::1','2026-07-10 22:13:08'),(1033,1,'login','auth',NULL,'::1','2026-07-10 22:13:13'),(1034,1,'login','auth',NULL,'::1','2026-07-10 22:13:19'),(1035,1,'login','auth',NULL,'::1','2026-07-10 22:13:24'),(1036,1,'login','auth',NULL,'::1','2026-07-10 22:13:31'),(1037,1,'login','auth',NULL,'::1','2026-07-10 22:13:36'),(1038,1,'login','auth',NULL,'::1','2026-07-10 22:13:41'),(1039,1,'login','auth',NULL,'::1','2026-07-10 22:13:46'),(1040,1,'login','auth',NULL,'::1','2026-07-10 22:13:52'),(1041,1,'login','auth',NULL,'::1','2026-07-10 22:13:58'),(1042,1,'login','auth',NULL,'::1','2026-07-10 22:14:05'),(1043,1,'login','auth',NULL,'::1','2026-07-10 22:14:10'),(1044,1,'login','auth',NULL,'::1','2026-07-10 22:14:17'),(1045,1,'login','auth',NULL,'::1','2026-07-10 22:14:23'),(1046,1,'login','auth',NULL,'::1','2026-07-10 22:14:28'),(1047,1,'login','auth',NULL,'::1','2026-07-10 22:14:34'),(1048,1,'login','auth',NULL,'::1','2026-07-10 22:14:40'),(1049,1,'login','auth',NULL,'::1','2026-07-10 22:14:46'),(1050,1,'login','auth',NULL,'::1','2026-07-10 22:14:58'),(1051,1,'login','auth',NULL,'::1','2026-07-10 22:14:58'),(1052,1,'Registered parent with children','students','{\"relation\": \"Mother\", \"student_ids\": [11, 12], \"parent_user_id\": 191}','::1','2026-07-10 22:14:59'),(1053,1,'login','auth',NULL,'::1','2026-07-10 22:15:06'),(1054,1,'login','auth',NULL,'::1','2026-07-10 22:15:12'),(1055,1,'login','auth',NULL,'::1','2026-07-10 22:15:17'),(1056,1,'login','auth',NULL,'::1','2026-07-10 22:15:22'),(1057,1,'login','auth',NULL,'::1','2026-07-10 22:15:28'),(1058,1,'login','auth',NULL,'::1','2026-07-10 22:16:05'),(1059,1,'login','auth',NULL,'::1','2026-07-10 22:16:12'),(1060,1,'login','auth',NULL,'::1','2026-07-10 22:16:17'),(1061,1,'logout','auth',NULL,'::1','2026-07-10 22:16:19'),(1062,1,'login','auth',NULL,'::1','2026-07-10 22:16:25'),(1063,1,'login','auth',NULL,'::1','2026-07-10 22:16:31'),(1064,1,'login','auth',NULL,'::1','2026-07-10 22:16:37'),(1065,1,'login','auth',NULL,'::1','2026-07-10 22:16:42'),(1066,1,'login','auth',NULL,'::1','2026-07-10 22:16:49'),(1067,1,'Settings updated: tab=school','settings',NULL,'::1','2026-07-10 22:16:52'),(1068,1,'login','auth',NULL,'::1','2026-07-10 22:16:55'),(1069,1,'login','auth',NULL,'::1','2026-07-10 22:17:01'),(1070,1,'login','auth',NULL,'::1','2026-07-10 22:17:07'),(1071,1,'login','auth',NULL,'::1','2026-07-10 22:17:14'),(1072,1,'login','auth',NULL,'::1','2026-07-10 22:17:21'),(1073,1,'login','auth',NULL,'::1','2026-07-10 22:17:27'),(1074,1,'login','auth',NULL,'::1','2026-07-10 22:17:34'),(1075,1,'login','auth',NULL,'::1','2026-07-10 22:17:40'),(1076,1,'login','auth',NULL,'::1','2026-07-10 22:17:47'),(1077,1,'login','auth',NULL,'::1','2026-07-10 22:17:53'),(1078,1,'login','auth',NULL,'::1','2026-07-10 22:18:01'),(1079,1,'login','auth',NULL,'::1','2026-07-10 22:18:10'),(1080,1,'login','auth',NULL,'::1','2026-07-10 22:18:16'),(1081,1,'login','auth',NULL,'::1','2026-07-10 22:18:22'),(1082,1,'login','auth',NULL,'::1','2026-07-10 22:18:27'),(1083,1,'login','auth',NULL,'::1','2026-07-10 22:18:32'),(1084,1,'login','auth',NULL,'::1','2026-07-10 22:18:37'),(1085,1,'login','auth',NULL,'::1','2026-07-10 22:18:43'),(1086,190,'logout','auth',NULL,'127.0.0.1','2026-07-10 22:18:44'),(1087,1,'login','auth',NULL,'::1','2026-07-10 22:18:48'),(1088,1,'login','auth',NULL,'::1','2026-07-10 22:18:54'),(1089,181,'login','auth',NULL,'127.0.0.1','2026-07-10 22:18:58'),(1090,1,'login','auth',NULL,'::1','2026-07-10 22:18:59'),(1091,1,'login','auth',NULL,'::1','2026-07-10 22:19:04'),(1092,1,'login','auth',NULL,'::1','2026-07-10 22:19:10'),(1093,1,'login','auth',NULL,'::1','2026-07-10 22:19:15'),(1094,1,'login','auth',NULL,'::1','2026-07-10 22:19:20'),(1095,1,'login','auth',NULL,'::1','2026-07-10 22:19:26'),(1096,1,'login','auth',NULL,'::1','2026-07-10 22:19:30'),(1097,1,'login','auth',NULL,'::1','2026-07-10 22:19:34'),(1098,1,'login','auth',NULL,'::1','2026-07-10 22:19:39'),(1099,1,'login','auth',NULL,'::1','2026-07-10 22:19:44'),(1100,1,'login','auth',NULL,'::1','2026-07-10 22:19:49'),(1101,1,'login','auth',NULL,'::1','2026-07-10 22:19:59'),(1102,1,'login','auth',NULL,'::1','2026-07-10 22:20:04'),(1103,1,'login','auth',NULL,'::1','2026-07-10 22:20:10'),(1104,1,'login','auth',NULL,'::1','2026-07-10 22:20:17'),(1105,1,'login','auth',NULL,'::1','2026-07-10 22:20:22'),(1106,1,'login','auth',NULL,'::1','2026-07-10 22:20:28'),(1107,181,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-10 22:24:03'),(1108,1,'login','auth',NULL,'::1','2026-07-10 22:30:30'),(1109,1,'login','auth',NULL,'::1','2026-07-10 22:30:36'),(1110,1,'login','auth',NULL,'::1','2026-07-10 22:30:43'),(1111,1,'login','auth',NULL,'::1','2026-07-10 22:30:51'),(1112,1,'login','auth',NULL,'::1','2026-07-12 09:06:37'),(1113,1,'login','auth',NULL,'::1','2026-07-12 09:07:09'),(1114,1,'logout','auth',NULL,'::1','2026-07-12 09:07:32'),(1115,1,'login','auth',NULL,'::1','2026-07-12 09:11:12'),(1116,1,'Created activity: Sport Day','activities',NULL,'::1','2026-07-12 09:11:12'),(1117,1,'Updated activity ID 2','activities',NULL,'::1','2026-07-12 09:11:25'),(1118,1,'Deleted activity ID 2','activities',NULL,'::1','2026-07-12 09:11:25'),(1119,1,'login','auth',NULL,'::1','2026-07-12 09:14:27'),(1120,181,'login','auth',NULL,'127.0.0.1','2026-07-12 09:15:38'),(1121,1,'Created section: Nursery','sections',NULL,'::1','2026-07-12 09:15:46'),(1122,1,'Updated section ID 3','sections',NULL,'::1','2026-07-12 09:16:00'),(1123,1,'Deleted section ID 3','sections',NULL,'::1','2026-07-12 09:16:00'),(1124,1,'login','auth',NULL,'::1','2026-07-12 09:21:18'),(1125,1,'Settings updated: tab=system','settings',NULL,'::1','2026-07-12 09:21:29'),(1126,1,'login','auth',NULL,'::1','2026-07-12 09:21:30'),(1127,1,'login','auth',NULL,'::1','2026-07-12 09:23:36'),(1128,1,'Settings updated: tab=system','settings',NULL,'::1','2026-07-12 09:23:36'),(1129,1,'login','auth',NULL,'::1','2026-07-12 09:55:21'),(1130,1,'login','auth',NULL,'::1','2026-07-12 09:56:00'),(1131,1,'Enabled two-factor authentication','auth',NULL,'::1','2026-07-12 09:56:02'),(1132,1,'login','auth',NULL,'::1','2026-07-12 09:56:28'),(1133,1,'Regenerated 2FA recovery codes','auth',NULL,'::1','2026-07-12 10:14:19'),(1134,1,'login','auth',NULL,'::1','2026-07-12 10:14:32'),(1135,1,'Disabled two-factor authentication','auth',NULL,'::1','2026-07-12 10:14:59'),(1136,1,'login','auth',NULL,'::1','2026-07-12 10:14:59'),(1137,1,'login','auth',NULL,'::1','2026-07-12 10:23:14'),(1138,1,'login','auth',NULL,'::1','2026-07-12 10:33:46'),(1139,1,'login','auth',NULL,'::1','2026-07-12 13:59:26'),(1140,1,'login','auth',NULL,'::1','2026-07-12 13:59:52'),(1141,1,'login','auth',NULL,'::1','2026-07-12 14:00:36'),(1142,NULL,'login','auth',NULL,'::1','2026-07-12 14:01:04'),(1143,NULL,'login','auth',NULL,'::1','2026-07-12 14:02:06'),(1144,1,'login','auth',NULL,'::1','2026-07-12 14:09:40'),(1145,1,'Updated notification template ID 1','notification_templates',NULL,'::1','2026-07-12 14:10:16'),(1146,1,'Updated notification template ID 1','notification_templates',NULL,'::1','2026-07-12 14:10:32'),(1147,1,'login','auth',NULL,'::1','2026-07-12 14:17:25'),(1148,1,'Archived student ID 175 to alumni (graduated)','alumni',NULL,'::1','2026-07-12 14:17:25'),(1149,1,'Restored student ID 175 from alumni','alumni',NULL,'::1','2026-07-12 14:17:52'),(1150,181,'login','auth',NULL,'127.0.0.1','2026-07-13 11:44:45'),(1151,181,'logout','auth',NULL,'127.0.0.1','2026-07-13 11:46:43'),(1152,181,'login','auth',NULL,'127.0.0.1','2026-07-13 11:48:07'),(1153,1,'login','auth',NULL,'::1','2026-07-13 11:55:04'),(1154,1,'login','auth',NULL,'::1','2026-07-13 12:22:41'),(1155,1,'login','auth',NULL,'::1','2026-07-13 12:24:08'),(1156,1,'login','auth',NULL,'::1','2026-07-13 12:24:34'),(1157,1,'login','auth',NULL,'::1','2026-07-13 12:27:30'),(1158,1,'login','auth',NULL,'::1','2026-07-13 12:29:47'),(1159,181,'login','auth',NULL,'127.0.0.1','2026-07-15 18:02:37'),(1160,181,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 18:02:50'),(1161,181,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 18:09:19'),(1162,181,'Linked guardian to student','students','{\"student_id\": 9}','127.0.0.1','2026-07-15 18:20:59'),(1163,181,'logout','auth',NULL,'127.0.0.1','2026-07-15 18:25:32'),(1164,181,'login','auth',NULL,'127.0.0.1','2026-07-15 18:25:47'),(1165,181,'Updated ID 1 in users','users','{\"changes\": {\"password_hash\": {\"new\": \"$2y$12$../6FqIgVrWXXxMWbO44QeBszXwn6xr7aCsQG70F4WbeOEc8BK4Qa\", \"old\": \"$2y$10$evD9jJ.iz.fCRTKDWdqVTOHh2kX/a.uI98u/omqRNq4EWsTimq97a\"}}, \"target_id\": 1}','127.0.0.1','2026-07-15 18:26:19'),(1166,181,'logout','auth',NULL,'127.0.0.1','2026-07-15 18:26:30'),(1167,1,'login','auth',NULL,'127.0.0.1','2026-07-15 18:26:36'),(1168,1,'Archived student ID 1 to alumni (transferred)','alumni',NULL,'127.0.0.1','2026-07-15 18:35:55'),(1169,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 18:40:37'),(1170,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 18:40:52'),(1171,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 18:41:18'),(1172,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 19:09:25'),(1173,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 19:09:59'),(1174,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 19:10:24'),(1175,1,'Settings updated: tab=school','settings',NULL,'127.0.0.1','2026-07-15 19:11:29'),(1176,1,'logout','auth',NULL,'127.0.0.1','2026-07-15 19:12:37'),(1177,5,'login','auth',NULL,'127.0.0.1','2026-07-15 19:12:44'),(1178,5,'logout','auth',NULL,'127.0.0.1','2026-07-15 19:12:50'),(1179,1,'login','auth',NULL,'127.0.0.1','2026-07-15 19:13:15'),(1180,1,'logout','auth',NULL,'127.0.0.1','2026-07-15 19:22:42'),(1181,190,'login','auth',NULL,'127.0.0.1','2026-07-15 19:22:48'),(1182,190,'logout','auth',NULL,'127.0.0.1','2026-07-15 19:24:38'),(1183,5,'login','auth',NULL,'127.0.0.1','2026-07-15 19:24:43'),(1184,5,'logout','auth',NULL,'127.0.0.1','2026-07-15 19:24:49'),(1185,1,'login','auth',NULL,'127.0.0.1','2026-07-15 19:25:23'),(1186,1,'login','auth',NULL,'127.0.0.1','2026-07-16 09:22:48'),(1187,1,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:28:50'),(1188,5,'login','auth',NULL,'127.0.0.1','2026-07-16 09:28:55'),(1189,5,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:37:00'),(1190,8,'login','auth',NULL,'127.0.0.1','2026-07-16 09:37:17'),(1191,8,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:37:33'),(1192,24,'login','auth',NULL,'127.0.0.1','2026-07-16 09:37:44'),(1193,24,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:37:49'),(1194,3,'login','auth',NULL,'127.0.0.1','2026-07-16 09:38:02'),(1195,3,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:38:42'),(1196,8,'login','auth',NULL,'127.0.0.1','2026-07-16 09:38:56'),(1197,8,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:39:05'),(1198,3,'login','auth',NULL,'127.0.0.1','2026-07-16 09:39:21'),(1199,3,'logout','auth',NULL,'127.0.0.1','2026-07-16 09:39:27'),(1200,175,'login','auth',NULL,'127.0.0.1','2026-07-16 09:39:42'),(1201,175,'logout','auth',NULL,'127.0.0.1','2026-07-16 10:36:38'),(1202,181,'login','auth',NULL,'127.0.0.1','2026-07-16 10:36:48'),(1203,181,'Updated ID 175 in users','users','{\"changes\": {\"section_id\": {\"new\": 1, \"old\": null}}, \"target_id\": 175}','127.0.0.1','2026-07-16 10:37:50'),(1204,181,'logout','auth',NULL,'127.0.0.1','2026-07-16 10:38:12'),(1205,1,'login','auth',NULL,'127.0.0.1','2026-07-16 10:38:39'),(1206,1,'logout','auth',NULL,'127.0.0.1','2026-07-16 10:56:52'),(1207,175,'login','auth',NULL,'127.0.0.1','2026-07-16 10:56:59'),(1208,183,'login','auth',NULL,'192.168.100.32','2026-07-16 11:51:21'),(1209,183,'logout','auth',NULL,'192.168.100.32','2026-07-16 11:51:44'),(1210,182,'login','auth',NULL,'192.168.100.32','2026-07-16 11:51:51'),(1211,182,'logout','auth',NULL,'192.168.100.32','2026-07-16 11:52:36'),(1212,175,'logout','auth',NULL,'127.0.0.1','2026-07-16 11:55:38'),(1213,181,'login','auth',NULL,'192.168.100.32','2026-07-16 11:56:13'),(1214,190,'login','auth',NULL,'192.168.100.76','2026-07-16 12:05:44'),(1215,1,'login','auth',NULL,'127.0.0.1','2026-07-16 12:12:43'),(1216,3,'login','auth',NULL,'192.168.100.57','2026-07-16 12:54:48'),(1217,3,'logout','auth',NULL,'192.168.100.57','2026-07-16 12:55:26'),(1218,NULL,'logout','auth',NULL,'127.0.0.1','2026-07-16 12:57:32'),(1219,181,'login','auth',NULL,'127.0.0.1','2026-07-16 12:57:43'),(1220,175,'login','auth',NULL,'192.168.100.57','2026-07-16 12:58:29'),(1221,181,'logout','auth',NULL,'127.0.0.1','2026-07-16 13:14:07'),(1222,1,'login','auth',NULL,'127.0.0.1','2026-07-16 13:14:18'),(1223,1,'logout','auth',NULL,'127.0.0.1','2026-07-16 13:20:22'),(1224,181,'login','auth',NULL,'127.0.0.1','2026-07-16 13:20:28'),(1225,181,'logout','auth',NULL,'127.0.0.1','2026-07-16 13:20:39'),(1226,190,'login','auth',NULL,'127.0.0.1','2026-07-16 13:20:44'),(1227,190,'logout','auth',NULL,'127.0.0.1','2026-07-16 13:21:21'),(1228,5,'login','auth',NULL,'127.0.0.1','2026-07-16 13:21:26'),(1229,5,'logout','auth',NULL,'127.0.0.1','2026-07-16 13:21:39'),(1230,1,'login','auth',NULL,'127.0.0.1','2026-07-16 13:22:00'),(1231,1,'login','auth',NULL,'127.0.0.1','2026-07-16 14:33:50'),(1232,1,'Updated ID 1 in users','profile','{\"changes\": {\"email\": {\"new\": \"abubakar17hm@gmail.com\", \"old\": \"admin@school.com\"}, \"gender\": {\"new\": \"male\", \"old\": null}, \"date_of_birth\": {\"new\": \"2026-07-16\", \"old\": null}}, \"target_id\": 1}','127.0.0.1','2026-07-16 14:36:52'),(1233,1,'Student deleted: SEC-2026-0003','students',NULL,'127.0.0.1','2026-07-16 14:40:11'),(1234,181,'login','auth',NULL,'127.0.0.1','2026-07-17 09:46:32'),(1235,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 09:48:48'),(1236,190,'login','auth',NULL,'127.0.0.1','2026-07-17 09:48:52'),(1237,190,'logout','auth',NULL,'127.0.0.1','2026-07-17 09:50:55'),(1238,181,'login','auth',NULL,'127.0.0.1','2026-07-17 09:51:02'),(1239,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 09:51:32'),(1240,3,'login','auth',NULL,'127.0.0.1','2026-07-17 09:51:57'),(1241,3,'logout','auth',NULL,'127.0.0.1','2026-07-17 10:03:23'),(1242,181,'login','auth',NULL,'127.0.0.1','2026-07-17 10:03:52'),(1243,181,'Created new user manually','users','{\"email\": \"abdurrahmanalhassan775@gmail.com\", \"role_id\": 26, \"user_id\": 196}','127.0.0.1','2026-07-17 10:41:31'),(1244,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 10:42:33'),(1245,181,'login','auth',NULL,'127.0.0.1','2026-07-17 10:43:23'),(1246,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 10:43:48'),(1247,196,'login','auth',NULL,'127.0.0.1','2026-07-17 10:43:59'),(1248,181,'login','auth',NULL,'127.0.0.1','2026-07-17 13:25:31'),(1249,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 13:25:58'),(1250,196,'login','auth',NULL,'127.0.0.1','2026-07-17 13:26:03'),(1251,196,'logout','auth',NULL,'127.0.0.1','2026-07-17 13:55:07'),(1252,196,'login','auth',NULL,'127.0.0.1','2026-07-17 13:55:29'),(1253,196,'logout','auth',NULL,'127.0.0.1','2026-07-17 13:56:19'),(1254,181,'login','auth',NULL,'127.0.0.1','2026-07-17 13:56:23'),(1255,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 14:18:14'),(1256,181,'login','auth',NULL,'127.0.0.1','2026-07-17 14:41:50'),(1257,181,'Created new user manually','users','{\"email\": \"sadiq@gmail.com\", \"role_id\": 2, \"user_id\": 197}','127.0.0.1','2026-07-17 14:44:12'),(1258,181,'logout','auth',NULL,'127.0.0.1','2026-07-17 14:46:53'),(1259,197,'login','auth',NULL,'127.0.0.1','2026-07-17 14:47:00'),(1260,181,'login','auth',NULL,'127.0.0.1','2026-07-18 08:42:39'),(1261,181,'login','auth',NULL,'127.0.0.1','2026-07-18 10:11:18'),(1262,181,'login','auth',NULL,'127.0.0.1','2026-07-20 10:53:14');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_audit_log`
--

DROP TABLE IF EXISTS `bar_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_audit_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `user_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `action` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `details` text COLLATE utf8mb4_unicode_ci,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_audit_log`
--

LOCK TABLES `bar_audit_log` WRITE;
/*!40000 ALTER TABLE `bar_audit_log` DISABLE KEYS */;
INSERT INTO `bar_audit_log` VALUES (1,1,'Admin','create_order','order #4','table #3','127.0.0.1','2026-07-22 15:12:08'),(2,1,'Admin','mapping_add','menu_item #3 → inv #5','qty:1','127.0.0.1','2026-07-22 17:25:45'),(3,1,'Admin','menu_add_item','item #16','Mango','127.0.0.1','2026-07-23 09:36:50'),(4,1,'Admin','menu_add_item','item #17','Mango','127.0.0.1','2026-07-23 09:55:36'),(5,1,'Admin','accept_order','order #2','','127.0.0.1','2026-07-23 09:59:26'),(6,1,'Admin','menu_edit_item','item #1','Heineken Bottle','::1','2026-07-23 10:11:38'),(7,1,'Admin','menu_edit_item','item #1','Heineken Bottle','::1','2026-07-23 10:12:00'),(8,1,'Admin','menu_edit_item','item #1','Heineken Bottle','::1','2026-07-23 10:12:54'),(9,1,'Admin','menu_edit_item','item #1','Heineken Bottle','::1','2026-07-23 10:14:16'),(10,1,'Admin','menu_edit_item','item #2','Guinness Draught','::1','2026-07-23 10:14:38'),(11,1,'Admin','menu_edit_item','item #3','Star Lager','::1','2026-07-23 10:14:38'),(12,1,'Admin','menu_edit_item','item #4','Mojito','::1','2026-07-23 10:14:38'),(13,1,'Admin','menu_edit_item','item #5','Margarita','::1','2026-07-23 10:14:39'),(14,1,'Admin','menu_edit_item','item #6','Pina Colada','::1','2026-07-23 10:14:39'),(15,1,'Admin','menu_edit_item','item #16','Mango','127.0.0.1','2026-07-23 10:29:55'),(16,1,'Admin','menu_edit_item','item #16','Mango','127.0.0.1','2026-07-23 10:39:38'),(17,1,'Admin','menu_edit_item','item #16','Mango','127.0.0.1','2026-07-23 10:52:12'),(18,1,'Admin','stock_adjust','Coca Cola','in 10','127.0.0.1','2026-07-23 10:56:14'),(19,1,'Admin','stock_adjust','Coca Cola','in 10','127.0.0.1','2026-07-23 10:56:29'),(20,1,'Admin','stock_adjust','Coca Cola','in 10','127.0.0.1','2026-07-23 10:56:50'),(21,1,'Admin','stock_adjust','Coca Cola','in 10','127.0.0.1','2026-07-23 11:25:20'),(22,1,'Admin','stock_adjust','Coca Cola','in 10','127.0.0.1','2026-07-23 11:25:31'),(23,1,'Admin','stock_adjust','Fresh Mint','in 10','127.0.0.1','2026-07-23 11:26:10'),(24,1,'Admin','stock_adjust','Heineken Bottles','in 1 — test','::1','2026-07-23 11:31:45'),(25,1,'Admin','stock_adjust','Fresh Mint','in 10','127.0.0.1','2026-07-23 11:32:37'),(26,1,'Admin','stock_add_item','item #11','Banana','127.0.0.1','2026-07-23 11:33:48'),(27,1,'Admin','stock_adjust','Heineken Bottles','in 5 — restock test','::1','2026-07-23 11:39:17'),(28,1,'Admin','stock_add_item','item #12','Banana','::1','2026-07-23 11:50:41'),(29,1,'Admin','stock_create_menu','inv #11 → menu #18','Banana','::1','2026-07-23 11:50:50'),(30,1,'Admin','menu_edit_item','item #18','Banana','127.0.0.1','2026-07-23 11:57:22'),(31,1,'Admin','menu_edit_item','item #18','Banana','127.0.0.1','2026-07-23 11:57:41'),(32,1,'Admin','table_toggle','table #1','id:1','127.0.0.1','2026-07-23 12:55:58'),(33,1,'Admin','table_add','table #11','','127.0.0.1','2026-07-23 13:04:40'),(34,1,'Admin','checkout','order #2','methods:cash total:15.4','127.0.0.1','2026-07-23 13:57:56'),(35,1,'Admin','create_order','order #5','table #4','127.0.0.1','2026-07-23 13:58:22'),(36,1,'Admin','create_order','order #6','table #5','127.0.0.1','2026-07-23 13:58:34'),(92,1,'Admin','create_order','order #24','table #6','192.168.100.12','2026-07-25 13:22:02'),(93,1,'Admin','table_toggle','table #1','id:1','127.0.0.1','2026-07-25 13:30:46'),(94,1,'Admin','create_order','order #25','table #1','127.0.0.1','2026-07-27 09:04:50'),(95,1,'Admin','table_regenerate_qr','table #1','id:1','127.0.0.1','2026-07-27 09:45:24'),(96,1,'Admin','create_order','order #26','table #7','127.0.0.1','2026-07-27 09:54:30'),(97,1,'Admin','table_regenerate_qr','table #2','id:2','127.0.0.1','2026-07-27 10:22:25'),(98,1,'Admin','table_regenerate_qr','table #3','id:3','127.0.0.1','2026-07-27 10:22:31'),(99,1,'Admin','table_regenerate_qr','table #4','id:4','127.0.0.1','2026-07-27 10:22:40'),(100,1,'Admin','table_regenerate_qr','table #5','id:5','127.0.0.1','2026-07-27 10:22:48'),(101,1,'Admin','table_regenerate_qr','table #2','id:2','127.0.0.1','2026-07-27 10:22:52'),(102,1,'Admin','table_regenerate_qr','table #3','id:3','127.0.0.1','2026-07-27 10:22:55'),(103,1,'Admin','table_regenerate_qr','table #4','id:4','127.0.0.1','2026-07-27 10:22:58'),(104,1,'Admin','table_regenerate_qr','table #8','id:8','127.0.0.1','2026-07-27 10:23:03'),(105,1,'Admin','table_regenerate_qr','table #3','id:3','127.0.0.1','2026-07-27 10:23:06'),(106,1,'Admin','table_regenerate_qr','table #2','id:2','127.0.0.1','2026-07-27 10:23:09'),(107,1,'Admin','table_regenerate_qr','table #1','id:1','127.0.0.1','2026-07-27 10:23:13'),(108,1,'Admin','table_regenerate_qr','table #5','id:5','127.0.0.1','2026-07-27 10:23:21'),(109,1,'Admin','table_regenerate_qr','table #6','id:6','127.0.0.1','2026-07-27 10:23:28'),(110,1,'Admin','table_regenerate_qr','table #7','id:7','127.0.0.1','2026-07-27 10:23:34'),(111,1,'Admin','table_regenerate_qr','table #8','id:8','127.0.0.1','2026-07-27 10:23:38'),(112,1,'Admin','table_regenerate_qr','table #11','id:12','127.0.0.1','2026-07-27 10:23:43'),(113,1,'Admin','table_regenerate_qr','table #10','id:10','127.0.0.1','2026-07-27 10:23:49'),(114,1,'Admin','table_regenerate_qr','table #9','id:9','127.0.0.1','2026-07-27 10:23:53'),(115,1,'Admin','kitchen_confirm_payment','order #27','method:cash amount:3.50','127.0.0.1','2026-07-27 12:38:44'),(116,1,'Admin','kitchen_confirm_payment','order #28','method:cash amount:1.50','127.0.0.1','2026-07-27 12:39:07');
/*!40000 ALTER TABLE `bar_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_categories`
--

DROP TABLE IF EXISTS `bar_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_categories` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_categories`
--

LOCK TABLES `bar_categories` WRITE;
/*!40000 ALTER TABLE `bar_categories` DISABLE KEYS */;
INSERT INTO `bar_categories` VALUES (1,'Beers',1),(2,'Cocktails',2),(3,'Wines',3),(4,'Spirits',4),(5,'Soft Drinks',5),(6,'Food & Snacks',6),(7,'Fruit',20);
/*!40000 ALTER TABLE `bar_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_inventory`
--

DROP TABLE IF EXISTS `bar_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_inventory` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT '0.00',
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pcs',
  `supplier_id` int unsigned DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `low_stock_threshold` decimal(10,2) NOT NULL DEFAULT '10.00',
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `bar_inventory_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `bar_suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_inventory`
--

LOCK TABLES `bar_inventory` WRITE;
/*!40000 ALTER TABLE `bar_inventory` DISABLE KEYS */;
INSERT INTO `bar_inventory` VALUES (1,'Heineken Bottles',54.00,'bottles',NULL,NULL,12.00),(2,'Star Lager Bottles',36.00,'bottles',NULL,NULL,12.00),(3,'Guinness Draught Keg',2.00,'kegs',NULL,NULL,1.00),(4,'Vodka',3.00,'bottles',NULL,NULL,2.00),(5,'Coca Cola',110.00,'cans',NULL,NULL,24.00),(6,'Lemon Juice',8.00,'liters',NULL,NULL,5.00),(7,'Ice Blocks',4.00,'bags',NULL,NULL,2.00),(8,'Fresh Mint',21.00,'bunches',NULL,NULL,3.00),(9,'Limes',20.00,'pcs',NULL,NULL,10.00),(10,'Sugar Syrup',5.00,'liters',NULL,NULL,3.00),(11,'Banana',20.00,'bunch',3,2000.00,10.00),(12,'Banana',20.00,'pcs',NULL,NULL,5.00);
/*!40000 ALTER TABLE `bar_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_inventory_transactions`
--

DROP TABLE IF EXISTS `bar_inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_inventory_transactions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `inventory_id` int unsigned NOT NULL,
  `type` enum('in','out','adjust') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `inventory_id` (`inventory_id`),
  CONSTRAINT `bar_inventory_transactions_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `bar_inventory` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_inventory_transactions`
--

LOCK TABLES `bar_inventory_transactions` WRITE;
/*!40000 ALTER TABLE `bar_inventory_transactions` DISABLE KEYS */;
INSERT INTO `bar_inventory_transactions` VALUES (1,5,'in',10.00,'','2026-07-23 10:56:14'),(2,5,'in',10.00,'','2026-07-23 10:56:29'),(3,5,'in',10.00,'','2026-07-23 10:56:50'),(4,5,'in',10.00,'','2026-07-23 11:25:20'),(5,5,'in',10.00,'','2026-07-23 11:25:31'),(6,8,'in',10.00,'','2026-07-23 11:26:10'),(7,1,'in',1.00,'test','2026-07-23 11:31:45'),(8,8,'in',10.00,'','2026-07-23 11:32:37'),(9,11,'in',20.00,'Initial stock','2026-07-23 11:33:48'),(10,1,'in',5.00,'restock test','2026-07-23 11:39:17'),(11,12,'in',20.00,'Initial stock','2026-07-23 11:50:41');
/*!40000 ALTER TABLE `bar_inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_login_attempts`
--

DROP TABLE IF EXISTS `bar_login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_login_attempts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_created` (`email`,`created_at`),
  KEY `idx_ip_created` (`ip`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_login_attempts`
--

LOCK TABLES `bar_login_attempts` WRITE;
/*!40000 ALTER TABLE `bar_login_attempts` DISABLE KEYS */;
INSERT INTO `bar_login_attempts` VALUES (29,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:29:28'),(30,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:30:37'),(31,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:31:25'),(32,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:32:12'),(33,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:32:42'),(34,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:36:28'),(35,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:37:08'),(36,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:44:18'),(37,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:46:52'),(38,'admin@bar.com','127.0.0.1',1,'2026-07-24 14:47:11'),(39,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:43:09'),(40,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:45:08'),(41,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:45:38'),(42,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:48:18'),(43,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:49:13'),(44,'admin@bar.com','127.0.0.1',1,'2026-07-25 12:50:34'),(45,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:02:37'),(46,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:03:04'),(47,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:05:03'),(48,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:05:20'),(49,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:06:09'),(50,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:07:13'),(51,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:07:41'),(52,'admin@bar.com','192.168.100.12',1,'2026-07-25 13:21:36'),(53,'admin@bar.com','127.0.0.1',1,'2026-07-25 13:30:22'),(54,'admin@bar.com','127.0.0.1',1,'2026-07-27 09:04:42');
/*!40000 ALTER TABLE `bar_login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_menu_inventory`
--

DROP TABLE IF EXISTS `bar_menu_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_menu_inventory` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `menu_item_id` int unsigned NOT NULL,
  `inventory_id` int unsigned NOT NULL,
  `qty_per_sale` decimal(10,4) NOT NULL DEFAULT '1.0000',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_menu_inv` (`menu_item_id`,`inventory_id`),
  KEY `inventory_id` (`inventory_id`),
  CONSTRAINT `bar_menu_inventory_ibfk_1` FOREIGN KEY (`menu_item_id`) REFERENCES `bar_menu_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bar_menu_inventory_ibfk_2` FOREIGN KEY (`inventory_id`) REFERENCES `bar_inventory` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_menu_inventory`
--

LOCK TABLES `bar_menu_inventory` WRITE;
/*!40000 ALTER TABLE `bar_menu_inventory` DISABLE KEYS */;
INSERT INTO `bar_menu_inventory` VALUES (1,3,5,1.0000),(2,18,11,1.0000);
/*!40000 ALTER TABLE `bar_menu_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_menu_items`
--

DROP TABLE IF EXISTS `bar_menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_menu_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int unsigned NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `bar_menu_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `bar_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_menu_items`
--

LOCK TABLES `bar_menu_items` WRITE;
/*!40000 ALTER TABLE `bar_menu_items` DISABLE KEYS */;
INSERT INTO `bar_menu_items` VALUES (1,1,'Heineken Bottle','Taste the original',3.50,'item_1_1784803342.jpg',1,'2026-07-21 12:25:39'),(2,1,'Guinness Draught','Stout beer 330ml',4.00,'item_2_1784803347.jpg',1,'2026-07-21 12:25:40'),(3,1,'Star Lager','Classic lager beer 330ml',2.50,'item_3_1784803416.jpg',1,'2026-07-21 12:25:40'),(4,2,'Mojito','Mint, lime, rum, soda water',6.00,'item_4_1784803352.jpg',1,'2026-07-21 12:25:40'),(5,2,'Margarita','Tequila, lime, triple sec',7.00,'item_5_1784803358.jpg',1,'2026-07-21 12:25:40'),(6,2,'Pina Colada','Rum, coconut, pineapple',6.50,'item_6_1784803418.jpg',1,'2026-07-21 12:25:40'),(7,3,'Merlot (Glass)','Red wine glass',5.00,'item_7_1784803366.jpg',1,'2026-07-21 12:25:40'),(8,3,'Sauvignon Blanc (Glass)','White wine glass',5.00,'item_8_1784803374.jpg',1,'2026-07-21 12:25:40'),(9,4,'Johnnie Walker Black','Blended scotch whiskey 50ml',8.00,'item_9_1784803380.jpg',1,'2026-07-21 12:25:40'),(10,4,'Jameson Irish Whiskey','Irish whiskey 50ml',7.00,'item_10_1784803383.jpg',1,'2026-07-21 12:25:40'),(11,5,'Coca-Cola','Can 330ml',1.50,'item_11_1784803389.jpg',1,'2026-07-21 12:25:40'),(12,5,'Sprite','Can 330ml',1.50,'item_12_1784803392.jpg',1,'2026-07-21 12:25:40'),(13,6,'Chicken Wings (6pcs)','Buffalo wings with dip',8.00,'item_13_1784803396.jpg',1,'2026-07-21 12:25:40'),(14,6,'French Fries','Crispy fries with ketchup',4.00,'item_14_1784803399.jpg',1,'2026-07-21 12:25:40'),(15,6,'Club Sandwich','Grilled chicken, bacon, lettuce, tomato',7.00,'item_15_1784803404.jpg',1,'2026-07-21 12:25:40'),(16,7,'Mango','Italian mango',500.00,'item_16_1784803932.jpeg',1,'2026-07-23 09:36:50'),(18,5,'Banana','Auto-created from inventory',1.50,'item_18_1784807861.jpeg',1,'2026-07-23 11:50:50');
/*!40000 ALTER TABLE `bar_menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_order_items`
--

DROP TABLE IF EXISTS `bar_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_order_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `menu_item_id` int unsigned NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `unit_price` decimal(10,2) NOT NULL,
  `status` enum('ordered','preparing','ready','served','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ordered',
  `notes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `bar_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `bar_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bar_order_items_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `bar_menu_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_order_items`
--

LOCK TABLES `bar_order_items` WRITE;
/*!40000 ALTER TABLE `bar_order_items` DISABLE KEYS */;
INSERT INTO `bar_order_items` VALUES (1,1,1,2,3.50,'ordered',NULL),(2,1,3,3,2.50,'ordered',NULL),(3,1,4,1,6.00,'ordered',NULL),(4,2,5,2,7.00,'ready',NULL),(23,27,1,1,3.50,'served',NULL),(24,28,18,1,1.50,'served',NULL),(25,29,18,1,1.50,'ordered',NULL),(26,30,12,1,1.50,'ordered',NULL),(27,31,18,1,1.50,'ordered',NULL),(28,32,8,1,5.00,'ordered',NULL),(29,33,1,1,3.50,'ordered',NULL),(30,34,2,1,4.00,'served',NULL);
/*!40000 ALTER TABLE `bar_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_orders`
--

DROP TABLE IF EXISTS `bar_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `table_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `status` enum('pending','accepted','ready','served','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `source` enum('staff','customer') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'staff',
  `customer_session` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_method` enum('cash','pos','card','online') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `closed_at` timestamp NULL DEFAULT NULL,
  `served_at` timestamp NULL DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `void_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voided_by` int unsigned DEFAULT NULL,
  `discount_type` enum('none','percent','fixed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `discount_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `table_id` (`table_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `bar_orders_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `bar_tables` (`id`),
  CONSTRAINT `bar_orders_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `bar_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_orders`
--

LOCK TABLES `bar_orders` WRITE;
/*!40000 ALTER TABLE `bar_orders` DISABLE KEYS */;
INSERT INTO `bar_orders` VALUES (1,1,1,'closed','customer','test-session-123','cash',20.50,1,'2026-07-21 13:19:14','2026-07-21 13:19:28',NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(2,1,1,'closed','customer','test-session-456','cash',15.40,1,'2026-07-21 13:19:41','2026-07-23 13:57:56',NULL,14.00,1.40,0,NULL,NULL,'none',0.00,0.00),(27,1,NULL,'served','customer','55d9735cbdf1efdd5a2a57395b286e7b','cash',3.50,1,'2026-07-27 11:24:41',NULL,'2026-07-27 12:30:47',0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(28,3,NULL,'closed','customer','77ba0889db05b6e75a6dae6c102a2917','cash',1.50,1,'2026-07-27 12:06:42','2026-07-27 12:39:18','2026-07-27 12:39:18',0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(29,3,NULL,'pending','customer','77ba0889db05b6e75a6dae6c102a2917','online',1.50,0,'2026-07-27 12:07:01',NULL,NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(30,3,NULL,'pending','customer','77ba0889db05b6e75a6dae6c102a2917','pos',1.50,0,'2026-07-27 12:07:22',NULL,NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(31,3,NULL,'pending','customer','77ba0889db05b6e75a6dae6c102a2917','card',1.50,0,'2026-07-27 12:07:34',NULL,NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(32,3,NULL,'pending','customer','77ba0889db05b6e75a6dae6c102a2917','online',5.00,0,'2026-07-27 12:28:20',NULL,NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(33,3,NULL,'pending','customer','56ac0bcf1fc9806d1fa996d3bcf5a52e','online',3.50,0,'2026-07-27 12:48:55',NULL,NULL,0.00,0.00,0,NULL,NULL,'none',0.00,0.00),(34,3,NULL,'closed','customer','56ac0bcf1fc9806d1fa996d3bcf5a52e','online',4.00,1,'2026-07-27 12:59:31','2026-07-27 13:25:49','2026-07-27 13:25:49',0.00,0.00,0,NULL,NULL,'none',0.00,0.00);
/*!40000 ALTER TABLE `bar_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_payments`
--

DROP TABLE IF EXISTS `bar_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `method` enum('cash','card','transfer','online') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bar_payments_reference` (`reference`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `bar_payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `bar_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_payments`
--

LOCK TABLES `bar_payments` WRITE;
/*!40000 ALTER TABLE `bar_payments` DISABLE KEYS */;
INSERT INTO `bar_payments` VALUES (1,1,20.50,'cash',NULL,'2026-07-21 13:19:28'),(2,2,15.40,'cash',NULL,'2026-07-23 13:57:56'),(9,27,3.50,'cash',NULL,'2026-07-27 12:38:44'),(10,28,1.50,'cash',NULL,'2026-07-27 12:39:07'),(11,34,4.00,'online','BAR-1785157171824','2026-07-27 12:59:57');
/*!40000 ALTER TABLE `bar_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_refunds`
--

DROP TABLE IF EXISTS `bar_refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_refunds` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `method` enum('cash','card','transfer','online') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `bar_refunds_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `bar_orders` (`id`),
  CONSTRAINT `bar_refunds_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `bar_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_refunds`
--

LOCK TABLES `bar_refunds` WRITE;
/*!40000 ALTER TABLE `bar_refunds` DISABLE KEYS */;
/*!40000 ALTER TABLE `bar_refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_restocks`
--

DROP TABLE IF EXISTS `bar_restocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_restocks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `inventory_id` int unsigned NOT NULL,
  `supplier_id` int unsigned DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `received_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `inventory_id` (`inventory_id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `bar_restocks_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `bar_inventory` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bar_restocks_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `bar_suppliers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bar_restocks_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `bar_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_restocks`
--

LOCK TABLES `bar_restocks` WRITE;
/*!40000 ALTER TABLE `bar_restocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `bar_restocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_roles`
--

DROP TABLE IF EXISTS `bar_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_roles`
--

LOCK TABLES `bar_roles` WRITE;
/*!40000 ALTER TABLE `bar_roles` DISABLE KEYS */;
INSERT INTO `bar_roles` VALUES (1,'admin'),(3,'bartender'),(2,'manager'),(4,'server');
/*!40000 ALTER TABLE `bar_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_settings`
--

DROP TABLE IF EXISTS `bar_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_settings` (
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_settings`
--

LOCK TABLES `bar_settings` WRITE;
/*!40000 ALTER TABLE `bar_settings` DISABLE KEYS */;
INSERT INTO `bar_settings` VALUES ('bar_address','123 Main Street'),('bar_name','The Bar'),('bar_url','http://192.168.100.13/bar'),('print_agent_token',''),('qr_message','Scan. Order. Sip. Repeat.'),('receipt_footer','Thank you for your patronage!'),('tax_rate','10');
/*!40000 ALTER TABLE `bar_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_shift_reconciliation`
--

DROP TABLE IF EXISTS `bar_shift_reconciliation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_shift_reconciliation` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `shift_date` date NOT NULL,
  `opened_at` datetime DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `opening_float` decimal(10,2) NOT NULL DEFAULT '0.00',
  `expected_cash` decimal(10,2) NOT NULL DEFAULT '0.00',
  `actual_cash` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_card` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_transfer` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_online` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_sales` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_refunds` decimal(10,2) NOT NULL DEFAULT '0.00',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `status` enum('open','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  PRIMARY KEY (`id`),
  KEY `idx_shift_date` (`shift_date`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `bar_shift_reconciliation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `bar_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_shift_reconciliation`
--

LOCK TABLES `bar_shift_reconciliation` WRITE;
/*!40000 ALTER TABLE `bar_shift_reconciliation` DISABLE KEYS */;
/*!40000 ALTER TABLE `bar_shift_reconciliation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_suppliers`
--

DROP TABLE IF EXISTS `bar_suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_suppliers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `address` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_suppliers`
--

LOCK TABLES `bar_suppliers` WRITE;
/*!40000 ALTER TABLE `bar_suppliers` DISABLE KEYS */;
INSERT INTO `bar_suppliers` VALUES (1,'Premium Beverages Ltd','John Okonkwo','08031234567','john@premiumbeverages.ng','12 Industrial Road, Lagos',NULL,1,'2026-07-23 11:15:25'),(2,'Global Drinks Distributors','Amanda Yusuf','08079876543','amanda@globaldrinks.ng','45 Trade Fair Complex, Abuja',NULL,1,'2026-07-23 11:15:25'),(3,'Fresh Farms Produce','Musa Ibrahim','09051234567','musa@freshfarms.ng','8 Farm Road, Ibadan',NULL,1,'2026-07-23 11:15:25'),(4,'Quick Supplies Co.','Chioma Obi','08123456789','chioma@quicksupplies.ng','22 Market Street, Enugu',NULL,1,'2026-07-23 11:15:25');
/*!40000 ALTER TABLE `bar_suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_tables`
--

DROP TABLE IF EXISTS `bar_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_tables` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `number` int NOT NULL,
  `capacity` int NOT NULL DEFAULT '2',
  `status` enum('free','occupied','reserved') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'free',
  `qr_token` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`),
  UNIQUE KEY `qr_token` (`qr_token`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_tables`
--

LOCK TABLES `bar_tables` WRITE;
/*!40000 ALTER TABLE `bar_tables` DISABLE KEYS */;
INSERT INTO `bar_tables` VALUES (1,1,2,'occupied','2c5e2914-89a5-11f1-8d56-e4a4718c36ce',1),(2,2,2,'free','2a69a589-89a5-11f1-8d56-e4a4718c36ce',1),(3,3,4,'free','28761447-89a5-11f1-8d56-e4a4718c36ce',1),(4,4,4,'free','23a428cc-89a5-11f1-8d56-e4a4718c36ce',1),(5,5,6,'free','310be186-89a5-11f1-8d56-e4a4718c36ce',1),(6,6,6,'free','357940c2-89a5-11f1-8d56-e4a4718c36ce',1),(7,7,8,'free','38c7c226-89a5-11f1-8d56-e4a4718c36ce',1),(8,8,2,'free','3b6cc5e0-89a5-11f1-8d56-e4a4718c36ce',1),(9,9,2,'free','4491b35b-89a5-11f1-8d56-e4a4718c36ce',1),(10,10,4,'free','41c98ea8-89a5-11f1-8d56-e4a4718c36ce',1),(12,11,2,'free','3e369e84-89a5-11f1-8d56-e4a4718c36ce',1);
/*!40000 ALTER TABLE `bar_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bar_users`
--

DROP TABLE IF EXISTS `bar_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bar_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reset_token` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `bar_users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `bar_roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bar_users`
--

LOCK TABLES `bar_users` WRITE;
/*!40000 ALTER TABLE `bar_users` DISABLE KEYS */;
INSERT INTO `bar_users` VALUES (1,'Admin','admin@bar.com','$2y$10$HiKgmLWN0xlSmnDrSuKkGOIV9rhZvzFcUSpqYVi4rLSJWWLp03QPa',1,1,'2026-07-21 12:25:39',NULL,NULL);
/*!40000 ALTER TABLE `bar_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_borrows`
--

DROP TABLE IF EXISTS `book_borrows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_borrows` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `book_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `borrowed_at` date NOT NULL,
  `due_date` date NOT NULL,
  `returned_at` date DEFAULT NULL,
  `fine` decimal(8,2) DEFAULT '0.00',
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bb_user` (`user_id`),
  KEY `idx_bb_book` (`book_id`),
  KEY `idx_bb_org` (`organization_id`),
  KEY `idx_bb_campus` (`campus_id`),
  KEY `idx_bb_section` (`section_id`),
  CONSTRAINT `book_borrows_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE,
  CONSTRAINT `book_borrows_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_borrows`
--

LOCK TABLES `book_borrows` WRITE;
/*!40000 ALTER TABLE `book_borrows` DISABLE KEYS */;
/*!40000 ALTER TABLE `book_borrows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `books`
--

DROP TABLE IF EXISTS `books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `books` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isbn` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int unsigned DEFAULT '1',
  `available` int unsigned DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `idx_books_org` (`organization_id`),
  KEY `idx_books_campus` (`campus_id`),
  KEY `idx_books_section` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `books`
--

LOCK TABLES `books` WRITE;
/*!40000 ALTER TABLE `books` DISABLE KEYS */;
/*!40000 ALTER TABLE `books` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bus_allocations`
--

DROP TABLE IF EXISTS `bus_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_allocations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int unsigned NOT NULL,
  `student_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_id` (`student_id`),
  KEY `idx_ba_term` (`term_id`),
  KEY `idx_ba_route` (`route_id`),
  CONSTRAINT `bus_allocations_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `bus_routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bus_allocations_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bus_allocations_ibfk_3` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bus_allocations`
--

LOCK TABLES `bus_allocations` WRITE;
/*!40000 ALTER TABLE `bus_allocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `bus_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bus_routes`
--

DROP TABLE IF EXISTS `bus_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_routes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bus_id` int unsigned NOT NULL,
  `route_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stops` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `bus_id` (`bus_id`),
  CONSTRAINT `bus_routes_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bus_routes`
--

LOCK TABLES `bus_routes` WRITE;
/*!40000 ALTER TABLE `bus_routes` DISABLE KEYS */;
/*!40000 ALTER TABLE `bus_routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buses`
--

DROP TABLE IF EXISTS `buses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `plate_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int unsigned DEFAULT '30',
  `driver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `driver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plate_no` (`plate_no`),
  KEY `idx_buses_org` (`organization_id`),
  KEY `idx_buses_campus` (`campus_id`),
  KEY `idx_buses_section` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buses`
--

LOCK TABLES `buses` WRITE;
/*!40000 ALTER TABLE `buses` DISABLE KEYS */;
/*!40000 ALTER TABLE `buses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campuses`
--

DROP TABLE IF EXISTS `campuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campuses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `address` text,
  `phone` varchar(30) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `organization_id` (`organization_id`),
  CONSTRAINT `campuses_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campuses`
--

LOCK TABLES `campuses` WRITE;
/*!40000 ALTER TABLE `campuses` DISABLE KEYS */;
INSERT INTO `campuses` VALUES (1,1,'Main Campus',NULL,NULL,1,'2026-07-17 11:42:36','2026-07-17 11:42:36');
/*!40000 ALTER TABLE `campuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `student_id` int unsigned NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Graduation',
  `session_id` int unsigned NOT NULL,
  `issued_by` int unsigned NOT NULL,
  `issued_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cert` (`student_id`,`type`,`session_id`),
  KEY `session_id` (`session_id`),
  KEY `issued_by` (`issued_by`),
  KEY `idx_cert_org` (`organization_id`),
  KEY `idx_cert_campus` (`campus_id`),
  KEY `idx_cert_section` (`section_id`),
  CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `certificates_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `academic_sessions` (`id`),
  CONSTRAINT `certificates_ibfk_3` FOREIGN KEY (`issued_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chart_of_accounts`
--

DROP TABLE IF EXISTS `chart_of_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chart_of_accounts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('asset','liability','equity','income','expense') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_system` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chart_of_accounts`
--

LOCK TABLES `chart_of_accounts` WRITE;
/*!40000 ALTER TABLE `chart_of_accounts` DISABLE KEYS */;
INSERT INTO `chart_of_accounts` VALUES (1,'1000','Cash in Hand','asset',1,'2026-07-10 11:59:24'),(2,'1010','Bank Account','asset',1,'2026-07-10 11:59:24'),(3,'2000','Accounts Payable','liability',1,'2026-07-10 11:59:24'),(4,'3000','Retained Earnings','equity',1,'2026-07-10 11:59:24'),(5,'4000','Tuition Fees','income',1,'2026-07-10 11:59:24'),(6,'4010','Transport Fees','income',1,'2026-07-10 11:59:24'),(7,'4020','Hostel Fees','income',1,'2026-07-10 11:59:24'),(8,'4030','Other Fees / Miscellaneous','income',1,'2026-07-10 11:59:24'),(9,'5000','Salaries & Wages','expense',1,'2026-07-10 11:59:24'),(10,'5010','Utilities','expense',1,'2026-07-10 11:59:24'),(11,'5020','Maintenance & Repairs','expense',1,'2026-07-10 11:59:24'),(12,'5030','Teaching Materials & Supplies','expense',1,'2026-07-10 11:59:24'),(13,'5040','Transport & Fuel','expense',1,'2026-07-10 11:59:24'),(14,'5050','Marketing & Admissions','expense',1,'2026-07-10 11:59:24'),(15,'5060','Administrative Expenses','expense',1,'2026-07-10 11:59:24'),(16,'5070','Other Expenses','expense',1,'2026-07-10 11:59:24'),(17,'2010','Tax Payable','liability',1,'2026-07-10 18:36:42'),(18,'2020','Pension Payable','liability',1,'2026-07-10 18:36:42'),(19,'2030','Other Deductions Payable','liability',1,'2026-07-10 18:36:42');
/*!40000 ALTER TABLE `chart_of_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_subjects`
--

DROP TABLE IF EXISTS `class_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subjects` (
  `class_id` int unsigned NOT NULL,
  `subject_id` int unsigned NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `teacher_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`class_id`,`subject_id`),
  KEY `subject_id` (`subject_id`),
  KEY `idx_cs_teacher` (`teacher_id`),
  KEY `idx_cs_org` (`organization_id`),
  KEY `idx_cs_campus` (`campus_id`),
  KEY `idx_cs_section` (`section_id`),
  CONSTRAINT `class_subjects_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_subjects_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_subjects_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_subjects`
--

LOCK TABLES `class_subjects` WRITE;
/*!40000 ALTER TABLE `class_subjects` DISABLE KEYS */;
INSERT INTO `class_subjects` VALUES (1,1,1,NULL,2,2),(1,13,1,NULL,2,NULL),(1,14,1,NULL,2,NULL),(1,15,1,NULL,2,NULL),(1,16,1,NULL,2,NULL),(1,17,1,NULL,2,NULL),(1,18,1,NULL,2,NULL),(1,19,1,NULL,2,NULL),(1,20,1,NULL,2,NULL),(1,21,1,NULL,2,NULL),(1,22,1,NULL,2,NULL),(1,23,1,NULL,2,NULL),(1,24,1,NULL,2,NULL),(1,25,1,NULL,2,NULL),(1,26,1,NULL,2,NULL),(1,27,1,NULL,2,NULL),(2,2,1,NULL,1,NULL),(2,3,1,NULL,1,NULL),(2,4,1,NULL,1,NULL),(2,5,1,NULL,1,NULL),(2,6,1,NULL,1,17),(2,7,1,NULL,1,NULL),(2,8,1,NULL,1,NULL),(2,9,1,NULL,1,NULL),(2,10,1,NULL,1,NULL),(2,11,1,NULL,1,NULL),(2,12,1,NULL,1,NULL),(3,2,1,NULL,1,NULL),(3,3,1,NULL,1,NULL),(3,4,1,NULL,1,NULL),(3,5,1,NULL,1,NULL),(3,6,1,NULL,1,NULL),(3,7,1,NULL,1,NULL),(3,8,1,NULL,1,NULL),(3,9,1,NULL,1,NULL),(3,10,1,NULL,1,NULL),(3,11,1,NULL,1,NULL),(3,12,1,NULL,1,NULL),(4,2,1,NULL,1,NULL),(4,3,1,NULL,1,NULL),(4,4,1,NULL,1,NULL),(4,5,1,NULL,1,NULL),(4,6,1,NULL,1,NULL),(4,7,1,NULL,1,NULL),(4,8,1,NULL,1,NULL),(4,9,1,NULL,1,NULL),(4,10,1,NULL,1,NULL),(4,11,1,NULL,1,NULL),(4,12,1,NULL,1,NULL),(5,2,1,NULL,1,NULL),(5,3,1,NULL,1,NULL),(5,4,1,NULL,1,NULL),(5,5,1,NULL,1,NULL),(5,6,1,NULL,1,NULL),(5,7,1,NULL,1,NULL),(5,8,1,NULL,1,NULL),(5,9,1,NULL,1,NULL),(5,10,1,NULL,1,NULL),(5,11,1,NULL,1,NULL),(5,12,1,NULL,1,NULL),(6,2,1,NULL,1,NULL),(6,3,1,NULL,1,NULL),(6,4,1,NULL,1,NULL),(6,5,1,NULL,1,NULL),(6,6,1,NULL,1,NULL),(6,7,1,NULL,1,NULL),(6,8,1,NULL,1,NULL),(6,9,1,NULL,1,NULL),(6,10,1,NULL,1,NULL),(6,11,1,NULL,1,NULL),(6,12,1,NULL,1,NULL),(7,2,1,NULL,1,NULL),(7,3,1,NULL,1,NULL),(7,4,1,NULL,1,NULL),(7,5,1,NULL,1,NULL),(7,6,1,NULL,1,NULL),(7,7,1,NULL,1,NULL),(7,8,1,NULL,1,NULL),(7,9,1,NULL,1,NULL),(7,10,1,NULL,1,NULL),(7,11,1,NULL,1,NULL),(7,12,1,NULL,1,NULL),(8,2,1,NULL,1,NULL),(8,3,1,NULL,1,NULL),(8,4,1,NULL,1,NULL),(8,5,1,NULL,1,NULL),(8,6,1,NULL,1,NULL),(8,7,1,NULL,1,NULL),(8,8,1,NULL,1,NULL),(8,9,1,NULL,1,NULL),(8,10,1,NULL,1,NULL),(8,11,1,NULL,1,NULL),(8,12,1,NULL,1,NULL),(9,2,1,NULL,1,NULL),(9,3,1,NULL,1,NULL),(9,4,1,NULL,1,NULL),(9,5,1,NULL,1,NULL),(9,6,1,NULL,1,NULL),(9,7,1,NULL,1,NULL),(9,8,1,NULL,1,NULL),(9,9,1,NULL,1,NULL),(9,10,1,NULL,1,NULL),(9,11,1,NULL,1,NULL),(9,12,1,NULL,1,NULL),(10,2,1,NULL,1,NULL),(10,3,1,NULL,1,NULL),(10,4,1,NULL,1,NULL),(10,5,1,NULL,1,NULL),(10,6,1,NULL,1,NULL),(10,7,1,NULL,1,NULL),(10,8,1,NULL,1,NULL),(10,9,1,NULL,1,NULL),(10,10,1,NULL,1,NULL),(10,11,1,NULL,1,NULL),(10,12,1,NULL,1,NULL),(11,2,1,NULL,1,NULL),(11,3,1,NULL,1,NULL),(11,4,1,NULL,1,NULL),(11,5,1,NULL,1,NULL),(11,6,1,NULL,1,NULL),(11,7,1,NULL,1,NULL),(11,8,1,NULL,1,NULL),(11,9,1,NULL,1,NULL),(11,10,1,NULL,1,NULL),(11,11,1,NULL,1,NULL),(11,12,1,NULL,1,NULL),(12,2,1,NULL,1,NULL),(12,3,1,NULL,1,NULL),(12,4,1,NULL,1,NULL),(12,5,1,NULL,1,NULL),(12,6,1,NULL,1,NULL),(12,7,1,NULL,1,NULL),(12,8,1,NULL,1,NULL),(12,9,1,NULL,1,NULL),(12,10,1,NULL,1,NULL),(12,11,1,NULL,1,NULL),(12,12,1,NULL,1,NULL),(13,2,1,NULL,1,NULL),(13,3,1,NULL,1,NULL),(13,4,1,NULL,1,NULL),(13,5,1,NULL,1,NULL),(13,6,1,NULL,1,NULL),(13,7,1,NULL,1,NULL),(13,8,1,NULL,1,NULL),(13,9,1,NULL,1,NULL),(13,10,1,NULL,1,NULL),(13,11,1,NULL,1,NULL),(13,12,1,NULL,1,NULL),(14,1,1,NULL,2,NULL),(14,13,1,NULL,2,NULL),(14,14,1,NULL,2,NULL),(14,15,1,NULL,2,NULL),(14,16,1,NULL,2,NULL),(14,17,1,NULL,2,NULL),(14,18,1,NULL,2,NULL),(14,19,1,NULL,2,NULL),(14,20,1,NULL,2,NULL),(14,21,1,NULL,2,NULL),(14,22,1,NULL,2,NULL),(14,23,1,NULL,2,NULL),(14,24,1,NULL,2,NULL),(14,25,1,NULL,2,NULL),(14,26,1,NULL,2,NULL),(14,27,1,NULL,2,NULL),(15,1,1,NULL,2,NULL),(15,13,1,NULL,2,NULL),(15,14,1,NULL,2,NULL),(15,15,1,NULL,2,NULL),(15,16,1,NULL,2,NULL),(15,17,1,NULL,2,NULL),(15,18,1,NULL,2,NULL),(15,19,1,NULL,2,NULL),(15,20,1,NULL,2,NULL),(15,21,1,NULL,2,NULL),(15,22,1,NULL,2,NULL),(15,23,1,NULL,2,NULL),(15,24,1,NULL,2,NULL),(15,25,1,NULL,2,NULL),(15,26,1,NULL,2,NULL),(15,27,1,NULL,2,NULL),(16,1,1,NULL,2,NULL),(16,13,1,NULL,2,NULL),(16,14,1,NULL,2,NULL),(16,15,1,NULL,2,NULL),(16,16,1,NULL,2,NULL),(16,17,1,NULL,2,NULL),(16,18,1,NULL,2,NULL),(16,19,1,NULL,2,NULL),(16,20,1,NULL,2,NULL),(16,21,1,NULL,2,NULL),(16,22,1,NULL,2,NULL),(16,23,1,NULL,2,NULL),(16,24,1,NULL,2,NULL),(16,25,1,NULL,2,NULL),(16,26,1,NULL,2,NULL),(16,27,1,NULL,2,NULL),(17,1,1,NULL,2,NULL),(17,13,1,NULL,2,NULL),(17,14,1,NULL,2,NULL),(17,15,1,NULL,2,NULL),(17,16,1,NULL,2,NULL),(17,17,1,NULL,2,NULL),(17,18,1,NULL,2,NULL),(17,19,1,NULL,2,NULL),(17,20,1,NULL,2,NULL),(17,21,1,NULL,2,NULL),(17,22,1,NULL,2,NULL),(17,23,1,NULL,2,NULL),(17,24,1,NULL,2,NULL),(17,25,1,NULL,2,NULL),(17,26,1,NULL,2,NULL),(17,27,1,NULL,2,NULL),(18,1,1,NULL,2,NULL),(18,13,1,NULL,2,NULL),(18,14,1,NULL,2,NULL),(18,15,1,NULL,2,NULL),(18,16,1,NULL,2,NULL),(18,17,1,NULL,2,NULL),(18,18,1,NULL,2,NULL),(18,19,1,NULL,2,NULL),(18,20,1,NULL,2,NULL),(18,21,1,NULL,2,NULL),(18,22,1,NULL,2,NULL),(18,23,1,NULL,2,NULL),(18,24,1,NULL,2,NULL),(18,25,1,NULL,2,NULL),(18,26,1,NULL,2,NULL),(18,27,1,NULL,2,NULL),(19,1,1,NULL,2,NULL),(19,13,1,NULL,2,NULL),(19,14,1,NULL,2,NULL),(19,15,1,NULL,2,NULL),(19,16,1,NULL,2,NULL),(19,17,1,NULL,2,NULL),(19,18,1,NULL,2,NULL),(19,19,1,NULL,2,NULL),(19,20,1,NULL,2,NULL),(19,21,1,NULL,2,NULL),(19,22,1,NULL,2,NULL),(19,23,1,NULL,2,NULL),(19,24,1,NULL,2,NULL),(19,25,1,NULL,2,NULL),(19,26,1,NULL,2,NULL),(19,27,1,NULL,2,NULL),(20,1,1,NULL,2,NULL),(20,13,1,NULL,2,NULL),(20,14,1,NULL,2,NULL),(20,15,1,NULL,2,NULL),(20,16,1,NULL,2,NULL),(20,17,1,NULL,2,NULL),(20,18,1,NULL,2,NULL),(20,19,1,NULL,2,NULL),(20,20,1,NULL,2,NULL),(20,21,1,NULL,2,NULL),(20,22,1,NULL,2,NULL),(20,23,1,NULL,2,NULL),(20,24,1,NULL,2,NULL),(20,25,1,NULL,2,NULL),(20,26,1,NULL,2,180),(20,27,1,NULL,2,NULL),(21,1,1,NULL,2,NULL),(21,13,1,NULL,2,NULL),(21,14,1,NULL,2,NULL),(21,15,1,NULL,2,NULL),(21,16,1,NULL,2,NULL),(21,17,1,NULL,2,NULL),(21,18,1,NULL,2,NULL),(21,19,1,NULL,2,NULL),(21,20,1,NULL,2,NULL),(21,21,1,NULL,2,NULL),(21,22,1,NULL,2,NULL),(21,23,1,NULL,2,NULL),(21,24,1,NULL,2,NULL),(21,25,1,NULL,2,NULL),(21,26,1,NULL,2,NULL),(21,27,1,NULL,2,NULL),(22,1,1,NULL,2,NULL),(22,13,1,NULL,2,NULL),(22,14,1,NULL,2,NULL),(22,15,1,NULL,2,NULL),(22,16,1,NULL,2,NULL),(22,17,1,NULL,2,NULL),(22,18,1,NULL,2,NULL),(22,19,1,NULL,2,NULL),(22,20,1,NULL,2,NULL),(22,21,1,NULL,2,NULL),(22,22,1,NULL,2,NULL),(22,23,1,NULL,2,NULL),(22,24,1,NULL,2,NULL),(22,25,1,NULL,2,NULL),(22,26,1,NULL,2,NULL),(22,27,1,NULL,2,NULL),(23,1,1,NULL,2,NULL),(23,13,1,NULL,2,NULL),(23,14,1,NULL,2,NULL),(23,15,1,NULL,2,NULL),(23,16,1,NULL,2,NULL),(23,17,1,NULL,2,NULL),(23,18,1,NULL,2,NULL),(23,19,1,NULL,2,NULL),(23,20,1,NULL,2,NULL),(23,21,1,NULL,2,NULL),(23,22,1,NULL,2,NULL),(23,23,1,NULL,2,NULL),(23,24,1,NULL,2,NULL),(23,25,1,NULL,2,NULL),(23,26,1,NULL,2,NULL),(23,27,1,NULL,2,NULL),(24,1,1,NULL,2,NULL),(24,13,1,NULL,2,NULL),(24,14,1,NULL,2,NULL),(24,15,1,NULL,2,NULL),(24,16,1,NULL,2,NULL),(24,17,1,NULL,2,NULL),(24,18,1,NULL,2,NULL),(24,19,1,NULL,2,NULL),(24,20,1,NULL,2,NULL),(24,21,1,NULL,2,NULL),(24,22,1,NULL,2,NULL),(24,23,1,NULL,2,NULL),(24,24,1,NULL,2,NULL),(24,25,1,NULL,2,NULL),(24,26,1,NULL,2,NULL),(24,27,1,NULL,2,NULL),(25,1,1,NULL,2,NULL),(25,13,1,NULL,2,NULL),(25,14,1,NULL,2,NULL),(25,15,1,NULL,2,NULL),(25,16,1,NULL,2,NULL),(25,17,1,NULL,2,NULL),(25,18,1,NULL,2,NULL),(25,19,1,NULL,2,NULL),(25,20,1,NULL,2,NULL),(25,21,1,NULL,2,NULL),(25,22,1,NULL,2,NULL),(25,23,1,NULL,2,NULL),(25,24,1,NULL,2,NULL),(25,25,1,NULL,2,NULL),(25,26,1,NULL,2,NULL),(25,27,1,NULL,2,NULL),(26,1,1,NULL,2,NULL),(26,13,1,NULL,2,NULL),(26,14,1,NULL,2,NULL),(26,15,1,NULL,2,NULL),(26,16,1,NULL,2,NULL),(26,17,1,NULL,2,NULL),(26,18,1,NULL,2,NULL),(26,19,1,NULL,2,NULL),(26,20,1,NULL,2,NULL),(26,21,1,NULL,2,NULL),(26,22,1,NULL,2,NULL),(26,23,1,NULL,2,NULL),(26,24,1,NULL,2,NULL),(26,25,1,NULL,2,NULL),(26,26,1,NULL,2,NULL),(26,27,1,NULL,2,NULL),(27,1,1,NULL,2,NULL),(27,13,1,NULL,2,NULL),(27,14,1,NULL,2,NULL),(27,15,1,NULL,2,NULL),(27,16,1,NULL,2,NULL),(27,17,1,NULL,2,NULL),(27,18,1,NULL,2,NULL),(27,19,1,NULL,2,NULL),(27,20,1,NULL,2,NULL),(27,21,1,NULL,2,NULL),(27,22,1,NULL,2,NULL),(27,23,1,NULL,2,NULL),(27,24,1,NULL,2,NULL),(27,25,1,NULL,2,NULL),(27,26,1,NULL,2,NULL),(27,27,1,NULL,2,NULL),(28,1,1,NULL,2,NULL),(28,13,1,NULL,2,NULL),(28,14,1,NULL,2,NULL),(28,15,1,NULL,2,NULL),(28,16,1,NULL,2,NULL),(28,17,1,NULL,2,NULL),(28,18,1,NULL,2,NULL),(28,19,1,NULL,2,NULL),(28,20,1,NULL,2,NULL),(28,21,1,NULL,2,NULL),(28,22,1,NULL,2,NULL),(28,23,1,NULL,2,NULL),(28,24,1,NULL,2,NULL),(28,25,1,NULL,2,NULL),(28,26,1,NULL,2,NULL),(28,27,1,NULL,2,NULL),(29,1,1,NULL,2,NULL),(29,13,1,NULL,2,NULL),(29,14,1,NULL,2,NULL),(29,15,1,NULL,2,NULL),(29,16,1,NULL,2,NULL),(29,17,1,NULL,2,NULL),(29,18,1,NULL,2,NULL),(29,19,1,NULL,2,NULL),(29,20,1,NULL,2,NULL),(29,21,1,NULL,2,NULL),(29,22,1,NULL,2,NULL),(29,23,1,NULL,2,NULL),(29,24,1,NULL,2,NULL),(29,25,1,NULL,2,NULL),(29,26,1,NULL,2,NULL),(29,27,1,NULL,2,NULL),(30,1,1,NULL,2,NULL),(30,13,1,NULL,2,NULL),(30,14,1,NULL,2,NULL),(30,15,1,NULL,2,NULL),(30,16,1,NULL,2,NULL),(30,17,1,NULL,2,NULL),(30,18,1,NULL,2,NULL),(30,19,1,NULL,2,NULL),(30,20,1,NULL,2,NULL),(30,21,1,NULL,2,NULL),(30,22,1,NULL,2,NULL),(30,23,1,NULL,2,NULL),(30,24,1,NULL,2,NULL),(30,25,1,NULL,2,NULL),(30,26,1,NULL,2,NULL),(30,27,1,NULL,2,NULL),(31,1,1,NULL,2,NULL),(31,13,1,NULL,2,NULL),(31,14,1,NULL,2,NULL),(31,15,1,NULL,2,NULL),(31,16,1,NULL,2,NULL),(31,17,1,NULL,2,NULL),(31,18,1,NULL,2,NULL),(31,19,1,NULL,2,NULL),(31,20,1,NULL,2,NULL),(31,21,1,NULL,2,NULL),(31,22,1,NULL,2,NULL),(31,23,1,NULL,2,NULL),(31,24,1,NULL,2,NULL),(31,25,1,NULL,2,NULL),(31,26,1,NULL,2,NULL),(31,27,1,NULL,2,NULL);
/*!40000 ALTER TABLE `class_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `classes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `arm` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'A',
  `class_master_id` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `fk_class_master` (`class_master_id`),
  KEY `idx_classes_org` (`organization_id`),
  KEY `idx_classes_campus` (`campus_id`),
  KEY `idx_classes_cb` (`created_by`),
  KEY `idx_classes_ub` (`updated_by`),
  CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_class_master` FOREIGN KEY (`class_master_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES (1,1,NULL,2,'SS 1','A',2,'2026-05-13 13:01:16',NULL,NULL),(2,1,NULL,1,'Primary 1','A',17,'2026-05-27 13:51:44',NULL,NULL),(3,1,NULL,1,'Primary 1','B',175,'2026-05-27 13:51:44',NULL,NULL),(4,1,NULL,1,'Primary 2','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(5,1,NULL,1,'Primary 2','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(6,1,NULL,1,'Primary 3','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(7,1,NULL,1,'Primary 3','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(8,1,NULL,1,'Primary 4','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(9,1,NULL,1,'Primary 4','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(10,1,NULL,1,'Primary 5','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(11,1,NULL,1,'Primary 5','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(12,1,NULL,1,'Primary 6','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(13,1,NULL,1,'Primary 6','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(14,1,NULL,2,'JSS 1','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(15,1,NULL,2,'JSS 1','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(16,1,NULL,2,'JSS 1','C',NULL,'2026-05-27 13:51:44',NULL,NULL),(17,1,NULL,2,'JSS 2','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(18,1,NULL,2,'JSS 2','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(19,1,NULL,2,'JSS 2','C',NULL,'2026-05-27 13:51:44',NULL,NULL),(20,1,NULL,2,'JSS 3','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(21,1,NULL,2,'JSS 3','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(22,1,NULL,2,'JSS 3','C',NULL,'2026-05-27 13:51:44',NULL,NULL),(23,1,NULL,2,'SSS 1','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(24,1,NULL,2,'SSS 1','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(25,1,NULL,2,'SSS 1','C',NULL,'2026-05-27 13:51:44',NULL,NULL),(26,1,NULL,2,'SSS 2','A',NULL,'2026-05-27 13:51:44',NULL,NULL),(27,1,NULL,2,'SSS 2','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(28,1,NULL,2,'SSS 2','C',NULL,'2026-05-27 13:51:44',NULL,NULL),(29,1,NULL,2,'SSS 3','A',180,'2026-05-27 13:51:44',NULL,NULL),(30,1,NULL,2,'SSS 3','B',NULL,'2026-05-27 13:51:44',NULL,NULL),(31,1,NULL,2,'SSS 3','C',NULL,'2026-05-27 13:51:44',NULL,NULL);
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cumulative_gpa`
--

DROP TABLE IF EXISTS `cumulative_gpa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cumulative_gpa` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `gpa` decimal(4,2) DEFAULT '0.00',
  `total_units` int unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gpa` (`student_id`,`term_id`),
  KEY `term_id` (`term_id`),
  CONSTRAINT `cumulative_gpa_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cumulative_gpa_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cumulative_gpa`
--

LOCK TABLES `cumulative_gpa` WRITE;
/*!40000 ALTER TABLE `cumulative_gpa` DISABLE KEYS */;
/*!40000 ALTER TABLE `cumulative_gpa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` int unsigned DEFAULT NULL,
  `recipient_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('sent','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'sent',
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `recipient_type` enum('individual','role','class','all') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'individual',
  `recipient_count` int DEFAULT '1',
  `type` enum('sent','draft') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'sent',
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `email_logs_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,1,'dankwarai02@gmail.com','School fees','You have to pay on time','sent','2026-05-26 15:30:32','individual',1,'sent'),(2,1,'dankwarai02@gmail.com','sacscd','scc cc  ','sent','2026-05-26 15:39:30','individual',1,'sent'),(3,1,'aharunamuhammad1503@gmail.com','sdfg','xZXczx','sent','2026-05-26 15:42:30','individual',1,'sent'),(4,1,'Dankwarai02@gmail.com','Reminder: School Fees Due','<p>Dear Parent/Guardian,</p><p>This is a reminder that school fees for the current term are due. Kindly ensure payment is made before the deadline to avoid any disruption to your child\'s education.</p><p>Please visit the school accounts office or use the online payment portal.</p><p>Thank you for your cooperation.</p>','sent','2026-05-26 15:51:30','individual',1,'sent'),(5,1,'amakamak3070@gmail.com','Welcome Back to a New Term!','<p>Dear Students and Parents,</p><p>We warmly welcome you back to a new and exciting term! We hope you had a restful holiday and are ready to learn and grow.</p><p>Please ensure all required materials and fees are ready. We look forward to a productive term together.</p>','sent','2026-05-31 09:13:39','individual',1,'sent'),(11,NULL,'abdurrahmanalhassan775@gmail.com','Verify your email address','Hi,<br><br>Please confirm your email address for <strong>Amina Royal Academy</strong> by clicking the link below:<br><br><a href=\"http://localhost/school/verify-email?token=0802ff8b48a310e9c280e91ee6d13cdc61d2014521acb4d093c1368be073bfc7\">http://localhost/school/verify-email?token=0802ff8b48a310e9c280e91ee6d13cdc61d2014521acb4d093c1368be073bfc7</a><br><br>This link expires in 24 hours. If you didn\'t request this, you can ignore this email.','sent','2026-07-17 10:41:31','individual',1,'sent'),(12,NULL,'sadiq@gmail.com','Verify your email address','Hi,<br><br>Please confirm your email address for <strong>Amina Royal Academy</strong> by clicking the link below:<br><br><a href=\"http://localhost/school/verify-email?token=10f89af93deef3e979f3f80a092ec599cd9bed6287b48f053b7a0e12dfdb63b2\">http://localhost/school/verify-email?token=10f89af93deef3e979f3f80a092ec599cd9bed6287b48f053b7a0e12dfdb63b2</a><br><br>This link expires in 24 hours. If you didn\'t request this, you can ignore this email.','sent','2026-07-17 14:44:12','individual',1,'sent');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_verifications`
--

DROP TABLE IF EXISTS `email_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_verifications` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_token_hash` (`token_hash`),
  CONSTRAINT `email_verifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_verifications`
--

LOCK TABLES `email_verifications` WRITE;
/*!40000 ALTER TABLE `email_verifications` DISABLE KEYS */;
INSERT INTO `email_verifications` VALUES (8,196,'29a8615694f99f0865bb820c42934c9bb8905a16f9492a950e6d1c57d27bdf5c','2026-07-18 11:41:26','2026-07-17 10:41:26'),(9,197,'4373db36d3b2eb194c380bab44c04eab264cab2233ea3a3f8b9842e1b56ea6f0','2026-07-18 15:44:07','2026-07-17 14:44:07');
/*!40000 ALTER TABLE `email_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_attendance`
--

DROP TABLE IF EXISTS `exam_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_attendance` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `exam_id` int unsigned NOT NULL,
  `student_id` int unsigned NOT NULL,
  `status` enum('present','absent','late') COLLATE utf8mb4_unicode_ci DEFAULT 'present',
  `check_in_time` datetime DEFAULT NULL,
  `recorded_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_exam_attendance` (`exam_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `exam_attendance_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_attendance_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_attendance`
--

LOCK TABLES `exam_attendance` WRITE;
/*!40000 ALTER TABLE `exam_attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_malpractices`
--

DROP TABLE IF EXISTS `exam_malpractices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_malpractices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `exam_id` int unsigned NOT NULL,
  `student_id` int unsigned NOT NULL,
  `incident_type` enum('tab_switch','copy_paste','unauthorized_device','unauthorized_person','cheating','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `description` text COLLATE utf8mb4_unicode_ci,
  `evidence` json DEFAULT NULL,
  `reported_by` int unsigned DEFAULT NULL,
  `status` enum('pending','investigating','confirmed','dismissed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `action_taken` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`),
  KEY `student_id` (`student_id`),
  KEY `reported_by` (`reported_by`),
  CONSTRAINT `exam_malpractices_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_malpractices_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_malpractices_ibfk_3` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_malpractices`
--

LOCK TABLES `exam_malpractices` WRITE;
/*!40000 ALTER TABLE `exam_malpractices` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_malpractices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_question_bank_links`
--

DROP TABLE IF EXISTS `exam_question_bank_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_question_bank_links` (
  `exam_id` int unsigned NOT NULL,
  `question_id` int unsigned NOT NULL,
  `sort_order` smallint unsigned DEFAULT '0',
  PRIMARY KEY (`exam_id`,`question_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `exam_question_bank_links_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_question_bank_links_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_question_bank_links`
--

LOCK TABLES `exam_question_bank_links` WRITE;
/*!40000 ALTER TABLE `exam_question_bank_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_question_bank_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_questions`
--

DROP TABLE IF EXISTS `exam_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_questions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `exam_id` int unsigned NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_a` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_b` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_c` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_d` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer` enum('a','b','c','d') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`),
  KEY `idx_eq_org` (`organization_id`),
  KEY `idx_eq_campus` (`campus_id`),
  KEY `idx_eq_section` (`section_id`),
  CONSTRAINT `exam_questions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_questions`
--

LOCK TABLES `exam_questions` WRITE;
/*!40000 ALTER TABLE `exam_questions` DISABLE KEYS */;
INSERT INTO `exam_questions` VALUES (1,1,NULL,2,1,'what is computer','is a computer','Is a machine','Is a language','Integration of difference component','d',NULL,NULL),(2,1,NULL,1,2,'What is English?','Is a English','Just English','Leave it as English','May be English','a',NULL,NULL);
/*!40000 ALTER TABLE `exam_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_results`
--

DROP TABLE IF EXISTS `exam_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_results` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `exam_id` int unsigned NOT NULL,
  `student_id` int unsigned NOT NULL,
  `score` tinyint unsigned DEFAULT '0',
  `external_grade` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacher_comment` text COLLATE utf8mb4_unicode_ci,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_exam_result` (`exam_id`,`student_id`),
  KEY `student_id` (`student_id`),
  KEY `idx_er_org` (`organization_id`),
  KEY `idx_er_campus` (`campus_id`),
  KEY `idx_er_section` (`section_id`),
  CONSTRAINT `exam_results_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_results_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_results`
--

LOCK TABLES `exam_results` WRITE;
/*!40000 ALTER TABLE `exam_results` DISABLE KEYS */;
INSERT INTO `exam_results` VALUES (1,1,NULL,2,1,164,0,NULL,NULL,'2026-05-31 09:05:39',NULL,NULL),(2,1,NULL,1,3,16,98,NULL,NULL,'2026-06-14 17:44:22',NULL,NULL),(3,1,NULL,1,3,14,60,NULL,NULL,'2026-06-14 17:44:22',NULL,NULL),(4,1,NULL,1,3,17,70,NULL,NULL,'2026-06-14 17:44:22',NULL,NULL),(5,1,NULL,1,3,18,50,NULL,NULL,'2026-06-14 17:44:22',NULL,NULL),(6,1,NULL,1,3,15,40,NULL,NULL,'2026-06-14 17:44:22',NULL,NULL);
/*!40000 ALTER TABLE `exam_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_sessions`
--

DROP TABLE IF EXISTS `exam_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `exam_id` int unsigned NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `invigilator_id` int unsigned DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`),
  KEY `invigilator_id` (`invigilator_id`),
  CONSTRAINT `exam_sessions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_sessions_ibfk_2` FOREIGN KEY (`invigilator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_sessions`
--

LOCK TABLES `exam_sessions` WRITE;
/*!40000 ALTER TABLE `exam_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exams`
--

DROP TABLE IF EXISTS `exams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exams` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `subject_id` int unsigned NOT NULL,
  `class_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exam_type` enum('cbt','pen_paper') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cbt',
  `status` enum('draft','submitted','approved','graded') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `question_paper_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submitted_by` int unsigned DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `duration` smallint unsigned NOT NULL,
  `max_score` tinyint unsigned DEFAULT '100',
  `start_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `external_type_id` int unsigned DEFAULT NULL,
  `external_grade` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `has_schedule` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `class_id` (`class_id`),
  KEY `term_id` (`term_id`),
  KEY `idx_exams_org` (`organization_id`),
  KEY `idx_exams_campus` (`campus_id`),
  KEY `idx_exams_section` (`section_id`),
  KEY `idx_exams_cb` (`created_by`),
  CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_3` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES (1,1,NULL,2,25,1,1,'Test','cbt','draft',NULL,NULL,NULL,60,100,'2026-05-27 19:00:00',1,NULL,NULL,0,'2026-05-27 15:51:52',NULL,NULL),(2,1,NULL,1,14,2,1,'Session','cbt','draft',NULL,NULL,NULL,60,100,NULL,0,NULL,NULL,0,'2026-05-27 16:02:57',NULL,NULL),(3,1,NULL,1,13,2,1,'paper 1','pen_paper','draft',NULL,NULL,NULL,60,100,'2026-06-14 18:30:00',1,NULL,NULL,0,'2026-06-14 17:11:43',NULL,NULL);
/*!40000 ALTER TABLE `exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `expense_date` date NOT NULL,
  `account_id` int unsigned NOT NULL,
  `vendor` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` enum('cash','bank','online') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `section_id` int unsigned DEFAULT NULL,
  `status` enum('pending','approved','rejected','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `recorded_by` int unsigned DEFAULT NULL,
  `approved_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `section_id` (`section_id`),
  KEY `recorded_by` (`recorded_by`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_status` (`status`),
  KEY `idx_expense_date` (`expense_date`),
  KEY `idx_exp_org` (`organization_id`),
  KEY `idx_exp_campus` (`campus_id`),
  CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`),
  CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL,
  CONSTRAINT `expenses_ibfk_3` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `expenses_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_exam_types`
--

DROP TABLE IF EXISTS `external_exam_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_exam_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_exam_types`
--

LOCK TABLES `external_exam_types` WRITE;
/*!40000 ALTER TABLE `external_exam_types` DISABLE KEYS */;
INSERT INTO `external_exam_types` VALUES (1,'WAEC','West African Examinations Council',1),(2,'NECO','National Examinations Council',1),(3,'JAMB','Joint Admissions and Matriculation Board',1);
/*!40000 ALTER TABLE `external_exam_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_grading_scales`
--

DROP TABLE IF EXISTS `external_grading_scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_grading_scales` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `external_type_id` int unsigned NOT NULL,
  `grade` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_score` tinyint unsigned NOT NULL,
  `max_score` tinyint unsigned NOT NULL,
  `remark` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_point` decimal(3,1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `external_type_id` (`external_type_id`),
  CONSTRAINT `external_grading_scales_ibfk_1` FOREIGN KEY (`external_type_id`) REFERENCES `external_exam_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_grading_scales`
--

LOCK TABLES `external_grading_scales` WRITE;
/*!40000 ALTER TABLE `external_grading_scales` DISABLE KEYS */;
INSERT INTO `external_grading_scales` VALUES (1,1,'A1',75,100,'Excellent',1.0),(2,1,'B2',70,74,'Very Good',2.0),(3,1,'B3',65,69,'Good',3.0),(4,1,'C4',60,64,'Credit',4.0),(5,1,'C5',55,59,'Credit',5.0),(6,1,'C6',50,54,'Credit',6.0),(7,1,'D7',45,49,'Pass',7.0),(8,1,'E8',40,44,'Pass',8.0),(9,1,'F9',0,39,'Fail',9.0);
/*!40000 ALTER TABLE `external_grading_scales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_adjustments`
--

DROP TABLE IF EXISTS `fee_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_adjustments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `fee_id` int unsigned NOT NULL,
  `kind` enum('discount','scholarship','waiver','penalty') COLLATE utf8mb4_unicode_ci NOT NULL,
  `adjust_type` enum('percent','fixed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fixed',
  `value` decimal(12,2) NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_adjustment` (`student_id`,`fee_id`,`kind`),
  KEY `fee_id` (`fee_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `fee_adjustments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_adjustments_ibfk_2` FOREIGN KEY (`fee_id`) REFERENCES `fee_structures` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_adjustments_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_adjustments`
--

LOCK TABLES `fee_adjustments` WRITE;
/*!40000 ALTER TABLE `fee_adjustments` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_adjustments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_installment_plans`
--

DROP TABLE IF EXISTS `fee_installment_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_installment_plans` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `fee_id` int unsigned NOT NULL,
  `installments` tinyint unsigned NOT NULL DEFAULT '2',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_plan` (`student_id`,`fee_id`),
  KEY `fee_id` (`fee_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `fee_installment_plans_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_installment_plans_ibfk_2` FOREIGN KEY (`fee_id`) REFERENCES `fee_structures` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_installment_plans_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_installment_plans`
--

LOCK TABLES `fee_installment_plans` WRITE;
/*!40000 ALTER TABLE `fee_installment_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_installment_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_reminder_log`
--

DROP TABLE IF EXISTS `fee_reminder_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_reminder_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `term_id` (`term_id`),
  KEY `sent_by` (`sent_by`),
  KEY `idx_student_term` (`student_id`,`term_id`),
  CONSTRAINT `fee_reminder_log_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_reminder_log_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_reminder_log_ibfk_3` FOREIGN KEY (`sent_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_reminder_log`
--

LOCK TABLES `fee_reminder_log` WRITE;
/*!40000 ALTER TABLE `fee_reminder_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_reminder_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_structures`
--

DROP TABLE IF EXISTS `fee_structures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_structures` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `class_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `term_id` (`term_id`),
  KEY `idx_fee_class_term` (`class_id`,`term_id`),
  KEY `idx_fee_org` (`organization_id`),
  KEY `idx_fee_campus` (`campus_id`),
  KEY `idx_fee_section` (`section_id`),
  KEY `idx_fee_cb` (`created_by`),
  CONSTRAINT `fee_structures_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_structures_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_structures`
--

LOCK TABLES `fee_structures` WRITE;
/*!40000 ALTER TABLE `fee_structures` DISABLE KEYS */;
INSERT INTO `fee_structures` VALUES (1,1,NULL,2,1,1,'Tuition Fee',2000.00,NULL,NULL);
/*!40000 ALTER TABLE `fee_structures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grading_scales`
--

DROP TABLE IF EXISTS `grading_scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grading_scales` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned NOT NULL,
  `grade` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_score` tinyint unsigned NOT NULL,
  `max_score` tinyint unsigned NOT NULL,
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_point` decimal(3,1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `idx_grading_org` (`organization_id`),
  KEY `idx_grading_campus` (`campus_id`),
  CONSTRAINT `grading_scales_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grading_scales`
--

LOCK TABLES `grading_scales` WRITE;
/*!40000 ALTER TABLE `grading_scales` DISABLE KEYS */;
/*!40000 ALTER TABLE `grading_scales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `holidays`
--

DROP TABLE IF EXISTS `holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `holidays` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `is_recurring` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`,`name`),
  KEY `section_id` (`section_id`),
  KEY `idx_holidays_org` (`organization_id`),
  KEY `idx_holidays_campus` (`campus_id`),
  CONSTRAINT `holidays_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holidays`
--

LOCK TABLES `holidays` WRITE;
/*!40000 ALTER TABLE `holidays` DISABLE KEYS */;
INSERT INTO `holidays` VALUES (1,1,NULL,NULL,'New Year','2026-01-01',1,'2026-07-16 13:19:31'),(2,1,NULL,NULL,'Easter Monday','2026-04-06',1,'2026-07-16 13:19:31'),(3,1,NULL,NULL,'Workers Day','2026-05-01',1,'2026-07-16 13:19:31'),(4,1,NULL,NULL,'Democracy Day','2026-06-12',1,'2026-07-16 13:19:31'),(5,1,NULL,NULL,'Independence Day','2026-10-01',1,'2026-07-16 13:19:31'),(6,1,NULL,NULL,'Christmas Day','2026-12-25',1,'2026-07-16 13:19:31'),(7,1,NULL,NULL,'Boxing Day','2026-12-26',1,'2026-07-16 13:19:31');
/*!40000 ALTER TABLE `holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entries`
--

DROP TABLE IF EXISTS `journal_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `entry_date` date NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_type` enum('payment','salary','expense','manual') COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_source` (`source_type`,`source_id`),
  KEY `idx_entry_date` (`entry_date`),
  KEY `idx_je_org` (`organization_id`),
  KEY `idx_je_campus` (`campus_id`),
  CONSTRAINT `journal_entries_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL,
  CONSTRAINT `journal_entries_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entries`
--

LOCK TABLES `journal_entries` WRITE;
/*!40000 ALTER TABLE `journal_entries` DISABLE KEYS */;
INSERT INTO `journal_entries` VALUES (1,1,NULL,'2026-06-21','Salary paid — June 2026 (backfill)','salary',1,NULL,181,'2026-07-10 11:59:40'),(2,1,NULL,'2026-06-21','Salary paid — June 2026 (backfill)','salary',2,NULL,181,'2026-07-10 11:59:40'),(3,1,NULL,'2026-06-21','Salary paid — June 2026 (backfill)','salary',3,2,181,'2026-07-10 11:59:40'),(10,1,NULL,'2026-07-15','Salary paid — July 2026','salary',6,2,1,'2026-07-15 18:30:00');
/*!40000 ALTER TABLE `journal_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_lines`
--

DROP TABLE IF EXISTS `journal_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_lines` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `journal_entry_id` int unsigned NOT NULL,
  `account_id` int unsigned NOT NULL,
  `debit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `credit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_journal_entry` (`journal_entry_id`),
  KEY `idx_account` (`account_id`),
  CONSTRAINT `journal_lines_ibfk_1` FOREIGN KEY (`journal_entry_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE,
  CONSTRAINT `journal_lines_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_lines`
--

LOCK TABLES `journal_lines` WRITE;
/*!40000 ALTER TABLE `journal_lines` DISABLE KEYS */;
INSERT INTO `journal_lines` VALUES (1,1,9,200000.00,0.00,'2026-07-10 11:59:40'),(2,1,2,0.00,200000.00,'2026-07-10 11:59:40'),(3,2,9,23456879.00,0.00,'2026-07-10 11:59:40'),(4,2,2,0.00,23456879.00,'2026-07-10 11:59:40'),(5,3,9,10000.00,0.00,'2026-07-10 11:59:40'),(6,3,2,0.00,10000.00,'2026-07-10 11:59:40'),(21,10,9,20000.00,0.00,'2026-07-15 18:30:00'),(22,10,2,0.00,20000.00,'2026-07-15 18:30:00');
/*!40000 ALTER TABLE `journal_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `identifier` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ip_identifier` (`ip_address`,`identifier`),
  KEY `idx_attempted_at` (`attempted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
INSERT INTO `login_attempts` VALUES (10,'::1','wrong@test.com','2026-06-30 18:00:56'),(13,'::1','wrong@test.com','2026-06-30 18:02:36'),(14,'::1','wrong@test.com','2026-06-30 18:03:05'),(16,'::1','wrong@test.com','2026-06-30 18:06:14'),(17,'::1','wrong@test.com','2026-06-30 18:09:22'),(18,'::1','wrong@test.com','2026-07-10 12:03:08'),(19,'::1','wrong@test.com','2026-07-10 12:35:01'),(20,'127.0.0.1','amak@gmail.com','2026-07-10 13:26:06'),(21,'::1','fb@gmail.com','2026-07-10 13:27:33'),(24,'::1','wrong@test.com','2026-07-10 14:50:48'),(25,'::1','wrong@test.com','2026-07-10 19:59:17'),(26,'::1','wrong@test.com','2026-07-10 21:05:40'),(27,'::1','wrong@test.com','2026-07-10 21:13:49'),(28,'::1','wrong@test.com','2026-07-10 21:43:47'),(29,'::1','wrong@test.com','2026-07-10 22:10:28'),(30,'::1','wrong@test.com','2026-07-10 22:16:08'),(31,'127.0.0.1','fbb@gmail.com','2026-07-10 22:18:53'),(39,'127.0.0.1','','2026-07-15 19:25:16'),(40,'127.0.0.1','amak@gmail.com','2026-07-16 09:39:33'),(41,'::1','admin@school.com','2026-07-16 10:48:10'),(42,'::1','admin@school.com','2026-07-16 10:49:03'),(43,'::1','admin@school.com','2026-07-16 10:49:32'),(44,'::1','admin@school.com','2026-07-16 10:50:16'),(45,'::1','admin@school.com','2026-07-16 10:51:13'),(46,'::1','','2026-07-16 10:51:13'),(47,'192.168.100.32','Admin@shool.com','2026-07-16 11:53:37'),(48,'192.168.100.32','admin@school.com','2026-07-16 11:54:02'),(49,'192.168.100.32','Admin@school.com','2026-07-16 11:54:31'),(50,'192.168.100.32','fb@gmail.com','2026-07-16 11:55:02'),(51,'127.0.0.1','','2026-07-16 12:07:18'),(52,'127.0.0.1','admin@school.com','2026-07-17 09:45:37'),(53,'127.0.0.1','admin@school.com','2026-07-17 09:45:40'),(54,'127.0.0.1','admin@school.com','2026-07-17 09:45:52'),(55,'127.0.0.1','abubakar17hm@gmail.com','2026-07-17 09:46:21'),(56,'::1','admin@school.com','2026-07-17 12:47:36'),(57,'::1','admin@school.com','2026-07-17 12:48:03'),(58,'::1','wrong@test.com','2026-07-17 12:48:05'),(59,'::1','admin@school.com','2026-07-17 12:48:08'),(60,'::1','admin@school.com','2026-07-17 12:48:25'),(61,'::1','admin@school.com','2026-07-17 12:48:45'),(62,'::1','wrong@test.com','2026-07-17 12:53:19'),(63,'::1','wrong@test.com','2026-07-17 12:56:00'),(64,'::1','abubakar17hm@gmail.com','2026-07-17 12:58:22'),(69,'127.0.0.1','','2026-07-17 14:39:27');
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` int unsigned NOT NULL,
  `receiver_id` int unsigned NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_msg_receiver` (`receiver_id`,`is_read`),
  KEY `idx_msg_sender` (`sender_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,2,1,'saffhgj,.',1,'2026-05-13 15:27:30'),(2,1,2,'cvbnm',1,'2026-05-13 15:38:17'),(3,2,1,'xcnm',0,'2026-05-13 15:38:59'),(4,3,2,'wrer',0,'2026-05-13 15:51:09'),(5,3,1,'swdfgf',1,'2026-05-13 15:51:21'),(6,1,3,'dfghjk',0,'2026-05-13 15:52:18'),(7,7,1,'I cannot pay school fees',0,'2026-05-26 09:42:32'),(8,2,5,'Class Master Abubakar Muhammad has submitted a CBT exam for review: \"Computer Studies\" — SS 1 A. Note: I&#039;m just testing',0,'2026-05-27 16:00:49'),(9,17,5,'Class Master Mai mota has submitted a CBT exam for review: \"English Language\" — Primary 1 A. Note: abcd',0,'2026-05-27 16:04:57'),(10,173,2,'QDEG',0,'2026-05-27 17:22:16'),(11,183,17,'Assalamu Alaikum',0,'2026-06-24 14:51:16'),(12,17,183,'Yayi daidai thank',0,'2026-06-24 14:52:07'),(13,181,2,'hello were have u been',0,'2026-07-12 10:29:16'),(17,181,184,'payment reminder',0,'2026-07-16 12:02:54');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int unsigned NOT NULL DEFAULT '1',
  `executed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration` (`migration`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'001_add_payment_method_index.sql',1,'2026-07-12 09:01:42'),(2,'002_finance_ledger.sql',1,'2026-07-12 09:01:43'),(3,'003_invoicing.sql',1,'2026-07-12 09:01:43'),(4,'005_password_resets.sql',1,'2026-07-12 09:01:43'),(5,'006_remember_tokens.sql',1,'2026-07-12 09:06:26'),(6,'007_api_tokens.sql',1,'2026-07-12 09:28:15'),(7,'008_two_factor_auth.sql',1,'2026-07-12 09:54:52'),(8,'009_email_verification.sql',1,'2026-07-12 10:22:47'),(9,'010_qr_attendance.sql',1,'2026-07-12 13:58:15'),(10,'011_notification_templates.sql',1,'2026-07-12 14:09:21'),(11,'012_alumni.sql',1,'2026-07-12 14:15:32'),(12,'013_question_bank.sql',1,'2026-07-15 16:57:28'),(13,'014_affective_assessment.sql',1,'2026-07-15 16:57:28'),(14,'015_gpa_cgpa.sql',1,'2026-07-15 16:57:29'),(15,'016_exam_scheduling.sql',1,'2026-07-15 16:57:29'),(16,'017_malpractices.sql',1,'2026-07-15 16:57:30'),(17,'018_external_exams.sql',1,'2026-07-15 16:57:30'),(18,'019_transcripts.sql',1,'2026-07-15 16:57:31'),(19,'020_external_grade_results.sql',1,'2026-07-15 16:57:53'),(20,'004_finance_full.sql',0,'2026-07-17 11:41:56'),(21,'021_subject_categories.sql',0,'2026-07-17 11:41:56'),(22,'022_staff_certificate_and_bank.sql',0,'2026-07-17 11:41:56'),(23,'023_timetable_saturday.sql',0,'2026-07-17 11:41:56'),(24,'024_promotion_chains.sql',0,'2026-07-17 11:41:56'),(25,'025_landing_accent_colors.sql',0,'2026-07-17 11:41:56'),(26,'026_user_theme_preference.sql',0,'2026-07-17 11:41:56'),(27,'027_remove_hostel.sql',0,'2026-07-17 11:41:57'),(28,'028_holidays_table.sql',0,'2026-07-17 11:41:57'),(29,'029_user_role_sections.sql',0,'2026-07-17 11:41:57'),(30,'030_organizations_campuses.sql',2,'2026-07-17 11:42:38'),(31,'031_add_org_campus_ids.sql',0,'2026-07-17 11:44:24'),(32,'032_seed_permissions.sql',3,'2026-07-17 11:44:25'),(33,'033_add_audit_columns.sql',4,'2026-07-17 12:05:39');
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_templates`
--

DROP TABLE IF EXISTS `notification_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_templates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_template` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body_template` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_templates`
--

LOCK TABLES `notification_templates` WRITE;
/*!40000 ALTER TABLE `notification_templates` DISABLE KEYS */;
INSERT INTO `notification_templates` VALUES (1,'new_message','New Internal Message','New message from {{sender_name}}','{{body_preview}}',1,'2026-07-12 14:10:50'),(2,'application_status_contacted','Application Status: Contacted','Application Update','📞 Your application has been reviewed and we will be in touch soon.',1,'2026-07-12 14:09:21'),(3,'application_status_new','Application Status: New','Application Update','Your application status has been updated.',1,'2026-07-12 14:09:21'),(4,'new_application_admin','New Public Application (Admin Alert)','📋 New Application','{{applicant_name}} applied for {{role_name}}{{child_detail}} (Score: {{score}}%).',1,'2026-07-12 14:09:21'),(5,'exam_submitted_for_review','Exam Submitted for Review','📋 Exam Submission: {{subject_name}} ({{class_name}})','Class Master {{class_master_name}} has submitted a CBT exam for review: \"{{subject_name}}\" — {{class_name}}.{{note_suffix}}',1,'2026-07-12 14:09:21');
/*!40000 ALTER TABLE `notification_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notif_user` (`user_id`,`is_read`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'New message from Super Admin','cvbnm',1,'2026-05-13 15:38:17'),(2,1,'New message from Abubakar Muhammad','xcnm',1,'2026-05-13 15:38:59'),(3,2,'New message from Auta Amaka','wrer',1,'2026-05-13 15:51:09'),(4,1,'New message from Auta Amaka','swdfgf',1,'2026-05-13 15:51:21'),(5,3,'New message from Super Admin','dfghjk',1,'2026-05-13 15:52:18'),(6,1,'📋 New Admission Account','Amina Kabir Idris created a pending account. Email: abubakar19hm@gmail.com',1,'2026-05-26 09:29:51'),(7,6,'Admission Update','📞 Your admission enquiry has been reviewed and we will be in touch soon.',1,'2026-05-26 09:37:25'),(8,6,'🎉 Admission Approved!','Congratulations Amina! Your admission is approved. Your Student ID is SEC-2026-0002. You can now access your full dashboard.',1,'2026-05-26 09:38:43'),(9,1,'New message from Abubakar Haruna Muhammad','I cannot pay school fees',1,'2026-05-26 09:42:32'),(10,1,'📋 New Admission Account','Fatima Abubakar created a pending account. Email: dankwarai02@gmail.com',1,'2026-05-26 10:58:54'),(11,8,'🎉 Admission Approved!','Congratulations Fatima! Your admission is approved. Your Student ID is PRI-2026-0003. You can now access your full dashboard.',1,'2026-05-26 11:00:16'),(12,1,'📋 New Application','Adam Labaran Adam applied for Student.',1,'2026-05-26 13:48:11'),(13,1,'📋 New Application','Amina Royal Academy applied for Student.',1,'2026-05-26 15:06:26'),(14,5,'📋 Exam Submission: Computer Studies (SS 1 A)','Class Master Abubakar Muhammad has submitted a CBT exam for review: \"Computer Studies\" — SS 1 A. Note: I&#039;m just testing',1,'2026-05-27 16:00:49'),(15,5,'📋 Exam Submission: English Language (Primary 1 A)','Class Master Mai mota has submitted a CBT exam for review: \"English Language\" — Primary 1 A. Note: abcd',1,'2026-05-27 16:04:57'),(16,2,'New message from Test Student','QDEG',1,'2026-05-27 17:22:16'),(17,1,'📋 New Application','shema&#039;u applied for Student (Score: 100%).',1,'2026-05-31 16:15:32'),(18,1,'📋 New Application','shema\'u applied for Student (Score: 100%).',1,'2026-05-31 16:40:34'),(19,1,'📋 New Application','sani applied for Teacher (Score: 100%).',1,'2026-05-31 17:15:04'),(20,1,'📋 New Application','yahaya muhammad applied for Parent (Score: 30%).',1,'2026-06-24 13:32:26'),(21,1,'📋 New Application','muhammad yahaya muhammad applied for Parent (Score: 30%).',1,'2026-06-24 13:50:53'),(22,17,'New message from muhammad yahaya muhammad','Assalamu Alaikum',1,'2026-06-24 14:51:16'),(23,183,'New message from Mai mota','Yayi daidai thank',1,'2026-06-24 14:52:07'),(24,2,'New message from Fatima Habib','hello were have u been',0,'2026-07-12 10:29:16'),(28,184,'New message from Fatima Habib','payment reminder',0,'2026-07-16 12:02:54');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online_registrations`
--

DROP TABLE IF EXISTS `online_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_registrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `full_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parent_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completeness_score` tinyint unsigned DEFAULT '0',
  `section_id` int unsigned DEFAULT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('new','contacted','admitted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_oreg_status` (`status`),
  KEY `idx_oreg_org` (`organization_id`),
  KEY `idx_oreg_campus` (`campus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_registrations`
--

LOCK TABLES `online_registrations` WRITE;
/*!40000 ALTER TABLE `online_registrations` DISABLE KEYS */;
INSERT INTO `online_registrations` VALUES (1,1,NULL,'Amina Royal Academy',NULL,'arm@gmail.com','1234567890',NULL,NULL,NULL,NULL,0,NULL,'Secondary','He is going to SS 1','admitted','2026-05-14 14:43:15'),(2,1,NULL,'Amina Kabir Idris','Abubakar Haruna Muhammad','abubakar19hm@gmail.com','09020439378','09020439378',NULL,NULL,NULL,0,NULL,'Secondary',NULL,'admitted','2026-05-26 09:29:51'),(3,1,NULL,'Fatima Abubakar','Abubakar','dankwarai02@gmail.com','09020439378','09020439378',NULL,NULL,NULL,0,1,'Primary',NULL,'admitted','2026-05-26 10:58:54'),(4,1,NULL,'Adam Labaran Adam','Adam Labaran','amakamak3070@gmail.com','09121517457','09121517457',NULL,NULL,NULL,0,1,'Primary','Applied for role: Student','admitted','2026-05-26 13:48:11'),(5,1,NULL,'Amina Royal Academy','Abubakar','adamlabaranadam@gmail.com','09020439378','09020439378',NULL,NULL,NULL,0,1,'Primary','Applied for role: Student','admitted','2026-05-26 15:06:22'),(6,1,NULL,'shema&#039;u','isyaku','abdulmutallibabdulkarim30@gmail.com','09038926842','09000000002','2006-09-23','female','reg_1780244127_ece7a521.jpg',100,2,'Secondary','Applied for role: Student','admitted','2026-05-31 16:15:27'),(7,1,NULL,'shema\'u','isyaku','abddulmutallibabdulkarim30@gmail.com','09038926842','09000000002','2006-02-06','female','reg_1780245630_5fbe3114.jpg',100,2,'Secondary','Applied for role: Student','admitted','2026-05-31 16:40:30'),(8,1,NULL,'sani',NULL,'nestrikn@gmail.com','09038926842',NULL,'1999-02-04','male','reg_1780247699_db32611c.jpg',100,NULL,'None','Applied for role: Teacher','admitted','2026-05-31 17:14:59'),(9,1,NULL,'yahaya muhammad','sadiq yahaya','sadeeqbnyahya@gmail.com','09137214513','09121031077',NULL,NULL,NULL,30,NULL,'None','Applied for role: Parent','admitted','2026-06-24 13:32:21'),(10,1,NULL,'muhammad yahaya muhammad','yahaya muhammad','sadeeqyahya20@gmail.com','09137214513','09137214513',NULL,NULL,NULL,30,NULL,'None','Applied for role: Parent','admitted','2026-06-24 13:50:50');
/*!40000 ALTER TABLE `online_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organizations`
--

DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `address` text,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `settings` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizations`
--

LOCK TABLES `organizations` WRITE;
/*!40000 ALTER TABLE `organizations` DISABLE KEYS */;
INSERT INTO `organizations` VALUES (1,'Default Organization','default',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-17 11:42:36','2026-07-17 11:42:36');
/*!40000 ALTER TABLE `organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parents`
--

DROP TABLE IF EXISTS `parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `occupation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_par_org` (`organization_id`),
  CONSTRAINT `parents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parents`
--

LOCK TABLES `parents` WRITE;
/*!40000 ALTER TABLE `parents` DISABLE KEYS */;
INSERT INTO `parents` VALUES (1,1,NULL,7,NULL,'2026-05-26 09:38:43',NULL,NULL),(2,1,NULL,9,NULL,'2026-05-26 11:00:16',NULL,NULL),(3,1,NULL,12,NULL,'2026-05-26 14:15:40',NULL,NULL),(4,1,NULL,14,NULL,'2026-05-26 15:06:58',NULL,NULL),(5,1,NULL,176,NULL,'2026-05-31 16:18:49',NULL,NULL),(6,1,NULL,178,NULL,'2026-05-31 16:47:20',NULL,NULL),(7,1,NULL,182,NULL,'2026-06-24 13:32:21',NULL,NULL),(8,1,NULL,183,NULL,'2026-06-24 13:50:50',NULL,NULL);
/*!40000 ALTER TABLE `parents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `student_id` int unsigned NOT NULL,
  `fee_id` int unsigned NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_date` date NOT NULL,
  `receipt_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_method` enum('cash','online') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `gateway_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  `refund_of` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_no` (`receipt_no`),
  KEY `recorded_by` (`recorded_by`),
  KEY `idx_pay_student` (`student_id`),
  KEY `idx_pay_fee` (`fee_id`),
  KEY `fk_payments_refund_of` (`refund_of`),
  KEY `idx_payment_method` (`payment_method`),
  KEY `idx_payment_date` (`payment_date`),
  KEY `idx_pay_org` (`organization_id`),
  KEY `idx_pay_campus` (`campus_id`),
  KEY `idx_pay_section` (`section_id`),
  KEY `idx_pay_cb` (`created_by`),
  CONSTRAINT `fk_payments_refund_of` FOREIGN KEY (`refund_of`) REFERENCES `payments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`fee_id`) REFERENCES `fee_structures` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (139,'alumni.restore'),(138,'alumni.view'),(94,'assignments.create'),(95,'assignments.edit'),(96,'assignments.grade'),(93,'assignments.view'),(88,'attendance.export'),(87,'attendance.mark'),(86,'attendance.view'),(143,'campuses.manage'),(68,'classes.assign_master'),(65,'classes.create'),(67,'classes.delete'),(66,'classes.edit'),(64,'classes.view'),(50,'dashboard.view'),(81,'exams.create'),(83,'exams.delete'),(82,'exams.edit'),(85,'exams.grade'),(84,'exams.manage_questions'),(80,'exams.view'),(109,'expenses.approve'),(108,'expenses.create'),(110,'expenses.pay'),(107,'expenses.view'),(97,'finance.dashboard'),(99,'finance.manage_fees'),(101,'finance.record_payment'),(102,'finance.refund'),(103,'finance.view_debtors'),(98,'finance.view_fees'),(100,'finance.view_payments'),(112,'journal.create'),(113,'journal.post'),(111,'journal.view'),(115,'library.manage_books'),(116,'library.manage_borrows'),(114,'library.view'),(144,'organizations.manage'),(141,'reports.export'),(140,'reports.view'),(77,'results.approve'),(74,'results.create'),(76,'results.delete'),(75,'results.edit'),(78,'results.export'),(79,'results.print'),(73,'results.view'),(105,'salaries.create'),(106,'salaries.pay'),(104,'salaries.view'),(142,'sections.manage'),(128,'settings.edit'),(131,'settings.manage_grading'),(132,'settings.manage_school_info'),(129,'settings.manage_sections'),(130,'settings.manage_sessions'),(127,'settings.view'),(58,'students.archive'),(52,'students.create'),(54,'students.delete'),(53,'students.edit'),(57,'students.export'),(56,'students.import'),(55,'students.promote'),(51,'students.view'),(70,'subjects.create'),(72,'subjects.delete'),(71,'subjects.edit'),(69,'subjects.view'),(134,'system.activity_log'),(133,'system.audit_logs'),(135,'system.backup'),(136,'system.email_templates'),(137,'system.registrations'),(63,'teachers.assign_subjects'),(60,'teachers.create'),(62,'teachers.delete'),(61,'teachers.edit'),(59,'teachers.view'),(90,'timetable.create'),(92,'timetable.delete'),(91,'timetable.edit'),(89,'timetable.view'),(120,'transport.allocate'),(118,'transport.manage_buses'),(119,'transport.manage_routes'),(117,'transport.view'),(126,'users.assign_permissions'),(122,'users.create'),(124,'users.delete'),(123,'users.edit'),(125,'users.manage_roles'),(121,'users.view');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_bank`
--

DROP TABLE IF EXISTS `question_bank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_bank` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `subject_id` int unsigned NOT NULL,
  `topic` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `difficulty` enum('easy','medium','hard') COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `question` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_a` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_b` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_c` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_d` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer` enum('a','b','c','d') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `question_bank_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_bank_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_bank`
--

LOCK TABLES `question_bank` WRITE;
/*!40000 ALTER TABLE `question_bank` DISABLE KEYS */;
/*!40000 ALTER TABLE `question_bank` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registration_children`
--

DROP TABLE IF EXISTS `registration_children`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registration_children` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `registration_id` int unsigned NOT NULL,
  `full_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completeness_score` int unsigned DEFAULT '0',
  `status` enum('new','contacted','admitted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new',
  `school_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `initial_password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `registration_id` (`registration_id`),
  KEY `section_id` (`section_id`),
  KEY `idx_rchild_org` (`organization_id`),
  CONSTRAINT `registration_children_ibfk_1` FOREIGN KEY (`registration_id`) REFERENCES `online_registrations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `registration_children_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registration_children`
--

LOCK TABLES `registration_children` WRITE;
/*!40000 ALTER TABLE `registration_children` DISABLE KEYS */;
/*!40000 ALTER TABLE `registration_children` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `remember_tokens`
--

DROP TABLE IF EXISTS `remember_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `remember_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `selector` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `validator_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_selector` (`selector`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `remember_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `remember_tokens`
--

LOCK TABLES `remember_tokens` WRITE;
/*!40000 ALTER TABLE `remember_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `remember_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `results` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `student_id` int unsigned NOT NULL,
  `subject_id` int unsigned NOT NULL,
  `class_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `ca1` tinyint unsigned DEFAULT '0',
  `ca2` tinyint unsigned DEFAULT '0',
  `assignment` tinyint unsigned DEFAULT '0',
  `midterm` tinyint unsigned DEFAULT '0',
  `exam` tinyint unsigned DEFAULT '0',
  `total` tinyint unsigned GENERATED ALWAYS AS (((((`ca1` + `ca2`) + `assignment`) + `midterm`) + `exam`)) STORED,
  `grade` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` smallint unsigned DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT '0',
  `status` enum('draft','pending_approval','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `pushed_at` datetime DEFAULT NULL,
  `approved_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_result` (`student_id`,`subject_id`,`term_id`),
  KEY `subject_id` (`subject_id`),
  KEY `term_id` (`term_id`),
  KEY `fk_result_approved_by` (`approved_by`),
  KEY `idx_res_class_term` (`class_id`,`term_id`),
  KEY `idx_res_student_term` (`student_id`,`term_id`),
  KEY `idx_res_status` (`status`),
  KEY `idx_results_org` (`organization_id`),
  KEY `idx_results_campus` (`campus_id`),
  KEY `idx_results_section` (`section_id`),
  KEY `idx_results_cb` (`created_by`),
  KEY `idx_results_ub` (`updated_by`),
  CONSTRAINT `fk_result_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_3` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`),
  CONSTRAINT `results_ibfk_4` FOREIGN KEY (`term_id`) REFERENCES `terms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `results`
--

LOCK TABLES `results` WRITE;
/*!40000 ALTER TABLE `results` DISABLE KEYS */;
/*!40000 ALTER TABLE `results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int unsigned NOT NULL,
  `permission_id` int unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,50),(2,50),(3,50),(4,50),(5,50),(6,50),(7,50),(8,50),(25,50),(26,50),(1,51),(2,51),(3,51),(4,51),(5,51),(25,51),(26,51),(1,52),(2,52),(3,52),(25,52),(26,52),(1,53),(2,53),(3,53),(25,53),(26,53),(1,54),(2,54),(3,54),(25,54),(26,54),(1,55),(2,55),(3,55),(25,55),(26,55),(1,56),(2,56),(3,56),(25,56),(26,56),(1,57),(2,57),(3,57),(25,57),(26,57),(1,58),(2,58),(3,58),(25,58),(26,58),(1,59),(2,59),(3,59),(25,59),(26,59),(1,60),(2,60),(3,60),(25,60),(26,60),(1,61),(2,61),(3,61),(25,61),(26,61),(1,62),(2,62),(3,62),(25,62),(26,62),(1,63),(2,63),(3,63),(25,63),(26,63),(1,64),(2,64),(3,64),(4,64),(25,64),(26,64),(1,65),(2,65),(3,65),(25,65),(26,65),(1,66),(2,66),(3,66),(25,66),(26,66),(1,67),(2,67),(3,67),(25,67),(26,67),(1,68),(2,68),(3,68),(25,68),(26,68),(1,69),(2,69),(3,69),(4,69),(25,69),(26,69),(1,70),(2,70),(3,70),(25,70),(26,70),(1,71),(2,71),(3,71),(25,71),(26,71),(1,72),(2,72),(3,72),(25,72),(26,72),(1,73),(2,73),(3,73),(4,73),(6,73),(7,73),(8,73),(25,73),(26,73),(1,74),(2,74),(3,74),(4,74),(25,74),(26,74),(1,75),(2,75),(3,75),(25,75),(26,75),(1,76),(2,76),(3,76),(25,76),(26,76),(1,77),(2,77),(3,77),(25,77),(26,77),(1,78),(2,78),(3,78),(8,78),(25,78),(26,78),(1,79),(2,79),(3,79),(25,79),(26,79),(1,80),(2,80),(3,80),(4,80),(8,80),(25,80),(26,80),(1,81),(2,81),(3,81),(4,81),(8,81),(25,81),(26,81),(1,82),(2,82),(3,82),(8,82),(25,82),(26,82),(1,83),(2,83),(3,83),(8,83),(25,83),(26,83),(1,84),(2,84),(3,84),(4,84),(8,84),(25,84),(26,84),(1,85),(2,85),(3,85),(4,85),(8,85),(25,85),(26,85),(1,86),(2,86),(3,86),(4,86),(25,86),(26,86),(1,87),(2,87),(3,87),(4,87),(25,87),(26,87),(1,88),(2,88),(3,88),(25,88),(26,88),(1,89),(2,89),(3,89),(4,89),(25,89),(26,89),(1,90),(2,90),(3,90),(25,90),(26,90),(1,91),(2,91),(3,91),(25,91),(26,91),(1,92),(2,92),(3,92),(25,92),(26,92),(1,93),(2,93),(4,93),(25,93),(26,93),(1,94),(2,94),(3,94),(4,94),(25,94),(26,94),(1,95),(2,95),(3,95),(4,95),(25,95),(26,95),(1,96),(2,96),(3,96),(4,96),(25,96),(26,96),(1,97),(2,97),(5,97),(25,97),(26,97),(1,98),(2,98),(5,98),(25,98),(26,98),(1,99),(2,99),(5,99),(25,99),(26,99),(1,100),(2,100),(5,100),(25,100),(26,100),(1,101),(2,101),(5,101),(25,101),(26,101),(1,102),(2,102),(5,102),(25,102),(26,102),(1,103),(2,103),(5,103),(25,103),(26,103),(1,104),(2,104),(5,104),(25,104),(26,104),(1,105),(2,105),(25,105),(26,105),(1,106),(2,106),(25,106),(26,106),(1,107),(2,107),(5,107),(25,107),(26,107),(1,108),(2,108),(5,108),(25,108),(26,108),(1,109),(2,109),(25,109),(26,109),(1,110),(2,110),(25,110),(26,110),(1,111),(2,111),(5,111),(25,111),(26,111),(1,112),(2,112),(25,112),(26,112),(1,113),(2,113),(25,113),(26,113),(1,114),(2,114),(25,114),(26,114),(1,115),(2,115),(25,115),(26,115),(1,116),(2,116),(25,116),(26,116),(1,117),(2,117),(25,117),(26,117),(1,118),(2,118),(25,118),(26,118),(1,119),(2,119),(25,119),(26,119),(1,120),(2,120),(25,120),(26,120),(1,121),(2,121),(25,121),(26,121),(1,122),(2,122),(25,122),(26,122),(1,123),(2,123),(25,123),(26,123),(1,124),(2,124),(25,124),(26,124),(1,125),(25,125),(1,126),(25,126),(1,127),(2,127),(25,127),(26,127),(1,128),(2,128),(25,128),(26,128),(1,129),(2,129),(25,129),(26,129),(1,130),(2,130),(25,130),(26,130),(1,131),(2,131),(25,131),(26,131),(1,132),(25,132),(1,133),(25,133),(1,134),(2,134),(25,134),(26,134),(1,135),(25,135),(1,136),(25,136),(1,137),(2,137),(25,137),(26,137),(1,138),(2,138),(3,138),(25,138),(26,138),(1,139),(2,139),(3,139),(25,139),(26,139),(1,140),(2,140),(3,140),(5,140),(8,140),(25,140),(26,140),(1,141),(2,141),(3,141),(8,141),(25,141),(26,141),(1,142),(25,142),(1,143),(25,143),(1,144),(25,144);
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_public` tinyint(1) DEFAULT '0',
  `vacancy_open` tinyint(1) DEFAULT '0',
  `required_fields` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'super_admin','Super Admin',1,0,0,NULL),(2,'principal','Principal',1,0,0,'[\"section_id\", \"qualification\", \"department\", \"gender\", \"dob\"]'),(3,'vice_principal','Vice Principal',1,0,0,NULL),(4,'teacher','Teacher',1,1,1,'[\"qualification\", \"department\", \"gender\", \"dob\", \"avatar\"]'),(5,'accountant','Accountant',1,0,0,NULL),(6,'parent','Parent',1,1,1,'[\"parent_name\", \"parent_phone\"]'),(7,'student','Student',1,1,1,'[\"section_id\", \"parent_name\", \"parent_phone\", \"gender\", \"dob\", \"avatar\"]'),(8,'exams_officer','Exams Officer',1,0,0,NULL),(16,'librarian','Librarian',1,1,1,NULL),(17,'nurse','Nurse',1,1,1,NULL),(18,'hr_officer','HR/Admin Officer',1,0,0,NULL),(19,'subject_teacher','Subject Teacher',1,0,0,NULL),(20,'class_teacher','Class Teacher',1,0,0,NULL),(22,'security_staff','Security Staff',1,1,1,NULL),(23,'non_teaching','Non-Teaching Staff',1,1,1,NULL),(25,'proprietor','Proprietor',1,0,0,NULL),(26,'head_master','Head Master',1,0,0,NULL);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salaries`
--

DROP TABLE IF EXISTS `salaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salaries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `month` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','paid') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `payment_date` date DEFAULT NULL,
  `recorded_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `recorded_by` (`recorded_by`),
  KEY `idx_sal_org` (`organization_id`),
  KEY `idx_sal_campus` (`campus_id`),
  KEY `idx_sal_section` (`section_id`),
  CONSTRAINT `salaries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `salaries_ibfk_2` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salaries`
--

LOCK TABLES `salaries` WRITE;
/*!40000 ALTER TABLE `salaries` DISABLE KEYS */;
INSERT INTO `salaries` VALUES (1,1,NULL,NULL,1,200000.00,'June 2026','paid','2026-06-21',181,'2026-06-21 12:13:43',NULL,NULL),(2,1,NULL,NULL,181,23456879.00,'June 2026','paid','2026-06-21',181,'2026-06-21 12:14:29',NULL,NULL),(3,1,NULL,2,2,10000.00,'June 2026','paid','2026-06-21',181,'2026-06-21 12:31:07',NULL,NULL),(6,1,NULL,2,2,20000.00,'July 2026','paid','2026-07-15',1,'2026-07-15 18:29:47',NULL,NULL);
/*!40000 ALTER TABLE `salaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_deductions`
--

DROP TABLE IF EXISTS `salary_deductions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_deductions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `salary_id` int unsigned NOT NULL,
  `dtype` enum('tax','pension','loan','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_salary` (`salary_id`),
  CONSTRAINT `salary_deductions_ibfk_1` FOREIGN KEY (`salary_id`) REFERENCES `salaries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_deductions`
--

LOCK TABLES `salary_deductions` WRITE;
/*!40000 ALTER TABLE `salary_deductions` DISABLE KEYS */;
/*!40000 ALTER TABLE `salary_deductions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `head_id` int unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sections_org` (`organization_id`),
  KEY `idx_sections_campus` (`campus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES (1,1,1,'Primary',NULL,'2026-05-13 10:56:19'),(2,1,1,'Secondary',NULL,'2026-05-13 10:56:19');
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_parents`
--

DROP TABLE IF EXISTS `student_parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_parents` (
  `student_id` int unsigned NOT NULL,
  `parent_id` int unsigned NOT NULL,
  `relation` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`student_id`,`parent_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `student_parents_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_parents_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_parents`
--

LOCK TABLES `student_parents` WRITE;
/*!40000 ALTER TABLE `student_parents` DISABLE KEYS */;
INSERT INTO `student_parents` VALUES (1,1,'Father/Mother'),(2,2,'Father/Mother'),(8,4,'Parent'),(9,7,'Parent'),(166,5,'Parent'),(168,6,'Parent'),(169,7,'Parent'),(170,8,'Parent');
/*!40000 ALTER TABLE `student_parents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `class_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `student_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `student_id` (`student_id`),
  KEY `idx_stu_class` (`class_id`),
  KEY `idx_stu_section` (`section_id`),
  KEY `idx_students_org` (`organization_id`),
  KEY `idx_students_campus` (`campus_id`),
  KEY `idx_students_cb` (`created_by`),
  KEY `idx_students_ub` (`updated_by`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `students_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`),
  CONSTRAINT `students_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=176 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,1,NULL,6,1,2,'SEC-2026-0002',NULL,NULL,NULL,'2026-05-26 09:29:51',NULL,NULL),(2,1,NULL,8,1,1,'PRI-2026-0003',NULL,NULL,NULL,'2026-05-26 10:58:54',NULL,NULL),(8,1,NULL,15,1,1,'PRI-2026-0005',NULL,NULL,NULL,'2026-05-26 15:06:58',NULL,NULL),(9,1,NULL,18,1,2,'STU-SS1-1887-0',NULL,'female',NULL,'2026-05-27 14:17:13',NULL,NULL),(10,1,NULL,19,1,2,'STU-SS1-8190-1',NULL,'female',NULL,'2026-05-27 14:17:13',NULL,NULL),(11,1,NULL,20,1,2,'STU-SS1-9028-2',NULL,'male',NULL,'2026-05-27 14:17:13',NULL,NULL),(12,1,NULL,21,1,2,'STU-SS1-7516-3',NULL,'male',NULL,'2026-05-27 14:17:13',NULL,NULL),(13,1,NULL,22,1,2,'STU-SS1-5734-4',NULL,'male',NULL,'2026-05-27 14:17:13',NULL,NULL),(14,1,NULL,23,2,1,'STU-PRI-6611-5',NULL,'female',NULL,'2026-05-27 14:17:13',NULL,NULL),(15,1,NULL,24,2,1,'STU-PRI-7156-6',NULL,'male','','2026-05-27 14:17:13',NULL,NULL),(16,1,NULL,25,2,1,'STU-PRI-5065-7',NULL,'female',NULL,'2026-05-27 14:17:13',NULL,NULL),(17,1,NULL,26,2,1,'STU-PRI-8044-8',NULL,'female',NULL,'2026-05-27 14:17:13',NULL,NULL),(18,1,NULL,27,2,1,'STU-PRI-5940-9',NULL,'male',NULL,'2026-05-27 14:17:13',NULL,NULL),(19,1,NULL,28,3,1,'STU-PRI-7813-10',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(20,1,NULL,29,3,1,'STU-PRI-6260-11',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(21,1,NULL,30,3,1,'STU-PRI-1942-12',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(22,1,NULL,31,3,1,'STU-PRI-7733-13',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(23,1,NULL,32,3,1,'STU-PRI-5567-14',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(24,1,NULL,33,4,1,'STU-PRI-5255-15',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(25,1,NULL,34,4,1,'STU-PRI-9740-16',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(26,1,NULL,35,4,1,'STU-PRI-3107-17',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(27,1,NULL,36,4,1,'STU-PRI-3370-18',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(28,1,NULL,37,4,1,'STU-PRI-9632-19',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(29,1,NULL,38,5,1,'STU-PRI-5583-20',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(30,1,NULL,39,5,1,'STU-PRI-9223-21',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(31,1,NULL,40,5,1,'STU-PRI-4912-22',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(32,1,NULL,41,5,1,'STU-PRI-7307-23',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(33,1,NULL,42,5,1,'STU-PRI-1915-24',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(34,1,NULL,43,6,1,'STU-PRI-4179-25',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(35,1,NULL,44,6,1,'STU-PRI-4986-26',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(36,1,NULL,45,6,1,'STU-PRI-6043-27',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(37,1,NULL,46,6,1,'STU-PRI-8164-28',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(38,1,NULL,47,6,1,'STU-PRI-5081-29',NULL,'male',NULL,'2026-05-27 14:17:14',NULL,NULL),(39,1,NULL,48,7,1,'STU-PRI-8406-30',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(40,1,NULL,49,7,1,'STU-PRI-3419-31',NULL,'female',NULL,'2026-05-27 14:17:14',NULL,NULL),(41,1,NULL,50,7,1,'STU-PRI-1369-32',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(42,1,NULL,51,7,1,'STU-PRI-9461-33',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(43,1,NULL,52,7,1,'STU-PRI-3637-34',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(44,1,NULL,53,8,1,'STU-PRI-2213-35',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(45,1,NULL,54,8,1,'STU-PRI-9424-36',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(46,1,NULL,55,8,1,'STU-PRI-3616-37',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(47,1,NULL,56,8,1,'STU-PRI-2452-38',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(48,1,NULL,57,8,1,'STU-PRI-5433-39',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(49,1,NULL,58,9,1,'STU-PRI-4541-40',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(50,1,NULL,59,9,1,'STU-PRI-9220-41',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(51,1,NULL,60,9,1,'STU-PRI-7642-42',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(52,1,NULL,61,9,1,'STU-PRI-4542-43',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(53,1,NULL,62,9,1,'STU-PRI-9982-44',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(54,1,NULL,63,10,1,'STU-PRI-2183-45',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(55,1,NULL,64,10,1,'STU-PRI-3737-46',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(56,1,NULL,65,10,1,'STU-PRI-5879-47',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(57,1,NULL,66,10,1,'STU-PRI-7218-48',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(58,1,NULL,67,10,1,'STU-PRI-3123-49',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(59,1,NULL,68,11,1,'STU-PRI-8348-50',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(60,1,NULL,69,11,1,'STU-PRI-3369-51',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(61,1,NULL,70,11,1,'STU-PRI-4693-52',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(62,1,NULL,71,11,1,'STU-PRI-6118-53',NULL,'female',NULL,'2026-05-27 14:17:15',NULL,NULL),(63,1,NULL,72,11,1,'STU-PRI-7099-54',NULL,'male',NULL,'2026-05-27 14:17:15',NULL,NULL),(64,1,NULL,73,12,1,'STU-PRI-5402-55',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(65,1,NULL,74,12,1,'STU-PRI-7526-56',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(66,1,NULL,75,12,1,'STU-PRI-1595-57',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(67,1,NULL,76,12,1,'STU-PRI-6430-58',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(68,1,NULL,77,12,1,'STU-PRI-1479-59',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(69,1,NULL,78,13,1,'STU-PRI-4102-60',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(70,1,NULL,79,13,1,'STU-PRI-9881-61',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(71,1,NULL,80,13,1,'STU-PRI-5956-62',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(72,1,NULL,81,13,1,'STU-PRI-5719-63',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(73,1,NULL,82,13,1,'STU-PRI-3362-64',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(74,1,NULL,83,14,2,'STU-JSS-3895-65',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(75,1,NULL,84,14,2,'STU-JSS-8824-66',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(76,1,NULL,85,14,2,'STU-JSS-4542-67',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(77,1,NULL,86,14,2,'STU-JSS-8405-68',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(78,1,NULL,87,14,2,'STU-JSS-4103-69',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(79,1,NULL,88,15,2,'STU-JSS-6353-70',NULL,'female',NULL,'2026-05-27 14:17:16',NULL,NULL),(80,1,NULL,89,15,2,'STU-JSS-8042-71',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(81,1,NULL,90,15,2,'STU-JSS-4375-72',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(82,1,NULL,91,15,2,'STU-JSS-9923-73',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(83,1,NULL,92,15,2,'STU-JSS-9592-74',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(84,1,NULL,93,16,2,'STU-JSS-9686-75',NULL,'male',NULL,'2026-05-27 14:17:16',NULL,NULL),(85,1,NULL,94,16,2,'STU-JSS-2494-76',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(86,1,NULL,95,16,2,'STU-JSS-4435-77',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(87,1,NULL,96,16,2,'STU-JSS-9082-78',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(88,1,NULL,97,16,2,'STU-JSS-3995-79',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(89,1,NULL,98,17,2,'STU-JSS-3210-80',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(90,1,NULL,99,17,2,'STU-JSS-4139-81',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(91,1,NULL,100,17,2,'STU-JSS-2657-82',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(92,1,NULL,101,17,2,'STU-JSS-6438-83',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(93,1,NULL,102,17,2,'STU-JSS-1838-84',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(94,1,NULL,103,18,2,'STU-JSS-8980-85',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(95,1,NULL,104,18,2,'STU-JSS-3212-86',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(96,1,NULL,105,18,2,'STU-JSS-1936-87',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(97,1,NULL,106,18,2,'STU-JSS-9725-88',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(98,1,NULL,107,18,2,'STU-JSS-1871-89',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(99,1,NULL,108,19,2,'STU-JSS-7796-90',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(100,1,NULL,109,19,2,'STU-JSS-8635-91',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(101,1,NULL,110,19,2,'STU-JSS-2558-92',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(102,1,NULL,111,19,2,'STU-JSS-4713-93',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(103,1,NULL,112,19,2,'STU-JSS-6583-94',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(104,1,NULL,113,20,2,'STU-JSS-8146-95',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(105,1,NULL,114,20,2,'STU-JSS-5531-96',NULL,'female',NULL,'2026-05-27 14:17:17',NULL,NULL),(106,1,NULL,115,20,2,'STU-JSS-5304-97',NULL,'male',NULL,'2026-05-27 14:17:17',NULL,NULL),(107,1,NULL,116,20,2,'STU-JSS-2040-98',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(108,1,NULL,117,20,2,'STU-JSS-5504-99',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(109,1,NULL,118,21,2,'STU-JSS-7028-100',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(110,1,NULL,119,21,2,'STU-JSS-6789-101',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(111,1,NULL,120,21,2,'STU-JSS-7889-102',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(112,1,NULL,121,21,2,'STU-JSS-2923-103',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(113,1,NULL,122,21,2,'STU-JSS-8872-104',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(114,1,NULL,123,22,2,'STU-JSS-2764-105',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(115,1,NULL,124,22,2,'STU-JSS-4842-106',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(116,1,NULL,125,22,2,'STU-JSS-6388-107',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(117,1,NULL,126,22,2,'STU-JSS-3211-108',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(118,1,NULL,127,22,2,'STU-JSS-4246-109',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(119,1,NULL,128,23,2,'STU-SSS-7259-110',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(120,1,NULL,129,23,2,'STU-SSS-1032-111',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(121,1,NULL,130,23,2,'STU-SSS-7518-112',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(122,1,NULL,131,23,2,'STU-SSS-4505-113',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(123,1,NULL,132,23,2,'STU-SSS-3307-114',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(124,1,NULL,133,24,2,'STU-SSS-7429-115',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(125,1,NULL,134,24,2,'STU-SSS-2880-116',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(126,1,NULL,135,24,2,'STU-SSS-5434-117',NULL,'female',NULL,'2026-05-27 14:17:18',NULL,NULL),(127,1,NULL,136,24,2,'STU-SSS-5351-118',NULL,'male',NULL,'2026-05-27 14:17:18',NULL,NULL),(128,1,NULL,137,24,2,'STU-SSS-2197-119',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(129,1,NULL,138,25,2,'STU-SSS-4687-120',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(130,1,NULL,139,25,2,'STU-SSS-4128-121',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(131,1,NULL,140,25,2,'STU-SSS-7079-122',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(132,1,NULL,141,25,2,'STU-SSS-2332-123',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(133,1,NULL,142,25,2,'STU-SSS-1533-124',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(134,1,NULL,143,26,2,'STU-SSS-6658-125',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(135,1,NULL,144,26,2,'STU-SSS-6746-126',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(136,1,NULL,145,26,2,'STU-SSS-7987-127',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(137,1,NULL,146,26,2,'STU-SSS-2153-128',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(138,1,NULL,147,26,2,'STU-SSS-5602-129',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(139,1,NULL,148,27,2,'STU-SSS-3887-130',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(140,1,NULL,149,27,2,'STU-SSS-5119-131',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(141,1,NULL,150,27,2,'STU-SSS-5992-132',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(142,1,NULL,151,27,2,'STU-SSS-6049-133',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(143,1,NULL,152,27,2,'STU-SSS-3328-134',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(144,1,NULL,153,28,2,'STU-SSS-4621-135',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(145,1,NULL,154,28,2,'STU-SSS-7346-136',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(146,1,NULL,155,28,2,'STU-SSS-9772-137',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(147,1,NULL,156,28,2,'STU-SSS-7855-138',NULL,'female',NULL,'2026-05-27 14:17:19',NULL,NULL),(148,1,NULL,157,28,2,'STU-SSS-4780-139',NULL,'male',NULL,'2026-05-27 14:17:19',NULL,NULL),(149,1,NULL,158,29,2,'STU-SSS-6899-140',NULL,'female','hausawa dan fulani','2026-05-27 14:17:20',NULL,NULL),(150,1,NULL,159,29,2,'STU-SSS-6306-141',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(151,1,NULL,160,29,2,'STU-SSS-1403-142',NULL,'male',NULL,'2026-05-27 14:17:20',NULL,NULL),(152,1,NULL,161,29,2,'STU-SSS-6370-143',NULL,'male',NULL,'2026-05-27 14:17:20',NULL,NULL),(153,1,NULL,162,29,2,'STU-SSS-6785-144',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(154,1,NULL,163,30,2,'STU-SSS-8262-145',NULL,'male',NULL,'2026-05-27 14:17:20',NULL,NULL),(155,1,NULL,164,30,2,'STU-SSS-7822-146',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(156,1,NULL,165,30,2,'STU-SSS-7136-147',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(157,1,NULL,166,30,2,'STU-SSS-9579-148',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(158,1,NULL,167,30,2,'STU-SSS-3238-149',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(159,1,NULL,168,31,2,'STU-SSS-6763-150',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(160,1,NULL,169,31,2,'STU-SSS-3986-151',NULL,'male',NULL,'2026-05-27 14:17:20',NULL,NULL),(161,1,NULL,170,31,2,'STU-SSS-7523-152',NULL,'male',NULL,'2026-05-27 14:17:20',NULL,NULL),(162,1,NULL,171,31,2,'STU-SSS-5736-153',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(163,1,NULL,172,31,2,'STU-SSS-5797-154',NULL,'female',NULL,'2026-05-27 14:17:20',NULL,NULL),(164,1,NULL,173,1,2,'ADM-TEST-001','2010-01-01',NULL,NULL,'2026-05-27 16:54:24',NULL,NULL),(166,1,NULL,177,29,2,'SEC-2026-0005','2006-09-23','female',NULL,'2026-05-31 16:18:49',NULL,NULL),(168,1,NULL,179,29,2,'SEC-2026-0007','2006-02-06','female',NULL,'2026-05-31 16:47:20',NULL,NULL),(169,1,NULL,184,2,1,'PRI-2026-0006',NULL,NULL,NULL,'2026-06-24 14:12:43',NULL,NULL),(170,1,NULL,185,2,1,'PRI-2026-0007','2026-06-24','male','','2026-06-24 14:12:43',NULL,NULL);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subjects`
--

DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subjects` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `idx_subjects_org` (`organization_id`),
  KEY `idx_subjects_campus` (`campus_id`),
  KEY `idx_subjects_cb` (`created_by`),
  KEY `idx_subjects_ub` (`updated_by`),
  CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subjects`
--

LOCK TABLES `subjects` WRITE;
/*!40000 ALTER TABLE `subjects` DISABLE KEYS */;
INSERT INTO `subjects` VALUES (1,1,NULL,2,'Maths','SS','2026-05-13 13:02:18',NULL,NULL),(2,1,NULL,1,'Mathematics','MATH-PRI','2026-05-27 13:51:44',NULL,NULL),(3,1,NULL,1,'English Language','ENG-PRI','2026-05-27 13:51:44',NULL,NULL),(4,1,NULL,1,'Social Studies','SOC-PRI','2026-05-27 13:51:44',NULL,NULL),(5,1,NULL,1,'Basic Science','SCI-PRI','2026-05-27 13:51:44',NULL,NULL),(6,1,NULL,1,'Agricultural Science','AGR-PRI','2026-05-27 13:51:44',NULL,NULL),(7,1,NULL,1,'Computer Studies','ICT-PRI','2026-05-27 13:51:44',NULL,NULL),(8,1,NULL,1,'P.H.E','PHE-PRI','2026-05-27 13:51:44',NULL,NULL),(9,1,NULL,1,'Religious Studies','REL-PRI','2026-05-27 13:51:44',NULL,NULL),(10,1,NULL,1,'Cultural & Creative Arts','CCA-PRI','2026-05-27 13:51:44',NULL,NULL),(11,1,NULL,1,'French','FRE-PRI','2026-05-27 13:51:45',NULL,NULL),(12,1,NULL,1,'Home Economics','HEC-PRI','2026-05-27 13:51:45',NULL,NULL),(13,1,NULL,2,'Mathematics','MATH-SEC','2026-05-27 13:51:45',NULL,NULL),(14,1,NULL,2,'English Language','ENG-SEC','2026-05-27 13:51:45',NULL,NULL),(15,1,NULL,2,'Civic Education','CIV-SEC','2026-05-27 13:51:45',NULL,NULL),(16,1,NULL,2,'Biology','BIO-SEC','2026-05-27 13:51:45',NULL,NULL),(17,1,NULL,2,'Chemistry','CHE-SEC','2026-05-27 13:51:45',NULL,NULL),(18,1,NULL,2,'Physics','PHY-SEC','2026-05-27 13:51:45',NULL,NULL),(19,1,NULL,2,'Economics','ECO-SEC','2026-05-27 13:51:45',NULL,NULL),(20,1,NULL,2,'Government','GOV-SEC','2026-05-27 13:51:45',NULL,NULL),(21,1,NULL,2,'Literature in English','LIT-SEC','2026-05-27 13:51:45',NULL,NULL),(22,1,NULL,2,'Geography','GEO-SEC','2026-05-27 13:51:45',NULL,NULL),(23,1,NULL,2,'Agricultural Science','AGR-SEC','2026-05-27 13:51:45',NULL,NULL),(24,1,NULL,2,'Further Mathematics','FMA-SEC','2026-05-27 13:51:45',NULL,NULL),(25,1,NULL,2,'Computer Studies','ICT-SEC','2026-05-27 13:51:45',NULL,NULL),(26,1,NULL,2,'Account','ACC-SEC','2026-05-27 13:51:45',NULL,NULL),(27,1,NULL,2,'Commerce','COM-SEC','2026-05-27 13:51:45',NULL,NULL);
/*!40000 ALTER TABLE `subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=531 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'school_name','Amina Royal Academy','2026-07-10 12:34:45'),(2,'school_logo','school_logo.png','2026-05-15 18:26:00'),(3,'school_motto','Empowering the Future Leaders','2026-05-15 18:26:00'),(4,'school_address','','2026-05-13 10:56:19'),(5,'school_phone','','2026-05-13 10:56:19'),(6,'school_email','','2026-05-13 10:56:19'),(7,'color_primary','#5e5c64','2026-07-15 18:41:18'),(8,'color_white','#dc2626','2026-07-15 18:40:37'),(9,'color_red','#17ab72','2026-07-10 22:24:03'),(10,'color_maroon','#800000','2026-05-13 10:56:19'),(11,'timezone','Africa/Lagos','2026-05-13 10:56:19'),(12,'currency','NGN','2026-05-13 10:56:19'),(13,'date_format','d/m/Y','2026-05-13 10:56:19'),(14,'pass_mark','40','2026-05-13 10:56:19'),(15,'ca_total','40','2026-05-13 10:56:19'),(16,'exam_total','60','2026-05-13 10:56:19'),(17,'sport_day','Wednesday','2026-05-13 10:56:19'),(34,'school_website','','2026-05-24 12:31:06'),(35,'language','en','2026-05-24 12:31:06'),(36,'grading_type','percentage','2026-05-24 12:31:06'),(37,'current_session_id','1','2026-05-24 12:31:06'),(38,'current_term_id','1','2026-05-24 12:31:06'),(39,'auto_promote','0','2026-05-24 12:31:06'),(40,'result_approval_required','1','2026-05-24 12:31:06'),(41,'attendance_method','manual','2026-05-24 12:31:06'),(42,'attendance_window_start','07:00','2026-05-24 12:31:06'),(43,'attendance_window_end','09:00','2026-05-24 12:31:06'),(44,'absence_notify_parent','1','2026-05-24 12:31:06'),(45,'school_start_time','08:00','2026-05-24 12:31:06'),(46,'school_end_time','15:00','2026-05-24 12:31:06'),(47,'period_duration','40','2026-05-24 12:31:06'),(48,'break_start','10:20','2026-05-24 12:31:06'),(49,'break_end','10:40','2026-05-24 12:31:06'),(50,'working_days','Monday,Tuesday,Wednesday,Thursday,Friday','2026-05-24 12:31:06'),(51,'fee_late_penalty_pct','5','2026-05-24 12:31:06'),(52,'fee_due_day','15','2026-05-24 12:31:06'),(53,'smtp_host','smtp.gmail.com','2026-05-26 14:24:31'),(54,'smtp_port','587','2026-05-24 12:31:06'),(55,'smtp_user','abubakar19hm@gmail.com','2026-05-26 14:15:11'),(56,'smtp_pass','wlcd hwlg ogam jaqj','2026-05-26 14:46:49'),(57,'smtp_from_name','Amina Royal Academy','2026-05-26 14:15:11'),(58,'smtp_encryption','tls','2026-05-24 12:31:06'),(59,'sms_gateway','','2026-05-24 12:31:06'),(60,'sms_api_key','','2026-05-24 12:31:06'),(61,'sms_sender_id','','2026-05-24 12:31:06'),(62,'paystack_public_key','','2026-05-24 12:31:06'),(63,'paystack_secret_key','','2026-05-24 12:31:06'),(181,'csrf_token','8c355e1fcb6f075d2ce519147645535bbbc318e105f3088ed28a6502ef574c4c','2026-06-21 14:58:51'),(337,'fee_reminder_days','7','2026-07-10 13:07:11'),(442,'landing_pages','[]','2026-07-12 09:23:36'),(489,'color_accent','#241f31','2026-07-15 19:11:29'),(490,'color_accent2','#06b6d4','2026-07-15 19:09:25'),(491,'color_navy','#5e5c64','2026-07-15 19:10:24');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `employee_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qualification` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_teach_org` (`organization_id`),
  KEY `idx_teachers_cb` (`created_by`),
  KEY `idx_teachers_ub` (`updated_by`),
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (1,1,NULL,2,'TCH-D1E5DB','Science','NCE','2026-05-13 12:14:37',NULL,NULL),(2,1,NULL,17,'EMP-2026-0017','','','2026-05-27 14:00:49',NULL,NULL),(3,1,NULL,175,'EMP-2026-0175','Engineering','ND','2026-05-31 09:45:40',NULL,NULL),(4,1,NULL,180,'EMP-2026-0180','science','Bsc accouting','2026-05-31 17:14:59',NULL,NULL),(5,1,NULL,190,'EMP-2026-0190',NULL,NULL,'2026-07-10 22:04:53',NULL,NULL),(6,1,NULL,196,'EMP-2026-0196',NULL,NULL,'2026-07-17 10:41:26',NULL,NULL),(7,1,NULL,197,'EMP-2026-0197',NULL,NULL,'2026-07-17 14:44:07',NULL,NULL);
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terms`
--

DROP TABLE IF EXISTS `terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terms` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `session_id` int unsigned NOT NULL,
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `session_id` (`session_id`),
  KEY `idx_term_active` (`is_active`),
  KEY `idx_terms_org` (`organization_id`),
  KEY `idx_terms_campus` (`campus_id`),
  CONSTRAINT `terms_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `academic_sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terms`
--

LOCK TABLES `terms` WRITE;
/*!40000 ALTER TABLE `terms` DISABLE KEYS */;
INSERT INTO `terms` VALUES (1,1,NULL,1,'1st Term',1,'2025-09-01','2026-12-31');
/*!40000 ALTER TABLE `terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetable`
--

DROP TABLE IF EXISTS `timetable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetable` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `class_id` int unsigned NOT NULL,
  `subject_id` int unsigned NOT NULL,
  `teacher_id` int unsigned NOT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `idx_tt_class` (`class_id`),
  KEY `idx_tt_teacher` (`teacher_id`),
  KEY `idx_tt_org` (`organization_id`),
  KEY `idx_tt_campus` (`campus_id`),
  KEY `idx_tt_section` (`section_id`),
  CONSTRAINT `timetable_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetable`
--

LOCK TABLES `timetable` WRITE;
/*!40000 ALTER TABLE `timetable` DISABLE KEYS */;
INSERT INTO `timetable` VALUES (3,1,NULL,1,3,6,175,'Monday','08:00:00','08:40:00',NULL,NULL);
/*!40000 ALTER TABLE `timetable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetable_templates`
--

DROP TABLE IF EXISTS `timetable_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetable_templates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `class_id` int unsigned DEFAULT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slot_type` enum('period','break') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'period',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject_id` int unsigned DEFAULT NULL,
  `teacher_id` int unsigned DEFAULT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `sort_order` smallint unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `idx_tpl_class` (`class_id`),
  KEY `idx_tpl_section` (`section_id`),
  KEY `idx_ttpl_org` (`organization_id`),
  KEY `idx_ttpl_campus` (`campus_id`),
  CONSTRAINT `timetable_templates_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_templates_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_templates_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE SET NULL,
  CONSTRAINT `timetable_templates_ibfk_4` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetable_templates`
--

LOCK TABLES `timetable_templates` WRITE;
/*!40000 ALTER TABLE `timetable_templates` DISABLE KEYS */;
INSERT INTO `timetable_templates` VALUES (51,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-26 16:50:29'),(52,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-26 16:50:29'),(53,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-26 16:50:29'),(54,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-26 16:50:29'),(55,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'10:40:00','11:20:00',4,'2026-05-26 16:50:29'),(56,1,NULL,1,NULL,'Monday','break','Lunch Break',NULL,NULL,'11:20:00','11:50:00',5,'2026-05-26 16:50:29'),(57,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-26 16:50:29'),(58,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-26 16:50:29'),(59,1,NULL,1,NULL,'Monday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-26 16:50:29'),(60,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-26 16:50:29'),(61,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-26 16:50:29'),(62,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-26 16:50:29'),(63,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-26 16:50:29'),(64,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'10:40:00','11:20:00',4,'2026-05-26 16:50:29'),(65,1,NULL,1,NULL,'Tuesday','break','Lunch Break',NULL,NULL,'11:20:00','11:50:00',5,'2026-05-26 16:50:29'),(66,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-26 16:50:29'),(67,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-26 16:50:29'),(68,1,NULL,1,NULL,'Tuesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-26 16:50:29'),(69,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-26 16:50:29'),(70,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-26 16:50:29'),(71,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-26 16:50:29'),(72,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-26 16:50:29'),(73,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'10:40:00','11:20:00',4,'2026-05-26 16:50:29'),(74,1,NULL,1,NULL,'Wednesday','break','Lunch Break',NULL,NULL,'11:20:00','11:50:00',5,'2026-05-26 16:50:29'),(75,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-26 16:50:29'),(76,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-26 16:50:29'),(77,1,NULL,1,NULL,'Wednesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-26 16:50:29'),(78,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-26 16:50:29'),(79,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-26 16:50:29'),(80,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-26 16:50:29'),(81,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-26 16:50:29'),(82,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'10:40:00','11:20:00',4,'2026-05-26 16:50:29'),(83,1,NULL,1,NULL,'Thursday','break','Lunch Break',NULL,NULL,'11:20:00','11:50:00',5,'2026-05-26 16:50:29'),(84,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-26 16:50:29'),(85,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-26 16:50:29'),(86,1,NULL,1,NULL,'Thursday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-26 16:50:29'),(87,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-26 16:50:29'),(88,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-26 16:50:29'),(89,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-26 16:50:29'),(91,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'10:40:00','11:20:00',4,'2026-05-26 16:50:29'),(92,1,NULL,1,NULL,'Friday','break','Lunch Break',NULL,NULL,'11:20:00','11:50:00',5,'2026-05-26 16:50:29'),(93,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-26 16:50:29'),(94,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-26 16:50:29'),(95,1,NULL,1,NULL,'Friday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-26 16:50:29'),(141,1,NULL,2,1,'Monday','period',NULL,1,2,'08:00:00','08:40:00',0,'2026-05-27 13:08:10'),(142,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-27 13:08:10'),(143,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-27 13:08:10'),(144,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-27 13:08:10'),(145,1,NULL,2,1,'Monday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-05-27 13:08:10'),(146,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-05-27 13:08:10'),(147,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-27 13:08:10'),(148,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-27 13:08:10'),(149,1,NULL,2,1,'Monday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-27 13:08:10'),(150,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-27 13:08:10'),(151,1,NULL,2,1,'Tuesday','period',NULL,1,2,'08:40:00','09:20:00',1,'2026-05-27 13:08:10'),(152,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-27 13:08:10'),(153,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-27 13:08:10'),(154,1,NULL,2,1,'Tuesday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-05-27 13:08:10'),(155,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-05-27 13:08:10'),(156,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-27 13:08:10'),(157,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-27 13:08:10'),(158,1,NULL,2,1,'Tuesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-27 13:08:10'),(159,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-27 13:08:10'),(160,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-27 13:08:10'),(161,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-27 13:08:10'),(162,1,NULL,2,1,'Wednesday','period',NULL,1,2,'10:00:00','10:40:00',3,'2026-05-27 13:08:10'),(163,1,NULL,2,1,'Wednesday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-05-27 13:08:10'),(164,1,NULL,2,1,'Wednesday','period',NULL,1,2,'11:10:00','11:50:00',5,'2026-05-27 13:08:10'),(165,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-27 13:08:10'),(166,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-27 13:08:10'),(167,1,NULL,2,1,'Wednesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-27 13:08:10'),(168,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-27 13:08:10'),(169,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-27 13:08:10'),(170,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-27 13:08:10'),(171,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-27 13:08:10'),(172,1,NULL,2,1,'Thursday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-05-27 13:08:10'),(173,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-05-27 13:08:10'),(174,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-27 13:08:10'),(175,1,NULL,2,1,'Thursday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-27 13:08:10'),(176,1,NULL,2,1,'Thursday','period',NULL,1,2,'13:10:00','13:50:00',8,'2026-05-27 13:08:10'),(177,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-05-27 13:08:10'),(178,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-05-27 13:08:10'),(179,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-05-27 13:08:10'),(180,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-05-27 13:08:10'),(181,1,NULL,2,1,'Friday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-05-27 13:08:10'),(182,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-05-27 13:08:10'),(183,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-05-27 13:08:10'),(184,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-05-27 13:08:10'),(185,1,NULL,2,1,'Friday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-05-27 13:08:10'),(186,1,NULL,1,3,'Monday','period',NULL,6,175,'08:00:00','08:40:00',0,'2026-06-16 17:14:18'),(187,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-06-16 17:14:18'),(188,1,NULL,1,3,'Monday','period',NULL,5,2,'09:20:00','10:00:00',2,'2026-06-16 17:14:18'),(189,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-06-16 17:14:18'),(190,1,NULL,1,3,'Monday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-06-16 17:14:18'),(191,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-06-16 17:14:18'),(192,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-06-16 17:14:18'),(193,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-06-16 17:14:18'),(194,1,NULL,1,3,'Monday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-06-16 17:14:18'),(195,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-06-16 17:14:18'),(196,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-06-16 17:14:18'),(197,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-06-16 17:14:18'),(198,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-06-16 17:14:18'),(199,1,NULL,1,3,'Tuesday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-06-16 17:14:18'),(200,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-06-16 17:14:18'),(201,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-06-16 17:14:18'),(202,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-06-16 17:14:18'),(203,1,NULL,1,3,'Tuesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-06-16 17:14:18'),(204,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-06-16 17:14:18'),(205,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-06-16 17:14:18'),(206,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-06-16 17:14:19'),(207,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-06-16 17:14:19'),(208,1,NULL,1,3,'Wednesday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-06-16 17:14:19'),(209,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-06-16 17:14:19'),(210,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-06-16 17:14:19'),(211,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-06-16 17:14:19'),(212,1,NULL,1,3,'Wednesday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-06-16 17:14:19'),(213,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-06-16 17:14:19'),(214,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-06-16 17:14:19'),(215,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-06-16 17:14:19'),(216,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-06-16 17:14:19'),(217,1,NULL,1,3,'Thursday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-06-16 17:14:19'),(218,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-06-16 17:14:19'),(219,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-06-16 17:14:19'),(220,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-06-16 17:14:19'),(221,1,NULL,1,3,'Thursday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-06-16 17:14:19'),(222,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'08:00:00','08:40:00',0,'2026-06-16 17:14:19'),(223,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'08:40:00','09:20:00',1,'2026-06-16 17:14:19'),(224,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'09:20:00','10:00:00',2,'2026-06-16 17:14:19'),(225,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'10:00:00','10:40:00',3,'2026-06-16 17:14:19'),(226,1,NULL,1,3,'Friday','break','Lunch Break',NULL,NULL,'10:40:00','11:10:00',4,'2026-06-16 17:14:19'),(227,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'11:10:00','11:50:00',5,'2026-06-16 17:14:19'),(228,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'11:50:00','12:30:00',6,'2026-06-16 17:14:19'),(229,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'12:30:00','13:10:00',7,'2026-06-16 17:14:19'),(230,1,NULL,1,3,'Friday','period',NULL,NULL,NULL,'13:10:00','13:50:00',8,'2026-06-16 17:14:19');
/*!40000 ALTER TABLE `timetable_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transcripts`
--

DROP TABLE IF EXISTS `transcripts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transcripts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `generated_by` int unsigned NOT NULL,
  `session_ids` json NOT NULL,
  `generated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `generated_by` (`generated_by`),
  CONSTRAINT `transcripts_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transcripts_ibfk_2` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transcripts`
--

LOCK TABLES `transcripts` WRITE;
/*!40000 ALTER TABLE `transcripts` DISABLE KEYS */;
/*!40000 ALTER TABLE `transcripts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role_sections`
--

DROP TABLE IF EXISTS `user_role_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role_sections` (
  `user_id` int unsigned NOT NULL,
  `role_id` int unsigned NOT NULL,
  `section_id` int unsigned NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`user_id`,`role_id`,`section_id`),
  KEY `section_id` (`section_id`),
  KEY `idx_urs_org` (`organization_id`),
  CONSTRAINT `user_role_sections_ibfk_1` FOREIGN KEY (`user_id`, `role_id`) REFERENCES `user_roles` (`user_id`, `role_id`) ON DELETE CASCADE,
  CONSTRAINT `user_role_sections_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role_sections`
--

LOCK TABLES `user_role_sections` WRITE;
/*!40000 ALTER TABLE `user_role_sections` DISABLE KEYS */;
INSERT INTO `user_role_sections` VALUES (3,5,2,1,NULL),(190,5,1,1,NULL);
/*!40000 ALTER TABLE `user_role_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int unsigned NOT NULL,
  `role_id` int unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1),(197,2),(2,4),(17,4),(175,4),(180,4),(3,5),(190,5),(7,6),(9,6),(12,6),(14,6),(176,6),(178,6),(182,6),(183,6),(6,7),(8,7),(15,7),(18,7),(19,7),(20,7),(21,7),(22,7),(23,7),(24,7),(25,7),(26,7),(27,7),(28,7),(29,7),(30,7),(31,7),(32,7),(33,7),(34,7),(35,7),(36,7),(37,7),(38,7),(39,7),(40,7),(41,7),(42,7),(43,7),(44,7),(45,7),(46,7),(47,7),(48,7),(49,7),(50,7),(51,7),(52,7),(53,7),(54,7),(55,7),(56,7),(57,7),(58,7),(59,7),(60,7),(61,7),(62,7),(63,7),(64,7),(65,7),(66,7),(67,7),(68,7),(69,7),(70,7),(71,7),(72,7),(73,7),(74,7),(75,7),(76,7),(77,7),(78,7),(79,7),(80,7),(81,7),(82,7),(83,7),(84,7),(85,7),(86,7),(87,7),(88,7),(89,7),(90,7),(91,7),(92,7),(93,7),(94,7),(95,7),(96,7),(97,7),(98,7),(99,7),(100,7),(101,7),(102,7),(103,7),(104,7),(105,7),(106,7),(107,7),(108,7),(109,7),(110,7),(111,7),(112,7),(113,7),(114,7),(115,7),(116,7),(117,7),(118,7),(119,7),(120,7),(121,7),(122,7),(123,7),(124,7),(125,7),(126,7),(127,7),(128,7),(129,7),(130,7),(131,7),(132,7),(133,7),(134,7),(135,7),(136,7),(137,7),(138,7),(139,7),(140,7),(141,7),(142,7),(143,7),(144,7),(145,7),(146,7),(147,7),(148,7),(149,7),(150,7),(151,7),(152,7),(153,7),(154,7),(155,7),(156,7),(157,7),(158,7),(159,7),(160,7),(161,7),(162,7),(163,7),(164,7),(165,7),(166,7),(167,7),(168,7),(169,7),(170,7),(171,7),(172,7),(173,7),(177,7),(179,7),(184,7),(185,7),(5,8),(181,25),(196,26);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `campus_id` int unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `section_id` int unsigned DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `bank_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totp_secret` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totp_enabled` tinyint(1) DEFAULT '0',
  `totp_recovery_codes` text COLLATE utf8mb4_unicode_ci,
  `email_verified_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`),
  KEY `role_id` (`role_id`),
  KEY `section_id` (`section_id`),
  KEY `idx_users_org` (`organization_id`),
  KEY `idx_users_campus` (`campus_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=198 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,NULL,1,NULL,NULL,'Super','Admin','abubakar17hm@gmail.com',NULL,'$2y$12$../6FqIgVrWXXxMWbO44QeBszXwn6xr7aCsQG70F4WbeOEc8BK4Qa','avatar_1_1779797867.jpg',NULL,'2026-07-16','male',NULL,NULL,1,'2026-07-16 15:33:50','2026-05-13 10:56:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(2,1,NULL,4,2,NULL,'Abubakar','Muhammad','aharunamuhammad1503@gmail.com','09020439378','$2y$12$TBxwywV1BaqMA.odDqpVuuYKYQxt5BBkNJRlOlozYMa3KgWG8I1aO','teacher_6a0470aabf7bf.jpg',NULL,NULL,NULL,NULL,NULL,1,'2026-05-31 10:04:02','2026-05-13 12:14:37',NULL,NULL,NULL,NULL,0,NULL,NULL),(3,1,NULL,5,NULL,NULL,'Auta','Amaka','amaka@gmail.com',NULL,'$2y$10$.kZHq9kZy0Clc9bRR2uOluk0wVYPCNOX9M.1bQq1xu9V4B4lssQmS',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-17 10:51:57','2026-05-13 15:41:55',NULL,NULL,NULL,NULL,0,NULL,NULL),(5,1,NULL,8,NULL,NULL,'Habu','','abcd@gmail.com',NULL,'$2y$10$kz51hc/h649RnEvx4mby3u5gonXBt8k3JNZBTneut/gkTrVW8PnSG',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-16 14:21:26','2026-05-24 15:12:39',NULL,NULL,NULL,NULL,0,NULL,NULL),(6,1,NULL,7,2,NULL,'Amina','Kabir Idris','abubakar19hm@gmail.com','09020439378','$2y$12$DoOfMlxqDb8cwoHh.2IWNO.dcfS/YyebX.xhdpV6WYldf6XlaEnta',NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-07-10 14:25:30','2026-05-26 09:29:51',NULL,NULL,NULL,NULL,0,NULL,NULL),(7,1,NULL,6,NULL,NULL,'Abubakar','Haruna Muhammad','p6@school.com','09020439378','$2y$12$kABvIrxIzNXCdF/UXVHfne3TbhUFFTQwoQ4lb/pP6dzO4lx9w1fXy',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-26 09:38:43',NULL,NULL,NULL,NULL,0,NULL,NULL),(8,1,NULL,7,1,NULL,'Fatima','Abubakar','dankwarai02@gmail.com','09020439378','$2y$12$riCMYhz1dseY/erhudzLHO9nk32hQA/KcU3MhEIVni3REPmwavFDy',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-16 10:38:56','2026-05-26 10:58:54',NULL,NULL,NULL,NULL,0,NULL,NULL),(9,1,NULL,6,NULL,NULL,'Abubakar','Guardian','p8@school.com','09020439378','$2y$12$PdTDDqEK45Kr5gNnlW8ku.iJUmILjUPCvmoBV232G68ntYtYBQxNy',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-26 11:00:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(12,1,NULL,6,2,NULL,'Adam','Labaran Adam','amakamak3070@gmail.com','09121517457','$2y$12$mn0156ArIpHBr2e.fkm6QOmL2C7uRAEchqr60PzqqKjUA4B6BAkTO',NULL,NULL,'2024-05-22','male',NULL,NULL,1,'2026-07-10 15:59:51','2026-05-26 13:48:11',NULL,NULL,NULL,NULL,0,NULL,NULL),(14,1,NULL,6,1,NULL,'Amina','Royal Academy','adamlabaranadam@gmail.com','09020439378','$2y$12$lXh9WMsi0r4ohR1o8amu0.pRx/y9icd92/RNft99fF2OzPkacbN7m',NULL,NULL,'2024-05-23','male',NULL,NULL,1,'2026-07-02 10:40:58','2026-05-26 15:06:22',NULL,NULL,NULL,NULL,0,NULL,NULL),(15,1,NULL,7,1,NULL,'Amina','Royal Academy','samina14@school.com','09020439378','$2y$10$YMZTWSWOzdHD8uE3WZu.AurvykgRJn6GJjPPEX2M50KTvBkhMa1im',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-26 15:06:58',NULL,NULL,NULL,NULL,0,NULL,NULL),(17,1,NULL,4,1,NULL,'Mai','mota','mm@gmail.com','','$2y$12$cMRoM679xu9i.BK8.a.Ft.9tCu9p1s2/5kGWmGrHu9A1y077ncQru',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-10 14:23:20','2026-05-27 14:00:49',NULL,NULL,NULL,NULL,0,NULL,NULL),(18,1,NULL,7,2,NULL,'Jane','Williams','jane.williams.610d9988@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(19,1,NULL,7,2,NULL,'Ruth','Brown','ruth.brown.270e4213@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(20,1,NULL,7,2,NULL,'Michael','Rodriguez','michael.rodriguez.b92f1a8f@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(21,1,NULL,7,2,NULL,'Grace','Anderson','grace.anderson.d3c28bb4@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(22,1,NULL,7,2,NULL,'Michael','Martinez','michael.martinez.9f976ed6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(23,1,NULL,7,1,NULL,'Michael','Davis','michael.davis.e254a287@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(24,1,NULL,7,1,NULL,'Daniel','Miller','06@example.com','','$2y$12$uuk2XvWNL5baxFLg.7nw6u32Rc5lTbz37t/XaejOJEon3MPAlh7Qi','student_6a1c7e2725f9b.jpg',NULL,NULL,'male',NULL,NULL,1,'2026-07-16 10:37:44','2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(25,1,NULL,7,1,NULL,'Jane','Anderson','jane.anderson.e1965b2c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(26,1,NULL,7,1,NULL,'Michael','Garcia','michael.garcia.7d4281ba@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(27,1,NULL,7,1,NULL,'John','Gonzalez','john.gonzalez.35e0e847@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(28,1,NULL,7,1,NULL,'Victoria','Smith','victoria.smith.94218067@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:13',NULL,NULL,NULL,NULL,0,NULL,NULL),(29,1,NULL,7,1,NULL,'Joseph','Davis','joseph.davis.e2e57f21@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(30,1,NULL,7,1,NULL,'Elizabeth','Martinez','elizabeth.martinez.71809641@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(31,1,NULL,7,1,NULL,'David','Davis','david.davis.481c9189@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(32,1,NULL,7,1,NULL,'Michael','Gonzalez','michael.gonzalez.848f717a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(33,1,NULL,7,1,NULL,'Victoria','Martinez','victoria.martinez.3b4d8328@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(34,1,NULL,7,1,NULL,'Peter','Johnson','peter.johnson.0528f773@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(35,1,NULL,7,1,NULL,'Elizabeth','Hernandez','elizabeth.hernandez.234bf525@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(36,1,NULL,7,1,NULL,'Grace','Gonzalez','grace.gonzalez.9fe5e636@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(37,1,NULL,7,1,NULL,'Mary','Thomas','mary.thomas.61a8f9b6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(38,1,NULL,7,1,NULL,'Samuel','Jones','samuel.jones.44c19fc6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(39,1,NULL,7,1,NULL,'Samuel','Martinez','samuel.martinez.804db328@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(40,1,NULL,7,1,NULL,'John','Wilson','john.wilson.409cb930@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(41,1,NULL,7,1,NULL,'David','Hernandez','david.hernandez.eb58140a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(42,1,NULL,7,1,NULL,'Michael','Martinez','michael.martinez.cdf52c23@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(43,1,NULL,7,1,NULL,'Elizabeth','Thomas','elizabeth.thomas.3885de45@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(44,1,NULL,7,1,NULL,'Jane','Rodriguez','jane.rodriguez.6c00164f@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(45,1,NULL,7,1,NULL,'Jane','Gonzalez','jane.gonzalez.65fdc672@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(46,1,NULL,7,1,NULL,'Ruth','Lopez','ruth.lopez.847a16e6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(47,1,NULL,7,1,NULL,'Peter','Rodriguez','peter.rodriguez.fe0266d7@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(48,1,NULL,7,1,NULL,'Daniel','Wilson','daniel.wilson.b96ec7c5@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(49,1,NULL,7,1,NULL,'Elizabeth','Lopez','elizabeth.lopez.3cc675f1@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(50,1,NULL,7,1,NULL,'Isaac','Gonzalez','isaac.gonzalez.d191d133@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:14',NULL,NULL,NULL,NULL,0,NULL,NULL),(51,1,NULL,7,1,NULL,'Mary','Garcia','mary.garcia.6086a4e2@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(52,1,NULL,7,1,NULL,'Elizabeth','Davis','elizabeth.davis.ad2fc4f0@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(53,1,NULL,7,1,NULL,'Jane','Smith','jane.smith.f696b552@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(54,1,NULL,7,1,NULL,'Peter','Thomas','peter.thomas.fcbb61f6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(55,1,NULL,7,1,NULL,'John','Martinez','john.martinez.496890b4@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(56,1,NULL,7,1,NULL,'Grace','Brown','grace.brown.a8f3204a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(57,1,NULL,7,1,NULL,'John','Williams','john.williams.b296e744@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(58,1,NULL,7,1,NULL,'Isaac','Thomas','isaac.thomas.d6304801@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(59,1,NULL,7,1,NULL,'Victoria','Rodriguez','victoria.rodriguez.0baf9caf@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(60,1,NULL,7,1,NULL,'John','Davis','john.davis.815d0689@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(61,1,NULL,7,1,NULL,'Mary','Johnson','mary.johnson.c4e8843a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(62,1,NULL,7,1,NULL,'Michael','Jones','michael.jones.05da205e@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(63,1,NULL,7,1,NULL,'Sarah','Wilson','sarah.wilson.c7985337@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(64,1,NULL,7,1,NULL,'Samuel','Lopez','samuel.lopez.4ead6112@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(65,1,NULL,7,1,NULL,'Grace','Jones','grace.jones.fed442dd@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(66,1,NULL,7,1,NULL,'Hannah','Davis','hannah.davis.e9db85d2@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(67,1,NULL,7,1,NULL,'Daniel','Gonzalez','daniel.gonzalez.fdaf3e1f@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(68,1,NULL,7,1,NULL,'Hannah','Williams','hannah.williams.d0c34afd@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(69,1,NULL,7,1,NULL,'Michael','Smith','michael.smith.9b5b3fed@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(70,1,NULL,7,1,NULL,'Joseph','Smith','joseph.smith.547d9fee@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(71,1,NULL,7,1,NULL,'Isaac','Miller','isaac.miller.4ee060fd@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(72,1,NULL,7,1,NULL,'Isaac','Hernandez','isaac.hernandez.e2e11bb6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(73,1,NULL,7,1,NULL,'Ruth','Hernandez','ruth.hernandez.a82dd373@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:15',NULL,NULL,NULL,NULL,0,NULL,NULL),(74,1,NULL,7,1,NULL,'Isaac','Smith','isaac.smith.56e90982@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(75,1,NULL,7,1,NULL,'Isaac','Garcia','isaac.garcia.e9229299@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(76,1,NULL,7,1,NULL,'Samuel','Davis','samuel.davis.5c60e884@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(77,1,NULL,7,1,NULL,'Isaac','Jones','isaac.jones.f0c95709@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(78,1,NULL,7,1,NULL,'Mary','Lopez','mary.lopez.5bbdab3b@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(79,1,NULL,7,1,NULL,'Joseph','Thomas','joseph.thomas.0945df82@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(80,1,NULL,7,1,NULL,'Elizabeth','Miller','elizabeth.miller.c1705116@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(81,1,NULL,7,1,NULL,'Elizabeth','Brown','elizabeth.brown.1a4f4fd8@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(82,1,NULL,7,1,NULL,'Hannah','Anderson','hannah.anderson.875f7d53@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(83,1,NULL,7,2,NULL,'John','Brown','john.brown.ce758260@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(84,1,NULL,7,2,NULL,'Peter','Garcia','peter.garcia.3eab0fb6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(85,1,NULL,7,2,NULL,'Daniel','Rodriguez','daniel.rodriguez.287c3b89@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(86,1,NULL,7,2,NULL,'Elizabeth','Garcia','elizabeth.garcia.f1ba5eaa@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(87,1,NULL,7,2,NULL,'Mary','Hernandez','mary.hernandez.7c272557@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(88,1,NULL,7,2,NULL,'Joseph','Martinez','joseph.martinez.abcc62c1@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(89,1,NULL,7,2,NULL,'Daniel','Johnson','daniel.johnson.713ee09a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(90,1,NULL,7,2,NULL,'David','Williams','david.williams.8fde7f30@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(91,1,NULL,7,2,NULL,'Hannah','Hernandez','hannah.hernandez.6fac59fe@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(92,1,NULL,7,2,NULL,'John','Rodriguez','john.rodriguez.499a8a45@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(93,1,NULL,7,2,NULL,'John','Johnson','john.johnson.a458946b@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:16',NULL,NULL,NULL,NULL,0,NULL,NULL),(94,1,NULL,7,2,NULL,'Victoria','Brown','victoria.brown.cb74dc9e@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(95,1,NULL,7,2,NULL,'Grace','Thomas','grace.thomas.fd782059@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(96,1,NULL,7,2,NULL,'Daniel','Johnson','daniel.johnson.526d4229@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(97,1,NULL,7,2,NULL,'Joseph','Miller','joseph.miller.e977d51d@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(98,1,NULL,7,2,NULL,'Peter','Gonzalez','peter.gonzalez.dc6d0bf2@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(99,1,NULL,7,2,NULL,'John','Anderson','john.anderson.efbfe1a9@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(100,1,NULL,7,2,NULL,'Samuel','Williams','samuel.williams.44049abb@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(101,1,NULL,7,2,NULL,'Mary','Martinez','mary.martinez.d4cfbe61@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(102,1,NULL,7,2,NULL,'Sarah','Johnson','sarah.johnson.000ffbb1@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(103,1,NULL,7,2,NULL,'Daniel','Hernandez','daniel.hernandez.77860c65@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(104,1,NULL,7,2,NULL,'Jane','Thomas','jane.thomas.7e1b6008@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(105,1,NULL,7,2,NULL,'Hannah','Lopez','hannah.lopez.07d5ffba@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(106,1,NULL,7,2,NULL,'Michael','Miller','michael.miller.e3267e29@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(107,1,NULL,7,2,NULL,'Samuel','Miller','samuel.miller.c664578b@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(108,1,NULL,7,2,NULL,'Michael','Garcia','michael.garcia.4d7fc50c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(109,1,NULL,7,2,NULL,'Joseph','Brown','joseph.brown.f3eb2ef7@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(110,1,NULL,7,2,NULL,'Peter','Wilson','peter.wilson.05f1a426@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(111,1,NULL,7,2,NULL,'John','Gonzalez','john.gonzalez.e6027d85@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(112,1,NULL,7,2,NULL,'Ruth','Thomas','ruth.thomas.cb5fa587@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(113,1,NULL,7,2,NULL,'Joseph','Garcia','joseph.garcia.35376039@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(114,1,NULL,7,2,NULL,'Ruth','Miller','ruth.miller.f6493aec@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(115,1,NULL,7,2,NULL,'Daniel','Hernandez','daniel.hernandez.113a9495@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(116,1,NULL,7,2,NULL,'Hannah','Garcia','hannah.garcia.1c812170@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:17',NULL,NULL,NULL,NULL,0,NULL,NULL),(117,1,NULL,7,2,NULL,'David','Thomas','david.thomas.a6448535@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(118,1,NULL,7,2,NULL,'Michael','Hernandez','michael.hernandez.2e042513@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(119,1,NULL,7,2,NULL,'Grace','Davis','grace.davis.f47aa1f0@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(120,1,NULL,7,2,NULL,'Daniel','Smith','daniel.smith.156f69bb@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(121,1,NULL,7,2,NULL,'Isaac','Martinez','isaac.martinez.070b71a1@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(122,1,NULL,7,2,NULL,'John','Garcia','john.garcia.58ce9128@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(123,1,NULL,7,2,NULL,'Grace','Garcia','grace.garcia.9221852a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(124,1,NULL,7,2,NULL,'Samuel','Hernandez','samuel.hernandez.2aaba0b8@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(125,1,NULL,7,2,NULL,'Peter','Lopez','peter.lopez.8b8cee37@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(126,1,NULL,7,2,NULL,'Jane','Williams','jane.williams.2c947757@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(127,1,NULL,7,2,NULL,'Hannah','Lopez','hannah.lopez.4563e31f@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(128,1,NULL,7,2,NULL,'Isaac','Anderson','isaac.anderson.651d8d74@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(129,1,NULL,7,2,NULL,'Michael','Gonzalez','michael.gonzalez.b69af1db@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(130,1,NULL,7,2,NULL,'Joseph','Thomas','joseph.thomas.720d7e95@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(131,1,NULL,7,2,NULL,'Isaac','Garcia','isaac.garcia.8c272da5@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(132,1,NULL,7,2,NULL,'Victoria','Jones','victoria.jones.3b378a5e@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(133,1,NULL,7,2,NULL,'Mary','Thomas','mary.thomas.ecf621e1@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(134,1,NULL,7,2,NULL,'Isaac','Gonzalez','isaac.gonzalez.47d2c698@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(135,1,NULL,7,2,NULL,'Samuel','Martinez','samuel.martinez.f43cdd50@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(136,1,NULL,7,2,NULL,'Jane','Rodriguez','jane.rodriguez.b8f6ea63@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(137,1,NULL,7,2,NULL,'Jane','Lopez','jane.lopez.5981bcea@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(138,1,NULL,7,2,NULL,'Jane','Anderson','jane.anderson.098ef15c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(139,1,NULL,7,2,NULL,'Hannah','Williams','hannah.williams.69940dd2@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(140,1,NULL,7,2,NULL,'Mary','Lopez','mary.lopez.0135f0d2@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(141,1,NULL,7,2,NULL,'Isaac','Jones','isaac.jones.1a98cc03@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(142,1,NULL,7,2,NULL,'Elizabeth','Johnson','elizabeth.johnson.d951219c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(143,1,NULL,7,2,NULL,'John','Hernandez','john.hernandez.9d528bbb@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(144,1,NULL,7,2,NULL,'Peter','Anderson','peter.anderson.a367e158@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(145,1,NULL,7,2,NULL,'Grace','Lopez','grace.lopez.666b2920@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(146,1,NULL,7,2,NULL,'Elizabeth','Rodriguez','elizabeth.rodriguez.bbce9ddc@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(147,1,NULL,7,2,NULL,'John','Wilson','john.wilson.a525a61a@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(148,1,NULL,7,2,NULL,'Elizabeth','Williams','elizabeth.williams.0915bd8b@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(149,1,NULL,7,2,NULL,'David','Jones','david.jones.ecfe7218@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(150,1,NULL,7,2,NULL,'Peter','Gonzalez','peter.gonzalez.0d6484ef@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(151,1,NULL,7,2,NULL,'Peter','Smith','peter.smith.e10e437c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(152,1,NULL,7,2,NULL,'Ruth','Martinez','ruth.martinez.fa8a9450@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(153,1,NULL,7,2,NULL,'Jane','Thomas','jane.thomas.fffa16ba@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(154,1,NULL,7,2,NULL,'Victoria','Thomas','victoria.thomas.f766ccf9@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(155,1,NULL,7,2,NULL,'Joseph','Miller','joseph.miller.2f8f266e@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(156,1,NULL,7,2,NULL,'Grace','Smith','grace.smith.ef176ff3@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(157,1,NULL,7,2,NULL,'Mary','Hernandez','mary.hernandez.445f4154@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(158,1,NULL,7,2,NULL,'Maryam','Murtala','maryamm@gmail.com','090876542345','$2y$12$62pTNKk47/FfXHX3MFda2e87LmtMYFtaWnMoERKtirTRyDot0irYq','student_6a1c7f022589b.jpeg',NULL,NULL,'female',NULL,NULL,1,'2026-05-31 19:34:28','2026-05-27 14:17:19',NULL,NULL,NULL,NULL,0,NULL,NULL),(159,1,NULL,7,2,NULL,'Sarah','Williams','sarah.williams.25c62ae7@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(160,1,NULL,7,2,NULL,'Ruth','Miller','ruth.miller.4ee53295@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(161,1,NULL,7,2,NULL,'Victoria','Gonzalez','victoria.gonzalez.e3d7b788@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(162,1,NULL,7,2,NULL,'Elizabeth','Thomas','elizabeth.thomas.2e176a06@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(163,1,NULL,7,2,NULL,'Ruth','Martinez','ruth.martinez.9c23e4aa@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(164,1,NULL,7,2,NULL,'Samuel','Johnson','samuel.johnson.0ce9599b@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(165,1,NULL,7,2,NULL,'Samuel','Martinez','samuel.martinez.1707515c@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(166,1,NULL,7,2,NULL,'Mary','Martinez','mary.martinez.6c008005@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(167,1,NULL,7,2,NULL,'Michael','Smith','michael.smith.7368ca00@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(168,1,NULL,7,2,NULL,'Michael','Williams','michael.williams.787a929d@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(169,1,NULL,7,2,NULL,'Jane','Garcia','jane.garcia.2c1ac944@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(170,1,NULL,7,2,NULL,'Victoria','Lopez','victoria.lopez.0e70e54f@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(171,1,NULL,7,2,NULL,'Mary','Hernandez','mary.hernandez.cf3fb5e6@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(172,1,NULL,7,2,NULL,'Grace','Smith','grace.smith.8bc72ec7@example.com',NULL,'$2y$10$PtplOApMxB5C1N6A01J7C.2OJgNPSTPxxoaottmvT7ADID8PncG56',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-05-27 14:17:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(173,1,NULL,NULL,NULL,NULL,'Test','Student','test.student@school.com',NULL,'$2y$12$fKxkTAhAh722ZySKrlCF9.iCy1MUex4jPbczZLCxfKZTEYB2UAqWC',NULL,NULL,NULL,'male',NULL,NULL,1,'2026-05-31 10:04:45','2026-05-27 16:52:18',NULL,NULL,NULL,NULL,0,NULL,NULL),(175,1,NULL,4,1,NULL,'Auta','','auta@gmail.com',NULL,'$2y$12$fDeL1UjsJr.JgOUIiKuUEu/P0qBSO709xChCe5uHVOPCLhaNqn2M.',NULL,NULL,'2007-08-26','male',NULL,NULL,1,'2026-07-16 13:58:29','2026-05-31 09:45:40',NULL,NULL,NULL,NULL,0,NULL,NULL),(176,1,NULL,6,2,NULL,'shema&#039;u','','abdulmutallibabdulkarim30@gmail.com','09038926842','$2y$12$EWoPPiPEWhx9zcs658mdeONRlLGxF2Ue7q9So0rFELwQmGYjJ3EAi','reg_1780244127_ece7a521.jpg',NULL,'2006-09-23','female',NULL,NULL,1,NULL,'2026-05-31 16:15:27',NULL,NULL,NULL,NULL,0,NULL,NULL),(177,1,NULL,7,2,NULL,'shema&#039;u','','sshema&#039;u176@school.com','09038926842','$2y$10$HM8E0fhGjHf7HS16xBBQ1.VYdP/DUudOsYw2xOPB5XfhLltX7SRy6','reg_1780244127_ece7a521.jpg',NULL,'2006-09-23','female',NULL,NULL,1,NULL,'2026-05-31 16:18:49',NULL,NULL,NULL,NULL,0,NULL,NULL),(178,1,NULL,6,2,NULL,'shema\'u','','abddulmutallibabdulkarim30@gmail.com','09038926842','$2y$12$kp18LD1GC/vp7MWFlaewc.DZ7mcXH7BgCUJCmUccT3w2Vav6IasYG','reg_1780245630_5fbe3114.jpg',NULL,'2006-02-06','female',NULL,NULL,1,'2026-05-31 17:57:26','2026-05-31 16:40:30',NULL,NULL,NULL,NULL,0,NULL,NULL),(179,1,NULL,7,NULL,NULL,'shema\'u','','sshemau178@school.com','09038926842','$2y$10$vbduaN7SCHrrxFX5tUWbnuYobI/LqCF10TKIYHFjEoBGEFPbAr3oa','reg_1780245630_5fbe3114.jpg',NULL,'2006-02-06','female',NULL,NULL,1,'2026-05-31 18:06:36','2026-05-31 16:47:20',NULL,NULL,NULL,NULL,0,NULL,NULL),(180,1,NULL,4,2,NULL,'sani','','nestrikn@gmail.com','09038926842','$2y$12$VWvRZaw11K7Oi.FedmdZiOOGRTz34MFTqJNvuiFWDRuQwx/FktE76','reg_1780247699_db32611c.jpg',NULL,'1999-02-04','male',NULL,NULL,1,'2026-05-31 19:31:51','2026-05-31 17:14:59',NULL,NULL,NULL,NULL,0,NULL,NULL),(181,1,NULL,25,NULL,NULL,'Fatima','Habib','fh@gmail.com',NULL,'$2y$12$e08CF87MpY/7WBm8ei2qH.uwsltTzARMk51m576u4KaaQApthhYka',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-20 11:53:14','2026-06-21 11:53:23',NULL,NULL,NULL,NULL,0,NULL,NULL),(182,1,NULL,6,1,NULL,'yahaya','muhammad','sadeeqbnyahya@gmail.com','09137214513','$2y$12$qKUVLqFnT6fsE8px5k4QFOgm9xwtBJiFalx.dJCKlNLlHQm/Q9Aom',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-16 12:51:51','2026-06-24 13:32:21',NULL,NULL,NULL,NULL,0,NULL,NULL),(183,1,NULL,6,1,NULL,'muhammad','yahaya muhammad','sadeeqyahya20@gmail.com','09137214513','$2y$12$woKu..DyG5EWKDPQEWCiB.HIeogNO9jEF0FaFaXB/Inekyoqjk5/m',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-16 12:51:21','2026-06-24 13:50:50',NULL,NULL,NULL,NULL,0,NULL,NULL),(184,1,NULL,7,1,NULL,'sadiq','yahaya','ssadiq182@school.com',NULL,'$2y$10$r/SgjxdAfSDX2TW8XH16c.M7sO75o0wXtvqS/GHl6xXiklHF9T62u',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-06-24 14:12:43',NULL,NULL,NULL,NULL,0,NULL,NULL),(185,1,NULL,7,1,NULL,'yahaya','muhammad','syahaya183@school.com','','$2y$12$P.jF5UKVq3dEpZxaa05cOO2K6xPcIFn2J1Rz2WZTDOfkZDuZQ9MZ2',NULL,NULL,'2026-06-24','male',NULL,NULL,1,'2026-06-24 18:08:20','2026-06-24 14:12:43',NULL,NULL,NULL,NULL,0,NULL,NULL),(190,1,NULL,5,NULL,NULL,'Accountant','','acct@gmail.com',NULL,'$2y$12$QRwwaCUwWLzn4rwO1KfQ9e6M6woSDCUkkpa6U7I9CHHWFBaatLhLm',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-17 10:48:52','2026-07-10 22:04:53',NULL,NULL,NULL,NULL,0,NULL,NULL),(196,1,NULL,26,1,NULL,'Babba','','abdurrahmanalhassan775@gmail.com',NULL,'$2y$12$mn9vJ/zBVMyrfJmNEB4Sdea7DPDwWPESYC/AXMmKkCo.tEFQrA3RW',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-07-17 14:55:29','2026-07-17 10:41:26',NULL,NULL,NULL,NULL,0,NULL,NULL),(197,1,NULL,2,2,NULL,'Sadiq','','sadiq@gmail.com',NULL,'$2y$12$s/Qdu9DmgnniGRpE.cryb.c41Ym7eGBdWUfF5hg8jsbaGXYEfJeZS',NULL,NULL,NULL,'male',NULL,NULL,1,'2026-07-17 15:47:00','2026-07-17 14:44:07',NULL,NULL,NULL,NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_student_fees`
--

DROP TABLE IF EXISTS `v_student_fees`;
/*!50001 DROP VIEW IF EXISTS `v_student_fees`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_student_fees` AS SELECT 
 1 AS `student_id`,
 1 AS `fee_id`,
 1 AS `term_id`,
 1 AS `class_id`,
 1 AS `section_id`,
 1 AS `category`,
 1 AS `gross_amount`,
 1 AS `net_amount`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_student_fees`
--

/*!50001 DROP VIEW IF EXISTS `v_student_fees`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`school_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_student_fees` AS select `st`.`id` AS `student_id`,`fs`.`id` AS `fee_id`,`fs`.`term_id` AS `term_id`,`fs`.`class_id` AS `class_id`,`st`.`section_id` AS `section_id`,`fs`.`category` AS `category`,`fs`.`amount` AS `gross_amount`,greatest(0,((`fs`.`amount` - coalesce(sum((case when (`fa`.`kind` in ('discount','scholarship','waiver')) then (case when (`fa`.`adjust_type` = 'percent') then ((`fs`.`amount` * `fa`.`value`) / 100) else `fa`.`value` end) else 0 end)),0)) + coalesce(sum((case when (`fa`.`kind` = 'penalty') then (case when (`fa`.`adjust_type` = 'percent') then ((`fs`.`amount` * `fa`.`value`) / 100) else `fa`.`value` end) else 0 end)),0))) AS `net_amount` from ((`students` `st` join `fee_structures` `fs` on((`fs`.`class_id` = `st`.`class_id`))) left join `fee_adjustments` `fa` on(((`fa`.`student_id` = `st`.`id`) and (`fa`.`fee_id` = `fs`.`id`)))) group by `st`.`id`,`fs`.`id`,`fs`.`term_id`,`fs`.`class_id`,`st`.`section_id`,`fs`.`category`,`fs`.`amount` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-27 14:38:28

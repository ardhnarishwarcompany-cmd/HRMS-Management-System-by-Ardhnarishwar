-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: hrms_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_audit_logs`
--

DROP TABLE IF EXISTS `admin_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_audit_logs`
--

LOCK TABLES `admin_audit_logs` WRITE;
/*!40000 ALTER TABLE `admin_audit_logs` DISABLE KEYS */;
INSERT INTO `admin_audit_logs` VALUES (1,'Super Admin','CREATE','Compliance','Added item: Audit smoke test','2026-08-13 07:42:49'),(2,'Super Admin','DELETE','Compliance','Deleted item #2','2026-08-13 07:42:49'),(3,'Super Admin','PENDING','Verification','Document #1','2026-08-14 09:58:19'),(4,'Super Admin','VERIFIED','Verification','Document #1','2026-08-14 09:58:23'),(5,'Super Admin','UPLOAD','Verification','PAN Card for Phabindra Kumar Sah','2026-09-02 07:50:05'),(6,'Super Admin','CREATE','Onboarding','Proposal for suhani','2026-09-08 04:48:11'),(7,'Super Admin','REJECTED','Verification','Document #4','2026-09-09 19:11:43'),(8,'Super Admin','REJECTED','Verification','Document #3','2026-09-09 19:11:48'),(9,'Super Admin','VERIFIED','Verification','Document #5','2026-09-09 19:13:01'),(10,'Super Admin','BACKGROUND_VERIFIED','Verification','Background check #1','2026-09-09 19:43:23'),(11,'Super Admin','VERIFIED','Verification','Document #6','2026-09-09 19:47:17'),(12,'Super Admin','VERIFIED','Verification','Document #7','2026-09-09 19:47:19'),(13,'Super Admin','VERIFIED','Verification','Document #8','2026-09-09 19:47:20'),(14,'Super Admin','VERIFIED','Verification','Document #9','2026-09-09 19:47:20'),(15,'Super Admin','VERIFIED','Verification','Document #10','2026-09-09 19:47:22'),(16,'Super Admin','VERIFIED','Verification','Document #11','2026-09-09 19:47:23'),(17,'Super Admin','PENDING','Verification','Document #4','2026-09-09 19:47:37'),(18,'Super Admin','VERIFIED','Verification','Document #4','2026-09-09 19:47:39'),(19,'Super Admin','PENDING','Verification','Document #3','2026-09-09 19:47:41'),(20,'Super Admin','VERIFIED','Verification','Document #3','2026-09-09 19:47:42'),(21,'Super Admin','IDENTITY_AADHAAR_VERIFIED','Verification','Identity record #10','2026-09-09 20:02:22');
/*!40000 ALTER TABLE `admin_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_payroll`
--

DROP TABLE IF EXISTS `admin_payroll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_payroll` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `payroll_month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `basic_salary` decimal(10,2) DEFAULT '0.00',
  `hra` decimal(10,2) DEFAULT '0.00',
  `ta` decimal(10,2) DEFAULT '0.00',
  `da` decimal(10,2) DEFAULT '0.00',
  `overtime_amount` decimal(10,2) DEFAULT '0.00',
  `gross_salary` decimal(10,2) DEFAULT '0.00',
  `pf` decimal(10,2) DEFAULT '0.00',
  `esic` decimal(10,2) DEFAULT '0.00',
  `net_salary` decimal(10,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `admin_payroll_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_payroll`
--

LOCK TABLES `admin_payroll` WRITE;
/*!40000 ALTER TABLE `admin_payroll` DISABLE KEYS */;
INSERT INTO `admin_payroll` VALUES (1,8,'2026-07',20967.74,0.00,0.00,0.00,0.00,20967.74,2516.13,157.26,18294.35,'2026-08-13 17:37:34'),(2,9,'2026-07',18709.68,0.00,0.00,0.00,0.00,18709.68,2245.16,140.32,16324.20,'2026-08-13 17:37:34'),(3,10,'2026-07',14838.71,0.00,0.00,0.00,0.00,14838.71,1780.65,111.29,12946.77,'2026-08-13 17:37:34'),(4,11,'2026-07',26612.90,0.00,0.00,0.00,0.00,26612.90,3193.55,199.60,23219.75,'2026-08-13 17:37:34'),(5,12,'2026-07',11854.84,0.00,0.00,0.00,0.00,11854.84,1422.58,88.91,10343.35,'2026-08-13 17:37:34'),(6,13,'2026-07',14096.77,0.00,0.00,0.00,0.00,14096.77,1691.61,105.73,12299.43,'2026-08-13 17:37:34'),(7,14,'2026-07',16693.55,0.00,0.00,0.00,0.00,16693.55,2003.23,125.20,14565.12,'2026-08-13 17:37:34'),(8,15,'2026-07',25967.74,0.00,0.00,0.00,0.00,25967.74,3116.13,194.76,22656.85,'2026-08-13 17:37:34'),(10,9,'2026-08',16838.71,0.00,0.00,0.00,0.00,16838.71,2020.65,126.29,14691.77,'2026-08-13 17:40:23'),(11,10,'2026-08',10967.74,0.00,0.00,0.00,0.00,10967.74,1316.13,82.26,9569.35,'2026-08-13 17:40:23'),(12,11,'2026-08',18145.16,0.00,0.00,0.00,0.00,18145.16,2177.42,136.09,15831.65,'2026-08-13 17:40:23'),(13,12,'2026-08',7903.23,0.00,0.00,0.00,0.00,7903.23,948.39,59.27,6895.57,'2026-08-13 17:40:23'),(14,13,'2026-08',8580.65,0.00,0.00,0.00,0.00,8580.65,1029.68,64.35,7486.62,'2026-08-13 17:40:23'),(15,14,'2026-08',10887.10,0.00,0.00,0.00,0.00,10887.10,1306.45,81.65,9499.00,'2026-08-13 17:40:23'),(16,15,'2026-08',16935.48,0.00,0.00,0.00,0.00,16935.48,2032.26,127.02,14776.20,'2026-08-13 17:40:23'),(17,8,'2026-08',16774.19,0.00,0.00,0.00,0.00,16774.19,2012.90,125.81,14635.48,'2026-08-14 13:14:25'),(18,19,'2026-08',11827.84,0.00,0.00,0.00,0.00,11827.84,1419.34,88.71,10319.79,'2026-08-21 08:42:18'),(19,20,'2026-08',16129.03,0.00,0.00,0.00,0.00,16129.03,1935.48,120.97,14072.58,'2026-09-01 02:23:48'),(20,21,'2026-08',14516.13,0.00,0.00,0.00,0.00,14516.13,1741.94,108.87,12665.32,'2026-09-01 02:23:48'),(21,24,'2026-08',11288.97,0.00,0.00,0.00,0.00,11288.97,1354.68,84.67,9849.62,'2026-09-01 02:23:48'),(22,25,'2026-08',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'2026-09-01 02:23:48'),(24,9,'2026-09',58000.00,0.00,0.00,0.00,0.00,58000.00,6960.00,435.00,50605.00,'2026-09-08 04:58:56'),(25,10,'2026-09',40000.00,0.00,0.00,0.00,0.00,40000.00,4800.00,300.00,34900.00,'2026-09-08 04:58:56'),(26,11,'2026-09',75000.00,0.00,0.00,0.00,0.00,75000.00,9000.00,562.50,65437.50,'2026-09-08 04:58:56'),(27,12,'2026-09',35000.00,0.00,0.00,0.00,0.00,35000.00,4200.00,262.50,30537.50,'2026-09-08 04:58:56'),(28,13,'2026-09',38000.00,0.00,0.00,0.00,0.00,38000.00,4560.00,285.00,33155.00,'2026-09-08 04:58:56'),(29,14,'2026-09',45000.00,0.00,0.00,0.00,0.00,45000.00,5400.00,337.50,39262.50,'2026-09-08 04:58:56'),(30,15,'2026-09',70000.00,0.00,0.00,0.00,0.00,70000.00,8400.00,525.00,61075.00,'2026-09-08 04:58:56'),(31,19,'2026-09',33333.00,0.00,0.00,0.00,0.00,33333.00,3999.96,250.00,29083.04,'2026-09-08 04:58:56'),(33,21,'2026-09',50000.00,0.00,0.00,0.00,0.00,50000.00,6000.00,375.00,43625.00,'2026-09-08 04:58:56'),(34,24,'2026-09',49994.00,0.00,0.00,0.00,0.00,49994.00,5999.28,374.96,43619.76,'2026-09-08 04:58:56'),(35,25,'2026-09',50000.00,0.00,0.00,0.00,0.00,50000.00,6000.00,375.00,43625.00,'2026-09-08 04:58:56'),(36,26,'2026-09',50000.00,0.00,0.00,0.00,0.00,50000.00,6000.00,375.00,43625.00,'2026-09-08 04:58:56'),(37,27,'2026-09',1666.37,0.00,0.00,0.00,0.00,1666.37,199.96,12.50,1453.91,'2026-09-08 04:58:56'),(38,28,'2026-09',40000.00,0.00,0.00,0.00,0.00,40000.00,4800.00,300.00,34900.00,'2026-09-08 04:58:56'),(39,29,'2026-09',1000.00,0.00,0.00,0.00,0.00,1000.00,120.00,7.50,872.50,'2026-09-08 04:58:56');
/*!40000 ALTER TABLE `admin_payroll` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_services`
--

DROP TABLE IF EXISTS `admin_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plan_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pricing_type` enum('CTC_PERCENT','DAYS_SALARY','FIXED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pricing_value` decimal(10,2) NOT NULL,
  `mrp` decimal(10,2) DEFAULT '0.00',
  `replacement_months` int DEFAULT '0',
  `token_amount` decimal(10,2) DEFAULT '0.00',
  `payment_terms` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_services`
--

LOCK TABLES `admin_services` WRITE;
/*!40000 ALTER TABLE `admin_services` DISABLE KEYS */;
INSERT INTO `admin_services` VALUES (1,'IT','A','DAYS_SALARY',5.00,100.00,2,5645.00,'6','Plan',1,'2026-08-16 16:53:36','2026-08-16 16:53:36'),(2,'IT','A','DAYS_SALARY',1000.00,2000.00,2,20.00,'7','no',1,'2026-08-25 14:52:52','2026-08-25 14:52:52'),(3,'HRMS','A','CTC_PERCENT',50000.00,599.00,2,10.00,'7','No',1,'2026-09-07 14:14:30','2026-09-07 14:14:30'),(4,'Sales','B','CTC_PERCENT',200000.00,0.00,3,5000.00,'7 days','',1,'2026-09-08 04:35:30','2026-09-08 04:35:30');
/*!40000 ALTER TABLE `admin_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agreement_templates`
--

DROP TABLE IF EXISTS `agreement_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agreement_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_file` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agreement_templates`
--

LOCK TABLES `agreement_templates` WRITE;
/*!40000 ALTER TABLE `agreement_templates` DISABLE KEYS */;
INSERT INTO `agreement_templates` VALUES (1,'Master Service Agreement — Acme Industries Pvt. Ltd','/api/uploads/agreement-templates/1788843199401-244590485.pdf','2026-09-08 04:53:19');
/*!40000 ALTER TABLE `agreement_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_interviews`
--

DROP TABLE IF EXISTS `ai_interviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_interviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `candidate_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `questions` json DEFAULT NULL,
  `answers` json DEFAULT NULL,
  `evaluation` json DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `status` enum('Pending','InProgress','Completed','Evaluated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_interviews`
--

LOCK TABLES `ai_interviews` WRITE;
/*!40000 ALTER TABLE `ai_interviews` DISABLE KEYS */;
INSERT INTO `ai_interviews` VALUES (1,'c0dea5a3905dc4ce155181a6df192e413c464c22','Test Candidate','tc@test.dev','Frontend Developer','[\"What attracted you to this Frontend Developer position?\", \"Describe your hands-on experience most relevant to a Frontend Developer role.\", \"Walk me through your most challenging project and your specific contribution.\", \"How do you prioritize tasks when everything feels urgent?\", \"Describe a time you disagreed with a teammate. How was it resolved?\"]','[\"For example, in my last project I specifically built and designed a React dashboard which improved load time by 40%. I led the migration and the result was a much better developer experience overall. Answer 1.\", \"For example, in my last project I specifically built and designed a React dashboard which improved load time by 40%. I led the migration and the result was a much better developer experience overall. Answer 2.\", \"For example, in my last project I specifically built and designed a React dashboard which improved load time by 40%. I led the migration and the result was a much better developer experience overall. Answer 3.\", \"For example, in my last project I specifically built and designed a React dashboard which improved load time by 40%. I led the migration and the result was a much better developer experience overall. Answer 4.\", \"For example, in my last project I specifically built and designed a React dashboard which improved load time by 40%. I led the migration and the result was a much better developer experience overall. Answer 5.\"]','{\"mode\": \"heuristic\", \"overall\": 9, \"summary\": \"Automated heuristic evaluation (AI model offline). Review answers manually for a final decision.\", \"per_question\": [{\"score\": 9, \"feedback\": \"Scored on depth, length, and concrete examples (heuristic mode).\", \"question\": \"What attracted you to this Frontend Developer position?\"}, {\"score\": 9, \"feedback\": \"Scored on depth, length, and concrete examples (heuristic mode).\", \"question\": \"Describe your hands-on experience most relevant to a Frontend Developer role.\"}, {\"score\": 9, \"feedback\": \"Scored on depth, length, and concrete examples (heuristic mode).\", \"question\": \"Walk me through your most challenging project and your specific contribution.\"}, {\"score\": 9, \"feedback\": \"Scored on depth, length, and concrete examples (heuristic mode).\", \"question\": \"How do you prioritize tasks when everything feels urgent?\"}, {\"score\": 9, \"feedback\": \"Scored on depth, length, and concrete examples (heuristic mode).\", \"question\": \"Describe a time you disagreed with a teammate. How was it resolved?\"}]}',9.00,'Evaluated','2026-08-13 09:15:29','2026-08-13 09:15:29'),(2,'a74b2b98f661a7377408ea515bb8446b61427df0','Public Page Check',NULL,'HR Executive','[\"What attracted you to this HR Executive position?\", \"Describe your hands-on experience most relevant to a HR Executive role.\", \"Walk me through your most challenging project and your specific contribution.\", \"How do you prioritize tasks when everything feels urgent?\", \"Describe a time you disagreed with a teammate. How was it resolved?\"]',NULL,NULL,NULL,'Pending','2026-08-13 09:16:45',NULL),(3,'d9e6fe308ddb018afb492bb799ed2918ddb2b764','Ahaan','razexunnamed@gmail.com','MERN Stack','[\"What attracted you to this MERN Stack position?\", \"Describe your hands-on experience most relevant to a MERN Stack role.\", \"Walk me through your most challenging project and your specific contribution.\", \"How do you prioritize tasks when everything feels urgent?\", \"Describe a time you disagreed with a teammate. How was it resolved?\"]',NULL,NULL,NULL,'Pending','2026-08-14 13:12:38',NULL);
/*!40000 ALTER TABLE `ai_interviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_model_versions`
--

DROP TABLE IF EXISTS `ai_model_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_model_versions` (
  `id` varchar(64) NOT NULL,
  `version_tag` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `dataset_ref` varchar(100) NOT NULL,
  `dataset_version` varchar(50) NOT NULL,
  `dataset_checksum` varchar(64) NOT NULL,
  `scoring_config` json NOT NULL,
  `feature_config` json NOT NULL,
  `rule_config` json NOT NULL,
  `evaluation_metrics` json NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `version_tag` (`version_tag`),
  KEY `idx_aiv_tag` (`version_tag`),
  KEY `idx_aiv_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_model_versions`
--

LOCK TABLES `ai_model_versions` WRITE;
/*!40000 ALTER TABLE `ai_model_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_model_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `asset_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` decimal(10,2) DEFAULT '0.00',
  `purchase_date` date DEFAULT NULL,
  `status` enum('ACTIVE','SOLD','MAINTENANCE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` VALUES (1,6,'Test Laptop','Electronics',45000.00,'2026-08-24','ACTIVE','test asset','2026-08-24 06:30:42','2026-08-24 06:30:42'),(3,19,'office laptop','electronics',50000.00,'2026-09-08','ACTIVE','','2026-09-08 06:03:42','2026-09-08 06:03:42');
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_corrections`
--

DROP TABLE IF EXISTS `attendance_corrections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_corrections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `emp_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_in` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_out` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `state` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requested_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decided_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decided_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_att_cor_emp` (`emp_id`),
  KEY `idx_att_cor_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_corrections`
--

LOCK TABLES `attendance_corrections` WRITE;
/*!40000 ALTER TABLE `attendance_corrections` DISABLE KEYS */;
INSERT INTO `attendance_corrections` VALUES (1,'0032','product intern','2026-08-16','09:39','09:40','done almost','pending','2026-08-16 09:40:04',NULL,NULL),(2,'005','Aahan shah','2026-08-16','11:20','17:26','time off','pending','2026-08-16 11:20:39',NULL,NULL),(3,'Em-10003','Suhani','2026-09-14','22:34','22:34','cvfds','pending','2026-09-14 22:35:03',NULL,NULL);
/*!40000 ALTER TABLE `attendance_corrections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_employees`
--

DROP TABLE IF EXISTS `attendance_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `emp_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `encoding` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `face_engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registered_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `emp_id` (`emp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_employees`
--

LOCK TABLES `attendance_employees` WRITE;
/*!40000 ALTER TABLE `attendance_employees` DISABLE KEYS */;
INSERT INTO `attendance_employees` VALUES (5,'002','Abc',NULL,NULL,'2026-08-16 08:51'),(6,'005','Ahaan',NULL,NULL,'2026-08-16 11:22'),(11,'006','Smoke Test','[[0,0.08414709848078966,0.09092974268256818,0.014112000805986721,-0.07568024953079283,-0.09589242746631385,-0.027941549819892587,0.06569865987187891,0.09893582466233819,0.041211848524175664,-0.05440211108893698,-0.09999902065507035,-0.0536572918000435,0.042016703682664094,0.09906073556948704,0.06502878401571169,-0.028790331666506533,-0.09613974918795569,-0.07509872467716762,0.014987720966295234,0.09129452507276277,0.08366556385360562,-0.0008851309290403876,-0.08462204041751707,-0.09055783620066238,-0.013235175009777304,0.07625584504796029,0.09563759284045031,0.027090578830786905,-0.06636338842129676,-0.09880316240928619,-0.040403764532306506,0.05514266812416906,0.09999118601072672,0.05290826861200239,-0.0428182669496151,-0.09917788534431159,-0.06435381333569995,0.029636857870938532,0.09637953862840878,0.07451131604793489,-0.0158622668804709,-0.09165215479156338,-0.08317747426285983,0.0017701925105413577,0.08509035245341184,0.09017883476488092,0.0123573122745224,-0.07682546613236668,-0.0953752652759472,-0.026237485370392877,0.06702291758433747,0.09866275920404854,0.03959251501818342,-0.05587890488516163,-0.09997551733586199,-0.052155100208691185,0.0436164755247825,0.09928726480845372,0.06367380071391379,-0.03048106211022167,-0.0966117770008393,-0.0739180696649223,0.016735570030280693,0.09200260381967906,0.08268286794901035,-0.0026551154023966798,-0.08555199789753223,-0.08979276806892914,-0.011478481378318722,0.07738906815578891,0.09510546532543747,0.025382336276203628,-0.06767719568873076,-0.09851462604682475,-0.038778163540943045,0.05661076368981804,0.09995201585807313,0.051397845598753523,-0.04441126687075084,-0.09938886539233753,-0.06298879942744538,0.03132287824330852,0.09683644611001854,0.07331903200732923,-0.01760756199485871,-0.09234584470040598,-0.08218178366308226,0.0035398302733660684,0.08600694058124532,0.0893996663600558,0.010598751175115686,-0.07794660696158047,-0.09482821412699473,-0.024525198546765437,0.0683261714736121,0.0983587745434345,0.037960773902752175,-0.057338187199042295,-0.09992068341863537,-0.05063656411097588,0.04520257871783506,0.09948267913584063,0.062298863144234884,-0.032162240316253095,-0.09705352835374847,-0.07271425000808526,0.018478174456066747,0.09268185054177851,0.0816742606636317,-0.004424267808507096,-0.08645514486106083,-0.08899956043668333,-0.009718190589320903,0.07849803886813106,0.09454353340247704,0.023666139336428606,-0.06896979409353891,-0.09819521690440836,-0.037140410143809026,0.058061118421231434,0.09988152247235796,0.04987131538963941,-0.04599034906895913,-0.09956869868891795,-0.061604045918865646,0.032999082567378206,0.0972630067242408],[0,0.08414709848078966,0.09092974268256818,0.014112000805986721,-0.07568024953079283,-0.09589242746631385,-0.027941549819892587,0.06569865987187891,0.09893582466233819,0.041211848524175664,-0.05440211108893698,-0.09999902065507035,-0.0536572918000435,0.042016703682664094,0.09906073556948704,0.06502878401571169,-0.028790331666506533,-0.09613974918795569,-0.07509872467716762,0.014987720966295234,0.09129452507276277,0.08366556385360562,-0.0008851309290403876,-0.08462204041751707,-0.09055783620066238,-0.013235175009777304,0.07625584504796029,0.09563759284045031,0.027090578830786905,-0.06636338842129676,-0.09880316240928619,-0.040403764532306506,0.05514266812416906,0.09999118601072672,0.05290826861200239,-0.0428182669496151,-0.09917788534431159,-0.06435381333569995,0.029636857870938532,0.09637953862840878,0.07451131604793489,-0.0158622668804709,-0.09165215479156338,-0.08317747426285983,0.0017701925105413577,0.08509035245341184,0.09017883476488092,0.0123573122745224,-0.07682546613236668,-0.0953752652759472,-0.026237485370392877,0.06702291758433747,0.09866275920404854,0.03959251501818342,-0.05587890488516163,-0.09997551733586199,-0.052155100208691185,0.0436164755247825,0.09928726480845372,0.06367380071391379,-0.03048106211022167,-0.0966117770008393,-0.0739180696649223,0.016735570030280693,0.09200260381967906,0.08268286794901035,-0.0026551154023966798,-0.08555199789753223,-0.08979276806892914,-0.011478481378318722,0.07738906815578891,0.09510546532543747,0.025382336276203628,-0.06767719568873076,-0.09851462604682475,-0.038778163540943045,0.05661076368981804,0.09995201585807313,0.051397845598753523,-0.04441126687075084,-0.09938886539233753,-0.06298879942744538,0.03132287824330852,0.09683644611001854,0.07331903200732923,-0.01760756199485871,-0.09234584470040598,-0.08218178366308226,0.0035398302733660684,0.08600694058124532,0.0893996663600558,0.010598751175115686,-0.07794660696158047,-0.09482821412699473,-0.024525198546765437,0.0683261714736121,0.0983587745434345,0.037960773902752175,-0.057338187199042295,-0.09992068341863537,-0.05063656411097588,0.04520257871783506,0.09948267913584063,0.062298863144234884,-0.032162240316253095,-0.09705352835374847,-0.07271425000808526,0.018478174456066747,0.09268185054177851,0.0816742606636317,-0.004424267808507096,-0.08645514486106083,-0.08899956043668333,-0.009718190589320903,0.07849803886813106,0.09454353340247704,0.023666139336428606,-0.06896979409353891,-0.09819521690440836,-0.037140410143809026,0.058061118421231434,0.09988152247235796,0.04987131538963941,-0.04599034906895913,-0.09956869868891795,-0.061604045918865646,0.032999082567378206,0.0972630067242408],[0,0.08414709848078966,0.09092974268256818,0.014112000805986721,-0.07568024953079283,-0.09589242746631385,-0.027941549819892587,0.06569865987187891,0.09893582466233819,0.041211848524175664,-0.05440211108893698,-0.09999902065507035,-0.0536572918000435,0.042016703682664094,0.09906073556948704,0.06502878401571169,-0.028790331666506533,-0.09613974918795569,-0.07509872467716762,0.014987720966295234,0.09129452507276277,0.08366556385360562,-0.0008851309290403876,-0.08462204041751707,-0.09055783620066238,-0.013235175009777304,0.07625584504796029,0.09563759284045031,0.027090578830786905,-0.06636338842129676,-0.09880316240928619,-0.040403764532306506,0.05514266812416906,0.09999118601072672,0.05290826861200239,-0.0428182669496151,-0.09917788534431159,-0.06435381333569995,0.029636857870938532,0.09637953862840878,0.07451131604793489,-0.0158622668804709,-0.09165215479156338,-0.08317747426285983,0.0017701925105413577,0.08509035245341184,0.09017883476488092,0.0123573122745224,-0.07682546613236668,-0.0953752652759472,-0.026237485370392877,0.06702291758433747,0.09866275920404854,0.03959251501818342,-0.05587890488516163,-0.09997551733586199,-0.052155100208691185,0.0436164755247825,0.09928726480845372,0.06367380071391379,-0.03048106211022167,-0.0966117770008393,-0.0739180696649223,0.016735570030280693,0.09200260381967906,0.08268286794901035,-0.0026551154023966798,-0.08555199789753223,-0.08979276806892914,-0.011478481378318722,0.07738906815578891,0.09510546532543747,0.025382336276203628,-0.06767719568873076,-0.09851462604682475,-0.038778163540943045,0.05661076368981804,0.09995201585807313,0.051397845598753523,-0.04441126687075084,-0.09938886539233753,-0.06298879942744538,0.03132287824330852,0.09683644611001854,0.07331903200732923,-0.01760756199485871,-0.09234584470040598,-0.08218178366308226,0.0035398302733660684,0.08600694058124532,0.0893996663600558,0.010598751175115686,-0.07794660696158047,-0.09482821412699473,-0.024525198546765437,0.0683261714736121,0.0983587745434345,0.037960773902752175,-0.057338187199042295,-0.09992068341863537,-0.05063656411097588,0.04520257871783506,0.09948267913584063,0.062298863144234884,-0.032162240316253095,-0.09705352835374847,-0.07271425000808526,0.018478174456066747,0.09268185054177851,0.0816742606636317,-0.004424267808507096,-0.08645514486106083,-0.08899956043668333,-0.009718190589320903,0.07849803886813106,0.09454353340247704,0.023666139336428606,-0.06896979409353891,-0.09819521690440836,-0.037140410143809026,0.058061118421231434,0.09988152247235796,0.04987131538963941,-0.04599034906895913,-0.09956869868891795,-0.061604045918865646,0.032999082567378206,0.0972630067242408]]','face-api','2026-09-14 19:41');
/*!40000 ALTER TABLE `attendance_employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_records`
--

DROP TABLE IF EXISTS `attendance_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `emp_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_out` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hours` double DEFAULT NULL,
  `overtime` double DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL,
  `hrms_sync` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hrms_sync_error` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hrms_sync_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corrected` tinyint(1) DEFAULT NULL,
  `corrected_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corrected_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correction_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `original` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_at` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_att_rec_emp_date` (`emp_id`,`date`),
  KEY `idx_att_rec_date` (`date`),
  KEY `idx_att_rec_approval` (`approval`),
  KEY `idx_att_rec_sync` (`hrms_sync`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_records`
--

LOCK TABLES `attendance_records` WRITE;
/*!40000 ALTER TABLE `attendance_records` DISABLE KEYS */;
INSERT INTO `attendance_records` VALUES (1,'0032','product intern','2026-08-16','08:49:40','Half Day','WiFi','127.0.0.1',NULL,'09:39:09',0.82,0,NULL,NULL,'synced','HTTP Error 404: Not Found','2026-08-20 08:51:04',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'002','Abc','2026-08-16','10:17:57','Late','Face','127.0.0.1','pending',NULL,0,0,NULL,NULL,'synced','HTTP Error 404: Not Found','2026-08-20 08:51:04',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'005','Aahan shah','2026-08-16','11:19:57','Half Day','WiFi','127.0.0.1','pending','11:20:02',0,0,NULL,NULL,'synced','HTTP Error 404: Not Found','2026-08-20 08:51:04',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(7,'002','Abc','2026-08-20','08:34:34','Present','Face','127.0.0.1','pending',NULL,0,0,NULL,NULL,'synced',NULL,'2026-08-20 08:34:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(8,'005','Ahaan','2026-08-20','08:34:54','Present','Face','127.0.0.1','pending',NULL,0,0,NULL,NULL,'synced',NULL,'2026-08-20 08:34:54',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(24,'Em-10003','Suhani','2026-09-14','22:32:16','Half Day','WiFi','::1','pending','22:34:38',0.04,0,NULL,NULL,'synced',NULL,'2026-09-14 22:34:38',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(25,'Em-10003','Suhani','2026-09-15','18:31:47','Late','WiFi','::1','pending',NULL,0,0,NULL,NULL,'synced',NULL,'2026-09-15 18:31:47',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `attendance_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_settings`
--

DROP TABLE IF EXISTS `attendance_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_settings` (
  `skey` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`skey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_settings`
--

LOCK TABLES `attendance_settings` WRITE;
/*!40000 ALTER TABLE `attendance_settings` DISABLE KEYS */;
INSERT INTO `attendance_settings` VALUES ('office','{\"lat\": 26.563677, \"lng\": 86.889893, \"radius\": 32.0, \"updated\": \"2026-08-16 11:22\"}'),('otp_Em-10003','{\"otp\":\"329776\",\"expires\":1788973553.251,\"sent_at\":1788973253.251,\"attempts\":0,\"mobile\":\"4547886999\",\"email\":\"advay708@gmail.com\"}');
/*!40000 ALTER TABLE `attendance_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_users`
--

DROP TABLE IF EXISTS `attendance_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emp_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mobile` (`mobile`),
  KEY `idx_att_users_role` (`role`),
  KEY `idx_att_users_emp` (`emp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_users`
--

LOCK TABLES `attendance_users` WRITE;
/*!40000 ALTER TABLE `attendance_users` DISABLE KEYS */;
INSERT INTO `attendance_users` VALUES (1,'Admin','9999999999','$2b$10$p.MiQ8TzXisZZk.gApBZX.guulfp6lAbz.qHpFqIBtlQ.OYfTq.5S','admin',NULL,'2026-08-16 07:24'),(6,'Hy','9988776644','$2b$10$7XUU1w8xeq1VLeIpgyjIZ.ZqiDUhWuCfoyUOShUubdsH/zhRqM0H6','employee','006','2026-08-20 08:29'),(7,'Abc','9992785593','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','employee','001','2026-08-16 08:25'),(8,'product intern','9992785583','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','employee','0032','2026-08-16 08:29'),(9,'Aahan shah','9807754603','8776f108e247ab1e2b323042c049c266407c81fbad41bde1e8dfc1bb66fd267e','employee','005','2026-08-16 11:11'),(10,'Phabindra Kumar Sah','9819754450','$2b$12$dr91Ru1luMJClFMgx8fljuaTAw3B5zBX0qxCkC8idVCcBfIxwxYZO','employee','002','2026-08-18 19:16'),(11,'Aaditya Chaudhary','9819754451','$2b$12$yDPUnPXxPLA43YhwEueSG..Uens2u3nx/CYqnVKTIJkDsnMjJBjIC','employee','9819','2026-09-01 21:44'),(12,'Suhani','9588382137','$2b$10$dOs5yd5OC3ruvkomiU3iNOR1BSprECxJKQBSBluv/kCXz234CJ76W','employee','Em-10003','2026-09-08 01:39');
/*!40000 ALTER TABLE `attendance_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` json DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,2,'Phabindra','ADD_PURCHASE_ORDER','\"Created order for \\\"Ahaan\\\" (₹0)\"','2026-08-22 20:05:57'),(2,2,'Phabindra','DELETE_PURCHASE_ORDER','\"Deleted purchase order\"','2026-08-22 20:06:04'),(4,6,'Test Company','ADD_ASSET','\"Added asset \\\"Test Laptop\\\" (₹45000)\"','2026-08-24 06:30:42'),(9,10,'Test','ADD_INVENTORY','\"Added item \\\"mouse\\\" (Qty: 269, Price: ₹6756)\"','2026-08-25 14:22:55'),(10,19,'Aryan','ADD_INVENTORY','\"Added item \\\"Speaker\\\" (Qty: 20, Price: ₹1500)\"','2026-09-08 06:03:11'),(11,19,'Aryan','ADD_ASSET','\"Added asset \\\"office laptop\\\" (₹50000)\"','2026-09-08 06:03:42'),(12,19,'Aryan','ADD_PURCHASE_ORDER','\"Created order for \\\"rekha\\\" (₹1500)\"','2026-09-08 06:04:19'),(13,19,'Aryan','ADD_PURCHASE_ORDER','\"Created order for \\\"ddd\\\" (₹2000)\"','2026-09-09 13:32:11'),(14,19,'Aryan','ADD_PURCHASE_ORDER','\"Created order for \\\"as\\\" (₹2200)\"','2026-09-09 15:04:20');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `background_verification`
--

DROP TABLE IF EXISTS `background_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `background_verification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `previous_company` varchar(255) DEFAULT NULL,
  `hr_email` varchar(255) DEFAULT NULL,
  `feedback` varchar(500) DEFAULT NULL,
  `rehire_eligible` varchar(50) DEFAULT NULL,
  `criminal_record` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `ix_background_verification_id` (`id`),
  CONSTRAINT `background_verification_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `background_verification`
--

LOCK TABLES `background_verification` WRITE;
/*!40000 ALTER TABLE `background_verification` DISABLE KEYS */;
/*!40000 ALTER TABLE `background_verification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `background_verifications`
--

DROP TABLE IF EXISTS `background_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `background_verifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `previous_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hr_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `feedback` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rehire_eligible` enum('Yes','No','Unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Unknown',
  `criminal_record` enum('Clear','Found','Unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Unknown',
  `status` enum('Pending','Under Verification','Approved','Rejected','Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bv_emp` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `background_verifications`
--

LOCK TABLES `background_verifications` WRITE;
/*!40000 ALTER TABLE `background_verifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `background_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `birthday_notifications`
--

DROP TABLE IF EXISTS `birthday_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `birthday_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` int NOT NULL,
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `birthday_notifications`
--

LOCK TABLES `birthday_notifications` WRITE;
/*!40000 ALTER TABLE `birthday_notifications` DISABLE KEYS */;
INSERT INTO `birthday_notifications` VALUES (1,1,'SUPER_ADMIN',6,'? Happy Birthday Ram',0,'2026-08-24 16:48:21'),(2,1,'SUPER_ADMIN',7,'? Happy Birthday RAm',0,'2026-08-25 14:14:51'),(3,25,'hr',7,'? Happy Birthday RAm',1,'2026-08-25 14:17:45');
/*!40000 ALTER TABLE `birthday_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manager_employee_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'Noida branch','RCU-321','noida','Noida , India',29,1,'2026-09-08 04:43:26');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_policies`
--

DROP TABLE IF EXISTS `candidate_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_policies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('high','medium','low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_policies`
--

LOCK TABLES `candidate_policies` WRITE;
/*!40000 ALTER TABLE `candidate_policies` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_statuses`
--

DROP TABLE IF EXISTS `candidate_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_statuses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_statuses`
--

LOCK TABLES `candidate_statuses` WRITE;
/*!40000 ALTER TABLE `candidate_statuses` DISABLE KEYS */;
INSERT INTO `candidate_statuses` VALUES (1,'APPLIED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(2,'SHORTLISTED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(3,'INTERVIEW',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(4,'SELECTED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(5,'REJECTED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30');
/*!40000 ALTER TABLE `candidate_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidateId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jobTitle` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `statusId` int DEFAULT '1',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `isActive` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `candidateId` (`candidateId`),
  KEY `statusId` (`statusId`),
  CONSTRAINT `candidates_ibfk_1` FOREIGN KEY (`statusId`) REFERENCES `candidate_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,'DEMO-C01','Rahul Gupta','c01@demo.hrms','9100000001','Backend Developer',1,NULL,1,'2026-07-13 07:13:50','2026-08-13 07:13:50'),(2,'DEMO-C02','Meera Joshi','c02@demo.hrms','9100000002','Backend Developer',2,NULL,1,'2026-06-13 07:13:50','2026-08-13 07:13:50'),(3,'DEMO-C03','Arjun Rao','c03@demo.hrms','9100000003','Backend Developer',4,NULL,1,'2026-05-13 07:13:50','2026-08-13 07:13:50'),(4,'DEMO-C04','Kavya Menon','c04@demo.hrms','9100000004','Frontend Developer',3,NULL,1,'2026-07-13 07:13:50','2026-08-13 07:13:50'),(5,'DEMO-C05','Siddharth Roy','c05@demo.hrms','9100000005','Frontend Developer',5,NULL,1,'2026-04-13 07:13:50','2026-08-13 07:13:50'),(6,'DEMO-C06','Pooja Reddy','c06@demo.hrms','9100000006','Frontend Developer',4,NULL,1,'2026-03-13 07:13:50','2026-08-13 07:13:50'),(7,'DEMO-C07','Aditya Kulkarni','c07@demo.hrms','9100000007','Sales Executive',1,NULL,1,'2026-08-03 07:13:50','2026-08-13 07:13:50'),(8,'DEMO-C08','Nisha Agarwal','c08@demo.hrms','9100000008','Sales Executive',2,NULL,1,'2026-06-13 07:13:50','2026-08-13 07:13:50'),(9,'DEMO-C09','Manish Tiwari','c09@demo.hrms','9100000009','Sales Executive',5,NULL,1,'2026-02-13 07:13:50','2026-08-13 07:13:50'),(10,'DEMO-C10','Ritika Bose','c10@demo.hrms','9100000010','SEO Executive',3,NULL,1,'2026-07-24 07:13:50','2026-08-13 07:13:50'),(11,'DEMO-C11','Harsh Vardhan','c11@demo.hrms','9100000011','SEO Executive',1,NULL,1,'2026-01-13 07:13:50','2026-08-13 07:13:50'),(12,'DEMO-C12','Tanvi Shah','c12@demo.hrms','9100000012','HR Recruiter',4,NULL,1,'2025-12-13 07:13:50','2026-08-13 07:13:50'),(13,'DEMO-C13','Deepak Kumar','c13@demo.hrms','9100000013','HR Recruiter',2,NULL,1,'2026-07-29 07:13:50','2026-08-13 07:13:50'),(14,'DEMO-C14','Ishita Malhotra','c14@demo.hrms','9100000014','Social Media Manager',1,NULL,1,'2026-05-13 07:13:50','2026-08-13 07:13:50'),(15,'WEB-MSRAF1J0','Priya Website','priya@web.test','+911234567890','Frontend Developer',1,'From website form #1: Applying via careers page',1,'2026-08-13 09:00:00','2026-08-13 09:00:00'),(16,'WEB-MSSI1FQ8','Acme Supplies','vendor@acme.test',NULL,'General Application',1,'From website form #2: Vendor onboarding request',1,'2026-08-14 05:21:08','2026-08-14 05:21:08'),(17,'WEB-MST6CIR1','Priya Verma','priya.verma@example.com','9812345670','React Developer',1,'From website form #5: 3 years experience in React and Node.',1,'2026-08-14 16:41:36','2026-08-14 16:41:36'),(20,'ROBO999991','Store Test Candidate','storetest@example.com','9999999999','Senior Full Stack Developer',2,'Registered through AI Interview Portal',1,'2026-09-14 16:52:10','2026-09-14 16:52:10'),(21,'ROBO522013','Suhani','vizora3@gmail.com','4354657543','Senior Full Stack Developer',1,'Registered through AI Interview Portal',1,'2026-09-14 16:52:10','2026-09-14 16:52:10');
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cash_flow`
--

DROP TABLE IF EXISTS `cash_flow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cash_flow` (
  `id` int NOT NULL AUTO_INCREMENT,
  `backup` decimal(12,2) DEFAULT NULL,
  `monthly_expense` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_flow`
--

LOCK TABLES `cash_flow` WRITE;
/*!40000 ALTER TABLE `cash_flow` DISABLE KEYS */;
/*!40000 ALTER TABLE `cash_flow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cash_reserves`
--

DROP TABLE IF EXISTS `cash_reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cash_reserves` (
  `id` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(12,2) NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_reserves`
--

LOCK TABLES `cash_reserves` WRITE;
/*!40000 ALTER TABLE `cash_reserves` DISABLE KEYS */;
/*!40000 ALTER TABLE `cash_reserves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certifications`
--

DROP TABLE IF EXISTS `certifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `issuer` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `credential_id` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certifications`
--

LOCK TABLES `certifications` WRITE;
/*!40000 ALTER TABLE `certifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `certifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_conversations`
--

DROP TABLE IF EXISTS `chatbot_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_conversations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int DEFAULT NULL,
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_ai_response` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_conversations`
--

LOCK TABLES `chatbot_conversations` WRITE;
/*!40000 ALTER TABLE `chatbot_conversations` DISABLE KEYS */;
INSERT INTO `chatbot_conversations` VALUES (1,'HR',7,'sess_1786674740606_cg30wkv0s','how many employees are there?','I couldn\'t find specific data for your query.',1,'2026-08-14 02:32:20'),(2,'ADMIN',1,'sess_1786727175948_2o0bvyinb','candidate','I couldn\'t find specific data for your query.',1,'2026-08-14 17:06:15'),(3,'ADMIN',1,'sess_1786727182690_ufzweuo29','interview','I couldn\'t find specific data for your query.',1,'2026-08-14 17:06:22'),(4,'ADMIN',1,'sess_1786727186692_kl3jcql41','employee','I couldn\'t find specific data for your query.',1,'2026-08-14 17:06:26'),(5,'ADMIN',NULL,'admin-1786728116032-oycxom','Pending leave requests','There are 3 leave application(s) awaiting approval.\n\nAll applications by status:\n• Approved: 6\n• Pending: 3\n• Rejected: 1\n\nOldest pending:\n• Aarav Sharma — Sick Leave, 2.0 day(s) from 14/08/2026\n• Aarav Sharma — Casual Leave, 2.0 day(s) from 20/08/2026\n• Ananya Das — Unpaid Leave, 2.0 day(s) from 03/08/2026',1,'2026-08-14 17:22:12'),(6,'ADMIN',NULL,'admin-1786728183047-cea6rc','How many employees do we have?','We currently have 9 active employees.\n\nBy department:\n• IT: 3\n• HR: 2\n• Sales: 2\n• Marketing: 2',1,'2026-08-14 17:23:09'),(7,'ADMIN',NULL,'admin-1786728183047-cea6rc','Pending leave requests','There are 3 leave application(s) awaiting approval.\n\nAll applications by status:\n• Approved: 6\n• Pending: 3\n• Rejected: 1\n\nOldest pending:\n• Aarav Sharma — Sick Leave, 2.0 day(s) from 14/08/2026\n• Aarav Sharma — Casual Leave, 2.0 day(s) from 20/08/2026\n• Ananya Das — Unpaid Leave, 2.0 day(s) from 03/08/2026',1,'2026-08-14 17:23:12'),(8,'ADMIN',NULL,'admin-1786728183047-cea6rc','What is the leave policy?','Leave entitlement configured in the system:\n• Casual Leave: 12 days/year (paid)\n• Sick Leave: 8 days/year (paid)\n• Earned Leave: 15 days/year (paid)\n• Comp-Off: 0 days/year (paid)\n• Unpaid Leave: 0 days/year (unpaid)\n\nEmployees can apply from their portal; approvals show under Leave Management.',1,'2026-08-14 17:23:15'),(9,'ADMIN',NULL,'admin-1786728183047-cea6rc','hy','I couldn\'t find that in the HRMS data or the FAQ knowledge base, and I won\'t guess.\n\nI answer from your live HRMS data. Try asking:\n• \"How many employees do we have?\"\n• \"Pending leave requests\"\n• \"What is the leave policy?\"\n• \"Latest payroll run\"\n• \"Recruitment pipeline status\"\n• \"AI interview results\"\n• \"Resume screening summary\"\n• \"Open job positions\"\n• \"New web form submissions\"\n• \"Office working hours\"\n• \"Upcoming holidays\"',1,'2026-08-14 17:23:20'),(10,'ADMIN',NULL,'admin-1786728183047-cea6rc','New web form submissions','Web form inbox:\n• Converted: 3\n• New: 3\n• Read: 1\n\n3 new submission(s) need attention in Web Forms.',1,'2026-08-14 17:23:36'),(11,'ADMIN',NULL,'admin-1786898921239-m2ef54','How many employees do we have?','We currently have 12 active employees.\n\nBy department:\n• HR: 5\n• IT: 3\n• Sales: 2\n• Marketing: 2',1,'2026-08-16 16:49:03'),(12,'ADMIN',NULL,'admin-1786898921239-m2ef54','Pending leave requests','There are 3 leave application(s) awaiting approval.\n\nAll applications by status:\n• Approved: 6\n• Pending: 3\n• Rejected: 1\n\nOldest pending:\n• Aarav Sharma — Sick Leave, 2.0 day(s) from 14/08/2026\n• Aarav Sharma — Casual Leave, 2.0 day(s) from 20/08/2026\n• Ananya Das — Unpaid Leave, 2.0 day(s) from 03/08/2026',1,'2026-08-16 16:49:10'),(13,'ADMIN',NULL,'admin-1786898921239-m2ef54','Recruitment pipeline status','Recruitment pipeline: 17 active candidate(s).\n\nBy stage:\n• APPLIED: 7\n• SHORTLISTED: 3\n• SELECTED: 3\n• INTERVIEW: 2\n• REJECTED: 2',1,'2026-08-16 16:49:15'),(14,'ADMIN',NULL,'admin-1786898921239-m2ef54','AI interview results','AI interviews:\n• Evaluated: 1 (avg score 9.0/10)\n• Pending: 2\n\nTop scorer: Test Candidate — 9.0/10 (Frontend Developer)',1,'2026-08-16 16:49:21'),(15,'ADMIN',NULL,'admin-1787424967001-mxvmwz','How many employees do we have?','We currently have 14 active employees.\n\nBy department:\n• HR: 6\n• IT: 4\n• Sales: 2\n• Marketing: 2',1,'2026-08-22 18:56:17'),(16,'EMPLOYEE',28,'sess_1788848335994_w4xbjzbbb','hlo','I couldn\'t find specific data for your query.',1,'2026-09-08 06:18:55'),(17,'EMPLOYEE',29,'sess_1788972203654_9xfgi1qoz','what servce provided','I couldn\'t find specific data for your query.',1,'2026-09-09 16:43:35'),(18,'EMPLOYEE',29,'sess_1788972203654_9xfgi1qoz','which service you provide','I couldn\'t find specific data for your query.',1,'2026-09-09 16:43:49');
/*!40000 ALTER TABLE `chatbot_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_settings`
--

DROP TABLE IF EXISTS `chatbot_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_settings` (
  `id` int NOT NULL,
  `settings` json NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_settings`
--

LOCK TABLES `chatbot_settings` WRITE;
/*!40000 ALTER TABLE `chatbot_settings` DISABLE KEYS */;
INSERT INTO `chatbot_settings` VALUES (1,'{\"language\": \"en\", \"autoRespond\": true, \"humanHandoff\": true, \"responseTime\": 3, \"workingHours\": \"9 AM - 6 PM\", \"sentimentAnalysis\": true}','2026-08-21 05:33:44');
/*!40000 ALTER TABLE `chatbot_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_templates`
--

DROP TABLE IF EXISTS `chatbot_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `keyword` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intent` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tpl_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_templates`
--

LOCK TABLES `chatbot_templates` WRITE;
/*!40000 ALTER TABLE `chatbot_templates` DISABLE KEYS */;
INSERT INTO `chatbot_templates` VALUES (1,'client','pricing','Our pricing starts from $999/month for basic packages. Would you like me to share our detailed pricing brochure?','pricing_inquiry','2026-08-21 05:30:25','2026-08-21 05:30:25'),(2,'client','demo','I\'d be happy to schedule a demo for you! Our team will reach out within 24 hours to confirm a suitable time.','demo_request','2026-08-21 05:30:25','2026-08-21 05:30:25'),(3,'client','support','Our support team is available 24/7. You can reach us at support@company.com or call our helpline.','support_request','2026-08-21 05:30:25','2026-08-21 05:30:25'),(4,'candidate','jobs','We\'re currently hiring! Please check our careers page for open positions. Which role interests you?','job_inquiry','2026-08-21 05:30:25','2026-08-21 05:30:25'),(5,'candidate','interview','Your interview has been scheduled. You\'ll receive a confirmation email with all details within 24 hours.','interview_info','2026-08-21 05:30:25','2026-08-21 05:30:25'),(7,'sales','lead','New lead assigned! Check your CRM dashboard for full details. Remember to follow up within 24 hours.','lead_assigned','2026-08-21 05:30:25','2026-08-21 05:30:25'),(8,'sales','target','You\'re currently at 75% of your monthly target. Keep up the great work! Need help with any deals?','target_progress','2026-08-21 05:30:25','2026-08-21 05:30:25'),(9,'sales','commission','Your commission structure: 5% on deals up to $10K, 8% on $10K-$50K, 12% on $50K+. View detailed breakdown in your dashboard.','commission_info','2026-08-21 05:30:25','2026-08-21 05:30:25'),(11,'candidate','status','Your application is under review. We\'ll update you within 5-7 working days.','application_status','2026-08-21 05:34:15','2026-08-21 05:34:15');
/*!40000 ALTER TABLE `chatbot_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_agreements`
--

DROP TABLE IF EXISTS `client_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_agreements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `agreement_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `agreement_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agreement_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `agreement_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','expired','terminated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  CONSTRAINT `fk_agreement_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_agreements`
--

LOCK TABLES `client_agreements` WRITE;
/*!40000 ALTER TABLE `client_agreements` DISABLE KEYS */;
INSERT INTO `client_agreements` VALUES (1,NULL,'Master Service Agreement — Acme Industries Pvt. Ltd.','Master Service Agreement','ARDH/AGR/2026/514570','2026-09-01','2027-08-31','/api/uploads/generated/agreement_1786731514613.pdf','active',NULL,'2026-08-14 18:18:34','2026-08-14 18:18:34'),(2,NULL,'Master Service Agreement — Acme Industries Pvt. Ltd.','Master Service Agreement','ARDH/AGR/2026/649372','2026-09-01','2027-08-31','/api/uploads/generated/agreement_1786731649416.pdf','active',NULL,'2026-08-14 18:20:49','2026-08-14 18:20:49');
/*!40000 ALTER TABLE `client_agreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_assignment_deliverables`
--

DROP TABLE IF EXISTS `client_assignment_deliverables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_assignment_deliverables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `assignment_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `type` varchar(40) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` bigint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `idx_employee` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_assignment_deliverables`
--

LOCK TABLES `client_assignment_deliverables` WRITE;
/*!40000 ALTER TABLE `client_assignment_deliverables` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_assignment_deliverables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_attendance`
--

DROP TABLE IF EXISTS `client_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `attendance_date` date NOT NULL,
  `check_in` datetime DEFAULT NULL,
  `check_out` datetime DEFAULT NULL,
  `status` enum('PRESENT','ABSENT','HALF_DAY','LEAVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PRESENT',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_emp_day` (`client_id`,`employee_id`,`attendance_date`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `client_attendance_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_attendance_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `client_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_attendance`
--

LOCK TABLES `client_attendance` WRITE;
/*!40000 ALTER TABLE `client_attendance` DISABLE KEYS */;
INSERT INTO `client_attendance` VALUES (9,16,12,'2026-09-07','2026-09-07 09:00:00','2026-09-07 18:00:00','PRESENT','Present','2026-09-07 14:15:35','2026-09-07 14:43:24'),(10,19,13,'2026-09-07','2026-09-07 08:12:00','2026-09-07 18:13:00','PRESENT','P','2026-09-07 14:28:20','2026-09-07 14:28:20'),(20,19,14,'2026-09-09','2026-09-09 14:55:00','2026-09-09 18:55:00','PRESENT','P','2026-09-09 09:26:04','2026-09-09 09:26:04'),(21,19,15,'2026-09-09','2026-09-09 20:23:00','2026-09-09 02:29:00','PRESENT','P','2026-09-09 14:53:45','2026-09-09 14:53:45');
/*!40000 ALTER TABLE `client_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_employee_conversations`
--

DROP TABLE IF EXISTS `client_employee_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_employee_conversations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_client_employee_chat` (`client_id`,`employee_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `client_employee_conversations_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_employee_conversations_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `client_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_employee_conversations`
--

LOCK TABLES `client_employee_conversations` WRITE;
/*!40000 ALTER TABLE `client_employee_conversations` DISABLE KEYS */;
INSERT INTO `client_employee_conversations` VALUES (1,19,15,'2026-09-09 15:32:28');
/*!40000 ALTER TABLE `client_employee_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_employee_deleted`
--

DROP TABLE IF EXISTS `client_employee_deleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_employee_deleted` (
  `id` int NOT NULL AUTO_INCREMENT,
  `original_employee_id` int DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `employeeCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departmentId` int DEFAULT NULL,
  `designationId` int DEFAULT NULL,
  `statusId` int DEFAULT NULL,
  `joiningDate` date DEFAULT NULL,
  `salary` int DEFAULT NULL,
  `isActive` tinyint DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_employee_deleted`
--

LOCK TABLES `client_employee_deleted` WRITE;
/*!40000 ALTER TABLE `client_employee_deleted` DISABLE KEYS */;
INSERT INTO `client_employee_deleted` VALUES (3,9,10,'EMP-0001','Test','abcd@gmail.com','8889775566',3,9,1,'2026-08-25',50000,1,'2026-08-26 03:51:54');
/*!40000 ALTER TABLE `client_employee_deleted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_employee_messages`
--

DROP TABLE IF EXISTS `client_employee_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_employee_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `sender_type` enum('employee','client') NOT NULL,
  `sender_id` int NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `client_employee_messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `client_employee_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_employee_messages`
--

LOCK TABLES `client_employee_messages` WRITE;
/*!40000 ALTER TABLE `client_employee_messages` DISABLE KEYS */;
INSERT INTO `client_employee_messages` VALUES (1,1,'employee',15,'hi','2026-09-09 16:00:18'),(2,1,'client',19,'hi','2026-09-10 05:22:30');
/*!40000 ALTER TABLE `client_employee_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_employees`
--

DROP TABLE IF EXISTS `client_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employeeCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departmentId` int NOT NULL,
  `designationId` int NOT NULL,
  `statusId` int DEFAULT '1',
  `joiningDate` date NOT NULL,
  `salary` int DEFAULT '0',
  `isActive` tinyint DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_client_email` (`client_id`,`email`),
  UNIQUE KEY `unique_client_empcode` (`client_id`,`employeeCode`),
  KEY `departmentId` (`departmentId`),
  KEY `designationId` (`designationId`),
  KEY `statusId` (`statusId`),
  CONSTRAINT `client_employees_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_employees_ibfk_2` FOREIGN KEY (`departmentId`) REFERENCES `departments` (`id`),
  CONSTRAINT `client_employees_ibfk_3` FOREIGN KEY (`designationId`) REFERENCES `designations` (`id`),
  CONSTRAINT `client_employees_ibfk_4` FOREIGN KEY (`statusId`) REFERENCES `employee_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_employees`
--

LOCK TABLES `client_employees` WRITE;
/*!40000 ALTER TABLE `client_employees` DISABLE KEYS */;
INSERT INTO `client_employees` VALUES (12,16,'EMP-0001','Arav','arav@gmail.com',NULL,'8796554455',2,4,1,'2026-09-07',40000,1,'2026-09-07 08:45:23','2026-09-07 08:45:23'),(13,19,'EMP-0001','ABC','phabindrakumar777@gmail.com',NULL,'0999278558',2,3,1,'2026-09-07',50000,1,'2026-09-07 14:27:37','2026-09-07 14:27:37'),(14,19,'EM-1007','SUHANU','advay708@gmail.com',NULL,'9057822921',3,5,1,'2026-09-10',20000,1,'2026-09-09 09:21:52','2026-09-09 09:21:52'),(15,19,'EM-1012','Advay','suhanimittal1975@gmail.com','$2b$10$KSf8ufOliypk.c4t4rjhIuP5BxAISPOML.VuQMl8EsWSqcFawIi6O','9069382292',3,5,1,'2026-09-09',20000,1,'2026-09-09 10:29:17','2026-09-09 10:29:17');
/*!40000 ALTER TABLE `client_employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_expenses`
--

DROP TABLE IF EXISTS `client_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_expenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `expense_date` date DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_expenses`
--

LOCK TABLES `client_expenses` WRITE;
/*!40000 ALTER TABLE `client_expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_features`
--

DROP TABLE IF EXISTS `client_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `feature_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_client_feature` (`client_id`,`feature_key`),
  CONSTRAINT `client_features_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=716 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_features`
--

LOCK TABLES `client_features` WRITE;
/*!40000 ALTER TABLE `client_features` DISABLE KEYS */;
INSERT INTO `client_features` VALUES (440,16,'ASSETS',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(441,16,'ATTENDANCE_TRACKER',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(442,16,'AUDIT_LOGS',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(443,16,'CANDIDATE_MANAGEMENT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(444,16,'COMPLAINT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(445,16,'EMPLOYEE_MANAGEMENT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(446,16,'FINANCE_DASHBOARD',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(447,16,'HR_CALLING',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(448,16,'INTERVIEW_TRACKER',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(449,16,'INVENTORY',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(450,16,'LEADS',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(451,16,'LIVE_CHAT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(452,16,'PAYROLL',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(453,16,'PERFORMANCE_REPORT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(454,16,'PERFORMANCE_TRACKER',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(455,16,'PURCHASE_ORDERS',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(456,16,'SALES_REPORT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(457,16,'TAX',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(458,16,'WORK_ASSIGNMENT',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(459,16,'WORK_POLICY',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(460,16,'WORK_TARGET',1,'2026-09-07 08:37:47','2026-09-07 08:37:47'),(537,19,'ASSETS',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(538,19,'ATTENDANCE_TRACKER',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(539,19,'AUDIT_LOGS',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(540,19,'CANDIDATE_MANAGEMENT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(541,19,'COMPLAINT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(542,19,'EMPLOYEE_MANAGEMENT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(543,19,'FINANCE_DASHBOARD',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(544,19,'HR_CALLING',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(545,19,'INTERVIEW_TRACKER',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(546,19,'INVENTORY',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(547,19,'LEADS',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(548,19,'LIVE_CHAT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(549,19,'PAYROLL',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(550,19,'PERFORMANCE_REPORT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(551,19,'PERFORMANCE_TRACKER',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(552,19,'PURCHASE_ORDERS',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(553,19,'SALES_REPORT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(554,19,'TAX',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(555,19,'WORK_ASSIGNMENT',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(556,19,'WORK_POLICY',1,'2026-09-07 13:50:21','2026-09-07 13:50:21'),(557,19,'WORK_TARGET',1,'2026-09-07 13:50:21','2026-09-07 13:50:21');
/*!40000 ALTER TABLE `client_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_hr_assignments`
--

DROP TABLE IF EXISTS `client_hr_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_hr_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `hr_employee_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_client_hr` (`client_id`,`hr_employee_id`),
  KEY `hr_employee_id` (`hr_employee_id`),
  CONSTRAINT `client_hr_assignments_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_hr_assignments_ibfk_2` FOREIGN KEY (`hr_employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_hr_assignments`
--

LOCK TABLES `client_hr_assignments` WRITE;
/*!40000 ALTER TABLE `client_hr_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_hr_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_interviews`
--

DROP TABLE IF EXISTS `client_interviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_interviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `candidate_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_profile` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_ctc` decimal(10,2) DEFAULT NULL,
  `expected_ctc` decimal(10,2) DEFAULT NULL,
  `notice_period` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hr_employee_id` int NOT NULL,
  `client_id` int NOT NULL,
  `call_status_id` int DEFAULT NULL,
  `interview_date` date DEFAULT NULL,
  `interview_time` time DEFAULT NULL,
  `selection_date` date DEFAULT NULL,
  `joining_date` date DEFAULT NULL,
  `client_status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `client_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hr_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `joined` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `language_id` int DEFAULT NULL,
  `cv_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  KEY `idx_hr` (`hr_employee_id`),
  KEY `idx_call_status` (`call_status_id`),
  KEY `idx_language` (`language_id`),
  CONSTRAINT `client_interviews_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_interviews_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_interviews`
--

LOCK TABLES `client_interviews` WRITE;
/*!40000 ALTER TABLE `client_interviews` DISABLE KEYS */;
INSERT INTO `client_interviews` VALUES (9,'Kumar','9876543211','Noida','Business Development Executive','Fresher',400000.00,500000.00,'15',28,19,7,'2026-09-07','19:50:00','2026-09-07','2026-09-07','pending',NULL,'Nothing','Noida','Yes',1,'/uploads/cv/1788789652298-270375816.pdf','2026-09-07 14:00:52','2026-09-07 14:14:41'),(10,'suhani','9588382137','Delhi','Full stack developer','2',200000.00,26000.00,'15',28,19,1,'2026-09-08','12:15:00',NULL,NULL,'pending',NULL,NULL,'nodia','No',2,'/uploads/cv/1788849970864-20913699.pdf','2026-09-08 06:46:10','2026-09-08 06:46:10'),(11,'suhani','9588382137','Haryana','Full stack developer','2',200000.00,260000.00,'15',28,19,6,'2026-09-09','15:10:00',NULL,NULL,'pending',NULL,'eeweweww ','adsd ','No',1,'/uploads/cv/1788946863193-888489002.pdf','2026-09-09 09:41:03','2026-09-09 09:41:03'),(12,'sanvi','9588382137','Haryana','Frontend Developer','2',200000.00,260000.00,'15',28,19,6,'2026-09-10','11:48:00',NULL,NULL,'pending',NULL,NULL,'saasadad','No',2,'/uploads/cv/1789017550540-73010964.pdf','2026-09-10 05:19:10','2026-09-10 05:19:10');
/*!40000 ALTER TABLE `client_interviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_invoice_items`
--

DROP TABLE IF EXISTS `client_invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_invoice_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` int DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hsn_sac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gst_rate` decimal(5,2) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `rate` decimal(10,2) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `client_invoice_items_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `client_invoices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_invoice_items`
--

LOCK TABLES `client_invoice_items` WRITE;
/*!40000 ALTER TABLE `client_invoice_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_invoices`
--

DROP TABLE IF EXISTS `client_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `invoice_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `client_gstin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `taxable_amount` decimal(10,2) DEFAULT NULL,
  `cgst` decimal(10,2) DEFAULT NULL,
  `sgst` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `amount_in_words` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  KEY `idx_client` (`client_id`),
  KEY `idx_employee` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_invoices`
--

LOCK TABLES `client_invoices` WRITE;
/*!40000 ALTER TABLE `client_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_lead_batches`
--

DROP TABLE IF EXISTS `client_lead_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_lead_batches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_records` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `client_lead_batches_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_lead_batches_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `client_employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_lead_batches`
--

LOCK TABLES `client_lead_batches` WRITE;
/*!40000 ALTER TABLE `client_lead_batches` DISABLE KEYS */;
INSERT INTO `client_lead_batches` VALUES (6,19,'sample_leads.xlsx',5,15,NULL,'2026-09-09 16:26:33');
/*!40000 ALTER TABLE `client_lead_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_leads`
--

DROP TABLE IF EXISTS `client_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_leads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `batch_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `assigned_date` datetime DEFAULT NULL,
  `status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `response_date` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `batch_id` (`batch_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `client_leads_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_leads_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `client_lead_batches` (`id`),
  CONSTRAINT `client_leads_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `client_employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_leads`
--

LOCK TABLES `client_leads` WRITE;
/*!40000 ALTER TABLE `client_leads` DISABLE KEYS */;
INSERT INTO `client_leads` VALUES (19,19,'Rahul Sharma','9876543210',6,15,'2026-09-09 21:56:33','pending',NULL,NULL,'2026-09-09 16:26:33','2026-09-09 16:26:33'),(20,19,'Priya Verma','9876543211',6,15,'2026-09-09 21:56:33','pending',NULL,NULL,'2026-09-09 16:26:33','2026-09-09 16:26:33'),(21,19,'Amit Kumar','9876543212',6,15,'2026-09-09 21:56:33','pending',NULL,NULL,'2026-09-09 16:26:33','2026-09-09 16:26:33'),(22,19,'Neha Singh','9876543213',6,15,'2026-09-09 21:56:33','pending',NULL,NULL,'2026-09-09 16:26:33','2026-09-09 16:26:33'),(23,19,'Vikas Mehta','9876543214',6,15,'2026-09-09 21:56:33','pending',NULL,NULL,'2026-09-09 16:26:33','2026-09-09 16:26:33');
/*!40000 ALTER TABLE `client_leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_leave_applications`
--

DROP TABLE IF EXISTS `client_leave_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_leave_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `client_employee_id` int NOT NULL,
  `leave_type` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Casual',
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `days` decimal(5,1) NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('Pending','Approved','Rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `approver_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decided_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  KEY `idx_emp` (`client_employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_leave_applications`
--

LOCK TABLES `client_leave_applications` WRITE;
/*!40000 ALTER TABLE `client_leave_applications` DISABLE KEYS */;
INSERT INTO `client_leave_applications` VALUES (1,1,2,'Casual','2026-08-20','2026-08-21',2.0,'E2E test','Approved','ok','2026-08-14 05:48:20','2026-08-14 05:48:20'),(2,2,5,'Sick','2026-08-21','2026-08-21',1.0,'health is not good.','Approved',NULL,'2026-08-21 06:50:25','2026-08-21 06:31:33'),(4,9,8,'Casual','2026-08-25','2026-08-26',2.0,NULL,'Rejected',NULL,'2026-08-24 21:42:06','2026-08-24 21:37:29'),(5,10,9,'Casual','2026-08-25','2026-08-25',1.0,NULL,'Approved',NULL,'2026-08-25 14:06:00','2026-08-25 14:05:55'),(6,19,13,'Sick','2026-09-09','2026-09-10',2.0,'xcff c cc   df   v ','Approved',NULL,'2026-09-09 09:24:33','2026-09-08 05:55:01'),(7,19,13,'Casual','2026-09-08','2026-09-09',2.0,NULL,'Approved',NULL,'2026-09-09 09:24:32','2026-09-08 13:53:11'),(8,19,15,'Casual','2026-09-09','2026-09-10',2.0,NULL,'Approved',NULL,'2026-09-09 13:54:18','2026-09-09 13:31:12');
/*!40000 ALTER TABLE `client_leave_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_offer_letters`
--

DROP TABLE IF EXISTS `client_offer_letters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_offer_letters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `candidate_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `salary_monthly` int NOT NULL DEFAULT '0',
  `joining_date` date NOT NULL,
  `template` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'standard',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `client_employee_id` int DEFAULT NULL,
  `department` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `work_mode` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT 'WFO/WFH',
  `internship_duration` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `working_days` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '6 Days per Week',
  `office_timings` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '9:00 AM – 6:00 PM',
  `lunch_break` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '1:00 PM – 1:30 PM',
  `notice_period` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '1 Month',
  `responsibilities` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_offer_letters`
--

LOCK TABLES `client_offer_letters` WRITE;
/*!40000 ALTER TABLE `client_offer_letters` DISABLE KEYS */;
INSERT INTO `client_offer_letters` VALUES (1,1,'Test Candidate',NULL,'QA Engineer',45000,'2026-09-01','standard','2026-08-14 05:50:01',NULL,NULL,'WFO/WFH',NULL,'6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month',NULL),(2,2,'Phabindra Kumar Sah','ahaanshah680@gmail.com','Frontend',400000,'2026-08-21','senior','2026-08-21 06:51:15',NULL,NULL,'WFO/WFH',NULL,'6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month',NULL),(4,10,'Abc',NULL,'Fullstack',30000,'2026-08-25','intern','2026-08-25 14:06:20',NULL,NULL,'WFO/WFH',NULL,'6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month',NULL),(5,19,'suhani','advay708@gmail.com','sales',20000,'2026-09-08','standard','2026-09-08 05:56:21',NULL,NULL,'WFO/WFH',NULL,'6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month',NULL),(6,19,'SUHANU','advay708@gmail.com','Frontend',20000,'2026-09-09','standard','2026-09-09 09:25:05',NULL,NULL,'WFO/WFH',NULL,'6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month',NULL),(7,19,'Advay','suhanimittal1975@gmail.com','Frontend Developer',20000,'2026-09-09','standard','2026-09-09 14:54:53',15,'IT','Work From Office','90 days','6 Days per Week','9:00 AM – 6:00 PM','1:00 PM – 1:30 PM','1 Month','wfwwwwdcd');
/*!40000 ALTER TABLE `client_offer_letters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_onboardings`
--

DROP TABLE IF EXISTS `client_onboardings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_onboardings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `service` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stage` enum('Proposal Sent','Details Submitted','Agreement Generated','Agreement Signed','Onboarded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Proposal Sent',
  `proposal_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `agreement_terms` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_onboardings`
--

LOCK TABLES `client_onboardings` WRITE;
/*!40000 ALTER TABLE `client_onboardings` DISABLE KEYS */;
INSERT INTO `client_onboardings` VALUES (1,'Acme Corp','John Doe','john@acme.com',NULL,'IT Staffing','Proposal Sent','Initial proposal for 5 developers',NULL,NULL,'2026-08-13 07:36:52','2026-08-13 07:36:52'),(2,'suhani','Advay','advay708@gmail.com','9588382137','HR','Proposal Sent',NULL,NULL,NULL,'2026-09-08 04:48:11','2026-09-08 04:48:11');
/*!40000 ALTER TABLE `client_onboardings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_payroll`
--

DROP TABLE IF EXISTS `client_payroll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_payroll` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `payroll_month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `basic_salary` decimal(10,2) DEFAULT '0.00',
  `hra` decimal(10,2) DEFAULT '0.00',
  `ta` decimal(10,2) DEFAULT '0.00',
  `da` decimal(10,2) DEFAULT '0.00',
  `attendance_days` int DEFAULT '0',
  `overtime_amount` decimal(10,2) DEFAULT '0.00',
  `gross_salary` decimal(10,2) DEFAULT '0.00',
  `pf` decimal(10,2) DEFAULT '0.00',
  `esic` decimal(10,2) DEFAULT '0.00',
  `net_salary` decimal(10,2) DEFAULT '0.00',
  `status` enum('draft','final') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_payroll` (`client_id`,`employee_id`,`payroll_month`),
  KEY `idx_client` (`client_id`),
  KEY `idx_employee` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_payroll`
--

LOCK TABLES `client_payroll` WRITE;
/*!40000 ALTER TABLE `client_payroll` DISABLE KEYS */;
INSERT INTO `client_payroll` VALUES (3,10,9,'2026-08',50000.00,23.00,4.00,23.00,20,3.00,50053.00,5.00,7.00,50041.00,'draft','2026-08-25 14:19:39','2026-08-25 14:19:39'),(4,19,13,'2026-10',20000.00,2000.00,2000.00,1500.00,30,500.00,26000.00,2200.00,6000.00,17800.00,'draft','2026-09-08 05:59:03','2026-09-08 05:59:03'),(5,19,14,'2026-09',20000.00,2000.00,1500.00,1000.00,20,500.00,25000.00,5.00,0.00,24995.00,'draft','2026-09-09 09:26:59','2026-09-09 09:26:59'),(6,19,15,'2026-09',20000.00,2000.00,2000.00,1500.00,20,500.00,26000.00,2000.00,0.00,24000.00,'draft','2026-09-09 14:52:59','2026-09-09 14:52:59');
/*!40000 ALTER TABLE `client_payroll` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_policies`
--

DROP TABLE IF EXISTS `client_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_policies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('high','medium','low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_policies`
--

LOCK TABLES `client_policies` WRITE;
/*!40000 ALTER TABLE `client_policies` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_revenue`
--

DROP TABLE IF EXISTS `client_revenue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_revenue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `revenue_date` date DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_revenue`
--

LOCK TABLES `client_revenue` WRITE;
/*!40000 ALTER TABLE `client_revenue` DISABLE KEYS */;
INSERT INTO `client_revenue` VALUES (2,10,4,5676.00,'2026-08-25','easyt','2026-08-25 14:22:24'),(3,19,1,26000.00,'2026-09-08','ssdssf','2026-09-08 06:01:36');
/*!40000 ALTER TABLE `client_revenue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_sales_calls`
--

DROP TABLE IF EXISTS `client_sales_calls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_sales_calls` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `call_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `call_time` time DEFAULT NULL,
  `call_date` date DEFAULT NULL,
  `status` enum('hold','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'hold',
  `follow_up_datetime` datetime DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sold_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  KEY `idx_employee` (`employee_id`),
  KEY `idx_status` (`status`),
  KEY `idx_followup` (`follow_up_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_sales_calls`
--

LOCK TABLES `client_sales_calls` WRITE;
/*!40000 ALTER TABLE `client_sales_calls` DISABLE KEYS */;
INSERT INTO `client_sales_calls` VALUES (2,9,8,'CALL-000001','hsghs','7856486934','as@gmail.com','03:29:00','2026-08-25','hold','2026-08-25 03:25:00','rdtyuio','2026-08-25','2026-08-24 21:40:31','2026-08-24 21:40:31'),(3,10,9,'CALL-000001','Test','9992785583','abcde@gmail.com','10:05:00','2026-09-05','hold','2026-08-25 20:05:00','nothing ','2026-08-26','2026-08-25 14:20:40','2026-08-25 14:20:40'),(4,19,13,'CALL-000001','Advay','9588382137','advay708@gmail.com','11:29:00','2026-09-09','hold','2026-09-09 11:29:00',NULL,'2026-09-08','2026-09-08 05:59:42','2026-09-08 05:59:42');
/*!40000 ALTER TABLE `client_sales_calls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_sales_report`
--

DROP TABLE IF EXISTS `client_sales_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_sales_report` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `plan_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `billing_months` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `amount_paid` decimal(10,2) DEFAULT '0.00',
  `payment_status` enum('paid','partial','unpaid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'unpaid',
  `payment_method` enum('cash','online') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `purchase_date` date NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `due_date` date NOT NULL,
  `subscription_status` enum('active','expired','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  KEY `idx_employee` (`employee_id`),
  KEY `idx_status` (`payment_status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_sales_report`
--

LOCK TABLES `client_sales_report` WRITE;
/*!40000 ALTER TABLE `client_sales_report` DISABLE KEYS */;
INSERT INTO `client_sales_report` VALUES (1,19,15,'Basic',1,2000.00,200.00,'partial','cash','2026-09-09','2026-09-11','2026-10-11','2026-10-09','active',NULL,'2026-09-09 15:37:37','2026-09-09 15:37:37');
/*!40000 ALTER TABLE `client_sales_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_services`
--

DROP TABLE IF EXISTS `client_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `service_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plan_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mrp` decimal(10,2) DEFAULT '0.00',
  `pricing_type` enum('CTC_PERCENT','DAYS_SALARY','FIXED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pricing_value` decimal(10,2) NOT NULL,
  `replacement_months` int DEFAULT '0',
  `token_amount` decimal(10,2) DEFAULT '0.00',
  `payment_terms` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_services`
--

LOCK TABLES `client_services` WRITE;
/*!40000 ALTER TABLE `client_services` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_sop_acknowledgements`
--

DROP TABLE IF EXISTS `client_sop_acknowledgements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_sop_acknowledgements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `sop_id` int NOT NULL,
  `version` int NOT NULL,
  `employee_id` int NOT NULL,
  `status` enum('accepted','rejected') NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `decided_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_client_sop_emp_ver` (`client_id`,`sop_id`,`version`,`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_sop_acknowledgements`
--

LOCK TABLES `client_sop_acknowledgements` WRITE;
/*!40000 ALTER TABLE `client_sop_acknowledgements` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_sop_acknowledgements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_work_assignments`
--

DROP TABLE IF EXISTS `client_work_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_work_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_value` int DEFAULT '0',
  `current_value` int DEFAULT '0',
  `unit` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `status` enum('assigned','in_progress','completed','overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'assigned',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_work_assignments`
--

LOCK TABLES `client_work_assignments` WRITE;
/*!40000 ALTER TABLE `client_work_assignments` DISABLE KEYS */;
INSERT INTO `client_work_assignments` VALUES (2,10,9,'Simple',NULL,0,0,'','2026-08-25','medium','assigned',10,'2026-08-25 14:21:54','2026-08-25 14:21:54'),(3,19,13,'hrms',NULL,0,0,'','2026-09-08','high','assigned',19,'2026-09-08 06:01:11','2026-09-08 06:01:11'),(4,19,15,'Job portal ',NULL,0,0,'','2026-09-16','high','assigned',19,'2026-09-09 14:57:45','2026-09-09 14:57:45');
/*!40000 ALTER TABLE `client_work_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_work_targets`
--

DROP TABLE IF EXISTS `client_work_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_work_targets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `target_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'daily',
  `target_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cwt_client` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_work_targets`
--

LOCK TABLES `client_work_targets` WRITE;
/*!40000 ALTER TABLE `client_work_targets` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_work_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gst_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `business_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `employee_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_code` (`client_code`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `gst_number` (`gst_number`),
  KEY `idx_clients_employee` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (16,'C1001','Arav','Arav','arav@gmail.com','8796554455','GSTIN','Noida','http://localhost:5178/complaint','ajgjhd','$2b$10$lkq4S6KRiDFGF7wv4dBvduuu1LhpJQfEHlCT5iPK.g96R10OCVlFy','ACTIVE','2026-09-07 08:37:47','2026-09-07 09:40:00',10),(19,'C1017','Aryan','Kumar','aryan@gmail.com','9876543211','GSTIN12345','Noida','http://localhost:5174/dashboard','What','$2b$10$ZvDTVHtLVH/Dh7eXCDaWTOBL0wcokWChV4DLgIBjlKvfl/li8TlSC','ACTIVE','2026-09-07 13:50:21','2026-09-08 04:25:56',NULL);
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comp_offs`
--

DROP TABLE IF EXISTS `comp_offs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comp_offs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `worked_date` date NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `approved_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comp_offs`
--

LOCK TABLES `comp_offs` WRITE;
/*!40000 ALTER TABLE `comp_offs` DISABLE KEYS */;
INSERT INTO `comp_offs` VALUES (1,19,'2026-08-21','i don\'t ','Approved','Super Admin','2026-08-21 07:34:28');
/*!40000 ALTER TABLE `comp_offs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `logo_url` text,
  `plan_tier` enum('STARTER','GROWTH','ENTERPRISE_ROBOTICS') NOT NULL,
  `status` enum('ACTIVE','INACTIVE','TRIAL','SUSPENDED') NOT NULL,
  `max_jobs` int NOT NULL,
  `max_candidates_per_month` int NOT NULL,
  `max_employees` int NOT NULL,
  `contact_email` varchar(255) NOT NULL,
  `contact_person` varchar(255) NOT NULL,
  `industry` varchar(150) NOT NULL,
  `ai_custom_rules_enabled` tinyint(1) NOT NULL,
  `recording_storage_used_mb` int NOT NULL,
  `recording_storage_quota_mb` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `domain` (`domain`),
  KEY `idx_company_domain` (`domain`),
  KEY `idx_company_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_settings`
--

DROP TABLE IF EXISTS `company_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `gstin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ifsc` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `branch` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_settings`
--

LOCK TABLES `company_settings` WRITE;
/*!40000 ALTER TABLE `company_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `company_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaint_replies`
--

DROP TABLE IF EXISTS `complaint_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaint_replies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_id` int NOT NULL,
  `sender_role` enum('employee','hr','client','sales','admin','it','manager') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `complaint_id` (`complaint_id`),
  CONSTRAINT `complaint_replies_ibfk_1` FOREIGN KEY (`complaint_id`) REFERENCES `complaints` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaint_replies`
--

LOCK TABLES `complaint_replies` WRITE;
/*!40000 ALTER TABLE `complaint_replies` DISABLE KEYS */;
INSERT INTO `complaint_replies` VALUES (1,2,'Thanks — we are looking into this now.',1,'admin','2026-09-07 07:59:33');
/*!40000 ALTER TABLE `complaint_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints`
--

DROP TABLE IF EXISTS `complaints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('technical','salary','attendance','management','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'other',
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'low',
  `status` enum('open','in_progress','resolved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `created_by_id` int NOT NULL,
  `created_by_role` enum('employee','hr','client','sales','admin','it','manager') COLLATE utf8mb4_unicode_ci NOT NULL,
  `assigned_to_id` int DEFAULT NULL,
  `assigned_to_role` enum('hr','admin','manager','it') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints`
--

LOCK TABLES `complaints` WRITE;
/*!40000 ALTER TABLE `complaints` DISABLE KEYS */;
INSERT INTO `complaints` VALUES (1,'bug','sdfgh','other','low','open',10,'client',NULL,NULL,10,1,'2026-08-25 17:42:58','2026-08-25 17:42:58'),(2,'V0 verify complaint','Automated verification of complaint submit from IT portal','other','low','open',26,'it',NULL,NULL,NULL,1,'2026-09-03 12:43:30','2026-09-07 08:00:00'),(3,'TYYJKW4WE','HJFGR','other','low','open',26,'it',NULL,NULL,NULL,1,'2026-09-03 12:46:19','2026-09-03 12:46:19'),(4,'UYKTJHREW','KJTYHRTEW','other','low','open',26,'it',NULL,NULL,NULL,1,'2026-09-03 12:46:35','2026-09-03 12:46:35'),(5,'VHRE','ytr','other','low','open',10,'sales',NULL,NULL,NULL,1,'2026-09-07 08:34:52','2026-09-07 08:34:52'),(6,'iuaiawbbas','dawdaafc','other','high','open',25,'it',NULL,NULL,NULL,1,'2026-09-08 15:00:47','2026-09-08 15:00:47'),(7,'wwewewew','ewrwrwr','other','medium','open',19,'employee',NULL,NULL,19,1,'2026-09-09 13:33:11','2026-09-09 13:33:11');
/*!40000 ALTER TABLE `complaints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compliance_items`
--

DROP TABLE IF EXISTS `compliance_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('PF','ESIC','TDS','GST','PT','Labour','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Other',
  `frequency` enum('Monthly','Quarterly','Yearly','One-time') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Monthly',
  `due_date` date NOT NULL,
  `status` enum('Pending','Completed','Overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `completed_at` datetime DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_items`
--

LOCK TABLES `compliance_items` WRITE;
/*!40000 ALTER TABLE `compliance_items` DISABLE KEYS */;
INSERT INTO `compliance_items` VALUES (1,'PF Return Filing (ECR)','PF','Monthly','2026-08-18','Overdue',NULL,NULL,'2026-08-13 07:34:48');
/*!40000 ALTER TABLE `compliance_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `hr_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `hr_id` (`hr_id`),
  CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `conversations_ibfk_2` FOREIGN KEY (`hr_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES (20,19,28,'2026-09-08 05:59:49'),(21,16,28,'2026-09-08 06:48:18'),(22,16,25,'2026-09-08 14:39:02'),(23,19,25,'2026-09-08 14:44:25'),(24,19,18,'2026-09-09 09:29:31'),(25,19,21,'2026-09-09 09:29:32'),(26,19,7,'2026-09-09 09:29:32'),(27,19,14,'2026-09-09 09:29:33');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credit_debit_notes`
--

DROP TABLE IF EXISTS `credit_debit_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_debit_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` int NOT NULL,
  `note_type` enum('Credit','Debit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note_date` date DEFAULT NULL,
  `created_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credit_debit_notes`
--

LOCK TABLES `credit_debit_notes` WRITE;
/*!40000 ALTER TABLE `credit_debit_notes` DISABLE KEYS */;
INSERT INTO `credit_debit_notes` VALUES (1,1,'Credit','CN-0001',5000.00,'Rate adjustment','2026-08-13','Super Admin','2026-08-13 06:36:54');
/*!40000 ALTER TABLE `credit_debit_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'HR',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(2,'Sales',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(3,'IT',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(4,'Marketing',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(5,'Others',1,'2026-08-13 04:46:21','2026-08-13 04:46:21'),(11,'Frontend',1,'2026-08-21 08:47:27','2026-08-21 08:47:27'),(12,'Quality Assurance',1,'2026-08-23 09:30:54','2026-08-23 09:30:54');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `designations`
--

DROP TABLE IF EXISTS `designations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `designations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `departmentId` int NOT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `departmentId` (`departmentId`,`name`),
  CONSTRAINT `designations_ibfk_1` FOREIGN KEY (`departmentId`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `designations`
--

LOCK TABLES `designations` WRITE;
/*!40000 ALTER TABLE `designations` DISABLE KEYS */;
INSERT INTO `designations` VALUES (1,1,'HR Manager',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(2,1,'Recruiter',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(3,2,'Sales Executive',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(4,2,'Sales Manager',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(5,3,'Frontend Developer',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(6,3,'Backend Developer',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(7,4,'SEO Executive',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(8,4,'Social Media Manager',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(9,3,'IT',1,'2026-08-13 04:46:21','2026-08-13 04:51:53'),(10,5,'Others',1,'2026-08-13 04:50:10','2026-08-13 04:51:53');
/*!40000 ALTER TABLE `designations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dev_bugs`
--

DROP TABLE IF EXISTS `dev_bugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_bugs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `project` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `severity` enum('Low','Medium','High','Critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `status` enum('Open','In Progress','Fixed','Verified','Closed','Reopened') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Open',
  `reported_by_id` int DEFAULT NULL,
  `reported_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assignee_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dev_bugs`
--

LOCK TABLES `dev_bugs` WRITE;
/*!40000 ALTER TABLE `dev_bugs` DISABLE KEYS */;
/*!40000 ALTER TABLE `dev_bugs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dev_deployments`
--

DROP TABLE IF EXISTS `dev_deployments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_deployments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `version_tag` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `environment` enum('Development','Staging','Production') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Production',
  `features` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('Success','Failed','Rolled Back') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Success',
  `deployed_by_id` int DEFAULT NULL,
  `deployed_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deployed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dev_deployments`
--

LOCK TABLES `dev_deployments` WRITE;
/*!40000 ALTER TABLE `dev_deployments` DISABLE KEYS */;
INSERT INTO `dev_deployments` VALUES (3,'HRMS',NULL,'Production',NULL,'Success',26,'Dummy IT Dev','2026-09-03 09:33:43'),(4,'HRMS',NULL,'Production',NULL,'Success',26,'Dummy IT Dev','2026-09-03 09:33:55'),(5,'HRMS','v9.9.9-dummy','Staging','DUMMY feature list','Success',26,'Dummy IT Dev','2026-09-03 09:35:04'),(6,'Ardhnarishwar website','V2','Production',NULL,'Success',25,'Testing','2026-09-08 14:25:14');
/*!40000 ALTER TABLE `dev_deployments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dev_milestones`
--

DROP TABLE IF EXISTS `dev_milestones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_milestones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_date` date DEFAULT NULL,
  `progress` int DEFAULT '0',
  `status` enum('Planned','On Track','At Risk','Delayed','Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Planned',
  `notes` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dev_milestones`
--

LOCK TABLES `dev_milestones` WRITE;
/*!40000 ALTER TABLE `dev_milestones` DISABLE KEYS */;
INSERT INTO `dev_milestones` VALUES (1,'HRMS','Batch 3 release','2026-08-31',60,'On Track',NULL,'2026-08-13 06:51:28');
/*!40000 ALTER TABLE `dev_milestones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dev_tasks`
--

DROP TABLE IF EXISTS `dev_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `project` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assignee_id` int DEFAULT NULL,
  `priority` enum('Low','Medium','High','Critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `status` enum('Backlog','In Progress','Code Review','Testing','Done') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Backlog',
  `review_status` enum('Not Submitted','Pending Review','Changes Requested','Approved') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Not Submitted',
  `due_date` date DEFAULT NULL,
  `created_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dev_tasks`
--

LOCK TABLES `dev_tasks` WRITE;
/*!40000 ALTER TABLE `dev_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `dev_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dev_timesheets`
--

DROP TABLE IF EXISTS `dev_timesheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_timesheets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `work_date` date NOT NULL,
  `project` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_id` int DEFAULT NULL,
  `hours` decimal(4,1) NOT NULL,
  `summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dev_timesheets`
--

LOCK TABLES `dev_timesheets` WRITE;
/*!40000 ALTER TABLE `dev_timesheets` DISABLE KEYS */;
INSERT INTO `dev_timesheets` VALUES (1,7,'2026-08-13','HRMS',NULL,6.5,'Payroll fixes','2026-08-13 06:51:28');
/*!40000 ALTER TABLE `dev_timesheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_expiries`
--

DROP TABLE IF EXISTS `document_expiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_expiries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doc_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `doc_type` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_type` enum('EMPLOYEE','CLIENT','COMPANY','VENDOR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'COMPANY',
  `entity_id` int DEFAULT NULL,
  `entity_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date NOT NULL,
  `remind_days` int DEFAULT '30',
  `notify_phone` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_alerted_at` timestamp NULL DEFAULT NULL,
  `status` enum('ACTIVE','RENEWED','EXPIRED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_expiry` (`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_expiries`
--

LOCK TABLES `document_expiries` WRITE;
/*!40000 ALTER TABLE `document_expiries` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_expiries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `document_name` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `ix_documents_id` (`id`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipient_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `template_id` int DEFAULT NULL,
  `status` enum('sent','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'sent',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_status` (`status`),
  KEY `idx_email_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,'ahaanshah777@gmail.com','Ahan','Nothing','kuch vhi',NULL,'failed','Missing credentials for \"PLAIN\"','2026-09-02 06:28:39'),(2,'phabindrakumar777@gmail.com','Ahaan','nothing','kuh vhi',NULL,'sent',NULL,'2026-09-02 06:32:40'),(3,'advay708@gmail.com','suhani','fffdf','weervfrff',NULL,'failed','Mail command failed: 530-5.7.0 Authentication Required. For more information, go to\n530 5.7.0  https://support.google.com/accounts/troubleshooter/2402620. 41be03b00d2f7-cc4554a98fesm4814337a12.30 - gsmtp','2026-09-08 05:03:37');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_templates`
--

DROP TABLE IF EXISTS `email_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_templates`
--

LOCK TABLES `email_templates` WRITE;
/*!40000 ALTER TABLE `email_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emergency_contacts`
--

DROP TABLE IF EXISTS `emergency_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emergency_contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emergency_contacts`
--

LOCK TABLES `emergency_contacts` WRITE;
/*!40000 ALTER TABLE `emergency_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `emergency_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emergency_logs`
--

DROP TABLE IF EXISTS `emergency_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emergency_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `click_count` int DEFAULT '1',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emergency_logs`
--

LOCK TABLES `emergency_logs` WRITE;
/*!40000 ALTER TABLE `emergency_logs` DISABLE KEYS */;
INSERT INTO `emergency_logs` VALUES (1,26,1,'triggered','2026-09-03 12:45:07'),(2,26,2,'triggered','2026-09-03 12:46:47'),(3,26,3,'triggered','2026-09-03 13:20:27'),(4,28,1,'triggered','2026-09-08 06:48:31'),(5,25,1,'triggered','2026-09-08 14:02:50');
/*!40000 ALTER TABLE `emergency_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_benefits`
--

DROP TABLE IF EXISTS `employee_benefits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_benefits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `benefit_type` enum('Insurance','Reimbursement','Bonus','Incentive','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `policy_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT '0.00',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Active','Pending','Approved','Rejected','Expired','Paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_benefits`
--

LOCK TABLES `employee_benefits` WRITE;
/*!40000 ALTER TABLE `employee_benefits` DISABLE KEYS */;
INSERT INTO `employee_benefits` VALUES (1,15,'Divya Nair','Insurance','Group Health Insurance','Star Health',NULL,500000.00,NULL,NULL,'Active',NULL,'2026-08-13 07:34:36');
/*!40000 ALTER TABLE `employee_benefits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_branches`
--

DROP TABLE IF EXISTS `employee_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_branches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `branch_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_emp` (`employee_id`),
  KEY `idx_branch` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_branches`
--

LOCK TABLES `employee_branches` WRITE;
/*!40000 ALTER TABLE `employee_branches` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_insurance`
--

DROP TABLE IF EXISTS `employee_insurance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_insurance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `policy_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `policy_number` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coverage_amount` decimal(12,2) NOT NULL,
  `premium_amount` decimal(12,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `nominee` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ins_emp` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_insurance`
--

LOCK TABLES `employee_insurance` WRITE;
/*!40000 ALTER TABLE `employee_insurance` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_insurance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_login_settings`
--

DROP TABLE IF EXISTS `employee_login_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_login_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `login_time` time DEFAULT NULL,
  `logout_time` time DEFAULT NULL,
  `is_custom` tinyint(1) DEFAULT '0',
  `is_flexible` tinyint(1) DEFAULT '0',
  `flexi_start_time` time DEFAULT NULL,
  `flexi_end_time` time DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_employee` (`employee_id`),
  CONSTRAINT `employee_login_settings_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_login_settings`
--

LOCK TABLES `employee_login_settings` WRITE;
/*!40000 ALTER TABLE `employee_login_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_login_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_rewards`
--

DROP TABLE IF EXISTS `employee_rewards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_rewards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `reward_type` enum('Incentive','Bonus') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `award_date` date DEFAULT NULL,
  `period` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('Pending','Paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rew_emp` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_rewards`
--

LOCK TABLES `employee_rewards` WRITE;
/*!40000 ALTER TABLE `employee_rewards` DISABLE KEYS */;
INSERT INTO `employee_rewards` VALUES (2,20,'Bonus','IT',5000.00,'2026-08-23','1','Pending',NULL,'Super Admin','2026-08-23 07:02:35'),(3,25,'Bonus','sales',543.00,'2026-08-25','15','Pending',NULL,'Super Admin','2026-08-25 14:53:35');
/*!40000 ALTER TABLE `employee_rewards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_skills`
--

DROP TABLE IF EXISTS `employee_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_skills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `skill` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` enum('Beginner','Intermediate','Advanced','Expert') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Beginner',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_skills`
--

LOCK TABLES `employee_skills` WRITE;
/*!40000 ALTER TABLE `employee_skills` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_statuses`
--

DROP TABLE IF EXISTS `employee_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_statuses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_statuses`
--

LOCK TABLES `employee_statuses` WRITE;
/*!40000 ALTER TABLE `employee_statuses` DISABLE KEYS */;
INSERT INTO `employee_statuses` VALUES (1,'WORKING',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(2,'ON_NOTICE',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(3,'RESIGNED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30'),(4,'TERMINATED',1,'2026-08-12 17:26:30','2026-08-12 17:26:30');
/*!40000 ALTER TABLE `employee_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employeeCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `joiningId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departmentId` int NOT NULL,
  `designationId` int NOT NULL,
  `statusId` int DEFAULT '1',
  `joiningDate` date NOT NULL,
  `salary` int DEFAULT '0',
  `isActive` tinyint DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `avatar` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_relation` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_mobile` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employeeCode` (`employeeCode`),
  UNIQUE KEY `joiningId` (`joiningId`),
  KEY `departmentId` (`departmentId`),
  KEY `designationId` (`designationId`),
  KEY `statusId` (`statusId`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`departmentId`) REFERENCES `departments` (`id`),
  CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`designationId`) REFERENCES `designations` (`id`),
  CONSTRAINT `employees_ibfk_3` FOREIGN KEY (`statusId`) REFERENCES `employee_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (7,'HR001',NULL,'HR Admin','hr@hrms.com','$2b$10$eNrHf9JeX6ju75HjoQe51OVrIqrumCsDGEbFQCVI/UoDQxpT3Q2SK',NULL,1,1,1,'2026-08-13',0,1,'2026-08-13 03:08:00','2026-08-24 14:42:54',NULL,NULL,NULL,NULL,NULL),(8,'DEMO001',NULL,'Aarav Sharma','aarav@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000001',3,6,1,'2024-06-13',65000,1,'2026-08-13 07:13:50','2026-08-23 06:01:50',NULL,NULL,NULL,NULL,NULL),(9,'DEMO002',NULL,'Priya Patel','priya@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000002',3,5,1,'2025-06-13',58000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(10,'DEMO003',NULL,'Rohan Verma','rohan@demo.hrms','$2b$10$hCiAI6PWyRos9hZ/PwqcE.C0Gnb45vlvwE2zo1GBzMECpWO0HDmWm','9000000003',2,3,1,'2025-11-13',40000,1,'2026-08-13 07:13:50','2026-09-07 09:07:11',NULL,NULL,NULL,NULL,NULL),(11,'DEMO004',NULL,'Sneha Iyer','sneha@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000004',2,4,1,'2023-04-13',75000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(12,'DEMO005',NULL,'Vikram Singh','vikram@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000005',4,7,1,'2026-03-13',35000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(13,'DEMO006',NULL,'Ananya Das','ananya@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000006',4,8,1,'2026-05-13',38000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(14,'DEMO007',NULL,'Karan Mehta','karan@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000007',1,2,1,'2025-02-13',45000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(15,'DEMO008',NULL,'Divya Nair','divya@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm','9000000008',3,6,2,'2024-10-13',70000,1,'2026-08-13 07:13:50','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(16,'0032',NULL,'product intern','intern0032@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm',NULL,1,1,1,'2026-08-16',0,1,'2026-08-16 05:47:12','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(18,'005',NULL,'Aahan shah','aahan005@demo.hrms','$2b$10$z7n9savgDSz./pb02mqyy.AaALowtvtZlu3IZKQudBaeu8lWgzBrm',NULL,1,1,1,'2026-08-16',0,1,'2026-08-16 05:47:12','2026-08-17 08:38:44',NULL,NULL,NULL,NULL,NULL),(19,'EMP5208','5000','Phabindra Kumar Sah','ahaanshah680@gmail.com',NULL,'9992785583',3,5,1,'2026-08-21',33333,1,'2026-08-21 06:19:17','2026-08-21 06:19:17',NULL,NULL,NULL,NULL,NULL),(20,'EMP8811','5002','Phabindra Kumar Sah','phabindrakumar777@gmail.com','$2b$10$vIn2e3BLi10Q06554daUWeLWMZbI5/IrS886ygnn0P/Z8ORKlsrfC','9992785583',1,1,1,'2026-08-22',50000,1,'2026-08-22 17:36:47','2026-08-22 17:36:47',NULL,NULL,NULL,NULL,NULL),(21,'EMP5979','990','Ahaan','ahaanshah777@gmail.com','$2b$10$xlXrN33JS7dHY9Ts9lzLXOH0DkbI7huF74GDpIeUanBeJwZmgjpkK','9992785583',1,1,1,'2026-08-23',50000,1,'2026-08-23 09:48:16','2026-08-24 16:25:43',NULL,NULL,NULL,NULL,NULL),(24,'EMP9534','45864','kumar','abcd@gmail.com','$2b$10$AmxRNRT.RL6IrVfWM/W18uNqVkITSGfri1d9BrjJ6eV2dbYuEPblW','8877669955',1,1,1,'2026-08-25',49994,1,'2026-08-24 21:32:35','2026-09-07 13:54:18',NULL,NULL,NULL,NULL,NULL),(25,'EMP5182','5001','Testing','abcde@gmail.com','$2b$10$wjqa6c/Ieby0LW2R.VvzH.98iyKxItyqnnUz4jMHUd0h1youCQs86','9988776655',3,9,1,'2026-08-25',50000,1,'2026-08-25 14:07:39','2026-09-07 19:27:28',NULL,NULL,NULL,NULL,NULL),(26,'ITDUMMY01',NULL,'Dummy IT Dev','dummy.itdev@test.local','$2b$10$TJEZTDGr/n8EMKkWErj0D.oR5XOpuyzQVe2ZMbP6baumH17JoiyJi','9999999999',3,9,1,'2026-09-01',50000,1,'2026-09-03 09:33:07','2026-09-03 11:52:12',NULL,NULL,NULL,NULL,NULL),(27,'EMP5903','1234','Aryan','aryan@gmail.com','$2b$10$k7GjNWYaQplD9LpJuvxjduSHfaTfaT13NuwOlyyu9ka5HegzbpySm','9876543211',2,3,1,'2026-09-07',49991,1,'2026-09-07 13:51:12','2026-09-07 13:51:12',NULL,NULL,NULL,NULL,NULL),(28,'EMP9968','234','A','ab@gmail.com','$2b$10$YZLP9QRf1D2Ko/oO.8t3d.zGr32i6Pm0Oi9uE9DgCbjqljPjeoy1y','9876543298',1,1,1,'2026-09-07',50000,1,'2026-09-07 13:58:09','2026-09-07 18:14:48',NULL,NULL,NULL,NULL,NULL),(29,'Em-10003','1456','suhani','advay708@gmail.com','$2b$10$JF44znnfpyXrdhbzaZcemeBdgGw9nnCHZzifU83CWu8wbhoHtHH8a','4547886999',2,4,1,'2026-09-08',30000,1,'2026-09-07 19:38:19','2026-09-09 20:38:59','uploads/profile/1788986339810-451785381.jpg','vyvybyb',NULL,NULL,NULL),(30,'006',NULL,'Smoke Test','smoke-006@smoke.invalid',NULL,NULL,1,1,1,'2026-09-14',0,1,'2026-09-14 13:56:44','2026-09-14 13:56:44',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employment_history`
--

DROP TABLE IF EXISTS `employment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employment_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `start_date` varchar(20) DEFAULT NULL,
  `end_date` varchar(20) DEFAULT NULL,
  `hr_contact_email` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `ix_employment_history_id` (`id`),
  CONSTRAINT `employment_history_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employment_history`
--

LOCK TABLES `employment_history` WRITE;
/*!40000 ALTER TABLE `employment_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `employment_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eod_reports`
--

DROP TABLE IF EXISTS `eod_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eod_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `report_date` date NOT NULL,
  `tasks_completed` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tasks_in_progress` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `blockers` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tomorrow_plan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','submitted','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'submitted',
  `hours_worked` decimal(5,2) DEFAULT '8.00',
  `submitted_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `approved_at` datetime DEFAULT NULL,
  `approved_by` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eod_reports`
--

LOCK TABLES `eod_reports` WRITE;
/*!40000 ALTER TABLE `eod_reports` DISABLE KEYS */;
INSERT INTO `eod_reports` VALUES (1,24,'kumar','HR',1,'2026-08-26','yes','90','no','sytsem design','nothing','approved',8.00,'2026-08-26 14:03:51',NULL,'Super Admin','2026-08-26 14:03:51','2026-09-08 11:44:43'),(2,26,'Dummy IT Dev','IT',3,'2026-09-03','GFGCVHJMN','WEJWH','WDHGFWBJ','Redesign verification - tomorrow plan','WDGFJEH','approved',8.00,'2026-09-03 17:54:46',NULL,'Super Admin','2026-09-03 17:54:46','2026-09-08 11:44:42'),(3,28,'A','HR',1,'2026-09-08','frontend completed','backend and deployment pending','error s of api ','work on backend ','ewev','approved',8.00,'2026-09-08 11:44:13',NULL,'Super Admin','2026-09-08 11:44:13','2026-09-08 11:44:39'),(4,25,'Testing','IT',3,'2026-09-08','frontend completed','backend and database pending','API connection error','work on backend and database ','efefefwwfewfwfww ','submitted',8.00,'2026-09-08 20:29:51',NULL,NULL,'2026-09-08 20:29:51','2026-09-08 20:29:51'),(5,29,'suhani','Sales',2,'2026-09-09','edwed','wwdc','dwwdcwd','ewwecwe','wwdcddwcc','submitted',8.00,'2026-09-09 22:23:09',NULL,NULL,'2026-09-09 22:23:09','2026-09-09 22:23:09'),(6,29,'suhani','Sales',2,'2026-09-09','ewef','dedwweffe','eefff','ererr','ewrefe','submitted',8.00,'2026-09-09 23:31:43',NULL,NULL,'2026-09-09 23:31:43','2026-09-09 23:31:43');
/*!40000 ALTER TABLE `eod_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_audit_logs`
--

DROP TABLE IF EXISTS `evs_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int DEFAULT '0',
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_audit_logs`
--

LOCK TABLES `evs_audit_logs` WRITE;
/*!40000 ALTER TABLE `evs_audit_logs` DISABLE KEYS */;
INSERT INTO `evs_audit_logs` VALUES (1,0,'Identity submitted for employee 1',NULL,'2026-08-14 08:36:25'),(2,0,'AADHAAR Verified for employee 1',NULL,'2026-08-14 08:36:25'),(3,0,'PAN Verified for employee 1',NULL,'2026-08-14 08:36:25'),(4,0,'Employment history added for employee 1',NULL,'2026-08-14 08:36:25'),(5,0,'Employment history Validated for employee 1',NULL,'2026-08-14 08:36:25'),(6,0,'Background verification opened for employee 1',NULL,'2026-08-14 08:36:25'),(7,0,'Background verification In Progress for employee 1',NULL,'2026-08-14 08:36:25'),(8,0,'Background verification Verified for employee 1',NULL,'2026-08-14 08:36:25'),(9,0,'HRMS Sync: 9 added, 0 updated',NULL,'2026-08-14 09:19:02'),(10,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:20:48'),(11,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:20:50'),(12,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:34:58'),(13,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:34:59'),(14,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:35:00'),(15,0,'HRMS Sync: 0 added, 9 updated',NULL,'2026-08-14 09:35:01'),(16,0,'Employment history added for employee 1',NULL,'2026-08-14 09:43:00'),(17,0,'Background verification opened for employee 1',NULL,'2026-08-14 09:43:00'),(18,0,'Employment history added for employee 2',NULL,'2026-08-14 09:43:00'),(19,0,'Background verification opened for employee 2',NULL,'2026-08-14 09:43:00'),(20,0,'Employment history added for employee 3',NULL,'2026-08-14 09:43:00'),(21,0,'Background verification opened for employee 3',NULL,'2026-08-14 09:43:00'),(22,0,'Identity submitted for employee 1',NULL,'2026-08-14 09:44:04'),(23,0,'Identity submitted for employee 2',NULL,'2026-08-14 09:44:04'),(24,0,'Identity submitted for employee 3',NULL,'2026-08-14 09:44:04'),(25,0,'AADHAAR Verified for employee 1',NULL,'2026-08-14 09:46:42'),(26,0,'PAN Verified for employee 1',NULL,'2026-08-14 09:46:44'),(27,0,'Employment history Validated for employee 1',NULL,'2026-08-14 09:47:01'),(28,0,'Background verification In Progress for employee 1',NULL,'2026-08-14 09:47:32'),(29,0,'Background verification Verified for employee 1',NULL,'2026-08-14 09:47:34'),(30,0,'Identity submitted for employee 2',NULL,'2026-08-14 09:55:08'),(31,0,'AADHAAR Rejected for employee 2',NULL,'2026-08-14 09:55:22'),(32,0,'AADHAAR Rejected for employee 3',NULL,'2026-08-14 09:55:38'),(33,0,'PAN Rejected for employee 2',NULL,'2026-08-14 09:55:40'),(34,0,'PAN Rejected for employee 3',NULL,'2026-08-14 09:55:41'),(35,0,'Employment history In Progress for employee 2',NULL,'2026-08-14 10:10:03'),(36,0,'Employment history Validated for employee 2',NULL,'2026-08-14 10:10:06'),(37,0,'Employment history In Progress for employee 3',NULL,'2026-08-14 10:10:08'),(38,0,'Employment history Rejected for employee 3',NULL,'2026-08-14 10:13:49'),(39,0,'Intl BT cid submitted e1',NULL,'2026-08-16 06:34:19'),(40,0,'Intl BD nid submitted e1',NULL,'2026-08-16 06:34:19'),(41,0,'Intl BT cid Verified e1',NULL,'2026-08-16 06:34:19'),(42,0,'HRMS Sync: 7 added, 9 updated',NULL,'2026-08-25 15:35:23'),(43,0,'HRMS Sync: 0 added, 16 updated',NULL,'2026-08-26 09:24:51'),(44,0,'HRMS Sync: 0 added, 16 updated','admin@hrms.com','2026-09-02 13:25:18'),(45,0,'Identity submitted for employee 13','system','2026-09-02 13:34:25'),(46,0,'PAN Verified for employee 13','system','2026-09-02 13:34:32'),(47,0,'HRMS Sync: 4 added, 16 updated','admin@hrms.com','2026-09-08 11:49:32');
/*!40000 ALTER TABLE `evs_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_background_verifications`
--

DROP TABLE IF EXISTS `evs_background_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_background_verifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `previous_company` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `hr_email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rehire_eligible` tinyint(1) DEFAULT '0',
  `criminal_record` tinyint(1) DEFAULT '0',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_evs_bg_emp` (`employee_id`),
  CONSTRAINT `fk_evs_bg_emp` FOREIGN KEY (`employee_id`) REFERENCES `evs_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_background_verifications`
--

LOCK TABLES `evs_background_verifications` WRITE;
/*!40000 ALTER TABLE `evs_background_verifications` DISABLE KEYS */;
INSERT INTO `evs_background_verifications` VALUES (1,29,'assa','advay708@gmail.com','sdds',1,0,'Verified','2026-09-10 01:13:06');
/*!40000 ALTER TABLE `evs_background_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_documents`
--

DROP TABLE IF EXISTS `evs_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `document_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_evs_doc_emp` (`employee_id`),
  CONSTRAINT `fk_evs_doc_emp` FOREIGN KEY (`employee_id`) REFERENCES `evs_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_documents`
--

LOCK TABLES `evs_documents` WRITE;
/*!40000 ALTER TABLE `evs_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `evs_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_employees`
--

DROP TABLE IF EXISTS `evs_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `designation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_employees`
--

LOCK TABLES `evs_employees` WRITE;
/*!40000 ALTER TABLE `evs_employees` DISABLE KEYS */;
INSERT INTO `evs_employees` VALUES (1,'Test Employee','test.emp@hrms.com','9800000000','Engineering','Developer','2026-09-02 13:16:37'),(2,'HR Admin','hr@hrms.com','','HR','HR Manager','2026-09-02 13:16:37'),(3,'Aarav Sharma','aarav@demo.hrms','9000000001','IT','Backend Developer','2026-09-02 13:16:37'),(4,'Priya Patel','priya@demo.hrms','9000000002','IT','Frontend Developer','2026-09-02 13:16:37'),(5,'Rohan Verma','rohan@demo.hrms','9000000003','Sales','Sales Executive','2026-09-02 13:16:37'),(6,'Sneha Iyer','sneha@demo.hrms','9000000004','Sales','Sales Manager','2026-09-02 13:16:37'),(7,'Vikram Singh','vikram@demo.hrms','9000000005','Marketing','SEO Executive','2026-09-02 13:16:37'),(8,'Ananya Das','ananya@demo.hrms','9000000006','Marketing','Social Media Manager','2026-09-02 13:16:37'),(9,'Karan Mehta','karan@demo.hrms','9000000007','HR','Recruiter','2026-09-02 13:16:37'),(10,'Divya Nair','divya@demo.hrms','9000000008','IT','Backend Developer','2026-09-02 13:16:37'),(11,'product intern','intern0032@demo.hrms','','HR','HR Manager','2026-09-02 13:16:37'),(12,'Aahan shah','aahan005@demo.hrms','','HR','HR Manager','2026-09-02 13:16:37'),(13,'Phabindra Kumar Sah','ahaanshah680@gmail.com','9992785583','IT','Frontend Developer','2026-09-02 13:16:37'),(14,'Phabindra Kumar Sah','phabindrakumar777@gmail.com','9992785583','HR','HR Manager','2026-09-02 13:16:37'),(15,'Ahaan','ahaanshah777@gmail.com','9992785583','HR','HR Manager','2026-09-02 13:16:37'),(16,'kumar','abcd@gmail.com','8877669955','HR','HR Manager','2026-09-02 13:16:37'),(17,'Testing','abcde@gmail.com','9988776655','IT','IT','2026-09-02 13:16:37'),(18,'Dummy IT Dev','dummy.itdev@test.local','9999999999','IT','IT','2026-09-08 11:49:32'),(19,'Aryan','aryan@gmail.com','9876543211','Sales','Sales Executive','2026-09-08 11:49:32'),(20,'A','ab@gmail.com','9876543298','HR','HR Manager','2026-09-08 11:49:32'),(21,'suhani','advay708@gmail.com.legacy.21','4547886999','Sales','Sales Manager','2026-09-08 11:49:32'),(29,'suhani','advay708@gmail.com','4547886999','Sales','Sales Manager','2026-09-10 01:12:42');
/*!40000 ALTER TABLE `evs_employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_employment_history`
--

DROP TABLE IF EXISTS `evs_employment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_employment_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `company_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `designation` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `start_date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `end_date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hr_contact_email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_evs_hist_emp` (`employee_id`),
  CONSTRAINT `fk_evs_hist_emp` FOREIGN KEY (`employee_id`) REFERENCES `evs_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_employment_history`
--

LOCK TABLES `evs_employment_history` WRITE;
/*!40000 ALTER TABLE `evs_employment_history` DISABLE KEYS */;
INSERT INTO `evs_employment_history` VALUES (1,1,'Prev Corp','Junior Dev','2022-01-01','2024-06-30','hr@prevcorp.com','Validated','','2026-09-02 13:16:37'),(2,1,'TechCorp Solutions Pvt Ltd','Senior Developer','2021-03-01','2024-06-30','hr@techcorp.example.com','Validated','','2026-09-02 13:16:37'),(3,2,'TechCorp Solutions Pvt Ltd','Senior Developer','2021-03-01','2024-06-30','hr@techcorp.example.com','Validated','','2026-09-02 13:16:37'),(4,3,'TechCorp Solutions Pvt Ltd','Senior Developer','2021-03-01','2024-06-30','hr@techcorp.example.com','Rejected','','2026-09-02 13:16:37');
/*!40000 ALTER TABLE `evs_employment_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_identity_verifications`
--

DROP TABLE IF EXISTS `evs_identity_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_identity_verifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `aadhaar_masked` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pan_masked` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `aadhaar_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Not Submitted',
  `pan_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Not Submitted',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  CONSTRAINT `fk_evs_id_emp` FOREIGN KEY (`employee_id`) REFERENCES `evs_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_identity_verifications`
--

LOCK TABLES `evs_identity_verifications` WRITE;
/*!40000 ALTER TABLE `evs_identity_verifications` DISABLE KEYS */;
INSERT INTO `evs_identity_verifications` VALUES (1,13,NULL,'UFXXXXXXXH','Not Submitted','Verified',NULL,'2026-09-02 13:34:32'),(10,29,'XXXX-XXXX-7637',NULL,'Verified','Not Submitted',NULL,'2026-09-10 01:32:22');
/*!40000 ALTER TABLE `evs_identity_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_international_verifications`
--

DROP TABLE IF EXISTS `evs_international_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_international_verifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `country_code` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `country_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `doc_type` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `doc_label` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `doc_masked` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending Approval',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_evs_intl` (`employee_id`,`country_code`,`doc_type`),
  CONSTRAINT `fk_evs_intl_emp` FOREIGN KEY (`employee_id`) REFERENCES `evs_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_international_verifications`
--

LOCK TABLES `evs_international_verifications` WRITE;
/*!40000 ALTER TABLE `evs_international_verifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `evs_international_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evs_verification_tokens`
--

DROP TABLE IF EXISTS `evs_verification_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evs_verification_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_evs_tok_doc` (`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evs_verification_tokens`
--

LOCK TABLES `evs_verification_tokens` WRITE;
/*!40000 ALTER TABLE `evs_verification_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `evs_verification_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exit_requests`
--

DROP TABLE IF EXISTS `exit_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exit_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resignation_date` date NOT NULL,
  `notice_period_days` int NOT NULL,
  `exit_date` date DEFAULT NULL,
  `exit_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'voluntary',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','approved','processing','completed','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `hr_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `exit_interview_date` date DEFAULT NULL,
  `final_settlement_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_employee_id` (`employee_id`),
  CONSTRAINT `fk_exit_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exit_requests`
--

LOCK TABLES `exit_requests` WRITE;
/*!40000 ALTER TABLE `exit_requests` DISABLE KEYS */;
INSERT INTO `exit_requests` VALUES (1,15,'Divya Nair','2026-06-13',30,'2026-07-13','voluntary','DEMO','approved',NULL,NULL,NULL,'2026-08-13 07:13:50','2026-08-13 07:13:50'),(2,12,'Vikram Singh','2026-01-13',30,'2026-02-13','voluntary','DEMO','approved',NULL,NULL,NULL,'2026-08-13 07:13:50','2026-08-13 07:13:50'),(3,13,'Ananya Das','2025-10-13',30,'2025-11-13','involuntary','DEMO','approved',NULL,NULL,NULL,'2026-08-13 07:13:50','2026-08-13 07:13:50'),(4,25,'Testing','2026-06-09',30,'2026-08-25','resignation','jhgfds','pending',NULL,NULL,NULL,'2026-08-25 17:55:23','2026-08-25 17:55:23'),(5,29,'suhani','2026-09-09',30,'2026-09-30','voluntary','','pending',NULL,NULL,NULL,'2026-09-08 04:59:49','2026-09-08 04:59:49');
/*!40000 ALTER TABLE `exit_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_categories`
--

DROP TABLE IF EXISTS `expense_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10707 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_categories`
--

LOCK TABLES `expense_categories` WRITE;
/*!40000 ALTER TABLE `expense_categories` DISABLE KEYS */;
INSERT INTO `expense_categories` VALUES (1,'Salary','2026-08-12 17:26:30'),(2,'Office Rent','2026-08-12 17:26:30'),(3,'Software','2026-08-12 17:26:30'),(4,'Marketing','2026-08-12 17:26:30'),(5,'Infrastructure','2026-08-12 17:26:30'),(6,'Other','2026-08-12 17:26:30'),(7,'Utilities','2026-08-12 17:26:30');
/*!40000 ALTER TABLE `expense_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` int DEFAULT NULL,
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `expense_date` date NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` VALUES (1,NULL,'demo',NULL,160000.00,'2026-08-06','DEMO','2026-08-13 07:13:50'),(2,NULL,'demo',NULL,169000.00,'2026-07-06','DEMO','2026-08-13 07:13:50'),(3,NULL,'demo',NULL,178000.00,'2026-06-06','DEMO','2026-08-13 07:13:50'),(4,NULL,'demo',NULL,187000.00,'2026-05-06','DEMO','2026-08-13 07:13:50'),(5,NULL,'demo',NULL,196000.00,'2026-04-06','DEMO','2026-08-13 07:13:50'),(6,NULL,'demo',NULL,205000.00,'2026-03-06','DEMO','2026-08-13 07:13:50'),(7,NULL,'demo',NULL,214000.00,'2026-02-06','DEMO','2026-08-13 07:13:50'),(8,NULL,'demo',NULL,163000.00,'2026-01-06','DEMO','2026-08-13 07:13:50'),(9,NULL,'demo',NULL,172000.00,'2025-12-06','DEMO','2026-08-13 07:13:50'),(10,NULL,'demo',NULL,181000.00,'2025-11-06','DEMO','2026-08-13 07:13:50'),(11,NULL,'demo',NULL,190000.00,'2025-10-06','DEMO','2026-08-13 07:13:50'),(12,NULL,'demo',NULL,199000.00,'2025-09-06','DEMO','2026-08-13 07:13:50');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feature_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `feature_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `feature_key` (`feature_key`)
) ENGINE=InnoDB AUTO_INCREMENT=30078 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features`
--

LOCK TABLES `features` WRITE;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` VALUES (1,'EMPLOYEE_MANAGEMENT',NULL,'2026-08-12 17:26:30'),(2,'CANDIDATE_MANAGEMENT',NULL,'2026-08-12 17:26:30'),(3,'ATTENDANCE_TRACKER',NULL,'2026-08-12 17:26:30'),(4,'INTERVIEW_TRACKER',NULL,'2026-08-12 17:26:30'),(5,'PAYROLL',NULL,'2026-08-12 17:26:30'),(6,'HR_CALLING',NULL,'2026-08-12 17:26:30'),(7,'SALES_REPORT',NULL,'2026-08-12 17:26:30'),(8,'PERFORMANCE_TRACKER',NULL,'2026-08-12 17:26:30'),(9,'PERFORMANCE_REPORT',NULL,'2026-08-12 17:26:30'),(10,'WORK_POLICY',NULL,'2026-08-12 17:26:30'),(11,'WORK_TARGET',NULL,'2026-08-12 17:26:30'),(12,'FINANCE_DASHBOARD',NULL,'2026-08-12 17:26:30'),(13,'INVENTORY',NULL,'2026-08-12 17:26:30'),(14,'ASSETS',NULL,'2026-08-12 17:26:30'),(15,'PURCHASE_ORDERS',NULL,'2026-08-12 17:26:30'),(16,'TAX',NULL,'2026-08-12 17:26:30'),(17,'AUDIT_LOGS',NULL,'2026-08-12 17:26:30'),(18,'WORK_ASSIGNMENT',NULL,'2026-08-12 17:26:30'),(19,'LIVE_CHAT',NULL,'2026-08-12 17:26:30'),(20,'COMPLAINT',NULL,'2026-08-12 17:26:30'),(21,'LEADS',NULL,'2026-08-12 17:26:30');
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_sales_leads`
--

DROP TABLE IF EXISTS `field_sales_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `field_sales_leads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_by` int NOT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `alternate_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pincode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `business_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requirement` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('new','contacted','interested','not_interested','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'new',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `next_followup_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_sales_leads`
--

LOCK TABLES `field_sales_leads` WRITE;
/*!40000 ALTER TABLE `field_sales_leads` DISABLE KEYS */;
INSERT INTO `field_sales_leads` VALUES (1,25,'Recruweb','Phabindra Kumar Sah','9992785583',NULL,'ahaanshah680@gmail.com','Mullana,Ambala, Haryana','Ambala',NULL,NULL,'Recruweb','kjhgfds','new','olkijuyhgtfre',NULL,'2026-08-25 15:52:00','2026-08-25 15:52:00');
/*!40000 ALTER TABLE `field_sales_leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finance_expenses`
--

DROP TABLE IF EXISTS `finance_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finance_expenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `employee_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT '0.00',
  `expense_date` date DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'cash',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finance_expenses`
--

LOCK TABLES `finance_expenses` WRITE;
/*!40000 ALTER TABLE `finance_expenses` DISABLE KEYS */;
INSERT INTO `finance_expenses` VALUES (1,'Salary','rwdfssf',29,'suhani',0.00,'2026-09-08','ewwdcx','upi','2026-09-08 05:04:58','2026-09-08 05:04:58');
/*!40000 ALTER TABLE `finance_expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finance_revenue`
--

DROP TABLE IF EXISTS `finance_revenue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finance_revenue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` int DEFAULT NULL,
  `client_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT '0.00',
  `gst` decimal(12,2) DEFAULT '0.00',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finance_revenue`
--

LOCK TABLES `finance_revenue` WRITE;
/*!40000 ALTER TABLE `finance_revenue` DISABLE KEYS */;
INSERT INTO `finance_revenue` VALUES (1,1,'Acme Corp','INV-TEST-001','2026-08-10',NULL,118000.00,18000.00,'Pending','fddf','2026-09-08 05:05:10','2026-09-08 05:05:10');
/*!40000 ALTER TABLE `finance_revenue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forms`
--

DROP TABLE IF EXISTS `forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `form_type` enum('client','candidate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hr_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `openings` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salary` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employment_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills_required` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `joining_timeline` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qualification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `expected_salary` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferred_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resume_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_profile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notice_period` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_ctc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `call_status_id` int DEFAULT NULL,
  `interview_date` datetime DEFAULT NULL,
  `interview_time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `selection_date` datetime DEFAULT NULL,
  `joining_date` datetime DEFAULT NULL,
  `client_status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `client_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cv_file` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `joined` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `status` enum('PENDING','REVIEWED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_form_type` (`form_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forms`
--

LOCK TABLES `forms` WRITE;
/*!40000 ALTER TABLE `forms` DISABLE KEYS */;
INSERT INTO `forms` VALUES (1,'client',NULL,'Test Co','Test HR','test@verify.local','9999999999','QA','1','1 LPA','0','Remote','Full Time','none','NA','verification test',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-08-22 10:00:23','2026-08-22 10:00:23'),(2,'client',NULL,'Tech HR Solutions Pvt. Ltd.','Phabindra Kumar Sah','ahaanshah680@gmail.com','+919992785583','Fullstack','3','4-6','2','Noida, India','Full Time','djgwudf','Immediate joining','jhw3iuerty3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-08-22 10:01:25','2026-08-22 10:01:25'),(3,'candidate','Phabindra Kumar Sah',NULL,NULL,'ahaanshah680@gmail.com','+919992785583',NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL,NULL,'Ambala','B.TEch','React','5','Remote','luch','/uploads/undefined','Fullstack','English','15','6',NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-08-22 19:07:29','2026-08-22 19:07:29'),(4,'candidate','Aahan shah',NULL,NULL,'ahaanshah680@gmail.com','9992785583',NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL,NULL,'Ambala','B.TEch','React','5','Remote','Recruweb','/uploads/undefined','Fullstack','English','15','6',NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-08-25 14:28:30','2026-08-25 14:28:30'),(5,'client',NULL,'Recruweb','Aahan shah','ahaanshah680@gmail.com','+9779992785583','Fullstack','2','4-6','2','Noida, India','Full Time','MERN, Next.js','Immediate joining','recruweb',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-08-25 14:51:49','2026-08-25 14:51:49'),(6,'candidate','suhani',NULL,NULL,'suhanimittal1975@gmail.com','9588382137',NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL,NULL,'Noida','mca','React , node , sql','3','Banglore',NULL,'/uploads/undefined','Full stack developer','english , hindi ','15','2',NULL,NULL,NULL,NULL,NULL,'pending',NULL,NULL,'No','PENDING','2026-09-08 04:29:46','2026-09-08 04:29:46');
/*!40000 ALTER TABLE `forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `general_ledger`
--

DROP TABLE IF EXISTS `general_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `general_ledger` (
  `id` int NOT NULL AUTO_INCREMENT,
  `clientId` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('DEBIT','CREDIT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `general_ledger`
--

LOCK TABLES `general_ledger` WRITE;
/*!40000 ALTER TABLE `general_ledger` DISABLE KEYS */;
/*!40000 ALTER TABLE `general_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `holidays`
--

DROP TABLE IF EXISTS `holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `holidays` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holiday_date` date NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holidays`
--

LOCK TABLES `holidays` WRITE;
/*!40000 ALTER TABLE `holidays` DISABLE KEYS */;
INSERT INTO `holidays` VALUES (1,'Ganesh Chaturthi','2026-09-14',NULL,'2026-09-08 04:37:23');
/*!40000 ALTER TABLE `holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_documents`
--

DROP TABLE IF EXISTS `hr_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doc_type` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` int DEFAULT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `generated_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emailed_to` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Draft','Sent','Signed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Draft',
  `signed_by` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_at` datetime DEFAULT NULL,
  `signature_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_documents`
--

LOCK TABLES `hr_documents` WRITE;
/*!40000 ALTER TABLE `hr_documents` DISABLE KEYS */;
INSERT INTO `hr_documents` VALUES (1,'offer_letter',7,'HR Admin','Offer of Employment - Software Engineer','documents/offer_letter-HR_Admin-1786600969923.pdf','Super Admin',NULL,'2026-08-13 06:02:50','Draft',NULL,NULL,NULL),(2,'offer_letter',8,'Aarav Sharma','Offer of Employment - QA Engineer','documents/offer_letter-Aarav_Sharma-1786614306286.pdf','Super Admin',NULL,'2026-08-13 09:45:06','Signed','Test HR','2026-08-13 15:30:06','signatures/sig-1786614306284-574411.png'),(3,'experience_letter',8,'Aarav Sharma','Experience Certificate - Aarav Sharma','documents/experience_letter-Aarav_Sharma-1786614306517.pdf','Super Admin',NULL,'2026-08-13 09:45:06','Signed','Priya Verma','2026-08-13 15:30:06','signatures/sig-1786614306564-39886.png'),(4,'offer_letter',8,'Aarav Sharma','Offer of Employment - Backend Developer','documents/offer_letter-Aarav_Sharma-1786731845295.pdf','Admin',NULL,'2026-08-14 18:24:05','Draft',NULL,NULL,NULL),(6,'offer_letter',29,'suhani','Offer of Employment - Full stack developer','documents/offer_letter-suhani-1788842705942.pdf','Super Admin',NULL,'2026-09-08 04:45:06','Signed','suhani','2026-09-08 10:15:06','signatures/sig-1788842705940-68052.png');
/*!40000 ALTER TABLE `hr_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_robo_chat_logs`
--

DROP TABLE IF EXISTS `hr_robo_chat_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_robo_chat_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_label` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `confidence` decimal(4,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_robo_chat_logs`
--

LOCK TABLES `hr_robo_chat_logs` WRITE;
/*!40000 ALTER TABLE `hr_robo_chat_logs` DISABLE KEYS */;
INSERT INTO `hr_robo_chat_logs` VALUES (1,'anonymous','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.',0.88,'2026-08-13 02:42:55'),(2,'anonymous','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.',0.88,'2026-08-13 02:43:06'),(3,'anonymous','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.',0.88,'2026-08-13 02:49:49'),(4,'anonymous','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.',0.88,'2026-08-13 02:52:20'),(5,'anonymous','What is the WFH policy?','WFH is allowed up to 2 days a week with prior manager approval. Mark WFH status in the attendance system on those days.',0.63,'2026-08-13 03:09:04'),(6,'anonymous','hy','I don\'t have an answer for that in my knowledge base yet. Please email HR at hr@company.com, or ask me about: leave policy, salary, benefits, interviews, WFH, attendance, IT support, performance reviews, or the exit process.',0.00,'2026-08-13 03:09:45'),(7,'anonymous','How many paid leaves do I get?','Employees are entitled to 18 paid leaves per year: 12 casual/sick leaves and 6 earned leaves. Unused earned leaves carry forward to the next year (max 12).',1.00,'2026-08-13 03:09:51'),(8,'anonymous','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.',0.88,'2026-08-13 03:09:59'),(9,'anonymous','What is the WFH policy?','WFH is allowed up to 2 days a week with prior manager approval. Mark WFH status in the attendance system on those days.',0.63,'2026-08-13 03:10:02'),(10,'anonymous','What is the notice period?','The standard notice period is 60 days for confirmed employees and 30 days during probation. Relieving and experience letters are issued after full handover.',1.00,'2026-08-13 03:10:05'),(11,'anonymous','How do I mark attendance?','Use the Smart Attendance page in the Employee Portal. You can check in manually, via OTP, or via office WiFi verification. Remember to check out before leaving.',0.88,'2026-08-13 03:10:07'),(12,'anonymous','attendence','I don\'t have an answer for that in my knowledge base yet. Please email HR at hr@company.com, or ask me about: leave policy, salary, benefits, interviews, WFH, attendance, IT support, performance reviews, or the exit process.',0.00,'2026-08-13 03:10:31');
/*!40000 ALTER TABLE `hr_robo_chat_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_robo_faqs`
--

DROP TABLE IF EXISTS `hr_robo_faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_robo_faqs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `question` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `keywords` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_robo_faqs`
--

LOCK TABLES `hr_robo_faqs` WRITE;
/*!40000 ALTER TABLE `hr_robo_faqs` DISABLE KEYS */;
INSERT INTO `hr_robo_faqs` VALUES (1,'Leave Policy','How many paid leaves do I get per year?','Employees are entitled to 18 paid leaves per year: 12 casual/sick leaves and 6 earned leaves. Unused earned leaves carry forward to the next year (max 12).','leave,paid,casual,sick,earned,holiday,vacation,carry','2026-08-13 02:28:39'),(2,'Leave Policy','How do I apply for leave?','Apply for leave from your Employee Portal dashboard. Your manager approves first, then HR confirms. Apply at least 2 working days in advance for planned leave.','apply,leave,application,request,manager,approval','2026-08-13 02:28:39'),(3,'Salary & Benefits','When is salary credited?','Salary is credited on the 1st working day of every month. Payslips are available for download in the Employee Portal under Payroll.','salary,credited,payday,payslip,payment,month','2026-08-13 02:28:39'),(4,'Salary & Benefits','What benefits does the company provide?','Benefits include health insurance for you and dependents, provident fund (PF), ESIC where applicable, performance incentives, and an annual bonus as per policy.','benefits,insurance,pf,esic,bonus,incentive,health','2026-08-13 02:28:39'),(5,'Interview Process','What is the interview process?','The pipeline is: Applied -> Screening -> Interview -> Shortlisted -> Selected -> Offer -> Joined. Technical rounds are followed by an HR discussion.','interview,process,rounds,pipeline,screening,shortlist,offer','2026-08-13 02:28:39'),(6,'Work from Home','What is the work from home policy?','WFH is allowed up to 2 days a week with prior manager approval. Mark WFH status in the attendance system on those days.','wfh,work from home,remote,hybrid,home','2026-08-13 02:28:39'),(7,'Attendance','How do I mark my attendance?','Use the Smart Attendance page in the Employee Portal. You can check in manually, via OTP, or via office WiFi verification. Remember to check out before leaving.','attendance,check in,check out,mark,otp,wifi,smart','2026-08-13 02:28:39'),(8,'Code of Conduct','What is the dress code?','Business casual from Monday to Thursday. Friday is casual dress day. Client-facing meetings require formal attire.','dress,code,attire,formal,casual,clothes','2026-08-13 02:28:39'),(9,'IT Support','How do I get IT support?','Raise a ticket from the Complaint/Support section of your portal, or email itsupport@company.com. Critical issues are addressed within 4 business hours.','it,support,laptop,ticket,computer,password,reset,system','2026-08-13 02:28:39'),(10,'Performance Review','How often are performance reviews held?','Performance reviews happen twice a year: mid-year (June) and annual (December). Ratings feed into increments and promotions.','performance,review,appraisal,rating,increment,promotion','2026-08-13 02:28:39'),(11,'Exit Process','What is the notice period?','The standard notice period is 60 days for confirmed employees and 30 days during probation. Relieving and experience letters are issued after full handover.','notice,period,resign,exit,relieving,experience,quit','2026-08-13 02:28:39'),(12,'Exit Process','How do I resign?','Submit your resignation through the Employee Portal or email your manager and HR. The exit workflow covers handover, asset return, and final settlement within 45 days after the last working day.','resign,resignation,quit,exit,settlement,handover','2026-08-13 02:28:39');
/*!40000 ALTER TABLE `hr_robo_faqs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_verification`
--

DROP TABLE IF EXISTS `identity_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_verification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `aadhaar_masked` varchar(20) DEFAULT NULL,
  `pan_masked` varchar(20) DEFAULT NULL,
  `aadhaar_status` varchar(50) DEFAULT NULL,
  `pan_status` varchar(50) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `ix_identity_verification_id` (`id`),
  CONSTRAINT `identity_verification_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_verification`
--

LOCK TABLES `identity_verification` WRITE;
/*!40000 ALTER TABLE `identity_verification` DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_verification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `internal_messages`
--

DROP TABLE IF EXISTS `internal_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `internal_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_type` enum('hr','it','superadmin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_id` int NOT NULL DEFAULT '0',
  `recipient_id` int DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_room` (`room`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `internal_messages`
--

LOCK TABLES `internal_messages` WRITE;
/*!40000 ALTER TABLE `internal_messages` DISABLE KEYS */;
INSERT INTO `internal_messages` VALUES (1,'hr-superadmin','superadmin',1,NULL,'Hello HR, this is Superadmin','2026-08-14 03:27:08'),(2,'hr-superadmin','hr',7,NULL,'Hi Superadmin, HR here','2026-08-14 03:27:08'),(3,'hr-it','hr',7,NULL,'Hello IT, HR here','2026-08-14 03:27:08'),(4,'hr-it','it',7,NULL,'HR team, IT received your message','2026-08-14 03:27:08'),(5,'hr-it','hr',15,NULL,'hy','2026-08-14 13:06:37'),(6,'hr-it','it',10,NULL,'hy','2026-08-14 13:06:53'),(7,'hr-it','hr',28,NULL,'hi','2026-09-08 06:48:15'),(8,'hr-it','it',25,NULL,'hi sir','2026-09-08 07:22:53'),(9,'hr-it','it',25,NULL,'Hi','2026-09-08 14:33:11'),(10,'hr-it:20','it',25,20,'hi','2026-09-09 08:44:20'),(11,'hr-it:28','it',25,28,'hi','2026-09-09 09:10:42'),(12,'hr-it:28','it',25,28,'hi','2026-09-09 09:50:00'),(13,'hr-it:28:25','hr',28,25,'hi','2026-09-10 05:11:02');
/*!40000 ALTER TABLE `internal_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `international_verification`
--

DROP TABLE IF EXISTS `international_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `international_verification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `country_code` varchar(5) DEFAULT NULL,
  `country_name` varchar(80) DEFAULT NULL,
  `doc_type` varchar(40) DEFAULT NULL,
  `doc_label` varchar(120) DEFAULT NULL,
  `doc_masked` varchar(40) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `ix_international_verification_id` (`id`),
  CONSTRAINT `international_verification_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `international_verification`
--

LOCK TABLES `international_verification` WRITE;
/*!40000 ALTER TABLE `international_verification` DISABLE KEYS */;
/*!40000 ALTER TABLE `international_verification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `interview_rounds`
--

DROP TABLE IF EXISTS `interview_rounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interview_rounds` (
  `id` varchar(64) NOT NULL,
  `company_id` varchar(64) NOT NULL,
  `job_id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `round_number` int NOT NULL,
  `round_type` enum('AI_SCREENING','TECHNICAL_ROBOTICS','SOFTWARE_SYSTEMS','PRACTICAL_OPERATIONS','GENERAL_APTITUDE','HR_BEHAVIORAL','LEADERSHIP_PROBLEM_SOLVING') NOT NULL,
  `time_limit_minutes` int NOT NULL,
  `passing_score` decimal(5,2) NOT NULL,
  `allow_retake` tinyint(1) NOT NULL,
  `proctoring_strictness` enum('STANDARD','STRICT','MILITARY_GRADE') NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `idx_rounds_job` (`job_id`),
  CONSTRAINT `interview_rounds_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `interview_rounds_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `interview_rounds`
--

LOCK TABLES `interview_rounds` WRITE;
/*!40000 ALTER TABLE `interview_rounds` DISABLE KEYS */;
/*!40000 ALTER TABLE `interview_rounds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int DEFAULT '0',
  `price` decimal(10,2) DEFAULT '0.00',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mrp` decimal(10,2) DEFAULT '0.00',
  `discount_price` decimal(10,2) DEFAULT '0.00',
  `gst_percent` decimal(5,2) DEFAULT '0.00',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (2,10,'mouse',269,6756.00,'hgg',6543.00,876.00,62.00,'2026-08-25 14:22:55','2026-08-25 14:22:55'),(3,19,'Speaker',20,1500.00,'Electronics',2000.00,2000.00,18.00,'2026-09-08 06:03:11','2026-09-08 06:03:11');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` int DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hsn_sac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gst_rate` decimal(5,2) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `rate` decimal(10,2) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `invoice_items_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
INSERT INTO `invoice_items` VALUES (1,1,'Recruitment fee - Senior Dev','998519',NULL,1,100000.00,100000.00),(2,2,'ugsuydtfse','4538',18.00,1,5453.00,5453.00),(3,3,'ugsuydtfse','4538',18.00,1,7867.00,7867.00),(4,4,'ugsuydtfse','4538',18.00,1,7654.00,7654.00);
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `invoice_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `client_gstin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `reference_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `terms_of_payment` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `buyers_order_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `terms_of_delivery` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `taxable_amount` decimal(10,2) DEFAULT NULL,
  `cgst` decimal(10,2) DEFAULT NULL,
  `sgst` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `amount_in_words` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `due_date` date DEFAULT NULL,
  `paid_amount` decimal(12,2) DEFAULT '0.00',
  `paid_date` date DEFAULT NULL,
  `receipt_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `upi_id` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  KEY `idx_invoices_client` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,NULL,'INV-TEST-001','Acme Corp','Pune, MH','27ABCDE1234F1Z5','Maharashtra','27','2026-08-10','REF-1','Net 15','PO-9','NA',100000.00,9000.00,9000.00,118000.00,'One Lakh Eighteen Thousand Only','2026-08-13 06:36:36','Overdue','2026-08-11',0.00,NULL,NULL,'acmebiz@upi',NULL),(2,NULL,'INV-1787393541670','Ahaa n','Noida','8y278354827635',NULL,NULL,'2026-08-22',NULL,NULL,NULL,NULL,5453.00,490.77,490.77,6434.54,NULL,'2026-08-22 10:12:21','Pending',NULL,0.00,NULL,NULL,NULL,NULL),(3,NULL,'INV-1787393730625','Ahaa n','Noida','8y278354827635',NULL,NULL,'2026-08-22',NULL,NULL,NULL,NULL,7867.00,708.03,708.03,9283.06,NULL,'2026-08-22 10:15:30','Pending',NULL,0.00,NULL,NULL,NULL,NULL),(4,25,'INV-1787672926745','Test','Noida','8y278354827635',NULL,NULL,'2026-08-25',NULL,NULL,NULL,NULL,7654.00,688.86,688.86,9031.72,NULL,'2026-08-25 15:48:46','Pending',NULL,0.00,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_bugs`
--

DROP TABLE IF EXISTS `it_bugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_bugs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `severity` enum('Low','Medium','High','Critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `status` enum('Open','In Progress','Fixed','Closed','Reopened') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Open',
  `reported_by` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `project` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_bugs`
--

LOCK TABLES `it_bugs` WRITE;
/*!40000 ALTER TABLE `it_bugs` DISABLE KEYS */;
INSERT INTO `it_bugs` VALUES (1,'Test Bug - Login button misaligned on mobile','Dummy test bug created during portal verification. Steps: 1) Open login page on mobile. 2) Observe login button. Expected: centered. Actual: shifted right.','Medium','Open',19,NULL,'HRMS Test Project','2026-08-23 10:04:36','2026-08-23 10:04:36'),(2,'DUMMY bug - payroll rounding','dummy','High','Fixed',26,NULL,'HRMS','2026-09-03 09:33:43','2026-09-03 10:46:36'),(3,'DUMMY bug - payroll rounding','dummy','High','Fixed',26,NULL,'HRMS','2026-09-03 09:33:55','2026-09-03 09:35:53'),(4,'Ardhnariswar','backend not working api error ','High','Open',25,25,'ardhnarishwar website','2026-09-08 14:23:44','2026-09-08 14:23:44');
/*!40000 ALTER TABLE `it_bugs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_code_reviews`
--

DROP TABLE IF EXISTS `it_code_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_code_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pr_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pr_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_id` int DEFAULT NULL,
  `author_id` int DEFAULT NULL,
  `reviewer_id` int DEFAULT NULL,
  `status` enum('Open','Changes Requested','Approved','Merged') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Open',
  `comments` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_code_reviews`
--

LOCK TABLES `it_code_reviews` WRITE;
/*!40000 ALTER TABLE `it_code_reviews` DISABLE KEYS */;
INSERT INTO `it_code_reviews` VALUES (1,'HRMS','https://github.com/Ahaan99/HRMS_PROJECTs',NULL,25,19,'Merged',NULL,'2026-09-03 09:13:05','2026-09-03 09:21:17'),(2,'DUMMY PR - refactor login','https://github.com/example/hrms/pull/999',NULL,26,26,'Merged',NULL,'2026-09-03 09:35:04','2026-09-03 09:35:04'),(3,'FLOW PR','https://github.com/x/y/pull/1',4,26,26,'Merged',NULL,'2026-09-03 09:57:55','2026-09-03 10:03:56'),(4,'Ardhnarishwar website','http://localhost:5177/it/code-reviews',7,25,29,'Open','dewwewwe  v','2026-09-08 14:13:21','2026-09-09 10:07:57'),(5,'aaddasf','http://localhost:5177/it/code-reviews',9,25,7,'Approved',NULL,'2026-09-09 09:07:50','2026-09-09 09:08:12');
/*!40000 ALTER TABLE `it_code_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_daily_work`
--

DROP TABLE IF EXISTS `it_daily_work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_daily_work` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `work_date` date NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours_spent` decimal(4,1) DEFAULT '0.0',
  `blockers` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_emp_date` (`employee_id`,`work_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_daily_work`
--

LOCK TABLES `it_daily_work` WRITE;
/*!40000 ALTER TABLE `it_daily_work` DISABLE KEYS */;
INSERT INTO `it_daily_work` VALUES (1,26,'2026-09-03','V0 verify daily work redesign',8.0,'Waiting on staging DB access','2026-09-03 09:35:04'),(4,25,'2026-09-08','qwwerrf f fv',8.0,'ffe ff','2026-09-08 07:18:33'),(6,25,'2026-09-09','asdaadad',8.0,'adaddadada','2026-09-09 09:06:30');
/*!40000 ALTER TABLE `it_daily_work` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_deliverables`
--

DROP TABLE IF EXISTS `it_deliverables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_deliverables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` enum('video','project_report','source_code') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint NOT NULL DEFAULT '0',
  `uploaded_by` int DEFAULT NULL,
  `uploaded_by_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_deliverables`
--

LOCK TABLES `it_deliverables` WRITE;
/*!40000 ALTER TABLE `it_deliverables` DISABLE KEYS */;
INSERT INTO `it_deliverables` VALUES (11,'source_code','testing','fghj','uploads\\deliverables\\1788429349286-627757763.zip','HRMS_PROJECTs-main.zip',11261268,25,'EMP5182','2026-09-03 09:55:49'),(12,'project_report','task','fghj','uploads\\deliverables\\1788434048387-398131978.pdf','OfferLetter-Ak.pdf',4926,25,'EMP5182','2026-09-03 11:14:08'),(13,'video','HRmS','updated HRmS video screen recording','uploads\\deliverables\\1788877815893-483796574.mp4','Screen Recording 2026-09-08 152739.mp4',194168941,25,'EMP5182','2026-09-08 14:30:18'),(14,'project_report','HRmS portal','ewsvs svfv','uploads\\deliverables\\1788877945700-352548281.pdf','HRMS_Production_Deployment_Guide_With_Screenshots.pdf',1333593,25,'EMP5182','2026-09-08 14:32:25'),(15,'video','sssa','ssaasas','uploads\\deliverables\\1788944951211-499830154.mp4','Screen Recording 2026-09-08 152739.mp4',194168941,25,'EMP5182','2026-09-09 09:09:13'),(16,'project_report','aswrs','dsfsfsf','uploads\\deliverables\\1788944995134-15779041.pdf','Suhani_Mittal_Resume.pdf',99404,25,'EMP5182','2026-09-09 09:09:55'),(17,'source_code','saaasa','dadaadad','uploads\\deliverables\\1788945025429-85749558.zip','IT_DAILY_WORK_CARD_LAYOUT_FIX_V2 (1).zip',12001,25,'EMP5182','2026-09-09 09:10:25');
/*!40000 ALTER TABLE `it_deliverables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_milestones`
--

DROP TABLE IF EXISTS `it_milestones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_milestones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `milestone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_date` date DEFAULT NULL,
  `progress` int DEFAULT '0',
  `status` enum('Not Started','On Track','At Risk','Delayed','Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Not Started',
  `owner_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_milestones`
--

LOCK TABLES `it_milestones` WRITE;
/*!40000 ALTER TABLE `it_milestones` DISABLE KEYS */;
INSERT INTO `it_milestones` VALUES (1,'HRMS','DUMMY milestone - Q3 release','dummy','2026-09-30',5,'On Track',26,'2026-09-03 09:35:04','2026-09-09 09:08:35');
/*!40000 ALTER TABLE `it_milestones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_tasks`
--

DROP TABLE IF EXISTS `it_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `project` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `priority` enum('Low','Medium','High','Critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `status` enum('To Do','In Progress','Review','Done') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'To Do',
  `due_date` date DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_by_label` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_tasks`
--

LOCK TABLES `it_tasks` WRITE;
/*!40000 ALTER TABLE `it_tasks` DISABLE KEYS */;
INSERT INTO `it_tasks` VALUES (5,'UI task assigned by Super Admin',NULL,'HRMS',26,'Medium','In Progress',NULL,NULL,'Super Admin','2026-09-03 10:02:05','2026-09-09 08:33:01'),(6,'Full stack developer','sdss d cccx ccx  ','hrms',29,'Low','Done','2026-09-12',NULL,'Super Admin','2026-09-08 04:46:24','2026-09-08 07:18:11'),(7,'ardhnarishwar website','ddfefd  w j e je jec ej f','ardhnarishwar website ',25,'Low','Review','2026-09-25',NULL,'Super Admin','2026-09-08 13:57:42','2026-09-08 14:13:21'),(8,'AI Chatbot','wefwwejebwwcj  icb  w  w w wdu wd dw wduw  w','Ai chat bot',25,'High','In Progress','2026-09-15',NULL,'Super Admin','2026-09-09 08:34:13','2026-09-09 08:34:27'),(9,'ssg','sdsds','dsdfsdv',25,'Low','Review','2026-09-10',NULL,'Super Admin','2026-09-09 09:06:07','2026-09-09 09:07:50');
/*!40000 ALTER TABLE `it_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `it_timesheets`
--

DROP TABLE IF EXISTS `it_timesheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `it_timesheets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `entry_date` date NOT NULL,
  `project` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hours` decimal(4,1) NOT NULL,
  `notes` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `it_timesheets`
--

LOCK TABLES `it_timesheets` WRITE;
/*!40000 ALTER TABLE `it_timesheets` DISABLE KEYS */;
INSERT INTO `it_timesheets` VALUES (1,26,'2026-09-03','HRMS','DUMMY timesheet task',6.5,'dummy','2026-09-03 09:35:04'),(2,25,'2026-09-03','Sales','Sales portal',6.0,'nothing','2026-09-03 09:51:36'),(3,25,'2026-09-08','Ardhnarishwar website','frontend',8.0,NULL,'2026-09-08 14:11:27'),(4,25,'2026-09-09','dada','adadad',9.0,'dsddsd','2026-09-09 09:07:00');
/*!40000 ALTER TABLE `it_timesheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_applications`
--

DROP TABLE IF EXISTS `job_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_post_id` int NOT NULL,
  `applicant_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resume_text` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `parsed_skills` varchar(600) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parsed_experience` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parsed_education` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ats_score` int DEFAULT '0',
  `status` enum('NEW','SHORTLISTED','REJECTED','CONVERTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'NEW',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post` (`job_post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_applications`
--

LOCK TABLES `job_applications` WRITE;
/*!40000 ALTER TABLE `job_applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_board_posts`
--

DROP TABLE IF EXISTS `job_board_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_board_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_type` enum('Full-time','Part-time','Contract','Internship') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Full-time',
  `salary_range` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `keywords` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('OPEN','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_board_posts`
--

LOCK TABLES `job_board_posts` WRITE;
/*!40000 ALTER TABLE `job_board_posts` DISABLE KEYS */;
INSERT INTO `job_board_posts` VALUES (1,'Frontend','CSE','Noida','Full-time','4-6','We are looking for a skilled Frontend Developer with strong experience in React.js, JavaScript, HTML, CSS, and modern frontend tools.\nYou will be responsible for building responsive user interfaces, integrating with APIs, and delivering high quality web applications.','react, node','OPEN','2026-08-14 09:51:16'),(2,'Fullstack','CSE','Noida','Full-time','5-7','no','MERN','OPEN','2026-08-25 14:54:33'),(3,'Software Developer','IT','Noida','Full-time','200000','aasscdd d  ','react , nodev, javascript,python','OPEN','2026-09-08 04:41:22');
/*!40000 ALTER TABLE `job_board_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_positions`
--

DROP TABLE IF EXISTS `job_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_positions`
--

LOCK TABLES `job_positions` WRITE;
/*!40000 ALTER TABLE `job_positions` DISABLE KEYS */;
INSERT INTO `job_positions` VALUES (1,'Frontend','2026-08-21 05:55:56'),(2,'Frontend Developer','2026-08-24 15:11:44'),(3,'Backend Developer','2026-08-24 15:11:44'),(4,'Full Stack Developer','2026-08-24 15:11:44'),(5,'Mobile App Developer','2026-08-24 15:11:44'),(6,'UI/UX Designer','2026-08-24 15:11:44'),(7,'QA Engineer','2026-08-24 15:11:44'),(8,'DevOps Engineer','2026-08-24 15:11:44'),(9,'Data Analyst','2026-08-24 15:11:44'),(10,'HR Executive','2026-08-24 15:11:44'),(11,'HR Manager','2026-08-24 15:11:44'),(12,'Sales Executive','2026-08-24 15:11:44'),(13,'Business Development Executive','2026-08-24 15:11:44'),(14,'Digital Marketing Executive','2026-08-24 15:11:44'),(15,'Content Writer','2026-08-24 15:11:44'),(16,'Graphic Designer','2026-08-24 15:11:44'),(17,'Accountant','2026-08-24 15:11:44'),(18,'Operations Executive','2026-08-24 15:11:44'),(19,'Customer Support Executive','2026-08-24 15:11:44'),(20,'Team Lead','2026-08-24 15:11:44'),(21,'Project Manager','2026-08-24 15:11:44'),(22,'Fullstack','2026-08-25 14:16:05'),(23,'Full stack developer','2026-09-08 04:30:38');
/*!40000 ALTER TABLE `job_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` varchar(64) NOT NULL,
  `company_id` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `department` varchar(150) NOT NULL,
  `location` varchar(255) NOT NULL,
  `job_type` enum('FULL_TIME','CONTRACT','REMOTE','HYBRID') NOT NULL,
  `experience_level` enum('ENTRY','MID','SENIOR','LEAD','PRINCIPAL') NOT NULL,
  `skill_category` varchar(32) NOT NULL,
  `description` text NOT NULL,
  `required_skills` json NOT NULL,
  `status` enum('OPEN','CLOSED','DRAFT') NOT NULL,
  `total_applicants` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_jobs_company_status` (`company_id`,`status`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `joining_forms`
--

DROP TABLE IF EXISTS `joining_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `joining_forms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hr_id` int NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `father_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marital_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `blood_group` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alt_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `present_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `present_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `present_state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `present_pincode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qualification10` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `board10` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year10` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `percent10` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_experience` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_salary` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_holder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ifsc` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `branch` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_relation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `father_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `father_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mother_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mother_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mother_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `qualification12` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `board12` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year12` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `percent12` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marksheet10` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marksheet12` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qualification_grad` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `university_grad` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_grad` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialization_grad` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_type_grad` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_year_grad` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year_grad` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passing_year_grad` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `percent_grad` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marksheet_grad` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qualification_pg` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `university_pg` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_pg` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialization_pg` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_type_pg` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_year_pg` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year_pg` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passing_year_pg` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `percent_pg` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marksheet_pg` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joining_forms`
--

LOCK TABLES `joining_forms` WRITE;
/*!40000 ALTER TABLE `joining_forms` DISABLE KEYS */;
INSERT INTO `joining_forms` VALUES (7,25,'RAm','Shyam','2026-08-25','Male','Single','b','Indian','9877665544','7865984455','abcde@gmail.com','Mullana,Ambala, Haryana','Ambala','Haryana','133207','GEneral','CBSE','2020','100','Fresher',NULL,NULL,NULL,NULL,'RAm','sbi','88997766554433','SBIN112233','State bank on india','parents','Family','9992785583','busines','9999999999','radha','husewife','8899776655','/uploads/profile/1787667282996-918136273.jpeg','/uploads/signature/1787667283002-947992615.png','2026-08-25 14:14:43','2026-08-25 14:14:43',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(8,28,'sonia','sanjeev','2003-10-08','Female','Single','B+VE','Indian','9588382137','8168468321','advay708@gmail.com','yamuna nagar','noida','UP','135001','Secondary education ','CBSE','2019','77','Fresher',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'rekha','Sister','8168468321','NA','9354182710','Rekha','Teacher','9068945592','/uploads/profile/1788849850347-396980213.jpg','/uploads/signature/1788849850348-693196915.jpg','2026-09-08 06:44:10','2026-09-08 06:44:10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,28,'sanvi','sanjeev','2003-10-08','Female','Single','A+','Indian','9588382137','8168468321','sanvi@gmail.com','rbfffdd',NULL,'haryana','135001','Swami vivekanad public school ','CBSE','2019','77','Fresher',NULL,NULL,NULL,NULL,'suhani','Bank of baroda','7015156325','PUNB00221R','Yamuna nagar',NULL,'Brother','8168468321','NA','9354182710','Rekha','Teacher','9068945592','/uploads/profile/1789017375814-991465809.jpg','/uploads/signature/1789017375815-701050039.jpg','2026-09-10 05:16:15','2026-09-10 05:16:15','swami vivekanad public school','CBSE','2019','77','/uploads/joining-docs/1789017375793-633843942.pdf','/uploads/joining-docs/1789017375800-538380939.pdf','B.Com','mm','mm','IT','Regular','2021',NULL,'2024','65','/uploads/joining-docs/1789017375808-251242807.pdf','MCA','mm','mm','IT','Regular','2024',NULL,'2026','84','/uploads/joining-docs/1789017375811-721075468.pdf');
/*!40000 ALTER TABLE `joining_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (6,'Bengali'),(1,'English'),(4,'Gujarati'),(2,'Hindi'),(9,'Kannada'),(18,'Korean'),(10,'Malayalam'),(3,'Marathi'),(12,'Odia'),(5,'Punjabi'),(7,'Tamil'),(8,'Telugu'),(11,'Urdu');
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lead_batches`
--

DROP TABLE IF EXISTS `lead_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lead_batches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_records` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lead_batches`
--

LOCK TABLES `lead_batches` WRITE;
/*!40000 ALTER TABLE `lead_batches` DISABLE KEYS */;
INSERT INTO `lead_batches` VALUES (1,'Book1.xlsx',14,28,1,'2026-09-08 06:36:54'),(2,'Leads_Assignment_Excel_Sheet.xlsx',100,29,1,'2026-09-10 06:39:42');
/*!40000 ALTER TABLE `lead_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leads`
--

DROP TABLE IF EXISTS `leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `batch_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_date` datetime DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `leads_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `lead_batches` (`id`),
  CONSTRAINT `leads_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leads`
--

LOCK TABLES `leads` WRITE;
/*!40000 ALTER TABLE `leads` DISABLE KEYS */;
INSERT INTO `leads` VALUES (1,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(2,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(3,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(4,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(5,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(6,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(7,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(8,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(9,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(10,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(11,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(12,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(13,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(14,NULL,NULL,1,28,1,'2026-09-08 12:06:55',NULL,NULL,'pending',1,'2026-09-08 06:36:54','2026-09-08 06:36:54'),(15,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(16,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(17,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(18,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(19,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(20,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(21,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(22,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(23,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(24,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(25,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(26,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(27,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(28,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(29,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(30,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(31,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(32,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(33,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(34,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(35,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(36,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(37,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(38,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(39,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(40,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(41,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(42,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(43,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(44,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(45,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(46,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(47,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(48,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(49,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(50,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(51,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(52,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(53,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(54,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(55,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(56,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(57,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(58,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(59,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(60,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(61,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(62,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(63,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(64,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(65,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(66,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(67,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(68,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(69,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(70,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(71,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(72,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(73,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(74,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(75,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(76,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(77,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(78,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(79,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(80,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(81,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(82,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(83,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(84,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(85,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(86,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(87,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(88,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(89,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(90,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(91,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(92,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(93,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(94,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(95,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(96,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(97,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(98,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(99,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(100,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(101,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(102,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(103,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(104,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(105,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(106,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(107,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(108,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(109,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(110,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(111,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(112,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(113,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42'),(114,NULL,NULL,2,29,1,'2026-09-10 12:09:43',NULL,NULL,'pending',1,'2026-09-10 06:39:42','2026-09-10 06:39:42');
/*!40000 ALTER TABLE `leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_applications`
--

DROP TABLE IF EXISTS `leave_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `days` decimal(5,1) NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('Pending','Approved','Rejected','Cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `approver_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_applications`
--

LOCK TABLES `leave_applications` WRITE;
/*!40000 ALTER TABLE `leave_applications` DISABLE KEYS */;
INSERT INTO `leave_applications` VALUES (1,8,1,'2026-06-13','2026-06-13',1.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(2,9,2,'2026-07-04','2026-07-06',3.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(3,10,3,'2026-03-13','2026-03-17',5.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(4,11,1,'2026-07-24','2026-07-25',2.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(5,12,2,'2025-12-13','2025-12-13',1.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(6,13,5,'2026-08-03','2026-08-04',2.0,'DEMO leave','Rejected',NULL,'Super Admin','2026-08-13 07:13:50','2026-08-21 07:35:37'),(7,14,4,'2026-05-13','2026-05-13',1.0,'DEMO leave','Approved',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(8,15,1,'2026-08-07','2026-08-07',1.0,'DEMO leave','Rejected',NULL,'HR Admin','2026-08-13 07:13:50','2026-08-13 07:13:50'),(16,8,1,'2026-08-20','2026-08-21',2.0,'Mock test: family function leave request','Approved',NULL,'Super Admin','2026-08-13 14:39:45','2026-09-08 04:36:31'),(17,8,2,'2026-08-14','2026-08-16',2.0,NULL,'Rejected','no','Super Admin','2026-08-14 08:10:02','2026-08-25 14:53:06'),(18,19,2,'2026-08-21','2026-08-22',2.0,NULL,'Approved',NULL,'Super Admin','2026-08-21 07:33:17','2026-08-21 07:36:19'),(19,19,1,'2026-08-28','2026-08-29',2.0,'Dummy test leave created during portal verification','Approved',NULL,'Super Admin','2026-08-23 10:08:32','2026-08-25 14:52:59'),(20,28,1,'2026-09-08','2026-09-10',3.0,'ww','Approved',NULL,'Super Admin','2026-09-08 06:09:58','2026-09-08 06:18:35'),(21,29,1,'2026-09-09','2026-09-10',2.0,'rwre','Approved',NULL,'Super Admin','2026-09-09 17:01:19','2026-09-09 17:01:36');
/*!40000 ALTER TABLE `leave_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_balances`
--

DROP TABLE IF EXISTS `leave_balances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_balances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `year` int NOT NULL,
  `allocated` decimal(5,1) DEFAULT '0.0',
  `used` decimal(5,1) DEFAULT '0.0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_emp_type_year` (`employee_id`,`leave_type_id`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=2578 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES (1,8,1,2026,12.0,3.0),(2,8,2,2026,8.0,0.0),(3,8,3,2026,15.0,0.0),(4,8,4,2026,0.0,0.0),(5,8,5,2026,0.0,0.0),(238,19,1,2026,12.0,2.0),(239,19,2,2026,8.0,2.0),(240,19,3,2026,15.0,0.0),(241,19,4,2026,1.0,0.0),(242,19,5,2026,0.0,0.0),(410,10,1,2026,12.0,0.0),(411,10,2,2026,8.0,0.0),(412,10,3,2026,15.0,5.0),(413,10,4,2026,0.0,0.0),(414,10,5,2026,0.0,0.0),(597,25,1,2026,12.0,0.0),(598,25,2,2026,8.0,0.0),(599,25,3,2026,15.0,0.0),(600,25,4,2026,0.0,0.0),(601,25,5,2026,0.0,0.0),(767,7,1,2026,12.0,0.0),(768,7,2,2026,8.0,0.0),(769,7,3,2026,15.0,0.0),(770,7,4,2026,0.0,0.0),(771,7,5,2026,0.0,0.0),(792,27,1,2026,12.0,0.0),(793,27,2,2026,8.0,0.0),(794,27,3,2026,15.0,0.0),(795,27,4,2026,0.0,0.0),(796,27,5,2026,0.0,0.0),(892,28,1,2026,12.0,3.0),(893,28,2,2026,8.0,0.0),(894,28,3,2026,15.0,0.0),(895,28,4,2026,0.0,0.0),(896,28,5,2026,0.0,0.0),(1531,29,1,2026,12.0,2.0),(1532,29,2,2026,8.0,0.0),(1533,29,3,2026,15.0,0.0),(1534,29,4,2026,0.0,0.0),(1535,29,5,2026,0.0,0.0);
/*!40000 ALTER TABLE `leave_balances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `annual_quota` int DEFAULT '0',
  `is_paid` tinyint DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_types`
--

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
INSERT INTO `leave_types` VALUES (1,'Casual Leave',12,1,'2026-08-13 06:02:21'),(2,'Sick Leave',8,1,'2026-08-13 06:02:21'),(3,'Earned Leave',15,1,'2026-08-13 06:02:21'),(4,'Comp-Off',0,1,'2026-08-13 06:02:21'),(5,'Unpaid Leave',0,0,'2026-08-13 06:02:21');
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11367 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (1,'Delhi','2026-08-17 16:01:38'),(2,'Mumbai','2026-08-17 16:01:38'),(3,'Bengaluru','2026-08-17 16:01:38'),(4,'Hyderabad','2026-08-17 16:01:38'),(5,'Chennai','2026-08-17 16:01:38'),(6,'Pune','2026-08-17 16:01:38'),(7,'Kolkata','2026-08-17 16:01:38'),(8,'Ahmedabad','2026-08-17 16:01:38'),(9,'Jaipur','2026-08-17 16:01:38'),(10,'Noida','2026-08-17 16:01:38'),(11,'Gurugram','2026-08-17 16:01:38'),(12,'Indore','2026-08-17 16:01:38'),(13,'Lucknow','2026-08-17 16:01:38'),(14,'Chandigarh','2026-08-17 16:01:38'),(15,'Remote','2026-08-17 16:01:38'),(4716,'Haryana','2026-08-25 15:42:49');
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_logs`
--

DROP TABLE IF EXISTS `login_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Login',
  `status` enum('success','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'success',
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ll_time` (`timestamp`),
  KEY `idx_ll_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_logs`
--

LOCK TABLES `login_logs` WRITE;
/*!40000 ALTER TABLE `login_logs` DISABLE KEYS */;
INSERT INTO `login_logs` VALUES (2,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-08-23 07:13:52'),(3,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-23 07:13:59'),(4,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-23 07:16:59'),(5,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-23 09:29:11'),(6,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-23 09:46:27'),(7,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-24 05:40:51'),(8,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-24 14:23:10'),(9,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-25 13:59:14'),(10,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-25 14:01:03'),(11,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-25 14:02:44'),(12,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-27 03:38:19'),(13,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-29 02:14:03'),(14,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-31 06:20:02'),(15,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-08-31 07:56:18'),(16,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-01 03:12:35'),(17,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-01 03:19:56'),(18,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 06:19:22'),(19,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-02 07:38:07'),(20,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 07:38:08'),(21,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 07:38:24'),(22,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-02 07:46:50'),(23,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 07:46:51'),(24,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-02 09:22:14'),(25,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:23:28'),(26,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:31:52'),(27,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:36:03'),(28,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:56:50'),(29,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-02 09:57:03'),(30,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:57:03'),(31,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-02 09:57:48'),(32,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 09:57:48'),(33,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-02 18:33:49'),(34,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:30:26'),(35,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:32:49'),(36,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:33:07'),(37,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:41:13'),(38,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:41:41'),(39,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:57:55'),(40,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 09:59:41'),(41,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 10:40:40'),(42,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 13:05:16'),(43,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 13:08:01'),(44,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-03 13:22:53'),(45,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-04 02:19:53'),(46,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-04 02:20:07'),(47,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-04 02:20:07'),(48,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-04 02:20:08'),(49,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-04 02:20:40'),(50,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-04 02:20:40'),(51,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:30:48'),(52,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:33:24'),(53,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:38:34'),(54,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:38:55'),(55,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:39:48'),(56,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 07:55:51'),(57,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 07:58:00'),(58,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 07:58:45'),(59,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 07:59:30'),(60,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 08:00:00'),(61,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 08:00:19'),(62,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 08:50:23'),(63,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 09:15:37'),(64,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 09:34:02'),(65,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 09:56:22'),(66,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 09:57:04'),(67,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:04:39'),(68,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:05:23'),(69,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:05:42'),(70,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:05:57'),(71,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:06:40'),(72,'admin@hrms.com','SUPER_ADMIN','::1','Login','failed','2026-09-07 10:06:56'),(73,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 10:06:57'),(74,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 10:06:58'),(75,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 10:07:56'),(76,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 14:01:56'),(77,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 14:13:29'),(78,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 14:14:37'),(79,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-07 14:49:38'),(80,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 17:14:59'),(81,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 19:04:44'),(82,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-07 19:18:08'),(83,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-08 12:14:44'),(84,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-08 13:33:38'),(85,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-09 17:20:39'),(86,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-09 18:27:07'),(87,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-09 18:40:57'),(88,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-09 19:31:59'),(89,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-10 02:24:14'),(90,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-14 13:50:15'),(91,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-14 14:11:50'),(92,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-14 16:58:29'),(93,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-15 17:24:29'),(94,'admin@hrms.com','SUPER_ADMIN','::ffff:127.0.0.1','Login','success','2026-09-15 18:00:33'),(95,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-16 04:35:29'),(96,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-16 05:25:28'),(97,'admin@hrms.com','SUPER_ADMIN','::ffff:172.17.242.173','Login','success','2026-09-16 05:42:42'),(98,'admin@hrms.com','SUPER_ADMIN','::ffff:172.17.242.173','Login','success','2026-09-16 06:35:37'),(99,'admin@hrms.com','SUPER_ADMIN','::ffff:172.17.242.173','Login','success','2026-09-16 06:35:50'),(100,'admin@hrms.com','SUPER_ADMIN','::ffff:172.17.242.173','Login','success','2026-09-16 06:41:20'),(101,'admin@hrms.com','SUPER_ADMIN','::ffff:172.17.242.173','Login','success','2026-09-16 06:41:52'),(102,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-16 17:00:43'),(103,'admin@hrms.com','SUPER_ADMIN','::1','Login','success','2026-09-16 17:01:17');
/*!40000 ALTER TABLE `login_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_otps`
--

DROP TABLE IF EXISTS `login_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_otps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `portal` enum('hr','employee','client','sales','it') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `identifier` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `otp_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` int DEFAULT '0',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lookup` (`portal`,`identifier`,`used`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_otps`
--

LOCK TABLES `login_otps` WRITE;
/*!40000 ALTER TABLE `login_otps` DISABLE KEYS */;
INSERT INTO `login_otps` VALUES (1,'employee',8,'aarav@demo.hrms','800949',1,'2026-08-13 15:28:13',1,'2026-08-13 09:38:13'),(2,'employee',9,'9000000002','254016',0,'2026-08-13 15:28:13',0,'2026-08-13 09:38:13'),(3,'hr',7,'hr@hrms.com','660187',0,'2026-08-13 15:28:13',0,'2026-08-13 09:38:13'),(4,'client',1,'demo@democorp.test','168143',0,'2026-08-13 15:28:13',1,'2026-08-13 09:38:13'),(5,'hr',7,'hr@hrms.com','871790',0,'2026-08-13 15:44:37',1,'2026-08-13 09:54:37'),(6,'employee',9,'9000000002','720047',0,'2026-08-13 15:50:01',1,'2026-08-13 10:00:01'),(7,'sales',10,'rohan@demo.hrms','952785',0,'2026-08-13 15:53:23',1,'2026-08-13 10:03:23'),(8,'client',1,'demo@democorp.test','938327',0,'2026-08-13 15:53:55',1,'2026-08-13 10:03:55'),(9,'hr',7,'hr@hrms.com','225591',0,'2026-08-13 20:22:54',1,'2026-08-13 14:32:54'),(10,'employee',8,'aarav@demo.hrms','665805',0,'2026-08-13 20:28:27',1,'2026-08-13 14:38:27'),(11,'client',1,'demo@democorp.test','848460',0,'2026-08-13 20:30:35',1,'2026-08-13 14:40:35'),(12,'sales',10,'rohan@demo.hrms','626874',0,'2026-08-13 20:37:12',1,'2026-08-13 14:47:12'),(13,'sales',10,'rohan@demo.hrms','401662',0,'2026-08-13 20:38:58',1,'2026-08-13 14:48:58'),(14,'client',2,'ahaanshah680@gmail.com','319334',0,'2026-08-21 12:30:09',0,'2026-08-21 06:55:09'),(15,'client',2,'ahaanshah680@gmail.com','137788',0,'2026-08-21 12:31:09',0,'2026-08-21 06:56:09'),(16,'client',2,'ahaanshah680@gmail.com','803660',0,'2026-08-21 12:35:13',0,'2026-08-21 07:00:13'),(17,'client',2,'ahaanshah680@gmail.com','389202',0,'2026-08-21 12:40:59',1,'2026-08-21 07:05:59'),(18,'client',2,'ahaanshah680@gmail.com','455274',0,'2026-08-21 12:41:43',1,'2026-08-21 07:06:43'),(19,'client',2,'ahaanshah680@gmail.com','553871',0,'2026-08-21 12:49:27',0,'2026-08-21 07:14:27'),(20,'client',2,'ahaanshah680@gmail.com','236652',0,'2026-08-21 12:50:16',0,'2026-08-21 07:15:16'),(21,'client',2,'ahaanshah680@gmail.com','589119',0,'2026-08-21 12:52:55',0,'2026-08-21 07:17:55'),(22,'client',2,'ahaanshah680@gmail.com','134849',0,'2026-08-21 12:59:08',0,'2026-08-21 07:24:08'),(23,'client',2,'ahaanshah680@gmail.com','777638',0,'2026-08-21 12:59:22',0,'2026-08-21 07:24:22'),(24,'employee',19,'ahaanshah680@gmail.com','620642',0,'2026-08-21 12:59:55',1,'2026-08-21 07:24:55'),(25,'hr',19,'ahaanshah680@gmail.com','751641',0,'2026-08-21 13:00:34',0,'2026-08-21 07:25:34'),(26,'client',2,'ahaanshah680@gmail.com','374310',0,'2026-08-21 13:07:19',0,'2026-08-21 07:32:19'),(27,'client',2,'ahaanshah680@gmail.com','397375',0,'2026-08-21 13:08:30',1,'2026-08-21 07:33:30'),(28,'hr',19,'ahaanshah680@gmail.com','920403',0,'2026-08-21 13:11:56',1,'2026-08-21 07:36:56'),(29,'client',2,'ahaanshah680@gmail.com','440283',0,'2026-08-21 13:12:47',0,'2026-08-21 07:37:47'),(30,'client',2,'ahaanshah680@gmail.com','601244',0,'2026-08-21 13:20:16',0,'2026-08-21 07:45:16'),(31,'client',2,'ahaanshah680@gmail.com','893948',0,'2026-08-21 13:24:55',0,'2026-08-21 07:49:55'),(32,'client',2,'ahaanshah680@gmail.com','320435',0,'2026-08-21 13:26:47',0,'2026-08-21 07:51:47'),(33,'client',2,'ahaanshah680@gmail.com','456674',0,'2026-08-21 13:36:22',0,'2026-08-21 08:01:22'),(34,'client',2,'ahaanshah680@gmail.com','862547',0,'2026-08-21 13:36:48',0,'2026-08-21 08:01:48'),(35,'client',2,'ahaanshah680@gmail.com','966766',0,'2026-08-21 13:37:10',0,'2026-08-21 08:02:10'),(36,'client',2,'ahaanshah680@gmail.com','677669',0,'2026-08-21 13:45:01',0,'2026-08-21 08:10:01'),(37,'client',2,'ahaanshah680@gmail.com','825949',0,'2026-08-21 13:53:26',0,'2026-08-21 08:18:26'),(38,'client',2,'ahaanshah680@gmail.com','387811',0,'2026-08-21 13:56:09',0,'2026-08-21 08:21:09'),(39,'client',2,'ahaanshah680@gmail.com','182691',0,'2026-08-21 13:57:23',1,'2026-08-21 08:22:23'),(40,'hr',19,'ahaanshah680@gmail.com','749020',0,'2026-08-21 13:58:10',0,'2026-08-21 08:23:10'),(41,'client',2,'ahaanshah680@gmail.com','762739',0,'2026-08-22 14:09:47',0,'2026-08-22 08:34:47'),(42,'employee',19,'ahaanshah680@gmail.com','132227',0,'2026-08-22 14:29:25',0,'2026-08-22 08:54:25'),(43,'hr',20,'phabindrakumar777@gmail.com','779515',0,'2026-08-22 23:46:15',0,'2026-08-22 18:11:15'),(44,'hr',20,'phabindrakumar777@gmail.com','802595',2,'2026-08-23 13:49:52',1,'2026-08-23 08:14:52'),(45,'hr',20,'phabindrakumar777@gmail.com','318248',0,'2026-08-23 13:51:39',1,'2026-08-23 08:16:39'),(46,'it',20,'phabindrakumar777@gmail.com','405864',0,'2026-08-23 14:04:18',0,'2026-08-23 08:29:18'),(47,'it',19,'ahaanshah680@gmail.com','913008',5,'2026-08-23 14:04:31',0,'2026-08-23 08:29:31'),(48,'it',19,'ahaanshah680@gmail.com','233095',0,'2026-08-23 14:05:09',0,'2026-08-23 08:30:09'),(49,'hr',19,'ahaanshah680@gmail.com','574258',0,'2026-08-23 15:07:25',1,'2026-08-23 09:32:25'),(50,'hr',20,'phabindrakumar777@gmail.com','733311',0,'2026-08-23 15:11:41',0,'2026-08-23 09:36:41'),(51,'client',2,'ahaanshah680@gmail.com','549723',0,'2026-08-23 15:20:51',1,'2026-08-23 09:45:51'),(52,'it',19,'ahaanshah680@gmail.com','196491',0,'2026-08-23 15:35:57',1,'2026-08-23 10:00:57'),(53,'employee',19,'ahaanshah680@gmail.com','426795',0,'2026-08-23 15:41:12',1,'2026-08-23 10:06:12'),(54,'client',2,'ahaanshah680@gmail.com','676882',0,'2026-08-24 00:38:45',1,'2026-08-23 19:03:45'),(55,'client',6,'admin@test.com','588041',0,'2026-08-24 11:10:01',0,'2026-08-24 05:35:01'),(56,'client',8,'ahaanshah680@gmail.com','686262',1,'2026-08-24 11:18:26',1,'2026-08-24 05:43:26'),(57,'client',8,'ahaanshah680@gmail.com','165530',0,'2026-08-24 11:19:23',0,'2026-08-24 05:44:23'),(58,'hr',24,'abcd@gmail.com','117762',0,'2026-08-26 14:10:10',0,'2026-08-26 08:35:10'),(59,'hr',24,'abcd@gmail.com','796267',0,'2026-08-26 14:10:24',0,'2026-08-26 08:35:24'),(60,'client',11,'abcd@gmail.com','988813',0,'2026-08-29 08:06:02',0,'2026-08-29 02:16:02'),(61,'hr',21,'ahaanshah777@gmail.com','923148',0,'2026-09-01 18:08:51',0,'2026-09-01 12:18:51'),(62,'it',21,'ahaanshah777@gmail.com','624102',0,'2026-09-02 12:10:26',0,'2026-09-02 06:20:26'),(63,'client',16,'arav@gmail.com','166375',0,'2026-09-07 15:05:54',0,'2026-09-07 09:15:54'),(64,'client',19,'aryan@gmail.com','678409',0,'2026-09-09 21:13:41',0,'2026-09-09 15:38:41');
/*!40000 ALTER TABLE `login_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_settings`
--

DROP TABLE IF EXISTS `login_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `default_login_time` time DEFAULT NULL,
  `default_logout_time` time DEFAULT NULL,
  `grace_period` int DEFAULT '10',
  `late_threshold` int DEFAULT '15',
  `allow_late_login` tinyint(1) DEFAULT '1',
  `allow_early_logout` tinyint(1) DEFAULT '0',
  `overtime_approval_required` tinyint(1) DEFAULT '1',
  `flexi_hours_enabled` tinyint(1) DEFAULT '0',
  `flexi_start_time` time DEFAULT NULL,
  `flexi_end_time` time DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `half_day_threshold` int DEFAULT '240',
  `auto_present_enabled` tinyint(1) DEFAULT '1',
  `auto_absent_enabled` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_settings`
--

LOCK TABLES `login_settings` WRITE;
/*!40000 ALTER TABLE `login_settings` DISABLE KEYS */;
INSERT INTO `login_settings` VALUES (1,'09:00:00','17:00:00',15,15,1,0,1,0,'08:00:00','20:00:00','2026-08-25 15:41:20',240,1,0);
/*!40000 ALTER TABLE `login_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `managers`
--

DROP TABLE IF EXISTS `managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `managers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'manager',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managers`
--

LOCK TABLES `managers` WRITE;
/*!40000 ALTER TABLE `managers` DISABLE KEYS */;
INSERT INTO `managers` VALUES (1,'Manager','manager@hrms.com','$2b$10$mFcAR4gdTFhtQ6H52/wXqeu1QNFkLVG2yewu/mBYEwHX1C9II2u8W','manager',1,'2026-08-12 17:26:29');
/*!40000 ALTER TABLE `managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_logs`
--

DROP TABLE IF EXISTS `message_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `channel` enum('SMS','WHATSAPP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_key` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('SENT','SIMULATED','FAILED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_logs`
--

LOCK TABLES `message_logs` WRITE;
/*!40000 ALTER TABLE `message_logs` DISABLE KEYS */;
INSERT INTO `message_logs` VALUES (1,'SMS','+9779807754603','HRMS test: your Twilio SMS integration is live.',NULL,'FAILED','Twilio send failed','admin@hrms.com','2026-08-14 07:57:46'),(2,'WHATSAPP','+919992785583','hy',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 07:22:45'),(3,'WHATSAPP','+919992785583','hy',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 07:22:55'),(4,'SMS','+919992785583','hy',NULL,'FAILED','Twilio send failed','admin@hrms.com','2026-08-22 07:27:03'),(5,'SMS','+919992785583','HY',NULL,'FAILED','Twilio send failed','admin@hrms.com','2026-08-22 07:28:07'),(6,'WHATSAPP','+919992785583','HY',NULL,'FAILED','Twilio: No Twilio trial phone number is assigned for messaging to this destination number. Please add the \'to\' number as a verified recipient.','admin@hrms.com','2026-08-22 07:28:14'),(7,'SMS','+919992785583','HY',NULL,'FAILED','No Twilio trial phone number is assigned for messaging to this destination number. Please add the \'to\' number as a verified recipient. (code 572002)','admin@hrms.com','2026-08-22 07:30:36'),(8,'WHATSAPP','+919992785583','HY',NULL,'FAILED','Twilio: No Twilio trial phone number is assigned for messaging to this destination number. Please add the \'to\' number as a verified recipient.','admin@hrms.com','2026-08-22 07:30:48'),(9,'WHATSAPP','+919992785583','hy',NULL,'FAILED','CallMeBot: empty','admin@hrms.com','2026-08-22 08:01:30'),(10,'WHATSAPP','+919334554413','hy',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:02:38'),(11,'WHATSAPP','+9779807754603','hy',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:03:01'),(12,'WHATSAPP','+919992785583','hy',NULL,'FAILED','CallMeBot: empty','admin@hrms.com','2026-08-22 08:04:18'),(13,'WHATSAPP','+919992785583','hy',NULL,'FAILED','CallMeBot: empty','admin@hrms.com','2026-08-22 08:04:30'),(14,'SMS','+919992785583','hy',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:08:05'),(15,'SMS','+9193345 54413','krishna',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:08:45'),(16,'SMS','+9195883 82137','deploy hua',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:09:48'),(17,'WHATSAPP','+919588382137','deploy hua',NULL,'SENT',NULL,'admin@hrms.com','2026-08-22 08:11:04'),(18,'WHATSAPP','+919588382137','Acha g yrr phir toh is according karte rahe toh aaja vi nahi ho payega',NULL,'SENT',NULL,'admin@hrms.com','2026-08-22 08:12:38'),(19,'WHATSAPP','+919588382137','hy',NULL,'SENT',NULL,'admin@hrms.com','2026-08-22 08:15:51'),(20,'WHATSAPP','+9199334554413','features add hua',NULL,'FAILED','GreenAPI: Validation failed. Details: \'chatId\': invalid phone number','admin@hrms.com','2026-08-22 08:16:44'),(21,'WHATSAPP','+9193345 54413','features add hua',NULL,'FAILED','GreenAPI: HTTP 466','admin@hrms.com','2026-08-22 08:17:41'),(22,'WHATSAPP','+919334554413','features add hua',NULL,'FAILED','GreenAPI: HTTP 466','admin@hrms.com','2026-08-22 08:18:06'),(23,'WHATSAPP','+919334554413','hy',NULL,'FAILED','GreenAPI: HTTP 466','admin@hrms.com','2026-08-22 08:18:27'),(24,'SMS','+919334554413','features add hua',NULL,'SIMULATED',NULL,'admin@hrms.com','2026-08-22 08:23:03');
/*!40000 ALTER TABLE `message_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_templates`
--

DROP TABLE IF EXISTS `message_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_key` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` enum('SMS','WHATSAPP','BOTH') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'BOTH',
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_event` (`event_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_templates`
--

LOCK TABLES `message_templates` WRITE;
/*!40000 ALTER TABLE `message_templates` DISABLE KEYS */;
INSERT INTO `message_templates` VALUES (1,'Leave Approved','leave_approved','BOTH','Hi {{name}}, your {{leave_type}} leave from {{from_date}} to {{to_date}} has been APPROVED.',1,'2026-08-14 06:27:40'),(2,'Leave Rejected','leave_rejected','BOTH','Hi {{name}}, your {{leave_type}} leave request was REJECTED. Note: {{note}}',1,'2026-08-14 06:27:40'),(3,'Interview Scheduled','interview_scheduled','BOTH','Hi {{name}}, your interview for {{position}} is scheduled on {{date}} at {{time}}.',1,'2026-08-14 06:27:40'),(4,'Offer Letter Sent','offer_sent','BOTH','Congratulations {{name}}! Your offer letter for {{position}} has been sent to your email.',1,'2026-08-14 06:27:40'),(5,'Document Expiry','doc_expiry','BOTH','Reminder: document \'{{doc_name}}\' expires on {{expiry_date}}. Please renew it.',1,'2026-08-14 06:27:40'),(6,'Visitor Arrived','visitor_arrived','BOTH','{{visitor_name}} has arrived at reception to meet you. Purpose: {{purpose}}.',1,'2026-08-14 06:27:40');
/*!40000 ALTER TABLE `message_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `sender_type` enum('client','hr','ai','it') COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_id` int NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (17,20,'client',19,'hi','2026-09-08 05:59:52'),(18,21,'hr',28,'hi','2026-09-08 06:48:21'),(19,20,'hr',28,'hi','2026-09-08 06:48:25'),(20,26,'client',19,'HI','2026-09-09 13:52:45'),(21,26,'client',19,'HI','2026-09-09 13:55:21'),(22,20,'client',19,'hi','2026-09-09 15:59:17');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `audience` enum('ADMIN','EMPLOYEE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ADMIN',
  `user_id` int DEFAULT NULL,
  `type` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_aud` (`audience`,`user_id`,`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'ADMIN',NULL,'interview','Interview completed: Test Candidate','Frontend Developer — scored 9/10 (heuristic)','/dashboard/ai-recruit',1,'2026-08-13 09:15:29');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offer_letter_templates`
--

DROP TABLE IF EXISTS `offer_letter_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `offer_letter_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hr_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `terms` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `body` text COLLATE utf8mb4_unicode_ci,
  `include_ctc` tinyint(1) NOT NULL DEFAULT '1',
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offer_letter_templates`
--

LOCK TABLES `offer_letter_templates` WRITE;
/*!40000 ALTER TABLE `offer_letter_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `offer_letter_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offer_letters`
--

DROP TABLE IF EXISTS `offer_letters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `offer_letters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `candidate_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salary` decimal(12,2) DEFAULT '0.00',
  `joining_date` date DEFAULT NULL,
  `company_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hr_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `template_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offer_letters`
--

LOCK TABLES `offer_letters` WRITE;
/*!40000 ALTER TABLE `offer_letters` DISABLE KEYS */;
INSERT INTO `offer_letters` VALUES (4,'suhani','advay708@gmail.com','software developer','IT',20000.00,'2026-09-08','Tech HR Solutions Pvt. Ltd.','Head of Human Resources','Noida, India','2026-09-08 05:02:37',NULL);
/*!40000 ALTER TABLE `offer_letters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `office_locations`
--

DROP TABLE IF EXISTS `office_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `office_locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `radius_m` int DEFAULT '200',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_locations`
--

LOCK TABLES `office_locations` WRITE;
/*!40000 ALTER TABLE `office_locations` DISABLE KEYS */;
INSERT INTO `office_locations` VALUES (1,'Head Office',28.6139000,77.2090000,250,1,'2026-08-13 08:33:39'),(2,'Recruweb',30.1182539,77.2901494,200,1,'2026-09-08 04:48:46');
/*!40000 ALTER TABLE `office_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `overtime_requests`
--

DROP TABLE IF EXISTS `overtime_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `overtime_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `ot_date` date NOT NULL,
  `hours` decimal(4,2) NOT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `decided_by` varchar(100) DEFAULT NULL,
  `decided_at` datetime DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ot_employee` (`employee_id`),
  KEY `idx_ot_status` (`status`),
  KEY `idx_ot_date` (`ot_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `overtime_requests`
--

LOCK TABLES `overtime_requests` WRITE;
/*!40000 ALTER TABLE `overtime_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `overtime_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_runs`
--

DROP TABLE IF EXISTS `payroll_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_runs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_salary` decimal(12,2) DEFAULT '0.00',
  `working_days` int DEFAULT '0',
  `present_days` decimal(5,1) DEFAULT '0.0',
  `paid_leave_days` decimal(5,1) DEFAULT '0.0',
  `unpaid_leave_days` decimal(5,1) DEFAULT '0.0',
  `ot_hours` decimal(6,1) DEFAULT '0.0',
  `ot_amount` decimal(12,2) DEFAULT '0.00',
  `deductions` decimal(12,2) DEFAULT '0.00',
  `net_salary` decimal(12,2) DEFAULT '0.00',
  `status` enum('Draft','Approved','Paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Draft',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_month_emp` (`month`,`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_runs`
--

LOCK TABLES `payroll_runs` WRITE;
/*!40000 ALTER TABLE `payroll_runs` DISABLE KEYS */;
INSERT INTO `payroll_runs` VALUES (1,'2026-08',7,'HR Admin',0.00,21,0.0,0.0,21.0,0.0,0.00,0.00,0.00,'Draft','2026-08-13 07:35:07'),(2,'2026-08',8,'Aarav Sharma',65000.00,21,8.0,0.0,13.0,0.0,0.00,40238.10,24761.90,'Draft','2026-08-13 07:35:07'),(3,'2026-08',9,'Priya Patel',58000.00,21,9.0,0.0,12.0,0.0,0.00,33142.86,24857.14,'Draft','2026-08-13 07:35:07'),(4,'2026-08',10,'Rohan Verma',40000.00,21,8.5,0.0,12.5,0.0,0.00,23809.52,16190.48,'Draft','2026-08-13 07:35:07'),(5,'2026-08',11,'Sneha Iyer',75000.00,21,7.5,0.0,13.5,0.0,0.00,48214.29,26785.71,'Draft','2026-08-13 07:35:07'),(6,'2026-08',12,'Vikram Singh',35000.00,21,7.0,0.0,14.0,0.0,0.00,23333.33,11666.67,'Draft','2026-08-13 07:35:07'),(7,'2026-08',13,'Ananya Das',38000.00,21,7.0,0.0,14.0,0.0,0.00,25333.33,12666.67,'Draft','2026-08-13 07:35:07'),(8,'2026-08',14,'Karan Mehta',45000.00,21,7.5,0.0,13.5,0.0,0.00,28928.57,16071.43,'Draft','2026-08-13 07:35:07'),(9,'2026-08',15,'Divya Nair',70000.00,21,7.5,0.0,13.5,0.0,0.00,45000.00,25000.00,'Draft','2026-08-13 07:35:08');
/*!40000 ALTER TABLE `payroll_runs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance_records`
--

DROP TABLE IF EXISTS `performance_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `performance_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `period` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quality` int DEFAULT NULL,
  `productivity` int DEFAULT NULL,
  `communication` int DEFAULT NULL,
  `teamwork` int DEFAULT NULL,
  `attendance` int DEFAULT NULL,
  `initiative` int DEFAULT NULL,
  `deadline` int DEFAULT NULL,
  `adaptability` int DEFAULT NULL,
  `avg_score` decimal(5,2) DEFAULT NULL,
  `status` enum('excellent','good','needs_improvement') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reviewed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewed_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance_records`
--

LOCK TABLES `performance_records` WRITE;
/*!40000 ALTER TABLE `performance_records` DISABLE KEYS */;
INSERT INTO `performance_records` VALUES (2,'Em-10003','suhani','Sales',3,'2026-09',10,8,9,10,10,5,5,5,7.75,'good','','Super Admin','2026-09-08','2026-09-08 04:50:51'),(3,'EMP9968','A','HR',2,'2026-09',5,5,5,5,7,5,7,9,6.00,'good','','Super Admin','2026-09-08','2026-09-08 06:16:18'),(4,'EMP5182','Testing','IT',0,'2026-09',5,7,5,5,5,5,5,5,5.25,'needs_improvement','','Super Admin','2026-09-08','2026-09-08 07:24:46'),(5,'EMP5182','Testing','IT',0,'2026-09',6,8,5,7,7,5,5,8,6.38,'good','','Super Admin','2026-09-08','2026-09-08 14:20:24');
/*!40000 ALTER TABLE `performance_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performances`
--

DROP TABLE IF EXISTS `performances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `performances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `employeeId` int NOT NULL,
  `score` int DEFAULT '0',
  `review` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reviewDate` date DEFAULT NULL,
  `month` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performances`
--

LOCK TABLES `performances` WRITE;
/*!40000 ALTER TABLE `performances` DISABLE KEYS */;
INSERT INTO `performances` VALUES (2,10,9,4,'Best','2026-08-25','August',2026,'2026-08-25 14:21:03','2026-08-25 14:21:03'),(3,11,11,4,'wertyu','2026-08-31','August',2026,'2026-08-31 06:00:05','2026-08-31 06:00:05'),(4,19,13,3,'dsfdfddd d  vff ','2026-09-08','September',2026,'2026-09-08 06:00:10','2026-09-08 06:00:10'),(5,19,15,3,'asaadad','2026-09-09','September',2026,'2026-09-09 14:51:59','2026-09-09 14:51:59');
/*!40000 ALTER TABLE `performances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policies`
--

DROP TABLE IF EXISTS `policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `policies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('high','medium','low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `auto_apply` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_policy` (`title`,`category`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policies`
--

LOCK TABLES `policies` WRITE;
/*!40000 ALTER TABLE `policies` DISABLE KEYS */;
INSERT INTO `policies` VALUES (2,'qsads','leave','high','adsdzcda',1,1,'2026-09-08 04:57:44','2026-09-08 04:57:44');
/*!40000 ALTER TABLE `policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy_logs`
--

DROP TABLE IF EXISTS `policy_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `policy_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `policy_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy_logs`
--

LOCK TABLES `policy_logs` WRITE;
/*!40000 ALTER TABLE `policy_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `policy_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy_rules`
--

DROP TABLE IF EXISTS `policy_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `policy_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `policy_type` enum('client','candidate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `policy_id` (`policy_id`),
  CONSTRAINT `policy_rules_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy_rules`
--

LOCK TABLES `policy_rules` WRITE;
/*!40000 ALTER TABLE `policy_rules` DISABLE KEYS */;
INSERT INTO `policy_rules` VALUES (1,2,NULL,'asd','11','text');
/*!40000 ALTER TABLE `policy_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `portal_settings`
--

DROP TABLE IF EXISTS `portal_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `portal_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `portal_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) DEFAULT '1',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `portal_name` (`portal_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portal_settings`
--

LOCK TABLES `portal_settings` WRITE;
/*!40000 ALTER TABLE `portal_settings` DISABLE KEYS */;
INSERT INTO `portal_settings` VALUES (1,'HR',1,'2026-08-17 08:40:50'),(2,'CLIENT',1,'2026-08-12 17:26:30'),(3,'SALES',1,'2026-08-12 17:26:30'),(902,'IT',1,'2026-08-17 08:48:41'),(903,'EMPLOYEE',1,'2026-08-17 08:48:41'),(904,'EMPLOYEE VERIFICATION',1,'2026-08-17 08:48:41'),(905,'SMART ATTENDANCE',1,'2026-08-17 08:48:41'),(906,'AI ROBO INTERVIEW',1,'2026-08-23 06:21:34');
/*!40000 ALTER TABLE `portal_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profit_reports`
--

DROP TABLE IF EXISTS `profit_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profit_reports` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `month` int NOT NULL,
  `year` int NOT NULL,
  `total_revenue` decimal(12,2) DEFAULT '0.00',
  `total_expenses` decimal(12,2) DEFAULT '0.00',
  `net_profit` decimal(12,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_month_year` (`month`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profit_reports`
--

LOCK TABLES `profit_reports` WRITE;
/*!40000 ALTER TABLE `profit_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `profit_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proposals`
--

DROP TABLE IF EXISTS `proposals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proposals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `proposal_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_company` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `items` json NOT NULL,
  `subtotal` decimal(12,2) DEFAULT '0.00',
  `discount_percent` decimal(5,2) DEFAULT '0.00',
  `tax_percent` decimal(5,2) DEFAULT '0.00',
  `total` decimal(12,2) DEFAULT '0.00',
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'INR',
  `valid_until` date DEFAULT NULL,
  `terms` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('DRAFT','PENDING_APPROVAL','REVISION','SENT','ACCEPTED','REJECTED','EXPIRED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `response_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `responded_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `client_id` int DEFAULT NULL,
  `client_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `discount_pct` decimal(5,2) DEFAULT '0.00',
  `discount_amount` decimal(12,2) DEFAULT '0.00',
  `tax_pct` decimal(5,2) DEFAULT '0.00',
  `tax_amount` decimal(12,2) DEFAULT '0.00',
  `token_amount` decimal(12,2) DEFAULT '0.00',
  `agreement_months` int DEFAULT NULL,
  `replacement_months` int DEFAULT NULL,
  `sales_employee_id` int DEFAULT NULL,
  `created_by_role` enum('admin','sales') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `submitted_at` datetime DEFAULT NULL,
  `approval_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `proposal_number` (`proposal_number`),
  KEY `idx_proposals_client` (`client_code`),
  KEY `idx_proposals_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proposals`
--

LOCK TABLES `proposals` WRITE;
/*!40000 ALTER TABLE `proposals` DISABLE KEYS */;
INSERT INTO `proposals` VALUES (1,'PRP-2026-0001',NULL,'Rahul Sharma','rahul.sharma@acme.com','Acme Pvt Ltd','HRMS Software Implementation Proposal','[{\"qty\": 1, \"rate\": 25000, \"service\": \"HRMS Setup\", \"description\": \"Complete HRMS configuration and setup\"}]',25000.00,0.00,0.00,29500.00,'INR','2026-08-31','1. This proposal is valid until the date mentioned above.\n2. Prices are exclusive of applicable taxes unless stated otherwise.\n3. Payment terms: 50% advance, 50% on delivery/completion.\n4. Any additional scope will be quoted separately.',NULL,'ACCEPTED',NULL,'Super Admin','2026-08-31 12:47:45','2026-08-31 12:48:37','2026-08-31 07:02:45','2026-08-31 07:03:37',NULL,'+91 98765 43210','We are pleased to present this proposal for implementing a comprehensive HRMS solution to streamline employee management, attendance, payroll, recruitment, and HR operations.',0.00,0.00,18.00,4500.00,0.00,NULL,NULL,NULL,'admin',NULL,NULL,NULL,NULL),(2,'PRP-2026-0002',NULL,'RAm','abc@gmai.com','Ace','HRMS','[{\"qty\": 1, \"rate\": 5678, \"service\": \"REC\", \"description\": \"hbjhss\"}]',5678.00,0.00,0.00,6700.04,'INR','2026-08-31','1. This proposal is valid until the date mentioned above.\n2. Prices are exclusive of applicable taxes unless stated otherwise.\n3. Payment terms: 50% advance, 50% on delivery/completion.\n4. Any additional scope will be quoted separately.',NULL,'EXPIRED',NULL,'Super Admin','2026-08-31 12:56:18',NULL,'2026-08-31 07:11:18','2026-09-02 07:51:54',NULL,'9999778855','kfsgdfsjh',0.00,0.00,18.00,1022.04,0.00,NULL,NULL,NULL,'admin',NULL,NULL,NULL,NULL),(3,'PRP-2026-0003','C1009','Test','abcd@gmail.com','ACEme','HRMS','[{\"qty\": 1, \"rate\": 566.88, \"service\": \"Rectruitement\", \"description\": \"zbcjadnb\"}]',566.88,0.00,0.00,668.92,'INR','2026-08-31','1. This proposal is valid until the date mentioned above.\n2. Prices are exclusive of applicable taxes unless stated otherwise.\n3. Payment terms: 50% advance, 50% on delivery/completion.\n4. Any additional scope will be quoted separately.',NULL,'ACCEPTED',NULL,'Super Admin','2026-08-31 13:08:53','2026-08-31 13:15:22','2026-08-31 07:23:53','2026-08-31 07:30:22',11,'9988776655','sgfiu',0.00,0.00,18.00,102.04,0.00,NULL,NULL,NULL,'admin',NULL,NULL,NULL,NULL),(4,'PRP-2026-0004','C1009','AJ','abcd@gmail.com','ABC','HMRS complete Setup','[{\"qty\": 1, \"rate\": 5677.85, \"service\": \"Installation\", \"description\": \"jhvjhsa\"}]',5677.85,0.00,0.00,6699.86,'INR','2026-08-31','1. This proposal is valid until the date mentioned above.\n2. Prices are exclusive of applicable taxes unless stated otherwise.\n3. Payment terms: 50% advance, 50% on delivery/completion.\n4. Any additional scope will be quoted separately.',NULL,'ACCEPTED',NULL,'Super Admin','2026-08-31 13:42:35','2026-08-31 13:43:06','2026-08-31 07:57:35','2026-08-31 07:58:06',11,'9988776655','System',0.00,0.00,18.00,1022.01,0.00,NULL,NULL,NULL,'admin',NULL,NULL,NULL,NULL),(5,'PRP-2026-0005','C1009','Ram','phabindrakumar777@gmail.com','Ac','HRMS','[{\"mrp\": 566, \"qty\": 1, \"rate\": 78, \"unit\": \"56\", \"plan_id\": null, \"service\": \"jhbdc\", \"description\": \"jfjk\"}]',78.00,0.00,0.00,92.04,'INR','2026-08-31','1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.',NULL,'EXPIRED',NULL,'Super Admin','2026-08-31 21:21:50',NULL,'2026-08-31 15:36:50','2026-09-02 07:51:54',11,'9988776655','G',0.00,0.00,18.00,14.04,5000.00,11,NULL,NULL,'admin',NULL,NULL,NULL,NULL),(6,'PRP-2026-0006',NULL,'Shyam','ab@gmail.com','Avshj','RECRT','[{\"mrp\": 4999, \"qty\": 1, \"rate\": 1077, \"unit\": \"10\", \"plan_id\": null, \"service\": \"RER\", \"description\": \"FGHJ\"}]',1077.00,0.00,0.00,1143.77,'INR','2026-08-31','1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.',NULL,'EXPIRED',NULL,'Super Admin','2026-08-31 21:28:52',NULL,'2026-08-31 15:43:52','2026-09-02 07:51:54',NULL,'9988774455','trdfghu',10.00,107.70,18.00,174.47,5000.00,11,7,NULL,'admin',NULL,NULL,NULL,NULL),(10,'PRP-2026-0007','C1001','KUCH vi','arav@gmail.com','TECH','HRMS service','[{\"mrp\": 599, \"qty\": 1, \"rate\": 788, \"unit\": \"1\", \"plan_id\": null, \"service\": \"RECT\", \"description\": \"eefwg\"}]',788.00,0.00,0.00,929.84,'INR','2026-09-07','1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.','Nothing','EXPIRED',NULL,'Super Admin','2026-09-07 14:24:08',NULL,'2026-09-07 08:39:08','2026-09-07 18:30:27',16,'8796554455','Too',0.00,0.00,18.00,141.84,5000.00,11,30,NULL,'admin',NULL,NULL,NULL,NULL),(14,'PRP-2026-0008','C1001','Arav','arav@gmail.com','TECH','HRMS','[{\"mrp\": 10000, \"qty\": 1, \"rate\": 5000, \"unit\": \"per month\", \"plan_id\": \"hr_tech_starter\", \"service\": \"HR Technology Starter Plan\", \"description\": \"HR Technology Starter Plan, 11-month agreement. Includes hiring support for 5 candidates, replacement support, payroll, compliance, HRMS access and operational HR support.\"}]',5000.00,0.00,0.00,5900.00,'INR','2026-09-07','1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.','tyu','ACCEPTED',NULL,'Rohan Verma','2026-09-07 14:51:27','2026-09-07 14:51:47','2026-09-07 09:06:12','2026-09-07 09:06:47',16,'8796554455','ghjk',0.00,0.00,18.00,900.00,5000.00,11,1,10,'sales','2026-09-07 14:51:12',NULL,'Super Admin','2026-09-07 14:51:27'),(16,'PRP-2026-0009','C1001','Probe Contact',NULL,NULL,'Probe - return flow','[{\"mrp\": null, \"qty\": 1, \"rate\": 1000, \"unit\": \"month\", \"plan_id\": null, \"service\": \"Probe service\", \"description\": \"x\"}]',1000.00,0.00,0.00,1000.00,'INR','2026-09-30',NULL,NULL,'ACCEPTED',NULL,'Rohan Verma','2026-09-07 15:22:32','2026-09-07 15:25:44','2026-09-07 09:34:02','2026-09-07 09:40:44',16,NULL,NULL,0.00,0.00,0.00,0.00,0.00,NULL,NULL,10,'sales','2026-09-07 15:22:03',NULL,'Super Admin','2026-09-07 15:22:32'),(17,'PRP-2026-0010','C1017','suhani','aryan@gmail.com','Aryan','Recruitment & HR','[{\"mrp\": 200, \"qty\": 1, \"rate\": 250, \"unit\": \"2\", \"plan_id\": null, \"service\": \"Recruitment\", \"description\": \"wedfx   vdff   xddfdffdfddf\"}]',250.00,0.00,0.00,295.00,'INR','2026-09-09','1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.','ddfv f','ACCEPTED',NULL,'Super Admin','2026-09-08 11:23:11','2026-09-08 11:23:29','2026-09-08 05:53:11','2026-09-08 05:53:29',19,'9876543211','dssds c  d ffd   d dcc  ddf d d d d  c dv d ev vc dffv',0.00,0.00,18.00,45.00,5000.00,11,2,NULL,'admin',NULL,NULL,NULL,NULL),(18,'PRP-2026-0011','C1017','payal','aryan@gmail.com','Aryan','eerwwfww','[{\"mrp\": 20, \"qty\": 1, \"rate\": 25, \"unit\": \"34\", \"plan_id\": null, \"service\": \"evevefv f\", \"description\": \"vefvee f\"}]',25.00,0.00,0.00,29.50,'INR',NULL,'1. Token amount of ₹5,000 is payable at agreement signing (where applicable) and is fully adjustable against the final invoice.\n2. Standard agreement period: 11 months.\n3. Recruitment invoices are payable within 7 days of candidate joining. Subscription invoices are payable monthly in advance unless otherwise agreed.\n4. Replacement support as per the selected plan, subject to the candidate leaving within the covered period and client payments being clear.\n5. Vacancy closure commitment: within 7 working days (recruitment plans).\n6. Prices are subject to GST and applicable statutory taxes.\n7. Bulk hiring, multi-location deployment, long-term outsourcing and enterprise contracts are eligible for customized commercial discussion.',NULL,'ACCEPTED',NULL,'Super Admin','2026-09-09 14:48:56','2026-09-09 17:37:01','2026-09-09 09:18:56','2026-09-09 12:07:01',19,'9876543211','wrcv c fdfef  e fe',0.00,0.00,18.00,4.50,5000.00,11,NULL,NULL,'admin',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `proposals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `vendor_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `items` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by_employee_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (3,19,'rekha',1500.00,'2026-09-08','pending','[{\"name\": \"speaker\", \"price\": 1500, \"quantity\": 1}]','2026-09-08 06:04:19','2026-09-08 06:04:19',NULL),(4,19,'ddd',2000.00,'2026-09-09','pending','[{\"name\": \"aaa\", \"price\": 2000, \"quantity\": 1}]','2026-09-09 13:32:11','2026-09-09 13:32:11',15),(5,19,'as',2200.00,'2026-09-09','pending','[{\"name\": \"ewweew\", \"price\": 2200, \"quantity\": 1}]','2026-09-09 15:04:20','2026-09-09 15:04:20',15);
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_banks`
--

DROP TABLE IF EXISTS `question_banks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_banks` (
  `id` varchar(64) NOT NULL,
  `company_id` varchar(64) DEFAULT NULL,
  `category` enum('TECHNICAL','HR','BEHAVIORAL','PROBLEM_SOLVING','PRACTICAL_SAFETY','OPERATIONAL_WORKFLOW','ROBOTICS_HARDWARE','CONTROL_SYSTEMS','EMBEDDED_C_CPP') NOT NULL,
  `role_category` varchar(150) NOT NULL,
  `target_skill_level` varchar(32) NOT NULL,
  `difficulty` enum('EASY','MEDIUM','HARD') NOT NULL,
  `title` varchar(255) NOT NULL,
  `prompt` text NOT NULL,
  `expected_duration_sec` int NOT NULL,
  `ideal_benchmark_answer` text NOT NULL,
  `key_concepts` json NOT NULL,
  `anti_patterns` json NOT NULL,
  `rubric_weights` json NOT NULL,
  `is_global` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `idx_qb_role` (`role_category`),
  KEY `idx_qb_category` (`category`),
  CONSTRAINT `question_banks_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_banks`
--

LOCK TABLES `question_banks` WRITE;
/*!40000 ALTER TABLE `question_banks` DISABLE KEYS */;
/*!40000 ALTER TABLE `question_banks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reimbursements`
--

DROP TABLE IF EXISTS `reimbursements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reimbursements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `expense_date` date NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('Pending','Approved','Rejected','Paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `decided_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decided_at` datetime DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reimb_emp` (`employee_id`),
  KEY `idx_reimb_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reimbursements`
--

LOCK TABLES `reimbursements` WRITE;
/*!40000 ALTER TABLE `reimbursements` DISABLE KEYS */;
INSERT INTO `reimbursements` VALUES (2,29,'Travel',2000.00,'2026-09-09','refe','Paid','Super Admin','2026-09-09 22:27:05',NULL,'2026-09-09 16:56:31');
/*!40000 ALTER TABLE `reimbursements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resume_screenings`
--

DROP TABLE IF EXISTS `resume_screenings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resume_screenings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills` json DEFAULT NULL,
  `experience_years` decimal(4,1) DEFAULT NULL,
  `education` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `match_score` decimal(5,2) DEFAULT NULL,
  `matched_keywords` json DEFAULT NULL,
  `missing_keywords` json DEFAULT NULL,
  `job_title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resume_excerpt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ats_score` decimal(5,1) DEFAULT NULL,
  `ats_breakdown` json DEFAULT NULL,
  `suggestions` json DEFAULT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resume_screenings`
--

LOCK TABLES `resume_screenings` WRITE;
/*!40000 ALTER TABLE `resume_screenings` DISABLE KEYS */;
INSERT INTO `resume_screenings` VALUES (1,'Ravi Kumar','ravi.kumar@mail.com',NULL,'[\"typescript\", \"react\", \"node\", \"node.js\", \"express\", \"next.js\", \"sql\", \"mysql\", \"rest\", \"api\", \"docker\", \"git\", \"tailwind\", \"agile\"]',5.0,'B.Tech',60.00,'[\"react\", \"typescript\", \"node\"]','[\"graphql\", \"aws\"]','Frontend Developer','Ravi Kumar\nravi.kumar@mail.com | +91 98765 43210\n\nSenior Frontend Developer with 5 years experience in React, TypeScript, Next.js and Node.js. Built REST APIs with Express and MySQL. B.Tech in Computer Science. Skilled in Tailwind, Git, Docker and agile workflows.','2026-08-13 09:15:45',NULL,NULL,NULL,NULL),(2,'PHABINDRA KUMAR SAH','phabindrakumar777@gmail.com','+91-9992785583','[\"javascript\", \"react\", \"node\", \"node.js\", \"express\", \"next.js\", \"python\", \"java\", \"spring\", \"c++\", \"sql\", \"postgresql\", \"mongodb\", \"rest\", \"api\", \"git\", \"css\", \"tailwind\", \"sap\", \"hr\", \"agile\", \"testing\", \"power bi\"]',NULL,'Bachelor’s degree in Computer Science Engineering',NULL,'[]','[]',NULL,'\n\nPHABINDRA KUMAR SAH\nLinkedIn: phabindra-kumar-sah\nGitHub: Ahaan99\nEmail: phabindrakumar777@gmail.com\nMobile: +91-9992785583\nSaptari, Nepal\nSUMMARY\nI recently completed my Bachelor’s degree in Computer Science Engineering. I am a dedicated Full-Stack MERN Developer with\nhands-on experience in React.js, Node.js, Express.js, and MongoDB. I have a strong foundation in software development, problem-\nsolving, and system design. Through academic projects and practical experience, I have developed responsive, scalable, and high-\nperformance web applications while maintaining a focus on clean and efficient code. I am eager to apply my technical skills and\ncontinue growing as a software developer.\nTECHNICAL SKILLS\nLanguages: C/C++, Python, JavaScript\nFrameworks & Libraries: React.js, Node.js, Express.js, Next.js, Spring Boot, Tailwind CSS, Fabric.js\nDatabases: MongoDB, PostgreSQL\nData Visualization: Power BI (dashboards, DAX, data modeling, report publishing)\nTools & Platforms: Git, GitHub, Postman, Cloudinary, VS Code\nEDUCATION\nMaharishi Markandeshwar UniversityHaryana, India\nB.Tech in Computer Science Engineering (CGPA: 7.5)Sep. 2022 – May 2026\nShikshadeep CollegeBiratnagar, Nepal\nScience with Mathematics (GPA: 3.03)Aug. 2020 – Aug. 2022\nEXPERIENCE\nSoftware Engineering InternJun. 2024 – Aug. 2024\nZaalima DevelopmentRemote\n–Engineered a responsive landing page utilizing React.js and Tailwind CSS, reducing load time by 40% and boosting conversions\nby 15%.\n–Integrated resilient RESTfu','2026-08-14 17:03:53',88.0,'[{\"max\": 15, \"score\": 12, \"details\": [\"Email found\", \"Phone found\", \"No LinkedIn/GitHub link\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 25, \"details\": [\"Detected: summary, experience, education, skills, projects, certifications\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 16, \"details\": [\"6 action verbs\", \"28 quantified figures\", \"0 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 15, \"details\": [\"455 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 20, \"details\": [\"23 recognized skills (no job keywords provided)\"], \"category\": \"Skill Coverage\"}]','[\"Add a LinkedIn or GitHub/portfolio link to strengthen your profile.\", \"Use bullet points — dense paragraphs are hard for ATS and recruiters to scan.\"]','Phabindra_Kumar_Sah_Resum (1).pdf'),(3,'Ravi Kumar','ravi.kumar@example.com',NULL,'[\"typescript\", \"react\", \"node\", \"node.js\", \"express\", \"sql\", \"git\", \"tailwind\"]',4.0,'me',80.00,'[\"react\", \"typescript\", \"node\", \"sql\"]','[\"docker\"]','Frontend Developer','Ravi Kumar\r\nravi.kumar@example.com | +91 98765 43210 | linkedin.com/in/ravikumar\r\n\r\nSUMMARY\r\nFrontend developer with 4 years of experience building React applications.\r\n\r\nEXPERIENCE\r\nFrontend Developer - TechNova (2021 - 2025)\r\n- Built a dashboard used by 5000 users, improved load time by 40%\r\n- Led migration to TypeScript, reduced bugs by 30%\r\n- Developed reusable component library with 60 components\r\n\r\nEDUCATION\r\nB.Tech Computer Science, 2020\r\n\r\nSKILLS\r\nReact, TypeScript, Node.js, Express, SQL, Git, Tailwind\r\n','2026-08-14 17:08:00',69.0,'[{\"max\": 15, \"score\": 9, \"details\": [\"Email found\", \"Phone missing\", \"Profile link found\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 20, \"details\": [\"Detected: summary, experience, education, skills\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 19, \"details\": [\"5 action verbs\", \"10 quantified figures\", \"3 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 5, \"details\": [\"71 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 16, \"details\": [\"4/5 job keywords found\"], \"category\": \"Keyword Match\"}]','[\"Add a phone number in a standard format.\", \"Resume is too short — add detail about roles and achievements.\", \"Add missing job keywords where truthful: docker.\"]','resume.txt'),(4,'Priya Verma','priya.verma@example.com',NULL,'[\"typescript\", \"react\", \"node\", \"node.js\", \"express\", \"sql\", \"rest\", \"api\", \"git\"]',3.0,'me',80.00,'[\"react\", \"typescript\", \"node\", \"sql\"]','[\"docker\"]','Frontend Developer','Priya Verma\npriya.verma@example.com | +91 98123 45670 | github.com/priyaverma\n\nSUMMARY\nFrontend developer with 3 years of experience building React and Node applications.\n\nEXPERIENCE\nReact Developer - CodeWorks (2022 - 2025)\n- Developed a customer portal serving 12000 users, improved conversion by 25%\n- Built REST APIs with Node.js and Express, reduced response time by 35%\n- Led migration of 40 components to TypeScript\n- Implemented CI pipeline, automated 90% of regression tests\n\nEDUCATION\nB.Tech Information Technology, 2021\n\nSKILLS\nReact, TypeScript, Node.js, Express, SQL, Git, Redux\n\nPROJECTS\n- Open source dashboard library with 300 GitHub stars','2026-08-14 17:09:26',75.0,'[{\"max\": 15, \"score\": 9, \"details\": [\"Email found\", \"Phone missing\", \"Profile link found\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 23, \"details\": [\"Detected: summary, experience, education, skills, projects\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 22, \"details\": [\"7 action verbs\", \"12 quantified figures\", \"5 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 5, \"details\": [\"95 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 16, \"details\": [\"4/5 job keywords found\"], \"category\": \"Keyword Match\"}]','[\"Add a phone number in a standard format.\", \"Resume is too short — add detail about roles and achievements.\", \"Add missing job keywords where truthful: docker.\"]','priya-verma-resume.txt'),(5,'Priya Verma','priya.verma@example.com',NULL,'[\"typescript\", \"react\", \"node\", \"node.js\", \"express\", \"sql\", \"rest\", \"api\", \"git\"]',3.0,'me',80.00,'[\"react\", \"typescript\", \"node\", \"sql\"]','[\"docker\"]','Frontend Developer','Priya Verma\npriya.verma@example.com | +91 98123 45670 | github.com/priyaverma\n\nSUMMARY\nFrontend developer with 3 years of experience building React and Node applications.\n\nEXPERIENCE\nReact Developer - CodeWorks (2022 - 2025)\n- Developed a customer portal serving 12000 users, improved conversion by 25%\n- Built REST APIs with Node.js and Express, reduced response time by 35%\n- Led migration of 40 components to TypeScript\n- Implemented CI pipeline, automated 90% of regression tests\n\nEDUCATION\nB.Tech Information Technology, 2021\n\nSKILLS\nReact, TypeScript, Node.js, Express, SQL, Git, Redux\n\nPROJECTS\n- Open source dashboard library with 300 GitHub stars','2026-08-14 17:10:47',81.0,'[{\"max\": 15, \"score\": 15, \"details\": [\"Email found\", \"Phone found\", \"Profile link found\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 23, \"details\": [\"Detected: summary, experience, education, skills, projects\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 22, \"details\": [\"7 action verbs\", \"12 quantified figures\", \"5 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 5, \"details\": [\"95 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 16, \"details\": [\"4/5 job keywords found\"], \"category\": \"Keyword Match\"}]','[\"Resume is too short — add detail about roles and achievements.\", \"Add missing job keywords where truthful: docker.\"]','priya-verma-resume.txt'),(6,'PHABINDRA KUMAR SAH','phabindrakumar777@gmail.com','+91-9992785583','[\"javascript\", \"react\", \"node\", \"node.js\", \"express\", \"next.js\", \"python\", \"java\", \"spring\", \"c++\", \"sql\", \"postgresql\", \"mongodb\", \"rest\", \"api\", \"git\", \"css\", \"tailwind\", \"sap\", \"hr\", \"agile\", \"testing\", \"power bi\"]',NULL,'Bachelor’s degree in Computer Science Engineering',100.00,'[\"mern\"]','[]','frontend','\n\nPHABINDRA KUMAR SAH\nLinkedIn: phabindra-kumar-sah\nGitHub: Ahaan99\nEmail: phabindrakumar777@gmail.com\nMobile: +91-9992785583\nSaptari, Nepal\nSUMMARY\nI recently completed my Bachelor’s degree in Computer Science Engineering. I am a dedicated Full-Stack MERN Developer with\nhands-on experience in React.js, Node.js, Express.js, and MongoDB. I have a strong foundation in software development, problem-\nsolving, and system design. Through academic projects and practical experience, I have developed responsive, scalable, and high-\nperformance web applications while maintaining a focus on clean and efficient code. I am eager to apply my technical skills and\ncontinue growing as a software developer.\nTECHNICAL SKILLS\nLanguages: C/C++, Python, JavaScript\nFrameworks & Libraries: React.js, Node.js, Express.js, Next.js, Spring Boot, Tailwind CSS, Fabric.js\nDatabases: MongoDB, PostgreSQL\nData Visualization: Power BI (dashboards, DAX, data modeling, report publishing)\nTools & Platforms: Git, GitHub, Postman, Cloudinary, VS Code\nEDUCATION\nMaharishi Markandeshwar UniversityHaryana, India\nB.Tech in Computer Science Engineering (CGPA: 7.5)Sep. 2022 – May 2026\nShikshadeep CollegeBiratnagar, Nepal\nScience with Mathematics (GPA: 3.03)Aug. 2020 – Aug. 2022\nEXPERIENCE\nSoftware Engineering InternJun. 2024 – Aug. 2024\nZaalima DevelopmentRemote\n–Engineered a responsive landing page utilizing React.js and Tailwind CSS, reducing load time by 40% and boosting conversions\nby 15%.\n–Integrated resilient RESTfu','2026-08-25 15:39:25',88.0,'[{\"max\": 15, \"score\": 12, \"details\": [\"Email found\", \"Phone found\", \"No LinkedIn/GitHub link\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 25, \"details\": [\"Detected: summary, experience, education, skills, projects, certifications\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 16, \"details\": [\"6 action verbs\", \"28 quantified figures\", \"0 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 15, \"details\": [\"455 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 20, \"details\": [\"1/1 job keywords found\"], \"category\": \"Keyword Match\"}]','[\"Add a LinkedIn or GitHub/portfolio link to strengthen your profile.\", \"Use bullet points — dense paragraphs are hard for ATS and recruiters to scan.\"]','Phabindra_Kumar_Sah_Resum.pdf'),(7,'SUHANI','rekhasuhani040@gmail.com','+91-9588382137','[\"javascript\", \"react\", \"node\", \"node.js\", \"express\", \"java\", \"sql\", \"mysql\", \"mongodb\", \"rest\", \"api\", \"git\", \"html\", \"css\", \"ui/ux\", \"hr\"]',NULL,'MasterofComputerApplications(2024–2026)',NULL,'[]','[]',NULL,'\n\nSUHANI\nYamunanagar,Haryana|+91-9588382137|rekhasuhani040@gmail.com\nlinkedin.com/in/suhani-mittal0aa314251\nPROFESSIONALSUMMARY\nMERNStackDeveloperwithhands-onexperienceinbuildingscalablefull-stackwebapplicationsusing\nMongoDB,Express.js,React.js,andNode.js.ProficientindesigningRESTAPIs,implementingJWT\nauthentication,anddevelopingresponsiveuserinterfaces.Strongproblem-solvingskillswithfocuson\ncleanarchitectureandperformanceoptimization.\nEDUCATION\nMasterofComputerApplications(2024–2026)\nMaharishiMarkandeshwarUniversity\nBachelorofCommerce(2021–2024)\nDAVCollegeforGirls,Yamunanagar\nSKILLS\n•Frontend:HTML,CSS,JavaScript,React.js,Bootstrap\n•Backend:Node.js,Express.js\n•Database:MongoDB,MySQL\n•CoreConcepts:RESTAPIs,CRUD,JWTAuthentication,MVCArchitecture\n•Tools:Git,GitHub,Postman,VSCode\n•Other:ResponsiveDesign,Debugging,APIIntegration\nPROJECTS\nStudentManagementSystem(MERNStack)\nDevelopedfull-stackMERNapplicationwithCRUDfunctionalityforstudentdatamanagement.\nIntegratedJWT-basedauthenticationandrole-basedaccesscontrol.\nBuiltresponsiveUIusingReact.jsandBootstrap.\nOptimizeddatahandlingbyconnectingRESTAPIswithMongoDB.\nSmartServiceBooking&PaymentManagementSystem\nEngineeredrole-basedMERNapplication(Admin,Customer,ServiceProvider).\nCreatedbookingsystemwithreal-timestatustracking.\nSecuredbackendbydevelopingRESTAPIsforbookingsandpayments.\nDesignedanalyticsdashboardforrevenueinsights.\nEducationPortal/DashboardSystem\nDevelopedReact.js-basedportalformanagingstudentsandteachers.\nHandledCRUDo','2026-09-08 04:49:43',71.0,'[{\"max\": 15, \"score\": 15, \"details\": [\"Email found\", \"Phone found\", \"Profile link found\"], \"category\": \"Contact Info\"}, {\"max\": 25, \"score\": 14, \"details\": [\"Detected: education, skills, projects\"], \"category\": \"Resume Sections\"}, {\"max\": 25, \"score\": 17, \"details\": [\"0 action verbs\", \"6 quantified figures\", \"6 bullet points\", \"Dates present\"], \"category\": \"Content Quality\"}, {\"max\": 15, \"score\": 5, \"details\": [\"36 words\", \"Good paragraph sizing\"], \"category\": \"Length & Format\"}, {\"max\": 20, \"score\": 20, \"details\": [\"16 recognized skills (no job keywords provided)\"], \"category\": \"Skill Coverage\"}]','[\"Add a clear \\\"Experience\\\" section heading — ATS parsers look for it.\", \"Use strong action verbs (built, led, improved…) to describe your work.\", \"Resume is too short — add detail about roles and achievements.\"]','suhani resume mern .pdf');
/*!40000 ALTER TABLE `resume_screenings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `revenue_categories`
--

DROP TABLE IF EXISTS `revenue_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `revenue_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7496 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `revenue_categories`
--

LOCK TABLES `revenue_categories` WRITE;
/*!40000 ALTER TABLE `revenue_categories` DISABLE KEYS */;
INSERT INTO `revenue_categories` VALUES (1,'Sales','2026-08-12 17:26:30'),(2,'Invoice','2026-08-12 17:26:30'),(3,'Subscription','2026-08-12 17:26:30'),(4,'Manual','2026-08-12 17:26:30'),(5,'Service','2026-08-12 17:26:30');
/*!40000 ALTER TABLE `revenue_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `revenue_targets`
--

DROP TABLE IF EXISTS `revenue_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `revenue_targets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `year` int NOT NULL,
  `month` int NOT NULL,
  `target_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `incentive_rate` decimal(5,2) NOT NULL DEFAULT '5.00',
  `notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_year_month` (`year`,`month`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `revenue_targets`
--

LOCK TABLES `revenue_targets` WRITE;
/*!40000 ALTER TABLE `revenue_targets` DISABLE KEYS */;
INSERT INTO `revenue_targets` VALUES (1,2026,8,500000.00,5.00,'Batch2 test','2026-08-13 06:36:15');
/*!40000 ALTER TABLE `revenue_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `revenues`
--

DROP TABLE IF EXISTS `revenues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `revenues` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` int DEFAULT NULL,
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `revenue_date` date NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `revenues_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `revenue_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `revenues`
--

LOCK TABLES `revenues` WRITE;
/*!40000 ALTER TABLE `revenues` DISABLE KEYS */;
INSERT INTO `revenues` VALUES (1,NULL,'demo',NULL,250000.00,'2026-08-01','DEMO','2026-08-13 07:13:50'),(2,NULL,'demo',NULL,263000.00,'2026-07-01','DEMO','2026-08-13 07:13:50'),(3,NULL,'demo',NULL,276000.00,'2026-06-01','DEMO','2026-08-13 07:13:50'),(4,NULL,'demo',NULL,289000.00,'2026-05-01','DEMO','2026-08-13 07:13:50'),(5,NULL,'demo',NULL,302000.00,'2026-04-01','DEMO','2026-08-13 07:13:50'),(6,NULL,'demo',NULL,315000.00,'2026-03-01','DEMO','2026-08-13 07:13:50'),(7,NULL,'demo',NULL,328000.00,'2026-02-01','DEMO','2026-08-13 07:13:50'),(8,NULL,'demo',NULL,251000.00,'2026-01-01','DEMO','2026-08-13 07:13:50'),(9,NULL,'demo',NULL,264000.00,'2025-12-01','DEMO','2026-08-13 07:13:50'),(10,NULL,'demo',NULL,277000.00,'2025-11-01','DEMO','2026-08-13 07:13:50'),(11,NULL,'demo',NULL,290000.00,'2025-10-01','DEMO','2026-08-13 07:13:50'),(12,NULL,'demo',NULL,303000.00,'2025-09-01','DEMO','2026-08-13 07:13:50');
/*!40000 ALTER TABLE `revenues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robo_admin_users`
--

DROP TABLE IF EXISTS `robo_admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `robo_admin_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hashed_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'hr_viewer',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robo_admin_users`
--

LOCK TABLES `robo_admin_users` WRITE;
/*!40000 ALTER TABLE `robo_admin_users` DISABLE KEYS */;
INSERT INTO `robo_admin_users` VALUES (1,'Super Admin','admin@ardhnarishvar.com','$2b$12$oR84T12XR6SGRQ95vT75bOUR6a9ccVgQ8aZpWL5DSaOpPOB2zO4EK','SUPER_ADMIN',1,'2026-09-14 21:30:43','2026-08-16 12:44:55');
/*!40000 ALTER TABLE `robo_admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robo_interview_sessions`
--

DROP TABLE IF EXISTS `robo_interview_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `robo_interview_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_id` int NOT NULL,
  `candidate_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `position_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'completed',
  `overall_score` float DEFAULT '0',
  `decision` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transcript` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ai_summary` json DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_robo_sess_cand` (`candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robo_interview_sessions`
--

LOCK TABLES `robo_interview_sessions` WRITE;
/*!40000 ALTER TABLE `robo_interview_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `robo_interview_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robo_snapshots`
--

DROP TABLE IF EXISTS `robo_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `robo_snapshots` (
  `snap_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` json NOT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`snap_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robo_snapshots`
--

LOCK TABLES `robo_snapshots` WRITE;
/*!40000 ALTER TABLE `robo_snapshots` DISABLE KEYS */;
INSERT INTO `robo_snapshots` VALUES ('candidates','[{\"id\": 999991, \"name\": \"Store Test Candidate\", \"email\": \"storetest@example.com\", \"phone\": \"9999999999\", \"skills\": [\"React\", \"Node\", \"SQL\"], \"status\": \"shortlisted\", \"position_title\": \"Senior Full Stack Developer\", \"experience_years\": 0}]','2026-09-14 22:24:32'),('config','{}','2026-09-02 14:34:37'),('proctor_logs','[{\"at\": \"2026-09-14T16:00:20.121Z\", \"events\": [{\"at\": \"2026-09-14T16:00:00.260Z\", \"type\": \"tech_monitor\", \"detail\": \"technical monitoring active\"}, {\"at\": \"2026-09-14T16:00:02.779Z\", \"type\": \"audio_monitor\", \"detail\": \"speaker detection active\"}], \"warnings\": 3, \"integrity\": 76, \"terminated\": true, \"violations\": [{\"at\": \"2026-09-14T16:00:11.486Z\", \"type\": \"no_face\"}, {\"at\": \"2026-09-14T16:00:15.798Z\", \"type\": \"no_face\"}, {\"at\": \"2026-09-14T16:00:20.112Z\", \"type\": \"no_face\"}], \"candidate_id\": 522013, \"eye_tracking\": \"unavailable\", \"speech_seconds\": 0, \"face_consistency\": \"not enrolled\"}]','2026-09-14 21:30:21'),('reports','[]','2026-09-14 20:37:19'),('results','[{\"saved_at\": \"2026-09-15T05:16:06.748Z\", \"has_video\": true, \"video_mime\": \"video/webm;codecs=vp9,opus\", \"candidate_id\": 999991, \"video_duration\": 0}, {\"saved_at\": \"2026-09-14T16:00:20.357Z\", \"has_video\": true, \"video_mime\": \"video/webm;codecs=vp9,opus\", \"candidate_id\": 522013, \"video_duration\": 18}]','2026-09-15 10:47:25'),('schedules','[{\"id\": 1789399893351, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T16:30\", \"interview_end_at\": \"2026-09-14T17:15\"}, {\"id\": 1789400466006, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T21:16\", \"interview_end_at\": \"2026-09-14T21:25\"}, {\"id\": 1789401219183, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T21:30\", \"interview_end_at\": \"2026-09-14T21:32\"}, {\"id\": 1789401335335, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"completed\", \"candidate_id\": 522013, \"scheduled_at\": \"2026-09-14T21:30\", \"interview_end_at\": \"2026-09-14T21:32\"}]','2026-09-14 21:30:21'),('synced_at','\"2026-09-15T13:33:04.449Z\"','2026-09-15 19:03:04'),('ui_candidates','[{\"id\": 999991, \"name\": \"Store Test Candidate\", \"email\": \"storetest@example.com\", \"phone\": \"9999999999\", \"result\": null, \"skills\": [\"React\", \"Node\", \"SQL\"], \"status\": \"shortlisted\", \"ai_score\": 0, \"position_id\": 1, \"resume_data\": \"\", \"resume_name\": \"test.pdf\", \"registered_at\": \"2026-09-14T15:28:54.9733730Z\", \"position_title\": \"Senior Full Stack Developer\", \"experience_years\": 0}]','2026-09-14 21:00:44'),('ui_proctor_logs','[{\"at\": \"2026-09-14T16:00:20.121Z\", \"events\": [{\"at\": \"2026-09-14T16:00:00.260Z\", \"type\": \"tech_monitor\", \"detail\": \"technical monitoring active\"}, {\"at\": \"2026-09-14T16:00:02.779Z\", \"type\": \"audio_monitor\", \"detail\": \"speaker detection active\"}], \"warnings\": 3, \"integrity\": 76, \"terminated\": true, \"violations\": [{\"at\": \"2026-09-14T16:00:11.486Z\", \"type\": \"no_face\"}, {\"at\": \"2026-09-14T16:00:15.798Z\", \"type\": \"no_face\"}, {\"at\": \"2026-09-14T16:00:20.112Z\", \"type\": \"no_face\"}], \"candidate_id\": 522013, \"eye_tracking\": \"unavailable\", \"speech_seconds\": 0, \"face_consistency\": \"not enrolled\"}]','2026-09-14 21:30:20'),('ui_results','[{\"saved_at\": \"2026-09-15T05:16:06.748Z\", \"has_video\": true, \"video_mime\": \"video/webm;codecs=vp9,opus\", \"candidate_id\": 999991, \"video_duration\": 0}, {\"saved_at\": \"2026-09-14T16:00:20.357Z\", \"has_video\": true, \"video_mime\": \"video/webm;codecs=vp9,opus\", \"candidate_id\": 522013, \"video_duration\": 18}]','2026-09-15 10:46:07'),('ui_schedules','[{\"id\": 1789399893351, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T16:30\", \"interview_end_at\": \"2026-09-14T17:15\"}, {\"id\": 1789400466006, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T21:16\", \"interview_end_at\": \"2026-09-14T21:25\"}, {\"id\": 1789401219183, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"scheduled\", \"candidate_id\": 999991, \"scheduled_at\": \"2026-09-14T21:30\", \"interview_end_at\": \"2026-09-14T21:32\"}, {\"id\": 1789401335335, \"notes\": \"\", \"round\": \"ai_screening\", \"status\": \"completed\", \"candidate_id\": 522013, \"scheduled_at\": \"2026-09-14T21:30\", \"interview_end_at\": \"2026-09-14T21:32\"}]','2026-09-14 21:30:20');
/*!40000 ALTER TABLE `robo_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robo_videos`
--

DROP TABLE IF EXISTS `robo_videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `robo_videos` (
  `candidate_id` int NOT NULL,
  `candidate_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `file` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'video/webm',
  `duration` int DEFAULT '0',
  `size` bigint DEFAULT '0',
  `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robo_videos`
--

LOCK TABLES `robo_videos` WRITE;
/*!40000 ALTER TABLE `robo_videos` DISABLE KEYS */;
INSERT INTO `robo_videos` VALUES (491213,'Phabindra Kumar Sah','candidate_491213.webm','video/webm',84,130842158,'2026-08-27 09:52:38'),(522013,'Suhani','candidate_522013.webm','video/webm',0,3087,'2026-09-14 21:25:54'),(999991,'Store Test Candidate','candidate_999991.webm','video/webm',0,10998262,'2026-09-15 10:50:41');
/*!40000 ALTER TABLE `robo_videos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_approval_matrix`
--

DROP TABLE IF EXISTS `salary_approval_matrix`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_approval_matrix` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rule_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_percent` decimal(6,2) NOT NULL,
  `max_percent` decimal(6,2) DEFAULT NULL,
  `approver_roles` json NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_approval_matrix`
--

LOCK TABLES `salary_approval_matrix` WRITE;
/*!40000 ALTER TABLE `salary_approval_matrix` DISABLE KEYS */;
INSERT INTO `salary_approval_matrix` VALUES (1,'Minor change (< 10%)',0.00,10.00,'[\"TL\"]','2026-08-23 05:47:11','2026-08-23 05:47:11'),(2,'Moderate change (10-25%)',10.00,25.00,'[\"TL\", \"MANAGER\"]','2026-08-23 05:47:11','2026-08-23 05:47:11'),(3,'Major change (> 25%)',25.00,NULL,'[\"TL\", \"MANAGER\", \"SUPER_ADMIN\"]','2026-08-23 05:47:11','2026-08-23 05:47:11');
/*!40000 ALTER TABLE `salary_approval_matrix` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_history`
--

DROP TABLE IF EXISTS `salary_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `old_salary` decimal(12,2) NOT NULL,
  `new_salary` decimal(12,2) NOT NULL,
  `revision_id` int DEFAULT NULL,
  `changed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `change_source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'revision',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sh_employee` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_history`
--

LOCK TABLES `salary_history` WRITE;
/*!40000 ALTER TABLE `salary_history` DISABLE KEYS */;
INSERT INTO `salary_history` VALUES (5,29,200000.00,30000.00,7,'Super Admin','Revision','2026-09-08 04:38:32');
/*!40000 ALTER TABLE `salary_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_revision_approvals`
--

DROP TABLE IF EXISTS `salary_revision_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_revision_approvals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `revision_id` int NOT NULL,
  `level` int NOT NULL,
  `approver_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `approver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` enum('Approved','Rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remarks` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sra_revision` (`revision_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_revision_approvals`
--

LOCK TABLES `salary_revision_approvals` WRITE;
/*!40000 ALTER TABLE `salary_revision_approvals` DISABLE KEYS */;
INSERT INTO `salary_revision_approvals` VALUES (7,6,0,'SUPER_ADMIN','Super Admin','Rejected',NULL,'2026-08-23 07:17:56'),(8,7,0,'SUPER_ADMIN','Super Admin','Approved',NULL,'2026-09-08 04:38:32');
/*!40000 ALTER TABLE `salary_revision_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_revisions`
--

DROP TABLE IF EXISTS `salary_revisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_revisions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `current_salary` decimal(12,2) NOT NULL,
  `proposed_salary` decimal(12,2) NOT NULL,
  `change_percent` decimal(6,2) NOT NULL,
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected','Cancelled','Applied') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `matrix_rule_id` int DEFAULT NULL,
  `required_roles` json NOT NULL,
  `current_level` int NOT NULL DEFAULT '0',
  `requested_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decided_at` datetime DEFAULT NULL,
  `applied_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sr_employee` (`employee_id`),
  KEY `idx_sr_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_revisions`
--

LOCK TABLES `salary_revisions` WRITE;
/*!40000 ALTER TABLE `salary_revisions` DISABLE KEYS */;
INSERT INTO `salary_revisions` VALUES (6,20,50000.00,6.00,-99.99,NULL,'2026-08-23','Rejected',3,'[\"TL\", \"MANAGER\", \"SUPER_ADMIN\"]',0,'Super Admin','2026-08-23 12:47:56',NULL,'2026-08-23 07:17:53'),(7,29,200000.00,30000.00,-85.00,'asaa','2026-09-08','Applied',3,'[\"TL\", \"MANAGER\", \"SUPER_ADMIN\"]',3,'Super Admin','2026-09-08 10:08:32','2026-09-08 10:08:32','2026-09-08 04:38:28');
/*!40000 ALTER TABLE `salary_revisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_eod_reports`
--

DROP TABLE IF EXISTS `sales_eod_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_eod_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date NOT NULL,
  `tasks_completed` int DEFAULT '0',
  `tasks_in_progress` int DEFAULT '0',
  `hours_worked` decimal(5,2) DEFAULT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('submitted','pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'submitted',
  `submitted_at` time DEFAULT NULL,
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `sales_eod_reports_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_eod_reports`
--

LOCK TABLES `sales_eod_reports` WRITE;
/*!40000 ALTER TABLE `sales_eod_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `sales_eod_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_inventory`
--

DROP TABLE IF EXISTS `sales_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT '0',
  `price` decimal(10,2) DEFAULT '0.00',
  `mrp` decimal(10,2) DEFAULT '0.00',
  `discount_price` decimal(10,2) DEFAULT '0.00',
  `gst_percent` decimal(5,2) DEFAULT '0.00',
  `low_stock_threshold` int DEFAULT '5',
  `created_by` int DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_inventory`
--

LOCK TABLES `sales_inventory` WRITE;
/*!40000 ALTER TABLE `sales_inventory` DISABLE KEYS */;
INSERT INTO `sales_inventory` VALUES (1,'Wireless Mouse','Electronics',26,899.00,1299.00,849.00,18.00,5,10,'2026-08-13 15:31:44','2026-08-13 15:32:06'),(2,'USB-C Cable','Accessories',50,249.00,0.00,0.00,0.00,5,10,'2026-08-13 15:32:03','2026-08-13 15:33:05');
/*!40000 ALTER TABLE `sales_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_report`
--

DROP TABLE IF EXISTS `sales_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_report` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `plan_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `billing_months` int NOT NULL COMMENT '1-12 months',
  `amount` decimal(10,2) NOT NULL,
  `amount_paid` decimal(10,2) DEFAULT '0.00',
  `payment_status` enum('paid','partial','unpaid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'unpaid',
  `payment_method` enum('cash','online') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `purchase_date` date NOT NULL,
  `start_date` date NOT NULL,
  `due_date` date NOT NULL,
  `subscription_status` enum('active','expired','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client_id` (`client_id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_due_date` (`due_date`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_report`
--

LOCK TABLES `sales_report` WRITE;
/*!40000 ALTER TABLE `sales_report` DISABLE KEYS */;
INSERT INTO `sales_report` VALUES (1,19,29,'Basic',1,20000.00,2000.00,'paid','online','2026-09-08','2026-09-10','2026-09-09','active','','2026-09-08 07:26:59','2026-09-08 07:26:59');
/*!40000 ALTER TABLE `sales_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `name` varchar(191) NOT NULL,
  `applied_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('2026-08-25_production_fixes.sql','2026-09-14 19:03:21'),('2026-09-08_invoices_client_id.sql','2026-09-14 19:03:21'),('2026-09-08_joining_education.sql','2026-09-14 19:03:21'),('2026-09-08_offer_letter_templates.sql','2026-09-14 19:03:21'),('2026-09-09_client_employee_chat.sql','2026-09-14 19:03:21'),('2026-09-09_client_employee_login.sql','2026-09-14 19:03:21'),('2026-09-09_client_portal_employee_controls.sql','2026-09-14 19:03:21'),('2026-09-09_employee_profile_optional_fields.sql','2026-09-14 19:03:21'),('2026-09-10_hr_portal_fixes.sql','2026-09-14 19:12:08'),('2026-09-12_complaints_it_role (2).sql','2026-09-14 19:03:21');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shift_timings`
--

DROP TABLE IF EXISTS `shift_timings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_timings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `check_in_start` time NOT NULL DEFAULT '09:00:00',
  `check_in_end` time NOT NULL DEFAULT '10:00:00',
  `check_out_start` time NOT NULL DEFAULT '17:00:00',
  `check_out_end` time NOT NULL DEFAULT '18:00:00',
  `grace_minutes` int NOT NULL DEFAULT '15',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_timings`
--

LOCK TABLES `shift_timings` WRITE;
/*!40000 ALTER TABLE `shift_timings` DISABLE KEYS */;
INSERT INTO `shift_timings` VALUES (4,'General Shift','09:00:00','10:00:00','17:00:00','18:00:00',15,'2026-08-14 03:43:48','2026-08-14 03:43:48'),(5,'Evening Shift','14:00:00','15:00:00','22:00:00','23:00:00',10,'2026-08-14 03:43:48','2026-08-14 03:43:48');
/*!40000 ALTER TABLE `shift_timings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `smart_attendance_otps`
--

DROP TABLE IF EXISTS `smart_attendance_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `smart_attendance_otps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `otp` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sao_emp` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `smart_attendance_otps`
--

LOCK TABLES `smart_attendance_otps` WRITE;
/*!40000 ALTER TABLE `smart_attendance_otps` DISABLE KEYS */;
/*!40000 ALTER TABLE `smart_attendance_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sop_acknowledgements`
--

DROP TABLE IF EXISTS `sop_acknowledgements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sop_acknowledgements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sop_id` int NOT NULL,
  `version` int NOT NULL,
  `employee_id` int NOT NULL,
  `ack_type` enum('Read','Training Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Read',
  `acknowledged_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sop_emp_ver` (`sop_id`,`employee_id`,`version`,`ack_type`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sop_acknowledgements`
--

LOCK TABLES `sop_acknowledgements` WRITE;
/*!40000 ALTER TABLE `sop_acknowledgements` DISABLE KEYS */;
INSERT INTO `sop_acknowledgements` VALUES (1,2,2,8,'Read','2026-08-13 16:17:39'),(2,2,2,8,'Training Completed','2026-08-13 16:17:42'),(3,7,1,28,'Read','2026-09-08 06:16:50'),(4,2,2,28,'Read','2026-09-08 06:16:52'),(5,3,1,28,'Read','2026-09-08 06:16:53'),(6,4,1,28,'Read','2026-09-08 06:16:53'),(7,3,1,29,'Read','2026-09-09 17:55:56');
/*!40000 ALTER TABLE `sop_acknowledgements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sop_version_files`
--

DROP TABLE IF EXISTS `sop_version_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sop_version_files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sop_id` int NOT NULL,
  `version` int NOT NULL,
  `file_kind` enum('report','sheet','source_code','video','project_report','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sop_ver` (`sop_id`,`version`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sop_version_files`
--

LOCK TABLES `sop_version_files` WRITE;
/*!40000 ALTER TABLE `sop_version_files` DISABLE KEYS */;
INSERT INTO `sop_version_files` VALUES (1,2,1,'other','uploads\\\\sops\\\\hr-onboarding-sop-v1.txt','hr-onboarding-sop-v1.txt',NULL,'2026-08-13 18:48:13'),(2,2,2,'other','uploads\\\\sops\\\\hr-onboarding-sop-v2.txt','hr-onboarding-sop-v2.txt',NULL,'2026-08-13 18:48:13'),(3,3,1,'other','uploads\\\\sops\\\\sales-call-handling-sop.txt','sales-call-handling-sop.txt',NULL,'2026-08-13 18:48:13'),(4,4,1,'other','uploads\\\\sops\\\\it-security-sop.txt','it-security-sop.txt',NULL,'2026-08-13 18:48:13'),(5,5,1,'other','uploads\\\\sops\\\\client-recruitment-sop-template.txt','client-recruitment-sop-template.txt',NULL,'2026-08-13 18:48:13'),(6,6,1,'other','uploads\\\\sops\\\\client-leave-policy-template.txt','client-leave-policy-template.txt',NULL,'2026-08-13 18:48:13'),(8,7,1,'report','D:\\HRMS_new\\HRMS_new\\HRMS\\HRMS Merging\\backen\\uploads\\sops\\1786647340870-757887530.txt','sop-report.txt',23,'2026-08-13 18:55:40'),(9,7,1,'sheet','D:\\HRMS_new\\HRMS_new\\HRMS\\HRMS Merging\\backen\\uploads\\sops\\1786647340871-40613925.csv','sop-sheet.csv',13,'2026-08-13 18:55:40'),(10,7,1,'source_code','D:\\HRMS_new\\HRMS_new\\HRMS\\HRMS Merging\\backen\\uploads\\sops\\1786647340872-610397497.zip','sop-src.zip',21,'2026-08-13 18:55:40'),(11,7,1,'video','D:\\HRMS_new\\HRMS_new\\HRMS\\HRMS Merging\\backen\\uploads\\sops\\1786647340872-349410273.mp4','sop-video.mp4',15,'2026-08-13 18:55:40');
/*!40000 ALTER TABLE `sop_version_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sop_versions`
--

DROP TABLE IF EXISTS `sop_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sop_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sop_id` int NOT NULL,
  `version` int NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `change_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sop_versions`
--

LOCK TABLES `sop_versions` WRITE;
/*!40000 ALTER TABLE `sop_versions` DISABLE KEYS */;
INSERT INTO `sop_versions` VALUES (2,2,1,'uploads\\\\sops\\\\hr-onboarding-sop-v1.txt','Initial version','HR Admin','2026-08-13 16:08:40','hr-onboarding-sop-v1.txt'),(3,2,2,'uploads\\\\sops\\\\hr-onboarding-sop-v2.txt','Added BGV step and buddy program','HR Admin','2026-08-13 16:08:40','hr-onboarding-sop-v2.txt'),(4,3,1,'uploads\\\\sops\\\\sales-call-handling-sop.txt','Initial version','HR Admin','2026-08-13 16:08:40','sales-call-handling-sop.txt'),(5,4,1,'uploads\\\\sops\\\\it-security-sop.txt','Initial version','HR Admin','2026-08-13 16:08:40','it-security-sop.txt'),(6,5,1,'uploads/sops/Recruitment-SOP-Template.pdf','Initial version','HR Admin','2026-08-13 16:08:40','Recruitment-SOP-Template.pdf'),(7,6,1,'uploads/sops/Leave-Policy-SOP-Template.pdf','Initial version','HR Admin','2026-08-13 16:08:40','Leave-Policy-SOP-Template.pdf'),(8,7,1,'D:\\HRMS_new\\HRMS_new\\HRMS\\HRMS Merging\\backen\\uploads\\sops\\1786647340870-757887530.txt','v1','HR','2026-08-13 18:55:40','sop-report.txt'),(9,8,1,'uploads/sops/Employee-Onboarding-SOP-Template.pdf','Initial release','System','2026-08-14 04:48:38','Employee-Onboarding-SOP-Template.pdf'),(10,9,1,'uploads/sops/Payroll-Attendance-SOP-Template.pdf','Initial release','System','2026-08-14 04:48:38','Payroll-Attendance-SOP-Template.pdf'),(11,10,1,'uploads/sops/Performance-Management-SOP-Template.pdf','Initial release','System','2026-08-14 04:48:38','Performance-Management-SOP-Template.pdf'),(12,11,1,'others/1788947601964-890807041.pdf','Initial version','Super Admin','2026-09-09 09:53:21',NULL);
/*!40000 ALTER TABLE `sop_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sops`
--

DROP TABLE IF EXISTS `sops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('Internal','Client') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Internal',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `current_version` int DEFAULT '1',
  `requires_ack` tinyint(1) DEFAULT '1',
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `requires_training` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sops`
--

LOCK TABLES `sops` WRITE;
/*!40000 ALTER TABLE `sops` DISABLE KEYS */;
INSERT INTO `sops` VALUES (2,'Employee Onboarding SOP','HR','Internal','Standard onboarding process for all new hires.',2,1,1,'HR Admin','2026-08-13 16:08:40','2026-08-13 16:08:40',1),(3,'Sales Call Handling SOP','Sales','Internal','Scripts and rules for inbound/outbound sales calls.',1,1,1,'HR Admin','2026-08-13 16:08:40','2026-08-13 16:08:40',1),(4,'IT Security & Access SOP','IT','Internal','Password, 2FA, device and incident policies.',1,1,1,'HR Admin','2026-08-13 16:08:40','2026-08-13 16:08:40',0),(5,'Recruitment SOP - Sample Format','Recruitment','Client','Editable recruitment SOP template for client HR teams.',1,1,1,'HR Admin','2026-08-13 16:08:40','2026-08-13 16:08:40',0),(6,'Leave Policy SOP - Sample Format','HR','Client','Editable leave policy template for client HR teams.',1,1,1,'HR Admin','2026-08-13 16:08:40','2026-08-13 16:08:40',0),(7,'Multi-file Test SOP','IT','Internal','Testing multi-file upload',1,1,1,'HR','2026-08-13 18:55:40','2026-09-09 06:13:30',0),(8,'Employee Onboarding SOP - Sample Format','HR','Client','Editable 90-day onboarding SOP with pre-joining, Day 1, and 30-60-90 checklists.',1,0,1,'System','2026-08-14 04:48:38','2026-08-14 04:48:38',0),(9,'Payroll & Attendance SOP - Sample Format','Finance','Client','Editable monthly payroll calendar, attendance rules, and compliance SOP.',1,0,1,'System','2026-08-14 04:48:38','2026-08-14 04:48:38',0),(10,'Performance Management SOP - Sample Format','HR','Client','Editable PMS cycle, rating scale, calibration, and PIP process SOP.',1,0,1,'System','2026-08-14 04:48:38','2026-08-14 04:48:38',0),(11,'sjaba','HR','Client','ewew',1,1,0,'Super Admin','2026-09-09 09:53:21','2026-09-09 09:54:11',0);
/*!40000 ALTER TABLE `sops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` varchar(64) NOT NULL,
  `company_id` varchar(64) NOT NULL,
  `plan_tier` enum('STARTER','GROWTH','ENTERPRISE_ROBOTICS') NOT NULL,
  `billing_cycle` enum('MONTHLY','ANNUAL') NOT NULL,
  `price_per_month` decimal(10,2) NOT NULL,
  `started_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `status` enum('ACTIVE','PAST_DUE','CANCELLED') NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sub_company_status` (`company_id`,`status`),
  CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `super_admin_attendance`
--

DROP TABLE IF EXISTS `super_admin_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `super_admin_attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `check_in` time DEFAULT NULL,
  `check_out` time DEFAULT NULL,
  `status` enum('PRESENT','ABSENT','LATE','HALF_DAY','WFH','LEAVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PRESENT',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `method` enum('MANUAL','OTP','WIFI','GEO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'MANUAL',
  `check_in_lat` decimal(10,7) DEFAULT NULL,
  `check_in_lng` decimal(10,7) DEFAULT NULL,
  `check_out_lat` decimal(10,7) DEFAULT NULL,
  `check_out_lng` decimal(10,7) DEFAULT NULL,
  `geo_status` enum('INSIDE','OUTSIDE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `office_id` int DEFAULT NULL,
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=332 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `super_admin_attendance`
--

LOCK TABLES `super_admin_attendance` WRITE;
/*!40000 ALTER TABLE `super_admin_attendance` DISABLE KEYS */;
INSERT INTO `super_admin_attendance` VALUES (7,8,'Aarav Sharma','2026-07-15','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-14 08:06:27','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(8,8,'Aarav Sharma','2026-07-16','00:00:00','00:00:00','LATE',1,'2026-08-13 07:13:50','2026-08-14 08:06:21','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,8,'Aarav Sharma','2026-07-17','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(10,8,'Aarav Sharma','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(11,8,'Aarav Sharma','2026-07-21','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(12,8,'Aarav Sharma','2026-07-22','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(13,8,'Aarav Sharma','2026-07-23','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(14,8,'Aarav Sharma','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(15,8,'Aarav Sharma','2026-07-27',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(16,8,'Aarav Sharma','2026-07-28','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(17,8,'Aarav Sharma','2026-07-29','10:05:00','18:30:00','ABSENT',1,'2026-08-13 07:13:50','2026-08-14 08:06:44','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(18,8,'Aarav Sharma','2026-07-30','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(19,8,'Aarav Sharma','2026-07-31','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(20,8,'Aarav Sharma','2026-08-03','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(21,8,'Aarav Sharma','2026-08-04','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(22,8,'Aarav Sharma','2026-08-05','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(23,8,'Aarav Sharma','2026-08-06','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(24,8,'Aarav Sharma','2026-08-07',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(25,8,'Aarav Sharma','2026-08-10','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(26,8,'Aarav Sharma','2026-08-11','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(27,8,'Aarav Sharma','2026-08-12','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(29,9,'Priya Patel','2026-07-15','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(30,9,'Priya Patel','2026-07-16','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(31,9,'Priya Patel','2026-07-17',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(32,9,'Priya Patel','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(33,9,'Priya Patel','2026-07-21','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(34,9,'Priya Patel','2026-07-22','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(35,9,'Priya Patel','2026-07-23','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(36,9,'Priya Patel','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(37,9,'Priya Patel','2026-07-27','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(38,9,'Priya Patel','2026-07-28',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(39,9,'Priya Patel','2026-07-29','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(40,9,'Priya Patel','2026-07-30','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(41,9,'Priya Patel','2026-07-31','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(42,9,'Priya Patel','2026-08-03','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(43,9,'Priya Patel','2026-08-04','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(44,9,'Priya Patel','2026-08-05','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(45,9,'Priya Patel','2026-08-06','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(46,9,'Priya Patel','2026-08-07','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(47,9,'Priya Patel','2026-08-10','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(48,9,'Priya Patel','2026-08-11','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(49,9,'Priya Patel','2026-08-12','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(50,9,'Priya Patel','2026-08-13','10:05:00','18:30:00','ABSENT',1,'2026-08-13 07:13:50','2026-08-14 08:05:11','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(51,10,'Rohan Verma','2026-07-15','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(52,10,'Rohan Verma','2026-07-16','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(53,10,'Rohan Verma','2026-07-17','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(54,10,'Rohan Verma','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(55,10,'Rohan Verma','2026-07-21','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(56,10,'Rohan Verma','2026-07-22','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(57,10,'Rohan Verma','2026-07-23','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(58,10,'Rohan Verma','2026-07-24','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(59,10,'Rohan Verma','2026-07-27','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(60,10,'Rohan Verma','2026-07-28','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(61,10,'Rohan Verma','2026-07-29',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(62,10,'Rohan Verma','2026-07-30','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(63,10,'Rohan Verma','2026-07-31','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(64,10,'Rohan Verma','2026-08-03','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(65,10,'Rohan Verma','2026-08-04','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(66,10,'Rohan Verma','2026-08-05','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(67,10,'Rohan Verma','2026-08-06','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(68,10,'Rohan Verma','2026-08-07','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(69,10,'Rohan Verma','2026-08-10','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(70,10,'Rohan Verma','2026-08-11','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(71,10,'Rohan Verma','2026-08-12','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(72,10,'Rohan Verma','2026-08-13','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(73,11,'Sneha Iyer','2026-07-15','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(74,11,'Sneha Iyer','2026-07-16','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(75,11,'Sneha Iyer','2026-07-17','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(76,11,'Sneha Iyer','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(77,11,'Sneha Iyer','2026-07-21','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(78,11,'Sneha Iyer','2026-07-22','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(79,11,'Sneha Iyer','2026-07-23','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(80,11,'Sneha Iyer','2026-07-24','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(81,11,'Sneha Iyer','2026-07-27','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(82,11,'Sneha Iyer','2026-07-28','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(83,11,'Sneha Iyer','2026-07-29','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(84,11,'Sneha Iyer','2026-07-30',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(85,11,'Sneha Iyer','2026-07-31','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(86,11,'Sneha Iyer','2026-08-03','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(87,11,'Sneha Iyer','2026-08-04','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(88,11,'Sneha Iyer','2026-08-05','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(89,11,'Sneha Iyer','2026-08-06','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(90,11,'Sneha Iyer','2026-08-07','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(91,11,'Sneha Iyer','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(92,11,'Sneha Iyer','2026-08-11','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(93,11,'Sneha Iyer','2026-08-12','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(94,11,'Sneha Iyer','2026-08-13','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(95,12,'Vikram Singh','2026-07-15','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(96,12,'Vikram Singh','2026-07-16','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(97,12,'Vikram Singh','2026-07-17','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(98,12,'Vikram Singh','2026-07-20',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(99,12,'Vikram Singh','2026-07-21','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(100,12,'Vikram Singh','2026-07-22','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(101,12,'Vikram Singh','2026-07-23','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(102,12,'Vikram Singh','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(103,12,'Vikram Singh','2026-07-27','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(104,12,'Vikram Singh','2026-07-28','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(105,12,'Vikram Singh','2026-07-29','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(106,12,'Vikram Singh','2026-07-30','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(107,12,'Vikram Singh','2026-07-31',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(108,12,'Vikram Singh','2026-08-03','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(109,12,'Vikram Singh','2026-08-04','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(110,12,'Vikram Singh','2026-08-05','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(111,12,'Vikram Singh','2026-08-06','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(112,12,'Vikram Singh','2026-08-07','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(113,12,'Vikram Singh','2026-08-10','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(114,12,'Vikram Singh','2026-08-11',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(115,12,'Vikram Singh','2026-08-12','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(116,12,'Vikram Singh','2026-08-13','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(117,13,'Ananya Das','2026-07-15','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(118,13,'Ananya Das','2026-07-16','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(119,13,'Ananya Das','2026-07-17','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(120,13,'Ananya Das','2026-07-20','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(121,13,'Ananya Das','2026-07-21',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(122,13,'Ananya Das','2026-07-22','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(123,13,'Ananya Das','2026-07-23','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(124,13,'Ananya Das','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(125,13,'Ananya Das','2026-07-27','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(126,13,'Ananya Das','2026-07-28','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(127,13,'Ananya Das','2026-07-29','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(128,13,'Ananya Das','2026-07-30','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(129,13,'Ananya Das','2026-07-31','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(130,13,'Ananya Das','2026-08-03','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(131,13,'Ananya Das','2026-08-04','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(132,13,'Ananya Das','2026-08-05','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(133,13,'Ananya Das','2026-08-06','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(134,13,'Ananya Das','2026-08-07','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(135,13,'Ananya Das','2026-08-10','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(136,13,'Ananya Das','2026-08-11','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(137,13,'Ananya Das','2026-08-12',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(138,13,'Ananya Das','2026-08-13','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(139,14,'Karan Mehta','2026-07-15','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(140,14,'Karan Mehta','2026-07-16','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(141,14,'Karan Mehta','2026-07-17','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(142,14,'Karan Mehta','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(143,14,'Karan Mehta','2026-07-21','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(144,14,'Karan Mehta','2026-07-22',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(145,14,'Karan Mehta','2026-07-23','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(146,14,'Karan Mehta','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(147,14,'Karan Mehta','2026-07-27','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(148,14,'Karan Mehta','2026-07-28','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(149,14,'Karan Mehta','2026-07-29','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(150,14,'Karan Mehta','2026-07-30','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(151,14,'Karan Mehta','2026-07-31','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(152,14,'Karan Mehta','2026-08-03','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(153,14,'Karan Mehta','2026-08-04','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(154,14,'Karan Mehta','2026-08-05','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(155,14,'Karan Mehta','2026-08-06','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(156,14,'Karan Mehta','2026-08-07','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(157,14,'Karan Mehta','2026-08-10','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(158,14,'Karan Mehta','2026-08-11','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(159,14,'Karan Mehta','2026-08-12','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(160,14,'Karan Mehta','2026-08-13',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(161,15,'Divya Nair','2026-07-15','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(162,15,'Divya Nair','2026-07-16','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(163,15,'Divya Nair','2026-07-17','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(164,15,'Divya Nair','2026-07-20','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(165,15,'Divya Nair','2026-07-21','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(166,15,'Divya Nair','2026-07-22','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(167,15,'Divya Nair','2026-07-23',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(168,15,'Divya Nair','2026-07-24','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(169,15,'Divya Nair','2026-07-27','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(170,15,'Divya Nair','2026-07-28','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(171,15,'Divya Nair','2026-07-29','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(172,15,'Divya Nair','2026-07-30','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(173,15,'Divya Nair','2026-07-31','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(174,15,'Divya Nair','2026-08-03',NULL,NULL,'ABSENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(175,15,'Divya Nair','2026-08-04','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(176,15,'Divya Nair','2026-08-05','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(177,15,'Divya Nair','2026-08-06','09:30:00','14:00:00','HALF_DAY',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(178,15,'Divya Nair','2026-08-07','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(179,15,'Divya Nair','2026-08-10','09:30:00','18:30:00','WFH',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(180,15,'Divya Nair','2026-08-11','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(181,15,'Divya Nair','2026-08-12','10:05:00','18:30:00','LATE',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(182,15,'Divya Nair','2026-08-13','09:30:00','18:30:00','PRESENT',1,'2026-08-13 07:13:50','2026-08-13 07:13:50','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(263,200,'Aarav Sharma','2026-08-12','10:05:00','18:30:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 08:10:13','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(264,201,'Bhavna Reddy','2026-08-13','10:07:00','18:11:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(265,202,'Chirag Shah','2026-08-12','09:14:00','17:22:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(266,203,'Deepika Rao','2026-08-11','10:21:00','18:33:00','LATE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(267,204,'Esha Gupta','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(268,205,'Farhan Ali','2026-08-09','10:35:00','18:55:00','WFH',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(269,206,'Gauri Joshi','2026-08-08','09:42:00','17:06:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(270,207,'Harsh Vardhan','2026-08-07','10:49:00','18:17:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(271,208,'Ishita Bose','2026-08-06',NULL,NULL,'LEAVE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(272,209,'Jayant Kapoor','2026-08-05','10:03:00','18:39:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(273,210,'Kavya Menon','2026-08-14','09:10:00','17:50:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(274,211,'Lakshay Arora','2026-08-13','10:17:00','18:01:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(275,212,'Meera Pillai','2026-08-12','09:24:00','17:12:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(276,213,'Nikhil Saxena','2026-08-11','10:31:00','18:23:00','LATE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(277,214,'Ojas Tiwari','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(278,215,'Pooja Bhatt','2026-08-09','10:45:00','18:45:00','WFH',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(279,216,'Qasim Khan','2026-08-08','09:52:00','17:56:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(280,217,'Ritika Malhotra','2026-08-07','10:59:00','18:07:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(281,218,'Sameer Chopra','2026-08-06',NULL,NULL,'LEAVE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(282,219,'Tanvi Desai','2026-08-05','10:13:00','18:29:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(283,220,'Uday Kulkarni','2026-08-14','09:20:00','17:40:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(284,221,'Vaishnavi Hegde','2026-08-13','10:27:00','18:51:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(285,222,'Wasim Sheikh','2026-08-12','09:34:00','17:02:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(286,223,'Yamini Krishnan','2026-08-11','10:41:00','18:13:00','LATE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(287,224,'Zoya Ansari','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(288,225,'Arjun Nambiar','2026-08-09','10:55:00','18:35:00','WFH',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(289,226,'Bhoomi Trivedi','2026-08-08','09:02:00','17:46:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(290,227,'Chetan Rawal','2026-08-07','10:09:00','18:57:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(291,228,'Damini Sood','2026-08-06',NULL,NULL,'LEAVE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(292,229,'Eklavya Mishra','2026-08-05','10:23:00','18:19:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(293,230,'Falguni Vora','2026-08-14','09:30:00','17:30:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(294,231,'Gaurav Bajaj','2026-08-13','10:37:00','18:41:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(295,232,'Heena Qureshi','2026-08-12','09:44:00','17:52:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(296,233,'Irfan Pathan','2026-08-11','10:51:00','18:03:00','LATE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(297,234,'Juhi Chawla','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(298,235,'Kartik Aryan','2026-08-09','10:05:00','18:25:00','WFH',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(299,236,'Lavanya Sastry','2026-08-08','09:12:00','17:36:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(300,237,'Mohit Rana','2026-08-07','10:19:00','18:47:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(301,238,'Neelam Kothari','2026-08-06',NULL,NULL,'LEAVE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(302,239,'Omkar Patil','2026-08-05','10:33:00','18:09:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(303,240,'Prerna Wadhwa','2026-08-14','09:40:00','17:20:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(304,241,'Rahul Dravid','2026-08-13','10:47:00','18:31:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(305,242,'Shreya Ghosh','2026-08-12','09:54:00','17:42:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(306,243,'Tarun Khanna','2026-08-11','10:01:00','18:53:00','LATE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(307,244,'Urvashi Dholakia','2026-08-10',NULL,NULL,'ABSENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(308,245,'Varun Grover','2026-08-09','10:15:00','18:15:00','WFH',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(309,246,'Yashika Jain','2026-08-08','09:22:00','17:26:00','HALF_DAY',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(310,247,'Zubin Mehta','2026-08-07','10:29:00','18:37:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(311,248,'Ankita Lokhande','2026-08-06',NULL,NULL,'LEAVE',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(312,249,'Bharat Thakur','2026-08-05','10:43:00','18:59:00','PRESENT',1,'2026-08-14 04:27:52','2026-08-14 04:27:52','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(315,16,'product intern','2026-08-16','08:49:40','09:39:09','HALF_DAY',1,'2026-08-16 05:49:23','2026-08-20 03:06:04','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(316,17,'Abc','2026-08-16','10:17:57',NULL,'LATE',1,'2026-08-16 05:49:23','2026-08-20 03:06:04','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(317,18,'Aahan shah','2026-08-16','11:19:57','11:20:02','HALF_DAY',1,'2026-08-16 05:49:23','2026-08-20 03:06:04','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(318,17,'Abc','2026-08-26','08:34:34','18:58:00','PRESENT',1,'2026-08-20 02:31:56','2026-08-26 10:10:36','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(319,18,'Aahan shah','2026-08-20','08:34:54',NULL,'PRESENT',1,'2026-08-20 02:49:54','2026-08-20 02:49:54','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(320,18,'Aahan shah','2026-08-26','09:00:00','18:30:00','PRESENT',1,'2026-08-25 14:17:33','2026-08-26 10:10:07','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(322,25,'Testing','2026-08-26','12:15:00','18:46:00','LEAVE',1,'2026-08-26 10:01:27','2026-08-26 10:09:24','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,'CLIENT',10),(323,20,'Phabindra Kumar Sah','2026-09-07','08:12:00','18:13:00','PRESENT',1,'2026-09-07 14:28:20','2026-09-07 14:28:20','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,'CLIENT',19),(324,27,'Aryan','2026-09-07','09:21:00','18:21:00','PRESENT',1,'2026-09-07 14:36:32','2026-09-07 14:36:32','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(325,29,'suhani','2026-09-08','10:05:00','07:06:00','PRESENT',1,'2026-09-08 04:36:09','2026-09-08 04:36:09','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(326,28,'A','2026-09-08','11:39:11','11:39:19','LATE',1,'2026-09-08 06:09:11','2026-09-08 06:09:19','GEO',30.1183100,77.2905600,30.1182650,77.2906585,'INSIDE',2,NULL,NULL),(327,29,'suhani','2026-09-09','14:55:00','18:55:00','PRESENT',1,'2026-09-09 09:26:04','2026-09-09 09:26:04','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,'CLIENT',19),(330,29,'suhani','2026-09-14','22:32:16','22:34:38','HALF_DAY',1,'2026-09-14 17:02:16','2026-09-14 17:04:38','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(331,29,'suhani','2026-09-15','18:31:47',NULL,'LATE',1,'2026-09-15 13:01:47','2026-09-15 13:01:47','MANUAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `super_admin_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `super_admin_targets`
--

DROP TABLE IF EXISTS `super_admin_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `super_admin_targets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` int NOT NULL,
  `assigned_by` int DEFAULT NULL,
  `quarter` enum('Q1','Q2','Q3','Q4') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `metrics` json DEFAULT NULL,
  `target_value` int DEFAULT NULL,
  `current_value` int DEFAULT '0',
  `unit` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `status` enum('pending','in_progress','completed','overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `priority` enum('high','medium','low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `super_admin_targets_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `super_admin_targets`
--

LOCK TABLES `super_admin_targets` WRITE;
/*!40000 ALTER TABLE `super_admin_targets` DISABLE KEYS */;
INSERT INTO `super_admin_targets` VALUES (1,'TYHGW4RREFDSRETE35T',26,NULL,NULL,NULL,NULL,4,4,'W','2026-09-03','completed','medium',1,'2026-09-03 12:12:54','2026-09-03 12:13:34'),(2,'Full stack',28,NULL,NULL,NULL,NULL,2000,0,'22','2026-09-09','pending','medium',1,'2026-09-08 06:12:26','2026-09-08 06:12:26'),(3,'complete 20 bugs ',25,NULL,NULL,NULL,NULL,20,13,'bugs','2026-09-09','in_progress','high',1,'2026-09-08 14:51:50','2026-09-09 09:11:02'),(4,'wrfrrr',29,NULL,NULL,NULL,NULL,20,2,'calls','2026-09-10','in_progress','high',1,'2026-09-09 16:55:18','2026-09-09 18:01:47');
/*!40000 ALTER TABLE `super_admin_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `super_admins`
--

DROP TABLE IF EXISTS `super_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `super_admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('ACTIVE','BLOCKED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `two_factor_enabled` tinyint(1) DEFAULT '0',
  `otp_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otp_channel` enum('EMAIL','SMS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'EMAIL',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `super_admins`
--

LOCK TABLES `super_admins` WRITE;
/*!40000 ALTER TABLE `super_admins` DISABLE KEYS */;
INSERT INTO `super_admins` VALUES (1,'Super Admin','admin@hrms.com','$2b$10$25UGkieqwbbNjHh0mgFki.Pj7wKcfG5xwQRqSmkpjL.TTwIPCttjK','ACTIVE','2026-08-12 17:26:29','2026-08-23 06:21:34',0,NULL,NULL,NULL,'EMAIL');
/*!40000 ALTER TABLE `super_admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `superadmin_sales_calls`
--

DROP TABLE IF EXISTS `superadmin_sales_calls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `superadmin_sales_calls` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `employee_id` int NOT NULL,
  `call_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `call_time` time DEFAULT NULL,
  `call_date` date DEFAULT NULL,
  `status` enum('hold','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'hold',
  `follow_up_datetime` datetime DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sold_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `salary` decimal(12,2) DEFAULT NULL,
  `ctc` decimal(14,2) DEFAULT NULL,
  `lpa` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_client` (`client_id`),
  KEY `idx_employee` (`employee_id`),
  KEY `idx_status` (`status`),
  KEY `idx_followup` (`follow_up_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `superadmin_sales_calls`
--

LOCK TABLES `superadmin_sales_calls` WRITE;
/*!40000 ALTER TABLE `superadmin_sales_calls` DISABLE KEYS */;
INSERT INTO `superadmin_sales_calls` VALUES (1,1,10,'CALL-MOCK-01','Mock Customer','9888777666','mock.customer@test.dev',NULL,'14:30:00','2026-08-13','hold',NULL,'Mock call: product demo discussed','2026-08-13','2026-08-13 14:52:52','2026-08-13 14:52:52',NULL,NULL,NULL),(2,1,10,'20260813-0001','Language Test Customer','9777666555','','Hindi','11:00:00','2026-08-13','hold',NULL,'',NULL,'2026-08-13 15:19:05','2026-08-13 15:19:05',NULL,NULL,NULL),(3,10,25,'20260825-0001','Test','9988776655','abcde@gmail.com','Hindi','09:35:00','2026-08-25','hold','2026-08-25 09:36:00','kjhgfdsa','2026-08-25','2026-08-25 15:51:29','2026-08-25 15:51:29',987654.00,11851848.00,118.52),(4,19,29,'20260908-0001','Advay','9588382137','advay708@gmail.com','Hindi','12:57:00','2026-09-08','hold','2026-09-09 12:57:00','','2026-09-08','2026-09-08 07:27:40','2026-09-08 07:27:40',NULL,NULL,NULL);
/*!40000 ALTER TABLE `superadmin_sales_calls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tax_records`
--

DROP TABLE IF EXISTS `tax_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tax_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `type` enum('GST','TDS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `createdAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tax_records`
--

LOCK TABLES `tax_records` WRITE;
/*!40000 ALTER TABLE `tax_records` DISABLE KEYS */;
INSERT INTO `tax_records` VALUES (4,19,'GST',2000.00,'2026-09-08','',NULL,NULL);
/*!40000 ALTER TABLE `tax_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_leaders`
--

DROP TABLE IF EXISTS `team_leaders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_leaders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'TL',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_leaders`
--

LOCK TABLES `team_leaders` WRITE;
/*!40000 ALTER TABLE `team_leaders` DISABLE KEYS */;
INSERT INTO `team_leaders` VALUES (1,'Team Leader','tl@hrms.com','$2b$10$mFcAR4gdTFhtQ6H52/wXqeu1QNFkLVG2yewu/mBYEwHX1C9II2u8W','TL',1,'2026-08-12 17:26:30');
/*!40000 ALTER TABLE `team_leaders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `training_assignments`
--

DROP TABLE IF EXISTS `training_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `training_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('Assigned','In Progress','Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Assigned',
  `completion_date` date DEFAULT NULL,
  `score` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `training_id` (`training_id`),
  CONSTRAINT `training_assignments_ibfk_1` FOREIGN KEY (`training_id`) REFERENCES `trainings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_assignments`
--

LOCK TABLES `training_assignments` WRITE;
/*!40000 ALTER TABLE `training_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trainings`
--

DROP TABLE IF EXISTS `trainings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trainings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trainer` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mode` enum('Online','Offline','Hybrid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Online',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Planned','Ongoing','Completed','Cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Planned',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trainings`
--

LOCK TABLES `trainings` WRITE;
/*!40000 ALTER TABLE `trainings` DISABLE KEYS */;
/*!40000 ALTER TABLE `trainings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `role` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `jti` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `device` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revoked` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jti` (`jti`)
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
INSERT INTO `user_sessions` VALUES (1,1,'SUPER_ADMIN','ea0bff2858d2bb93c6ef4a8647038a1202673fa5512ba507','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-13 08:47:18','2026-08-13 09:53:36'),(2,1,'SUPER_ADMIN','4b296950b803427f6e25ba61edbbe5bf6065df77f70c8e6d','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',1,'2026-08-13 08:47:33','2026-08-13 08:47:33'),(3,1,'SUPER_ADMIN','e218e10c381aa8221bbf0ac9836eb7620d1b00196580b499','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-13 08:47:52','2026-08-13 08:47:52'),(4,1,'SUPER_ADMIN','1786c52c45f574f50ed4b90921548428391a2bd11772669d','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9168','::ffff:127.0.0.1',0,'2026-08-14 01:54:48','2026-08-14 01:54:48'),(5,1,'SUPER_ADMIN','c0aa10c2e1ccb3a1f85603945723df7b25776149a4a15400','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9168','::ffff:127.0.0.1',0,'2026-08-14 01:56:41','2026-08-14 01:56:41'),(6,1,'SUPER_ADMIN','96bdc9ecb61a07afa7f63afc41215b1ee347a2d7a032aa7c','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9168','::ffff:127.0.0.1',0,'2026-08-14 03:27:07','2026-08-14 03:27:07'),(7,1,'SUPER_ADMIN','ba829836ad99e101679bada4672effeda80732fa70b04cbd','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-14 03:29:40','2026-08-14 08:34:40'),(8,1,'SUPER_ADMIN','0865ad24acdbb5fb2a5a2ee1aa459276afa610f76c87ffcf','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9168','::1',0,'2026-08-14 06:42:22','2026-08-14 08:10:13'),(9,1,'SUPER_ADMIN','c2b0543d211836ac8c17115e9857c8df486153886f0e5f76','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-14 09:35:54','2026-08-14 12:49:14'),(10,1,'SUPER_ADMIN','93787e5cb18ae9f74571fc253f628c8c9bda45c5cb3adcd5','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-14 10:13:16','2026-08-14 10:22:55'),(11,1,'SUPER_ADMIN','130adb473b7791fda31ca6d8d23b7aee2d4ab8dd26c33be6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-14 12:49:44','2026-08-14 13:21:42'),(12,1,'SUPER_ADMIN','8eafae31a329dd93a9a50c2db28c0854efbd2d028010f7cf','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-14 13:06:41','2026-08-14 13:06:45'),(13,1,'SUPER_ADMIN','5c69ad32fec6336b66a2854facdbc0369a8ea7d93f116347','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-14 13:25:23','2026-08-14 13:28:23'),(14,1,'SUPER_ADMIN','29f277ca8ec0a44eaf9963a27affdab8f4a0cec796508668','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-14 13:28:45','2026-08-14 13:48:56'),(15,1,'SUPER_ADMIN','25258d3334d6fc1b14d7013f698ad86bc6ba8c9bf5d26c93','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-14 16:40:57','2026-08-14 17:38:56'),(16,1,'SUPER_ADMIN','74d52466ca1d57a49296b5c4f21ede4ded8b991a0a7f70da','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-15 05:41:16','2026-08-15 06:47:03'),(17,1,'SUPER_ADMIN','18853ae8465cef409a1d4eae7d8ebd5558b2dcdb750331f5','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-16 03:47:07','2026-08-16 17:21:10'),(18,1,'SUPER_ADMIN','19e24f306d5bbf06a37e01f39f4f138df488d1d6afc74fc0','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-17 08:40:04','2026-08-17 08:58:58'),(19,1,'SUPER_ADMIN','458806de80b9adaee66033a5d25599ef3bf7d2819ab9b11c','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-17 09:34:07','2026-08-17 09:41:37'),(20,1,'SUPER_ADMIN','ddadec42b6b8dcaab9ece408d80ecdb584a098607d6e7f3a','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-18 03:28:10','2026-08-18 03:28:19'),(21,1,'SUPER_ADMIN','65f8c582c1c5085fac5ad86c61730d6517fa64b967d6af00','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-18 03:40:04','2026-08-18 03:40:05'),(22,1,'SUPER_ADMIN','f7f494a16dd5c535ccdf75fa0d25bd32b85e4b164e31a7e5','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-18 03:42:27','2026-08-18 03:42:27'),(23,1,'SUPER_ADMIN','55ab576e10bd5ffcf74fb2c2de5de72504b96779977d3a70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-18 13:34:19','2026-08-18 13:43:10'),(24,1,'SUPER_ADMIN','7b654e45644d95705f7722e3cb1df8f04dd249a05a60f322','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-19 09:54:50','2026-08-19 09:54:50'),(25,1,'SUPER_ADMIN','e4dfb98ea1a1c1916776d820d822e117cedd32b7e6f5664c','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 04:48:24','2026-08-21 04:48:26'),(26,1,'SUPER_ADMIN','6dc5bd6de3e4353b9012488b8c64fe63e5d421060e02ec9b','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 04:54:27','2026-08-21 04:54:28'),(27,1,'SUPER_ADMIN','55628a4fa41d1c3c2360cbc44d056e594ee89576d0a12bde','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 04:55:40','2026-08-21 04:55:41'),(28,1,'SUPER_ADMIN','eb6fa12e8ad3174b0b7ffbb43f6b2d2a40cf12eb23c1c62a','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 05:00:41','2026-08-21 05:00:42'),(29,1,'SUPER_ADMIN','9a76d06dec0bb82cf43abcf330e7da4a0797663bd7e24eed','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 05:05:43','2026-08-21 05:05:43'),(30,1,'SUPER_ADMIN','d9f0c1680f7cbb3c098747ea9718f4421cb1b23535887e19','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-21 05:12:50','2026-08-21 09:43:49'),(31,1,'SUPER_ADMIN','6d4d330a97d00e08ceaa70ce38ba180dda4a9248d29f32c4','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 05:33:44','2026-08-21 05:33:44'),(32,1,'SUPER_ADMIN','5a04af5271c985fc6ce4d72fa1364a9973dadc09b6ea1fab','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 05:42:49','2026-08-21 05:42:49'),(33,1,'SUPER_ADMIN','3c8578502d9c5344d99d8caa5b0f954d9226e9e964122724','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 05:58:34','2026-08-21 05:58:34'),(34,1,'SUPER_ADMIN','bcae52c052143e328e34e8ebd847554502f837d268fcbd30','python-requests/2.34.2','::ffff:127.0.0.1',0,'2026-08-21 06:16:39','2026-08-21 06:16:39'),(35,1,'SUPER_ADMIN','e5b9d2b83b851e3187bfc49333c4ba3309c8d3dce522823a','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-22 07:20:50','2026-08-22 10:49:12'),(36,1,'SUPER_ADMIN','6dfed8b0bfe4dca1f3a55139b826257a4891991839f7f4c8','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-22 14:13:25','2026-08-22 14:13:26'),(37,1,'SUPER_ADMIN','db4f414da3cbbd145bd45df0261b0810eec4cc34c5515757','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-22 15:12:05','2026-08-22 18:59:21'),(38,1,'SUPER_ADMIN','cd88fb114967276f800f5737c8489c40b8e19a43ee09db8a','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9168','::1',0,'2026-08-22 16:17:36','2026-08-22 16:17:36'),(39,1,'SUPER_ADMIN','238c198f15f11660ddd331389cc5b8bd9a071cd8537cdc4b','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-22 19:03:58','2026-08-23 03:24:45'),(40,1,'SUPER_ADMIN','b77c6cc5eb78fc907fd03e25feff44f07238e7df224e662d','node','::1',0,'2026-08-22 19:13:07','2026-08-22 19:13:07'),(41,1,'SUPER_ADMIN','e41faff0fbacdbac9c2b0b05318b77724607c125a11d55e6','node','::1',0,'2026-08-22 19:13:56','2026-08-22 19:13:56'),(42,1,'SUPER_ADMIN','5d59d6b81c8c887518140cd9e53f42e239c64c9be477bde1','node','::1',0,'2026-08-22 19:14:49','2026-08-22 19:14:49'),(43,1,'SUPER_ADMIN','9015edff09b71e9e59d707469dfd64ab1e031363da796285','node','::1',0,'2026-08-22 19:20:12','2026-08-22 19:20:12'),(44,1,'SUPER_ADMIN','d21a1eef744280d88b0bfd55badb3e1ae2b1ea6fbe68f3a7','node','::1',0,'2026-08-22 19:21:42','2026-08-22 19:21:42'),(45,1,'SUPER_ADMIN','ad6616e25a77a87ce54ec37db550b390ddc55431c538c39a','node','::1',0,'2026-08-23 04:01:38','2026-08-23 04:01:39'),(46,1,'SUPER_ADMIN','5e78802fe12114c521c367b930a3af871968d303f6e6c16b','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-23 04:05:45','2026-08-25 13:58:40'),(47,1,'SUPER_ADMIN','d4f7311c1b7cc91e0c3dd92daefeb94d072cc660e1e1a0e6','node','::1',0,'2026-08-23 04:21:17','2026-08-23 04:21:17'),(48,1,'SUPER_ADMIN','8db14c54e7174e1ee51528942322aec0e28eaca63135d79b','node','::1',0,'2026-08-23 04:22:24','2026-08-23 04:22:25'),(49,1,'SUPER_ADMIN','9ea9d80189e9a7f2c3590d084cda87206e6a9555f603decb','node','::1',0,'2026-08-23 04:23:00','2026-08-23 04:23:00'),(50,1,'SUPER_ADMIN','c881f88031faf9c1f6f9080a54f003f4314576f6ba9f6e53','node','::1',0,'2026-08-23 04:23:38','2026-08-23 04:23:38'),(51,1,'SUPER_ADMIN','7312d29b792f1f0bf0c778a0c86f1880bdf185cac4583c13','node','::1',0,'2026-08-23 04:25:53','2026-08-23 04:25:53'),(52,1,'SUPER_ADMIN','7153c90e6ddd0a0a761e07e9fef31a041a25a5f959ce12a0','node','::1',0,'2026-08-23 04:26:24','2026-08-23 04:26:24'),(53,1,'SUPER_ADMIN','125151088fcb9712964ccaa2eb3b8804c13a5a0e557a4753','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-23 07:13:59','2026-08-23 07:16:04'),(54,1,'SUPER_ADMIN','9f248d180bc28614c67544680f45acab17a079ef17ebaaa5','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-23 07:16:59','2026-08-23 07:49:40'),(55,1,'SUPER_ADMIN','7263ab93ccf890be50018d8e0bfa6b7fb8f01472b03ea9cc','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-23 09:29:11','2026-08-23 09:31:12'),(56,1,'SUPER_ADMIN','cd491e65deeda5d378bce130e809504652170d8da8558697','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-23 09:46:27','2026-08-27 03:37:59'),(57,1,'SUPER_ADMIN','76bdf146d9de7cc883e42d41cd3111c277525c72b221979b','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-24 05:40:50','2026-08-24 07:24:30'),(58,1,'SUPER_ADMIN','0cf015b4f2cbe01f3e066a507ccd1a728757763fe82c0502','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-08-24 14:23:10','2026-08-24 23:20:46'),(59,1,'SUPER_ADMIN','7fcd73fc4410f994916aef976942baf2ecbd41fa3b0f2539','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-25 13:59:13','2026-08-25 14:00:19'),(60,1,'SUPER_ADMIN','f4c6669dbc146da7e98aa18375631870028004530983f054','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-25 14:01:03','2026-08-25 14:02:03'),(61,1,'SUPER_ADMIN','25dbefdcd2975ce81e2d197fe50c29dee21de07830d5e307','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-25 14:02:44','2026-08-25 17:55:58'),(62,1,'SUPER_ADMIN','18358d42036f9ccc2b9c64567fe6865aaeeeb1e694e7fd6e','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-27 03:38:19','2026-08-27 05:22:48'),(63,1,'SUPER_ADMIN','aa2c6a48355f83861dad07916903c9045fb67f23099090d3','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-29 02:14:03','2026-08-31 06:19:43'),(64,1,'SUPER_ADMIN','3c305609d2f039f52de50c3160907aee44dead1b81b99eb0','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-31 06:20:02','2026-08-31 07:55:34'),(65,1,'SUPER_ADMIN','40e86575099ba495ecc19cc368708deb22521113b0041585','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-08-31 07:56:18','2026-09-01 02:29:08'),(66,1,'SUPER_ADMIN','9b2b850a9009658d8c79af3b5a1dcc35010710be35be9639','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-09-01 03:12:35','2026-09-01 03:19:11'),(67,1,'SUPER_ADMIN','8afc5adcbf4b50a3aa8bd19ec7cffd2860b7cf25a5cda42f','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','::1',0,'2026-09-01 03:19:56','2026-09-07 14:01:37'),(68,1,'SUPER_ADMIN','864da609778c041b9e903ec2276aeed1a58dcc99e157fa27','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-02 06:19:21','2026-09-02 07:59:13'),(69,1,'SUPER_ADMIN','a5c7b00f392a017d451a95584fa9f4975565ef987a87ef74','node','::1',0,'2026-09-02 07:38:08','2026-09-02 07:38:08'),(70,1,'SUPER_ADMIN','ce82e9d9cbba2a3cbbfc57d881a40712828c3e8855f2d437','node','::1',0,'2026-09-02 07:38:24','2026-09-02 07:38:24'),(71,1,'SUPER_ADMIN','1f4c78da5885c174ee0af980e7c96e7a3c111050e4a8cb56','node','::1',0,'2026-09-02 07:46:51','2026-09-02 07:46:51'),(72,1,'SUPER_ADMIN','998f17365c2e6c232be23c1c24adcc0f712acd6da4a0491a','node','::1',0,'2026-09-02 09:23:27','2026-09-02 09:23:27'),(73,1,'SUPER_ADMIN','b67d044c16279261b06cebc9d9238b963cf25a61e107212e','node','::1',0,'2026-09-02 09:31:52','2026-09-02 09:31:52'),(74,1,'SUPER_ADMIN','7d63c3198a4353ccb7a21d2cc1e7f4fd1b41d98820a4978b','node','::1',0,'2026-09-02 09:36:03','2026-09-02 09:36:03'),(75,1,'SUPER_ADMIN','92295a33c7b36d3e49b091b97b80f86fb5e4f0e5e4289542','node','::1',0,'2026-09-02 09:56:50','2026-09-02 09:56:50'),(76,1,'SUPER_ADMIN','c6852763962cfaa6b14afece3f205be8b967a57834aaa16f','node','::1',0,'2026-09-02 09:57:03','2026-09-02 09:57:04'),(77,1,'SUPER_ADMIN','17ca2de2711302a84decfc2c575cbc212f2cdd85bb269f72','node','::1',0,'2026-09-02 09:57:48','2026-09-02 09:57:48'),(78,1,'SUPER_ADMIN','c3788b01bd9340cee819b649331a694ab867fd9dc4c6c8c7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-02 18:33:49','2026-09-02 18:45:17'),(79,1,'SUPER_ADMIN','19ff8b2137cb018614acd28539b58f4aba591f5f655882a0','Python-urllib/3.13','::1',0,'2026-09-03 09:30:25','2026-09-03 09:30:25'),(80,1,'SUPER_ADMIN','d27e3be63fa6d00f4caa24f8fb39e970d99aff6fb875029e','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9278','::1',0,'2026-09-03 09:32:49','2026-09-03 09:32:49'),(81,1,'SUPER_ADMIN','0859e333ce393e0ec069f49a54297407f1c82aa421c24d19','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.9278','::1',0,'2026-09-03 09:33:07','2026-09-03 09:33:07'),(82,1,'SUPER_ADMIN','eba01737cf3fd89629a51559e82c7c72f539afc6cb3f3616','node','::1',0,'2026-09-03 09:41:13','2026-09-03 09:41:13'),(83,1,'SUPER_ADMIN','f5273c0aa94e9faea53e8c2a1960c7e45582453dc97903c3','node','::1',0,'2026-09-03 09:41:41','2026-09-03 09:41:41'),(84,1,'SUPER_ADMIN','b9217fa5e73b538ba81435f36753fa87e7bde43228ea33b1','node','::1',0,'2026-09-03 09:57:55','2026-09-03 09:57:55'),(85,1,'SUPER_ADMIN','8cf7b39cd4ee439101473c8c0da7e3adc5c5f5c31bb36f13','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-03 09:59:41','2026-09-03 10:02:32'),(86,1,'SUPER_ADMIN','80ffb5075644fa69b14370fcfaacad657718db5636b7d2f0','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-03 10:40:40','2026-09-03 11:20:44'),(87,1,'SUPER_ADMIN','469fc9d6802adc0e1973a54a77aa5e16a27f036cf81cf617','node','::1',0,'2026-09-03 13:05:16','2026-09-03 13:05:16'),(88,1,'SUPER_ADMIN','e35eeedb3cfe334b1c4afd34a1c10d83d07b9efc463bb6b3','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-03 13:08:01','2026-09-03 13:10:01'),(89,1,'SUPER_ADMIN','d48c957d189790e2e7ca7424865043e46263cb3e32e8788b','node','::1',0,'2026-09-03 13:22:53','2026-09-03 13:22:53'),(90,1,'SUPER_ADMIN','08d3ba8edeedaa942500bc90903873aa24f1d52352f084ef','node','::1',0,'2026-09-04 02:19:53','2026-09-04 02:19:53'),(91,1,'SUPER_ADMIN','c09e75490fad72dba25e0d22d28c765f9b787076c771b0b5','node','::1',0,'2026-09-04 02:20:07','2026-09-04 02:20:08'),(92,1,'SUPER_ADMIN','81870d7e89cdb7eccf2502e4e9ac209186f3e24c075ed307','node','::1',0,'2026-09-04 02:20:08','2026-09-04 02:20:09'),(93,1,'SUPER_ADMIN','e5356daea4218df06cbd14f59aff281cdda36aae4fd7c4f2','node','::1',0,'2026-09-04 02:20:40','2026-09-04 02:20:40'),(94,1,'SUPER_ADMIN','cf84d99c04c5223e6f8028a4b41d6f6856fcd0908a611ff8','node','::ffff:127.0.0.1',0,'2026-09-07 07:30:48','2026-09-07 07:30:50'),(95,1,'SUPER_ADMIN','5ca9a05732dc46a3e6cb3321df1f89e24ffbab5864904058','node','::ffff:127.0.0.1',0,'2026-09-07 07:33:24','2026-09-07 07:33:26'),(96,1,'SUPER_ADMIN','69a6cb11ae9f4c47570d2724073dee6bc0ca819c8dc7d54f','node','::ffff:127.0.0.1',0,'2026-09-07 07:38:34','2026-09-07 07:38:34'),(97,1,'SUPER_ADMIN','2730854da07a18660581bebb23d3ebeee9ef32dc58a7a553','curl/8.21.0','::ffff:127.0.0.1',0,'2026-09-07 07:38:55','2026-09-07 07:38:55'),(98,1,'SUPER_ADMIN','563c0eb6138e9459237064e9b291dfbd01293ac1fc771a45','node','::ffff:127.0.0.1',0,'2026-09-07 07:39:47','2026-09-07 07:39:48'),(99,1,'SUPER_ADMIN','2c547df105c868e85bdc09cf21d8f434f758b098ececbf79','node','::ffff:127.0.0.1',0,'2026-09-07 07:55:51','2026-09-07 07:55:51'),(100,1,'SUPER_ADMIN','23ac576796bba657e01ca5421b5e051412b968b689068100','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 07:58:00','2026-09-07 07:58:02'),(101,1,'SUPER_ADMIN','3e1bdacf6844967cb57ef1b124ab325e599268612afd12c7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 07:58:45','2026-09-07 07:58:49'),(102,1,'SUPER_ADMIN','fed0b54b91b93de7ddd95188dcc586c5dce3a19d5692d9a8','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 07:59:30','2026-09-07 07:59:33'),(103,1,'SUPER_ADMIN','844b03920bfbecdcc67067b274a2f06ce29b914283eac36a','node','::ffff:127.0.0.1',0,'2026-09-07 08:00:00','2026-09-07 08:00:00'),(104,1,'SUPER_ADMIN','b5113986f06d97ba8a0476ce84781dea5da0ff518ace419b','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 08:00:19','2026-09-07 09:07:20'),(105,1,'SUPER_ADMIN','934480cfed2cbeef6813756859f288458d2d96e4b9e8d9bc','node','::ffff:127.0.0.1',0,'2026-09-07 08:50:23','2026-09-07 08:50:23'),(106,1,'SUPER_ADMIN','ca232ac2cb0e8ed01206c949a984ad795b28a8c13e238957','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 09:15:37','2026-09-07 09:40:30'),(107,1,'SUPER_ADMIN','3f13962942fc18948ad86c680e959696c8abdca8e670fbad','node','::ffff:127.0.0.1',0,'2026-09-07 09:34:02','2026-09-07 09:34:02'),(108,1,'SUPER_ADMIN','f74da636c1b48fd26679564a9ca10bcb5b0b2fcb0ff86fc6','node','::ffff:127.0.0.1',0,'2026-09-07 09:56:22','2026-09-07 09:56:23'),(109,1,'SUPER_ADMIN','f2096d7aaebde2090bf67cd278c44e11b9a4150293a394d0','node','::ffff:127.0.0.1',0,'2026-09-07 09:57:04','2026-09-07 09:57:04'),(110,1,'SUPER_ADMIN','2a0c77d03d732db36ecf85b75841547b3de07ea4f3fa5648','node','::ffff:127.0.0.1',0,'2026-09-07 10:04:39','2026-09-07 10:04:40'),(111,1,'SUPER_ADMIN','d418b866054ec2db0aaf150c6429454273c69ba50b730b20','node','::ffff:127.0.0.1',0,'2026-09-07 10:05:23','2026-09-07 10:05:24'),(112,1,'SUPER_ADMIN','4574a6c9d0da7994d0f0beb03ead8f0795fb6870c8f12743','node','::ffff:127.0.0.1',0,'2026-09-07 10:05:42','2026-09-07 10:05:42'),(113,1,'SUPER_ADMIN','9c78867c40a402aaa3796099b5cc3321267eb2c8028d1944','node','::ffff:127.0.0.1',0,'2026-09-07 10:05:57','2026-09-07 10:05:57'),(114,1,'SUPER_ADMIN','ca22a65480ab263f3f5e3fdab4a0aede86cfb29e1e17b65b','node','::ffff:127.0.0.1',0,'2026-09-07 10:06:40','2026-09-07 10:06:40'),(115,1,'SUPER_ADMIN','3e1c01e990f2f865800e8b42b0ba081a36071d26ec77f71a','node','::1',0,'2026-09-07 10:06:57','2026-09-07 10:06:57'),(116,1,'SUPER_ADMIN','3206f7047921574fed4c34f2ab884cd9a90675576dcdfa7a','node','::1',0,'2026-09-07 10:06:58','2026-09-07 10:06:58'),(117,1,'SUPER_ADMIN','3f3d337a2bd18b073731fbce2ce4cfab476183b280fccf31','node','::ffff:127.0.0.1',0,'2026-09-07 10:07:56','2026-09-07 10:07:57'),(118,1,'SUPER_ADMIN','73849d80621ed8cbd1e733e0a8733067a3b508cf283b57ba','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-07 14:01:56','2026-09-07 14:47:01'),(119,1,'SUPER_ADMIN','e883be10b3ed2f3700a6a9c01048cf10deab07ba7bea8dfc','node','::1',0,'2026-09-07 14:13:29','2026-09-07 14:13:29'),(120,1,'SUPER_ADMIN','c6cc322ca12c9b520ab0ab5262dd5021002cb4d0f7a005d9','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36','::1',0,'2026-09-07 14:14:37','2026-09-07 14:32:38'),(121,1,'SUPER_ADMIN','66fb4d10b10aaede399fad80fd4d6832debac31ea8de29eb','node','::ffff:127.0.0.1',0,'2026-09-07 14:49:38','2026-09-07 14:49:40'),(122,1,'SUPER_ADMIN','756e781e4f6292e0b2a7b26ff3bbec689f7b44c30c0d5f57','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-07 17:14:59','2026-09-07 19:04:22'),(123,1,'SUPER_ADMIN','cdd6c9f539dd7b03a80a8d589732e1c4b17e9ff0bbab3b42','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-07 19:04:44','2026-09-07 19:17:46'),(124,1,'SUPER_ADMIN','4178e9f36ed37bbd523d0708453b761829268bb76a034921','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-07 19:18:08','2026-09-08 08:31:33'),(125,1,'SUPER_ADMIN','75453c6f03ed6daf5ee3e9289a77a8d5052ff78c2800b139','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-08 12:14:44','2026-09-08 13:15:38'),(126,1,'SUPER_ADMIN','4b8968f906bec9e065f9b56a6d3533b8b29c62857a027b25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-08 13:33:38','2026-09-09 17:20:30'),(127,1,'SUPER_ADMIN','6abba19a4ea1d98cc4dbde265a54a562c9e4c6f47c2b2083','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-09 17:20:39','2026-09-09 18:17:11'),(128,1,'SUPER_ADMIN','c85a9ed84e3ba4b1c9bbfebae801b19655c44dd984d94554','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-09 18:27:07','2026-09-09 18:40:07'),(129,1,'SUPER_ADMIN','1059c19b4db70912ec72c2995ad284d019a23d8052906cf1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-09 18:40:57','2026-09-09 19:17:51'),(130,1,'SUPER_ADMIN','8d799330de4a97d470b6598c8cb71f9e56d5f5da838c664c','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-09 19:31:59','2026-09-09 20:20:46'),(131,1,'SUPER_ADMIN','3231403b40c4691040f5ab5c8ccd68b4b6db9521b1cd643b','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-10 02:24:14','2026-09-14 16:58:10'),(132,1,'SUPER_ADMIN','2ff37f5ad389fac2fe667e7db6a1bc93f7f4666498975912','node','::1',0,'2026-09-14 13:50:15','2026-09-14 13:50:15'),(133,1,'SUPER_ADMIN','5bceb0ed7a188df46f7c8004b9f6bf08d76e58aeb824f6ca','node','::1',0,'2026-09-14 14:11:50','2026-09-14 14:11:50'),(134,1,'SUPER_ADMIN','a482d97bf370861f632f77b287c23a3c44b16deb97c7ac2a','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-14 16:58:29','2026-09-15 17:24:21'),(135,1,'SUPER_ADMIN','5dd883bab3ea62936f17e188bc2828a24dd74be30a98b205','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-15 17:24:29','2026-09-16 04:31:50'),(136,1,'SUPER_ADMIN','f046e31772f4a8ec501a0063c1614d17c6606631e8bb92dd','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:127.0.0.1',0,'2026-09-15 18:00:33','2026-09-15 18:00:33'),(137,1,'SUPER_ADMIN','209798ed696da499652d4561ffa8167231e92714b2774acb','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-16 04:35:29','2026-09-16 05:24:37'),(138,1,'SUPER_ADMIN','20d6bf2c4fefd1558912b68bdc5be4afb2cc3cad159a4d58','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::1',0,'2026-09-16 05:25:28','2026-09-16 08:27:46'),(139,1,'SUPER_ADMIN','ff4191afd1c7e1582bb5b4b550dcfe8efd8559602f5347a9','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:172.17.242.173',0,'2026-09-16 05:42:42','2026-09-16 05:42:42'),(140,1,'SUPER_ADMIN','aa4b0ee95de22b7ae8590451c4090dc71483da3f72e8e5f2','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:172.17.242.173',0,'2026-09-16 06:35:37','2026-09-16 06:35:37'),(141,1,'SUPER_ADMIN','dbfc8757dffadc62618170b9adcef3279fe26cc063524153','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:172.17.242.173',0,'2026-09-16 06:35:50','2026-09-16 06:35:50'),(142,1,'SUPER_ADMIN','653656b1100348159df969c344884805e28264af4a408a74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:172.17.242.173',0,'2026-09-16 06:41:20','2026-09-16 06:41:20'),(143,1,'SUPER_ADMIN','08fc5181e961ad5f41ed7cb0f2266d042fab063982d9661a','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','::ffff:172.17.242.173',0,'2026-09-16 06:41:52','2026-09-16 06:41:52'),(144,1,'SUPER_ADMIN','c8554992749137b518439cae586ffc69677ae50826f04721','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','::1',0,'2026-09-16 17:00:43','2026-09-16 17:00:44'),(145,1,'SUPER_ADMIN','ef4656144f058060641fc4c2a6768e7bb5d9f5d84dfc63fc','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','::1',0,'2026-09-16 17:01:17','2026-09-16 17:32:38');
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `ix_users_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_audit_logs`
--

DROP TABLE IF EXISTS `verification_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_audit_logs`
--

LOCK TABLES `verification_audit_logs` WRITE;
/*!40000 ALTER TABLE `verification_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `verification_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_documents`
--

DROP TABLE IF EXISTS `verification_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `employee_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `doc_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('Pending','Verified','Rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `verified_by` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_documents`
--

LOCK TABLES `verification_documents` WRITE;
/*!40000 ALTER TABLE `verification_documents` DISABLE KEYS */;
INSERT INTO `verification_documents` VALUES (1,15,'Divya Nair','PAN Card',NULL,'Verified',NULL,'Super Admin','2026-08-14 15:43:23','2026-08-13 07:36:28'),(3,29,'suhani','Aadhaar Card','uploads/others/1788979343803-725500649.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:42','2026-09-09 18:42:23'),(4,29,'suhani','Aadhaar Card','uploads/others/1788979584144-418701148.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:39','2026-09-09 18:46:24'),(5,29,'suhani','Aadhaar Card','uploads/others/1788981166129-115046883.pdf','Verified',NULL,'Super Admin','2026-09-10 00:43:01','2026-09-09 19:12:46'),(6,29,'suhani','PAN Card','uploads/others/1788983153260-406947119.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:17','2026-09-09 19:45:53'),(7,29,'suhani','Address Proof','uploads/others/1788983161299-122238920.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:18','2026-09-09 19:46:01'),(8,29,'suhani','Graduation (if any)','uploads/others/1788983174313-835979179.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:20','2026-09-09 19:46:14'),(9,29,'suhani','Post Graduation (if any)','uploads/others/1788983185746-596235194.jpeg','Verified',NULL,'Super Admin','2026-09-10 01:17:20','2026-09-09 19:46:25'),(10,29,'suhani','Bank Details','uploads/others/1788983204095-79114122.jpeg','Verified',NULL,'Super Admin','2026-09-10 01:17:22','2026-09-09 19:46:44'),(11,29,'suhani','asas','uploads/others/1788983219119-100209544.pdf','Verified',NULL,'Super Admin','2026-09-10 01:17:23','2026-09-09 19:46:59');
/*!40000 ALTER TABLE `verification_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_tokens`
--

DROP TABLE IF EXISTS `verification_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_verification_tokens_token` (`token`),
  KEY `ix_verification_tokens_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_tokens`
--

LOCK TABLES `verification_tokens` WRITE;
/*!40000 ALTER TABLE `verification_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `verification_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitors`
--

DROP TABLE IF EXISTS `visitors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `purpose` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `host_employee_id` int DEFAULT NULL,
  `host_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `badge_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_in` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `check_out` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_checkin` (`check_in`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitors`
--

LOCK TABLES `visitors` WRITE;
/*!40000 ALTER TABLE `visitors` DISABLE KEYS */;
INSERT INTO `visitors` VALUES (1,'rekha','9068945592','ABC','aaddcd',29,'suhani','V543530','2026-09-08 04:42:23',NULL);
/*!40000 ALTER TABLE `visitors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_form_keys`
--

DROP TABLE IF EXISTS `web_form_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `web_form_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `api_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key` (`api_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_form_keys`
--

LOCK TABLES `web_form_keys` WRITE;
/*!40000 ALTER TABLE `web_form_keys` DISABLE KEYS */;
INSERT INTO `web_form_keys` VALUES (1,'0de36df991d4b4bafc10b482bc8202c67e2957cf70aeb4668661ea17cd97d6f5','Company Website',1,'2026-08-13 08:55:44');
/*!40000 ALTER TABLE `web_form_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_form_submissions`
--

DROP TABLE IF EXISTS `web_form_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `web_form_submissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `form_type` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'contact',
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` json DEFAULT NULL,
  `source` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('New','Read','Converted','Archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'New',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_form_submissions`
--

LOCK TABLES `web_form_submissions` WRITE;
/*!40000 ALTER TABLE `web_form_submissions` DISABLE KEYS */;
INSERT INTO `web_form_submissions` VALUES (1,'job_application','Priya Website','priya@web.test','+911234567890','Frontend Developer','Applying via careers page','{\"position\": \"Frontend Developer\"}','http://localhost:5173','Archived','2026-08-13 09:00:00'),(2,'vendor_registration','Acme Supplies','vendor@acme.test',NULL,NULL,'Vendor onboarding request',NULL,'api','Converted','2026-08-13 10:04:56'),(3,'employee_new_joining','New Joiner','joiner@test.dev',NULL,NULL,'Joining form via website',NULL,'api','New','2026-08-13 10:04:56'),(4,'contact','Rahul Sharma','rahul.sharma@example.com','9876543210','Website inquiry','I want to know more about your HRMS product.',NULL,'api','Archived','2026-08-14 16:40:07'),(5,'job_application','Priya Verma','priya.verma@example.com','9812345670','Applying for React Developer','3 years experience in React and Node.','{\"position\": \"React Developer\", \"experience\": \"3 years\"}','api','Converted','2026-08-14 16:40:07'),(6,'enquiry','Amit Patel','amit.patel@example.com',NULL,'Pricing enquiry','What are the pricing plans for 50 employees?',NULL,'api','Read','2026-08-14 16:40:07'),(7,'demo_request','Sneha Iyer',NULL,'9900112233','Demo request','Please schedule a product demo next week.','{\"company\": \"TechNova Pvt Ltd\"}','api','New','2026-08-14 16:40:07');
/*!40000 ALTER TABLE `web_form_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_assignments`
--

DROP TABLE IF EXISTS `work_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `assigned_to` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_to_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','in_progress','completed','overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `progress` int DEFAULT '0',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_assignments`
--

LOCK TABLES `work_assignments` WRITE;
/*!40000 ALTER TABLE `work_assignments` DISABLE KEYS */;
INSERT INTO `work_assignments` VALUES (2,'CVBNM','CVBN','DEMO001','Aarav Sharma','IT',3,'medium','pending','2026-09-03',0,'Super Admin','2026-09-02 18:33:11'),(3,'ASDFGHJ','CBNM','ITDUMMY01','Dummy IT Dev','IT',3,'medium','completed','2026-09-03',100,'Super Admin','2026-09-03 12:06:23'),(4,'full stack','Step 1 — Check Dashboard\n\nAfter login, confirm that you are redirected to:\n\n/employee-dashboard\n\nCheck whether the dashboard loads correctly.\n\nStep 2 — Test Jobs\n\nFrom the dashboard, open Jobs / Find Jobs.\n\nCheck:\n\nJobs are loading\nJob titles are visible\nCompany information appears\nSearch/filter works\nJob description opens\nApply button works\nStep 3 — Test Job Application\n\nPick one test job and click:\n\nApply Now\n\nComplete the application.\n\nThen check whether you get a success message.\n\nStep 4 — Test Profile\n\nOpen:\n\nProfile\n\nCheck:\n\nName\nEmail\nPhone\nCity\nSkills\nEducation\nExperience\nResume/profile photo if applicable\n\nTry updating one non-sensitive field and save it.\n\nStep 5 — Test Logout\n\nClick:\n\nLogout\n\nThen verify:\n\nYou return to /login\nOpen /profile directly\nIt should not show the logged-in profile\nLogin again and confirm everything still works.','Em-10003','suhani','Sales',2,'medium','pending','2026-09-08',0,'Super Admin','2026-09-08 04:52:37'),(5,'Full stack developer','dfsdvdfd  fddd  d d d d ','EMP9968','A','HR',1,'medium','pending','2026-09-09',0,'Super Admin','2026-09-08 06:11:12'),(6,'Ardhnarishwar website ','EWFrawgarvv efw w re','EMP5182','Testing','IT',3,'high','in_progress','2026-09-08',40,'Super Admin','2026-09-08 14:57:40');
/*!40000 ALTER TABLE `work_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_policies`
--

DROP TABLE IF EXISTS `work_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_policies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL DEFAULT '0',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('attendance','leave','behavior','meal_management','general') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'general',
  `departmentId` int DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','draft','under_review','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `effective_date` date DEFAULT NULL,
  `policy_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `isAutomated` tinyint(1) DEFAULT '1',
  `autoDeduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `autoApply` tinyint(1) DEFAULT '1',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_policies`
--

LOCK TABLES `work_policies` WRITE;
/*!40000 ALTER TABLE `work_policies` DISABLE KEYS */;
INSERT INTO `work_policies` VALUES (3,0,'V0 verify policy','general',0,'Created by automated verification','Work Arrangements','draft','2026-09-15','POL001',1,1,NULL,1,'2026-09-03 12:44:59','2026-09-03 12:44:59'),(4,19,'ddd ','general',0,'wrerer  dvdv',NULL,'draft',NULL,NULL,1,1,NULL,1,'2026-09-08 06:00:45','2026-09-08 06:00:45');
/*!40000 ALTER TABLE `work_policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'hrms_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-16 23:02:46

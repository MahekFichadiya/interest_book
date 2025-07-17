-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 16, 2025 at 10:43 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `om`
--

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `custId` int(5) NOT NULL,
  `custName` varchar(20) NOT NULL,
  `custPhn` varchar(15) NOT NULL,
  `custAddress` varchar(50) DEFAULT NULL,
  `custPic` varchar(255) DEFAULT NULL,
  `date` datetime NOT NULL,
  `userId` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custId`, `custName`, `custPhn`, `custAddress`, `date`, `userId`) VALUES
(8, 'Dhruvi friend', '7284986365', 'swastik schhol, snagar', '2025-04-10 17:55:00', 10),
(9, 'demo hello', '+919824620842', '', '2025-04-10 18:04:00', 10),
(20, 'Jaini Kotadia', '+919601657374', '', '2025-04-13 11:23:00', 10),
(23, 'Tanvee', '+919023104036', '', '2025-04-16 12:59:00', 10),
(24, 'Barat Dada', '+918490867071', '', '2025-05-07 18:56:00', 10),
(25, 'Bipin Mama Wp', '9325286152', '', '2025-05-07 18:56:00', 10),
(26, 'divya p', '+919909126243', '', '2025-05-07 18:56:00', 10),
(27, 'Hasan Bangali', '9824378122', '', '2025-05-07 18:56:00', 10),
(28, 'Insiya', '9724147722', '', '2025-05-07 18:56:00', 10),
(29, 'Jalak Jani', '08780465075', '', '2025-05-07 18:56:00', 10),
(30, 'Jayesh Kaka', '+919998525938', '', '2025-05-07 18:56:00', 10),
(31, 'Kasak', '+91 96386 16607', '', '2025-05-07 18:56:00', 10),
(32, 'Kresha', '9328091872', '', '2025-05-07 18:56:00', 10),
(33, 'Mahi Shah C. U. Shah', '+919662097329', '', '2025-05-07 18:56:00', 10),
(34, 'Mayank Dosi', '9429577595', '', '2025-05-07 18:56:00', 10),
(35, 'Nadim sager Sir', '9998543574', '', '2025-05-07 18:56:00', 10),
(36, 'NTM BOOK STORE', '9909125934', '', '2025-05-07 18:57:00', 10),
(37, 'Pratik Bhai', '8460394473', '', '2025-05-07 18:57:00', 10);

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `backupedCustomer` AFTER DELETE ON `customer` FOR EACH ROW BEGIN
    INSERT INTO historycustomer (custId, custName, custPhn, custAddress, custPic, date, userId)
    VALUES (OLD.custId, OLD.custName, OLD.custPhn, OLD.custAddress, OLD.custPic, OLD.date, OLD.userId);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `deposite`
--

CREATE TABLE `deposite` (
  `depositeId` int(5) NOT NULL,
  `depositeAmount` int(10) NOT NULL,
  `depositeDate` date NOT NULL,
  `depositeNote` varchar(100) NOT NULL,
  `loanid` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `deposite`
--

INSERT INTO `deposite` (`depositeId`, `depositeAmount`, `depositeDate`, `depositeNote`, `loanid`) VALUES
(1, 0, '0000-00-00', '', 63),
(2, 1000, '2025-01-04', 'interest upto april', 63),
(3, 200, '0018-10-16', '', 63),
(4, 200, '2025-04-13', 'demo', 63),
(5, 200, '2025-04-14', 'deposited demo', 63),
(6, 200, '2025-04-14', 'y', 63),
(7, 200, '2025-04-14', 'deposited by Google pay', 63),
(8, 200, '2025-04-14', 'deposit ', 63),
(9, 200, '2025-04-14', 'Google pay', 63),
(10, 200, '2025-04-14', 'gpay', 63),
(11, 200, '2025-04-14', 'hello', 63),
(12, 200, '2025-04-14', 'mital', 63),
(13, 200, '2025-04-14', 'dnrkgksk', 63),
(14, 200, '2025-04-14', 'hii', 63);

--
-- Triggers `deposite`
--
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_delete` AFTER DELETE ON `deposite` FOR EACH ROW BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = OLD.loanid;
    
    -- Calculate total deposits for this loan (after deletion)
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = OLD.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = OLD.loanid;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_insert` AFTER INSERT ON `deposite` FOR EACH ROW BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = NEW.loanid;
    
    -- Calculate total deposits for this loan
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = NEW.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = NEW.loanid;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_update` AFTER UPDATE ON `deposite` FOR EACH ROW BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = NEW.loanid;
    
    -- Calculate total deposits for this loan
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = NEW.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = NEW.loanid;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `historycustomer`
--

CREATE TABLE `historycustomer` (
  `custId` int(5) NOT NULL,
  `custName` varchar(20) NOT NULL,
  `custPhn` varchar(15) NOT NULL,
  `custAddress` varchar(100) NOT NULL,
  `custPic` varchar(255) DEFAULT NULL,
  `date` datetime NOT NULL,
  `userId` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `historycustomer`
--

INSERT INTO `historycustomer` (`custId`, `custName`, `custPhn`, `custAddress`, `date`, `userId`) VALUES
(10, 'Agrata Nade 2', '+91 98259 40209', '', '2025-04-10 19:12:00', 10),
(11, 'Devanshi Pg', '9327553203', '', '2025-04-10 19:39:00', 10),
(12, 'Bhailal Sir', '+918000068515', '', '2025-04-10 20:19:00', 10),
(13, 'Divya Mami', '8140994720', '', '2025-04-10 20:32:00', 10),
(21, 'Prachi', '7621842827', '', '2025-04-14 22:24:00', 10),
(22, 'Mumma 💕', '+918160944941', '', '2025-04-14 22:27:00', 10);

-- --------------------------------------------------------

--
-- Table structure for table `historyloan`
--

CREATE TABLE `historyloan` (
  `loanId` int(5) NOT NULL,
  `amount` int(10) NOT NULL,
  `rate` float NOT NULL,
  `startDate` datetime NOT NULL,
  `endDate` date DEFAULT NULL,
  `image` varchar(100) NOT NULL,
  `note` varchar(100) NOT NULL,
  `updatedAmount` int(10) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `userId` int(5) NOT NULL,
  `custId` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `historyloan`
--

INSERT INTO `historyloan` (`loanId`, `amount`, `rate`, `startDate`, `endDate`, `image`, `note`, `updatedAmount`, `type`, `userId`, `custId`) VALUES
(7, 30000, 1.5, '2025-04-10 20:47:00', '2031-05-31', 'OmJavellerssHTML/LoanImages/34f5c28c-6acd-464a-aa49-80cca381f20f6524654747696170938.jpg', 'demo 1', 30000, 1, 10, 8),
(8, 35000, 1.5, '2025-04-10 20:52:00', '2025-04-30', 'OmJavellersHtml/LoanImages/IMG-20250406-WA0033.jpg', 'demo2', 35000, 1, 10, 8),
(9, 4000, 1, '2025-04-10 20:59:00', '0000-00-00', 'OmJavellersHtml/LoanImages/IMG-20250406-WA0028.jpg', 'demo3', 4000, 1, 10, 8),
(11, 25000, 1.5, '2025-04-11 20:05:00', '0000-00-00', 'OmJavellersHtml/LoanImages/IMG-20250409-WA0007.jpg', 'demo ', 25000, 1, 10, 10),
(12, 10000, 0.5, '2025-04-11 22:52:00', '0000-00-00', 'OmJavellersHtml/LoanImages/IMG-20250411-WA0003.jpg', 'demo', 10000, 1, 10, 8),
(13, 60000, 1.5, '2025-04-11 22:57:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG_20250403_010012_494.jpg', 'google', 60000, 1, 10, 8),
(14, 2000, 5, '2025-04-11 23:12:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'select ', 2000, 1, 10, 10),
(15, 25000, 1.5, '2025-04-12 22:45:00', '2025-05-31', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo', 25000, 1, 10, 10),
(16, 70000, 1.5, '2025-04-12 22:50:00', '2025-05-31', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0003.jpg', 'demo1', 70000, 1, 10, 10),
(17, 70000, 1.5, '2025-04-12 22:54:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250406-WA0028.jpg', 'demo 2', 70000, 1, 10, 10),
(18, 70000, 1.5, '2025-04-12 23:00:00', '2025-04-12', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0003.jpg', 'xndnkf', 70000, 1, 10, 10),
(19, 25000, 1.5, '2025-04-12 23:05:00', '2025-04-12', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'dhrur', 25000, 1, 10, 9),
(21, 10000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 10000, 1, 10, 9),
(22, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(23, 25000, 1.5, '2025-04-13 00:12:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'xmrkf', 25000, 1, 10, 10),
(24, 10000, 0.5, '2025-04-13 00:21:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0003.jpg', 'y', 10000, 1, 10, 10),
(25, 10000, 0.5, '2025-04-13 00:33:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'y', 10000, 1, 10, 10),
(26, 10000, 0.5, '2025-04-13 00:34:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'y', 10000, 1, 10, 10),
(27, 70000, 1.5, '2025-04-13 00:35:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'm', 70000, 1, 10, 10),
(28, 30000, 2, '2025-04-13 00:48:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0003.jpg', 'demo', 30000, 1, 10, 10),
(29, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(30, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(31, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(32, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(33, 70000, 1.5, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 70000, 1, 10, 9),
(34, 20000, 1.5, '2025-04-13 11:24:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'Jaini demo 1', 20000, 1, 10, 20),
(35, 25000, 1.5, '2025-02-13 11:56:00', '2025-08-30', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'jaini demo 2', 25000, 1, 10, 20),
(36, 70000, 1.5, '2025-02-13 12:02:00', '2025-06-30', 'OmJavellerssHTML/LoanImages/IMG-20250406-WA0024.jpg', 'jaini demo 3', 70000, 1, 10, 20),
(37, 50000, 1.5, '2025-02-13 13:40:00', '2031-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo', 50000, 1, 10, 20),
(38, 50000, 1.5, '2025-01-13 13:49:00', '2031-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo1', 50000, 1, 10, 20),
(39, 50000, 1.5, '2025-04-10 14:15:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo2', 50000, 1, 10, 20),
(40, 50000, 2, '2025-04-10 14:21:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo interest ', 50000, 1, 10, 8),
(41, 50000, 1.5, '2025-04-10 14:24:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo interest 2', 52284, 1, 10, 8),
(42, 50000, 1.5, '2025-04-10 14:30:00', '2025-04-30', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo', 52284, 1, 10, 9),
(43, 50000, 1.5, '2025-04-10 14:31:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo1', 52284, 1, 10, 9),
(44, 50000, 1.5, '2025-04-10 14:34:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo2', 52284, 1, 10, 9),
(45, 50000, 1.5, '2025-04-10 14:38:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo 3', 52284, 1, 10, 9),
(46, 50000, 1.5, '2025-04-10 14:42:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo 4', 52284, 1, 10, 9),
(47, 50000, 1.5, '2025-04-10 15:07:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0007.jpg', 'demo1', 52284, 1, 10, 10),
(48, 50000, 1.5, '2025-04-10 15:38:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo 2', 50000, 1, 10, 10),
(49, 50000, 1.5, '2025-04-10 15:40:00', '2025-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250406-WA0013.jpg', 'demo 3', 50000, 1, 10, 10),
(50, 50000, 1.5, '2025-04-10 15:44:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo5', 50000, 1, 10, 10),
(51, 50000, 1.5, '2025-04-10 15:59:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo interest 2', 50000, 1, 10, 8),
(52, 50000, 1.5, '2025-04-10 16:10:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0007.jpg', 'demo', 50000, 1, 10, 8),
(53, 50000, 1.5, '2025-04-10 16:10:00', '2025-04-20', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo1', 50000, 1, 10, 8),
(54, 50000, 1.5, '2025-02-13 16:13:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0007.jpg', 'demo2', 50000, 1, 10, 8),
(55, 50000, 1.5, '2025-04-10 16:21:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250406-WA0033.jpg', 'demo 4', 50000, 1, 10, 8),
(56, 50000, 1.5, '2025-02-13 16:22:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo 6', 50000, 1, 10, 8),
(57, 50000, 1.5, '2025-04-10 16:28:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250410-WA0003.jpg', 'demo1', 50000, 1, 10, 8),
(58, 50000, 1.5, '2025-02-13 16:28:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0007.jpg', 'demo2', 50000, 1, 10, 8),
(59, 50000, 1.5, '2025-04-13 16:51:00', '2032-04-13', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0005.jpg', 'demo1', 50000, 1, 10, 9),
(60, 50000, 1.5, '2025-02-01 16:51:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/20250403_124558.jpg', 'demo2', 50000, 1, 10, 9),
(61, 70000, 1.5, '2025-01-01 16:52:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/IMG-20250401-WA0073.jpg', 'demo1', 70000, 1, 10, 20),
(62, 70000, 1.5, '2025-04-13 16:53:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/f2903937-c508-47d9-bf85-504c1fcc9f1a4802955238554944752.jpg', 'demo2', 70000, 1, 10, 20),
(66, 200000, 1.5, '0001-11-30 00:00:00', '0001-11-30', 'OmjavellersHtml/LoanImages/20250412_001511.jpg', 'demo', 8000, 1, 10, 8);

-- --------------------------------------------------------

--
-- Table structure for table `interest`
--

CREATE TABLE `interest` (
  `InterestId` int(5) NOT NULL,
  `interestAmount` int(10) NOT NULL,
  `interestDate` date NOT NULL,
  `interestNote` varchar(100) DEFAULT NULL,
  `loanId` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `interest`
--

INSERT INTO `interest` (`InterestId`, `interestAmount`, `interestDate`, `interestNote`, `loanId`) VALUES
(7, 1000, '2025-01-04', 'interest upto april', 63),
(8, 200, '0018-10-16', 'interest till April ', 63),
(9, 0, '0018-10-16', '', 63),
(15, 500, '0000-00-00', 'y', 63),
(16, 500, '0000-00-00', 'd', 64),
(18, 200, '2025-04-14', 'interest demo', 63),
(19, 200, '2025-04-14', 'interest demo', 63),
(20, 200, '2025-04-14', 'interest demo', 63),
(21, 200, '2025-04-14', 'interest ', 63),
(22, 500, '2025-04-14', 'clear', 63),
(23, 500, '2025-04-14', 'mital', 63);

-- --------------------------------------------------------

--
-- Table structure for table `loan`
--

CREATE TABLE `loan` (
  `loanId` int(5) NOT NULL,
  `amount` int(10) NOT NULL,
  `rate` float NOT NULL,
  `startDate` datetime NOT NULL,
  `endDate` date DEFAULT NULL,
  `image` varchar(100) NOT NULL,
  `note` varchar(100) NOT NULL,
  `updatedAmount` int(10) NOT NULL,
  `totalDeposite` int(10) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `userId` int(5) NOT NULL,
  `custId` int(5) NOT NULL,
  `interest` decimal(10,2) NOT NULL DEFAULT 0.00,
  `totalInterest` decimal(10,2) NOT NULL,
  `lastInterestUpdatedAt` date DEFAULT NULL,
  `dailyInterest` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Daily interest amount calculated from monthly interest'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loan`
--

INSERT INTO `loan` (`loanId`, `amount`, `rate`, `startDate`, `endDate`, `image`, `note`, `updatedAmount`, `totalDeposite`, `type`, `userId`, `custId`, `interest`, `totalInterest`, `lastInterestUpdatedAt`, `dailyInterest`) VALUES
(63, 80000, 1.5, '2030-11-01 12:00:00', '2030-11-01', 'OmjavellersHtml/LoanImages/Snapchat-226898991.jpg', 'hiring poster', 70000, 0, 1, 10, 9, 1050.00, 73500.00, '2025-06-16', 35.00),
(64, 8000, 1, '2025-04-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 8000, 0, 1, 10, 9, 80.00, 880.00, '2025-06-16', 2.67),
(65, 5000, 1, '2025-05-02 18:46:00', '2025-03-02', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo', 5000, 0, 1, 10, 9, 50.00, 450.00, '2025-06-16', 1.67),
(67, 5000, 2, '2025-06-16 13:34:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/2df2ed38-29d3-4baf-914b-3be928cec8692643132718976339287.jpg', 'demo current interest ', 5000, 0, 1, 10, 23, 100.00, 600.00, '2025-06-16', 3.33),
(68, 5000, 2, '2025-05-16 13:36:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/88c3643d-9cba-4367-9ce5-14585257ec306549513797301108875.jpg', '1 month', 5000, 0, 1, 10, 23, 100.00, 700.00, '2025-06-16', 3.33),
(69, 5000, 2, '2025-04-16 13:36:00', '0000-00-00', 'OmJavellerssHTML/LoanImages/5731dcb8-daa2-4cf4-9d51-341a763cfb396226656519422982429.jpg', 'demo', 5000, 0, 1, 10, 23, 100.00, 1000.00, '2025-06-16', 3.33);

--
-- Triggers `loan`
--
DELIMITER $$
CREATE TRIGGER `backupedLoan` AFTER DELETE ON `loan` FOR EACH ROW BEGIN
    INSERT INTO historyloan (loanId, amount, rate, startDate, endDate, image, note, updatedAmount, type, userId, custId)
    VALUES (OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, OLD.image, OLD.note, OLD.updatedAmount, OLD.type, OLD.userId, OLD.custId);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_interest_on_loan_insert` BEFORE INSERT ON `loan` FOR EACH ROW BEGIN
    DECLARE days_passed INT;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE daily_interest DECIMAL(10,2);
    DECLARE total_interest_to_add DECIMAL(10,2);

    -- Calculate monthly interest: (updatedAmount * rate) / 100
    SET monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);
    
    -- Calculate daily interest: monthly interest / 30
    SET daily_interest = ROUND(monthly_interest / 30, 2);
    
    -- Set the interest fields
    SET NEW.interest = monthly_interest;
    SET NEW.dailyInterest = daily_interest;
    
    -- Calculate days passed since start date
    SET days_passed = DATEDIFF(CURDATE(), DATE(NEW.startDate));

    -- Only calculate totalInterest if more than 1 day has passed
    IF days_passed > 1 THEN
        -- Calculate months passed (for totalInterest calculation)
        SET months_passed = TIMESTAMPDIFF(MONTH, NEW.startDate, NOW());

        -- If at least 1 month has passed, calculate totalInterest
        IF months_passed >= 1 THEN
            SET total_interest_to_add = monthly_interest * months_passed;
            SET NEW.totalInterest = total_interest_to_add;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        ELSE
            -- If less than 1 month but more than 1 day, set totalInterest to 0
            SET NEW.totalInterest = 0.00;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        END IF;
    ELSE
        -- If 1 day or less has passed, set totalInterest to 0
        SET NEW.totalInterest = 0.00;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_totalinterest_on_loan_insert` BEFORE INSERT ON `loan` FOR EACH ROW BEGIN
    DECLARE days_passed INT;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE total_interest_to_add DECIMAL(10,2);

    -- Calculate days passed since start date
    SET days_passed = DATEDIFF(CURDATE(), DATE(NEW.startDate));

    -- Only proceed if more than 1 day has passed
    IF days_passed > 1 THEN
        -- Calculate monthly interest amount
        SET monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);

        -- Calculate months passed (for totalInterest calculation)
        SET months_passed = TIMESTAMPDIFF(MONTH, NEW.startDate, NOW());

        -- If at least 1 month has passed, calculate totalInterest
        IF months_passed >= 1 THEN
            SET total_interest_to_add = monthly_interest * months_passed;

            -- Set the values directly in the NEW record
            SET NEW.interest = monthly_interest;
            SET NEW.totalInterest = total_interest_to_add;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        ELSE
            -- If less than 1 month but more than 1 day, just set the monthly interest
            SET NEW.interest = monthly_interest;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userId` int(5) NOT NULL,
  `name` varchar(20) NOT NULL,
  `mobileNo` varchar(15) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`userId`, `name`, `mobileNo`, `email`, `password`) VALUES
(10, 'Mahek 1', '7284048987', 'mahekfichadiya@gmail.com', 'mitu1234');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`custId`),
  ADD KEY `fk_customer_user` (`userId`);

--
-- Indexes for table `deposite`
--
ALTER TABLE `deposite`
  ADD PRIMARY KEY (`depositeId`),
  ADD KEY `fk_deposite_loan` (`loanid`);

--
-- Indexes for table `historycustomer`
--
ALTER TABLE `historycustomer`
  ADD PRIMARY KEY (`custId`),
  ADD KEY `fk_historycustomer_user` (`userId`);

--
-- Indexes for table `historyloan`
--
ALTER TABLE `historyloan`
  ADD PRIMARY KEY (`loanId`),
  ADD KEY `fk_historyloan_user` (`userId`),
  ADD KEY `fk_historyloan_customer` (`custId`);

--
-- Indexes for table `interest`
--
ALTER TABLE `interest`
  ADD PRIMARY KEY (`InterestId`),
  ADD KEY `fk_interest_loan` (`loanId`);

--
-- Indexes for table `loan`
--
ALTER TABLE `loan`
  ADD PRIMARY KEY (`loanId`),
  ADD KEY `fk_loan_user` (`userId`),
  ADD KEY `fk_loan_customer` (`custId`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `unique_email` (`email`),
  ADD UNIQUE KEY `unique_mobile` (`mobileNo`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `custId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `deposite`
--
ALTER TABLE `deposite`
  MODIFY `depositeId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `historyloan`
--
ALTER TABLE `historyloan`
  MODIFY `loanId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `interest`
--
ALTER TABLE `interest`
  MODIFY `InterestId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `loan`
--
ALTER TABLE `loan`
  MODIFY `loanId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `userId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `fk_customer_user` FOREIGN KEY (`userId`) REFERENCES `user` (`userId`);

--
-- Constraints for table `deposite`
--
ALTER TABLE `deposite`
  ADD CONSTRAINT `fk_deposite_loan` FOREIGN KEY (`loanid`) REFERENCES `loan` (`loanId`);

--
-- Constraints for table `interest`
--
ALTER TABLE `interest`
  ADD CONSTRAINT `fk_interest_loan` FOREIGN KEY (`loanId`) REFERENCES `loan` (`loanId`) ON DELETE CASCADE;

--
-- Constraints for table `loan`
--
ALTER TABLE `loan`
  ADD CONSTRAINT `fk_loan_customer` FOREIGN KEY (`custId`) REFERENCES `customer` (`custId`),
  ADD CONSTRAINT `fk_loan_user` FOREIGN KEY (`userId`) REFERENCES `user` (`userId`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `update_interest_every_10_min` ON SCHEDULE EVERY 10 MINUTE STARTS '2025-04-14 16:11:20' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
  UPDATE loans
  SET 
    interest = ROUND((amount * rate) / 100 / 30, 2),
    totalInterest = totalInterest + ROUND((amount * rate) / 100 / 30, 2),
    lastInterestUpdatedAt = NOW()
  WHERE 
    endDate > NOW();
END$$

CREATE DEFINER=`root`@`localhost` EVENT `calculate_totalinterest_monthly` ON SCHEDULE EVERY 1 MONTH STARTS '2025-06-16 14:12:44' ON COMPLETION PRESERVE ENABLE DO BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE loan_id INT;
    DECLARE loan_start_date DATETIME;
    DECLARE loan_updated_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE loan_last_updated DATE;
    DECLARE current_total_interest DECIMAL(10,2);
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE interest_to_add DECIMAL(10,2);
    
    -- Cursor to iterate through all active loans
    DECLARE loan_cursor CURSOR FOR 
        SELECT 
            loanId, 
            startDate, 
            updatedAmount, 
            rate, 
            lastInterestUpdatedAt,
            totalInterest
        FROM loan 
        WHERE updatedAmount > 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Start processing loans
    OPEN loan_cursor;
    
    loan_loop: LOOP
        FETCH loan_cursor INTO 
            loan_id, 
            loan_start_date, 
            loan_updated_amount, 
            loan_rate, 
            loan_last_updated,
            current_total_interest;
        
        IF done THEN
            LEAVE loan_loop;
        END IF;
        
        -- Calculate monthly interest amount
        SET monthly_interest = ROUND((loan_updated_amount * loan_rate) / 100, 2);
        
        -- Add monthly interest to totalInterest every month
        -- This provides real monthly interest accumulation for production use
        
        -- Add the monthly interest amount to totalInterest
        UPDATE loan 
        SET 
            interest = monthly_interest,
            totalInterest = totalInterest + monthly_interest,
            lastInterestUpdatedAt = NOW()
        WHERE loanId = loan_id;
        
    END LOOP;
    
    CLOSE loan_cursor;
    
    -- Monthly interest calculation completed - totalInterest updated for all active loans
    
END$$

DELIMITER ;

-- ========================================
-- MIGRATION SCRIPTS SECTION
-- ========================================
-- This section contains all migration scripts to update existing databases
-- These scripts are safe to run multiple times and will check for existing structures

-- ----------------------------------------
-- Migration 1: Add Customer Picture Field
-- ----------------------------------------
-- Add custPic field to customer table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'customer'
     AND COLUMN_NAME = 'custPic') = 0,
    'ALTER TABLE `customer` ADD COLUMN `custPic` varchar(255) DEFAULT NULL AFTER `custAddress`',
    'SELECT "Column custPic already exists in customer table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add custPic field to historycustomer table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'historycustomer'
     AND COLUMN_NAME = 'custPic') = 0,
    'ALTER TABLE `historycustomer` ADD COLUMN `custPic` varchar(255) DEFAULT NULL AFTER `custAddress`',
    'SELECT "Column custPic already exists in historycustomer table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ----------------------------------------
-- Migration 2: Create OTP Verification Table
-- ----------------------------------------
-- Create the otp_verification table
CREATE TABLE IF NOT EXISTS `otp_verification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_otp_code` (`otp_code`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_email_otp` (`email`, `otp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------------------
-- Migration 3: Create Loan Documents Table
-- ----------------------------------------
-- Create loan_documents table for multiple document support
CREATE TABLE IF NOT EXISTS `loan_documents` (
  `documentId` int(11) NOT NULL AUTO_INCREMENT,
  `loanId` int(5) NOT NULL,
  `documentPath` varchar(255) NOT NULL,
  PRIMARY KEY (`documentId`),
  KEY `fk_loan_documents_loan` (`loanId`),
  CONSTRAINT `fk_loan_documents_loan` FOREIGN KEY (`loanId`) REFERENCES `loan` (`loanId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------------------
-- Migration 4: Add Payment Mode Fields
-- ----------------------------------------
-- Add paymentMode field to deposite table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'deposite'
     AND COLUMN_NAME = 'paymentMode') = 0,
    'ALTER TABLE `deposite` ADD COLUMN `paymentMode` varchar(20) DEFAULT ''cash'' AFTER `depositeNote`',
    'SELECT "Column paymentMode already exists in deposite table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add paymentMode field to interest table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'interest'
     AND COLUMN_NAME = 'paymentMode') = 0,
    'ALTER TABLE `interest` ADD COLUMN `paymentMode` varchar(20) DEFAULT ''cash'' AFTER `interestNote`',
    'SELECT "Column paymentMode already exists in interest table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add paymentMode field to loan table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'loan'
     AND COLUMN_NAME = 'paymentMode') = 0,
    'ALTER TABLE `loan` ADD COLUMN `paymentMode` varchar(20) DEFAULT ''cash'' AFTER `note`',
    'SELECT "Column paymentMode already exists in loan table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ----------------------------------------
-- Migration 5: Add Foreign Key Constraints with Cascading Deletion
-- ----------------------------------------
-- Add foreign key constraint for loan -> customer relationship (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'loan'
     AND CONSTRAINT_NAME = 'fk_loan_customer_cascade') = 0,
    'ALTER TABLE `loan` ADD CONSTRAINT `fk_loan_customer_cascade` FOREIGN KEY (`custId`) REFERENCES `customer`(`custId`) ON DELETE CASCADE ON UPDATE CASCADE',
    'SELECT "Foreign key fk_loan_customer_cascade already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key constraint for interest -> loan relationship (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'interest'
     AND CONSTRAINT_NAME = 'fk_interest_loan_cascade') = 0,
    'ALTER TABLE `interest` ADD CONSTRAINT `fk_interest_loan_cascade` FOREIGN KEY (`loanId`) REFERENCES `loan`(`loanId`) ON DELETE CASCADE ON UPDATE CASCADE',
    'SELECT "Foreign key fk_interest_loan_cascade already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key constraint for deposite -> loan relationship (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'deposite'
     AND CONSTRAINT_NAME = 'fk_deposite_loan_cascade') = 0,
    'ALTER TABLE `deposite` ADD CONSTRAINT `fk_deposite_loan_cascade` FOREIGN KEY (`loanid`) REFERENCES `loan`(`loanId`) ON DELETE CASCADE ON UPDATE CASCADE',
    'SELECT "Foreign key fk_deposite_loan_cascade already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key constraint for customer -> user relationship (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'customer'
     AND CONSTRAINT_NAME = 'fk_customer_user_cascade') = 0,
    'ALTER TABLE `customer` ADD CONSTRAINT `fk_customer_user_cascade` FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) ON DELETE CASCADE ON UPDATE CASCADE',
    'SELECT "Foreign key fk_customer_user_cascade already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ----------------------------------------
-- Migration 6: Add User Unique Constraints
-- ----------------------------------------
-- Add unique constraint for email (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'user'
     AND INDEX_NAME = 'unique_email') = 0,
    'ALTER TABLE `user` ADD UNIQUE KEY `unique_email` (`email`)',
    'SELECT "Unique constraint unique_email already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add unique constraint for mobile number (if not exists)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'user'
     AND INDEX_NAME = 'unique_mobile') = 0,
    'ALTER TABLE `user` ADD UNIQUE KEY `unique_mobile` (`mobileNo`)',
    'SELECT "Unique constraint unique_mobile already exists" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ----------------------------------------
-- Migration 7: Create Cleanup Events
-- ----------------------------------------
-- Add a cleanup event to automatically delete expired OTP records
DELIMITER $$
CREATE EVENT IF NOT EXISTS `cleanup_expired_otp`
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    DELETE FROM otp_verification
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
END$$
DELIMITER ;

-- Event to automatically delete settled loans after 30 days
DELIMITER $$
CREATE EVENT IF NOT EXISTS `auto_delete_settled_loans`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    -- Move loans to history that have been settled for 30+ days
    INSERT INTO historyloan (loanId, amount, rate, startDate, endDate, image, note, updatedAmount, type, userId, custId)
    SELECT loanId, amount, rate, startDate, endDate, image, note, updatedAmount, type, userId, custId
    FROM loan
    WHERE updatedAmount = 0
    AND endDate IS NOT NULL
    AND endDate < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    -- Delete the settled loans from main table
    DELETE FROM loan
    WHERE updatedAmount = 0
    AND endDate IS NOT NULL
    AND endDate < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END$$
DELIMITER ;

-- Enable the event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- ----------------------------------------
-- Migration 8: Interest Payment Trigger Updates
-- ----------------------------------------
-- Update interest payment trigger to handle totalInterest deduction
DROP TRIGGER IF EXISTS `update_totalinterest_after_interest_payment`;

DELIMITER $$
CREATE TRIGGER `update_totalinterest_after_interest_payment` AFTER INSERT ON `interest` FOR EACH ROW BEGIN
    DECLARE current_total_interest DECIMAL(10,2);
    DECLARE new_total_interest DECIMAL(10,2);

    -- Get current totalInterest for the loan
    SELECT totalInterest INTO current_total_interest
    FROM loan
    WHERE loanId = NEW.loanId;

    -- Calculate new totalInterest after payment deduction
    SET new_total_interest = GREATEST(0, current_total_interest - NEW.interestAmount);

    -- Update the loan table with new totalInterest
    UPDATE loan
    SET totalInterest = new_total_interest,
        lastInterestUpdatedAt = CURDATE()
    WHERE loanId = NEW.loanId;
END$$
DELIMITER ;

-- ========================================
-- END OF MIGRATION SCRIPTS
-- ========================================

SELECT 'All migration scripts completed successfully!' AS Status;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

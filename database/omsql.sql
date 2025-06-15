-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 11, 2025 at 01:38 PM
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
-- Database: `omsql`
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
    INSERT INTO historycustomer (custId, custName, custPhn, custAddress, date, userId)
    VALUES (OLD.custId, OLD.custName, OLD.custPhn, OLD.custAddress, OLD.date, OLD.userId);
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

-- --------------------------------------------------------

--
-- Table structure for table `historycustomer`
--

CREATE TABLE `historycustomer` (
  `custId` int(5) NOT NULL,
  `custName` varchar(20) NOT NULL,
  `custPhn` varchar(15) NOT NULL,
  `custAddress` varchar(100) NOT NULL,
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
  `lastInterestUpdatedAt` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loan`
--

INSERT INTO `loan` (`loanId`, `amount`, `rate`, `startDate`, `endDate`, `image`, `note`, `updatedAmount`, `totalDeposite`, `type`, `userId`, `custId`, `interest`, `totalInterest`, `lastInterestUpdatedAt`) VALUES
(63, 80000, 1.5, '2030-11-01 12:00:00', '2030-11-01', 'OmjavellersHtml/LoanImages/Snapchat-226898991.jpg', 'hiring poster', 70000, 0, 1, 10, 9, 0.00, 0.00, NULL),
(64, 8000, 1, '2025-01-01 23:12:00', '2025-01-01', 'OmJavellerssHTML/LoanImages/Welcome To.png', 'hello', 8000, 0, 1, 10, 9, 0.00, 0.00, NULL),
(65, 5000, 1, '2025-03-02 18:46:00', '2025-03-02', 'OmJavellerssHTML/LoanImages/IMG-20250409-WA0009.jpg', 'demo', 5000, 0, 1, 10, 9, 0.00, 0.00, NULL);

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

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userId` int(5) NOT NULL,
  `name` varchar(20) NOT NULL,
  `mobileNo` varchar(15) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(8) NOT NULL
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
  ADD PRIMARY KEY (`userId`);

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
  MODIFY `loanId` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

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

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

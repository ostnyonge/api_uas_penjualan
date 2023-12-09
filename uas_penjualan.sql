-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 09, 2023 at 08:26 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uas_penjualan`
--

-- --------------------------------------------------------

--
-- Table structure for table `detail_pesanan`
--

CREATE TABLE `detail_pesanan` (
  `id_detail_pesanan` int(11) NOT NULL,
  `id_pesanan` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `subtotal` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_pesanan`
--

INSERT INTO `detail_pesanan` (`id_detail_pesanan`, `id_pesanan`, `id_produk`, `jumlah`, `subtotal`) VALUES
(33543234, 2, 3, 5, '635000'),
(50163651, 4, 1, 5, '935000'),
(54573446, 1, 1, 3, '561000'),
(72740023, 3, 2, 7, '1043000');

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama` varchar(128) NOT NULL,
  `alamat` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `no_telepon` varchar(15) NOT NULL,
  `tanggal_input` datetime NOT NULL,
  `tanggal_update` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama`, `alamat`, `email`, `no_telepon`, `tanggal_input`, `tanggal_update`) VALUES
(1, 'ali mustolih', 'sawangan', 'alimustolih@gmail.com', '081343238812', '2023-12-04 10:55:06', '2023-12-04 10:55:06'),
(2, 'sandi', 'pekapuran', 'sandi@gmail.com', '081310112233', '2023-12-04 11:04:04', '2023-12-04 11:04:04'),
(3, 'wisnu', 'pekapuran', 'wisnu42@gmail.com', '085784273652', '2023-12-04 11:05:01', '2023-12-04 11:05:01');

-- --------------------------------------------------------

--
-- Table structure for table `pesanan`
--

CREATE TABLE `pesanan` (
  `id_pesanan` int(11) NOT NULL,
  `kode_pesanan` varchar(128) NOT NULL,
  `id_pelanggan` int(11) NOT NULL,
  `harga` int(100) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `tanggal_pesanan` datetime NOT NULL,
  `tanggal_update` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pesanan`
--

INSERT INTO `pesanan` (`id_pesanan`, `kode_pesanan`, `id_pelanggan`, `harga`, `jumlah`, `tanggal_pesanan`, `tanggal_update`) VALUES
(1, '39622097', 3, 187000, 3, '2023-12-08 03:34:59', '2023-12-08 03:34:59'),
(2, '18809658', 1, 127000, 5, '2023-12-08 03:37:15', '2023-12-08 04:45:22'),
(3, '37949287', 2, 149000, 7, '2023-12-08 06:59:38', '2023-12-08 06:59:38'),
(4, '33906924', 1, 187000, 5, '2023-12-10 02:07:23', '2023-12-10 02:07:39');

-- --------------------------------------------------------

--
-- Table structure for table `produk`
--

CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL,
  `kode_produk` varchar(10) NOT NULL,
  `nama_produk` varchar(100) NOT NULL,
  `deskripsi` varchar(100) NOT NULL,
  `harga` int(100) NOT NULL,
  `stok` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produk`
--

INSERT INTO `produk` (`id_produk`, `kode_produk`, `nama_produk`, `deskripsi`, `harga`, `stok`) VALUES
(1, '42390877', 'Beryful', 'Black tea + Roselle + Rosehip + Elderberry + Flavour', 187000, 5),
(2, '46681800', 'Blue Jasmine', 'Green Tea + Jasmine + Blue Pea Flower', 149000, 31),
(3, '78652554', 'Coco Pandan', 'Green Tea + Coconut + Pandan Leaf + Stevia Leaf', 127000, 23);

-- --------------------------------------------------------

--
-- Table structure for table `role`
--

CREATE TABLE `role` (
  `id` int(11) NOT NULL,
  `role` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `role`
--

INSERT INTO `role` (`id`, `role`) VALUES
(1, 'admin'),
(2, 'user_biasa');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `nama` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(100) NOT NULL,
  `jabatan` varchar(128) NOT NULL,
  `role` int(11) NOT NULL,
  `tanggal_bergabung` datetime NOT NULL,
  `tanggal_update` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `nama`, `email`, `password`, `jabatan`, `role`, `tanggal_bergabung`, `tanggal_update`) VALUES
(1, 'ostnyonge', 'ostnyonge@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Cyber Security', 1, '2023-11-29 09:55:25', '2023-12-05 02:46:44'),
(2, 'sandwich', 'sandwich@gmail.com', 'bd24a2701018cfd6f8292fe30ab3b4a1a57b96ba0b74af8b706ad5887afd2b5e', 'IT Support', 2, '2023-11-29 10:09:58', '2023-12-02 12:40:23'),
(3, 'miegoreng', 'miegoreng@gmail.com', '84c6f3595955c06f9eedcb46dff257372faf7c12f124d7fa15cfa73a0b1d4afd', 'UI / UX', 2, '2023-12-02 12:45:34', '2023-12-02 12:45:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD PRIMARY KEY (`id_detail_pesanan`),
  ADD KEY `id_pesanan` (`id_pesanan`),
  ADD KEY `id_produk` (`id_produk`),
  ADD KEY `jumlah` (`jumlah`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id_pesanan`),
  ADD KEY `id_pelanggan` (`id_pelanggan`);

--
-- Indexes for table `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `role` (`role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id_pelanggan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD CONSTRAINT `detail_pesanan_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`),
  ADD CONSTRAINT `detail_pesanan_ibfk_2` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD CONSTRAINT `pesanan_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`role`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

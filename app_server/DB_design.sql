-- 1. TABEL USER / KARYAWAN (Untuk Login Kasir/Admin)
CREATE TABLE `mst_user` (
  `id_user` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL, -- Disarankan menggunakan hash (bcrypt/password_hash)
  `nama_lengkap` VARCHAR(100) NOT NULL,
  `role` ENUM('Kasir', 'Admin', 'Owner') DEFAULT 'Kasir',
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. TABEL CUSTOMER
CREATE TABLE `mst_customer` (
  `id_customer` INT AUTO_INCREMENT PRIMARY KEY,
  `nama_customer` VARCHAR(100) NOT NULL,
  `no_telp` VARCHAR(15) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. TABEL TERAPIS / STYLIST
CREATE TABLE `mst_terapis` (
  `id_terapis` INT AUTO_INCREMENT PRIMARY KEY,
  `nama_terapis` VARCHAR(100) NOT NULL,
  `no_telp` VARCHAR(15) NULL,
  `status_kerja` ENUM('Aktif', 'Resign') DEFAULT 'Aktif',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. TABEL BARANG DAN JASA
CREATE TABLE `mst_produk_jasa` (
  `id_item` INT AUTO_INCREMENT PRIMARY KEY,
  `nama_item` VARCHAR(150) NOT NULL,
  `tipe` ENUM('Barang', 'Jasa') NOT NULL, -- Pembeda untuk laporan stok & komisi
  `harga_jual` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `stok` INT NOT NULL DEFAULT 0, -- Jika Jasa, stok bisa diabaikan atau diset 0
  `komisi_nominal` DECIMAL(12,2) NOT NULL DEFAULT 0.00, -- Nominal komisi langsung untuk terapis per item ini
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. TABEL TRANSAKSI PENJUALAN (HEADER)
CREATE TABLE `tr_penjualan` (
  `id_penjualan` INT AUTO_INCREMENT PRIMARY KEY,
  `no_faktur` VARCHAR(20) NOT NULL UNIQUE, -- Contoh: INV-20260624-0001
  `tanggal_transaksi` DATETIME NOT NULL,
  `id_customer` INT NULL,
  `id_user` INT NOT NULL, -- Kasir yang menginput
  `total_bayar` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `status_transaksi` ENUM('Pending', 'Selesai', 'Batal') DEFAULT 'Pending', 
  -- 'Pending' digunakan untuk fitur SIMPAN SEMENTARA saat pelanggan sedang perawatan
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_customer`) REFERENCES `mst_customer`(`id_customer`) ON DELETE SET NULL,
  FOREIGN KEY (`id_user`) REFERENCES `mst_user`(`id_user`)
) ENGINE=InnoDB;

-- 6. TABEL TRANSAKSI PENJUALAN DETAIL
CREATE TABLE `tr_penjualan_detail` (
  `id_detail` INT AUTO_INCREMENT PRIMARY KEY,
  `id_penjualan` INT NOT NULL,
  `id_item` INT NOT NULL,
  `qty` INT NOT NULL DEFAULT 1,
  `harga_satuan` DECIMAL(12,2) NOT NULL,
  `subtotal` DECIMAL(12,2) NOT NULL, -- (qty * harga_satuan)
  `id_terapis` INT NULL, -- Bisa NULL jika item yang dibeli adalah 'Barang' retail tanpa terapis
  `komisi_terapis` DECIMAL(12,2) NOT NULL DEFAULT 0.00, -- Menyimpan nominal komisi saat transaksi terjadi (snapshot harga)
  FOREIGN KEY (`id_penjualan`) REFERENCES `tr_penjualan`(`id_penjualan`) ON DELETE CASCADE,
  FOREIGN KEY (`id_item`) REFERENCES `mst_produk_jasa`(`id_item`),
  FOREIGN KEY (`id_terapis`) REFERENCES `mst_terapis`(`id_terapis`) ON DELETE SET NULL
) ENGINE=InnoDB;
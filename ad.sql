-- vung nuoi
CREATE TABLE VungNuoi (
  MaVung VARCHAR2(10) PRIMARY KEY,
  TenVung VARCHAR2(100) NOT NULL,
  DienTich NUMBER(10,2),
  ViTri VARCHAR2(100),
  MoTa VARCHAR2(255)
);

-- ho nuoi
CREATE TABLE HoNuoi (
  MaHo VARCHAR2(10) PRIMARY KEY,
  TenHo VARCHAR2(100) NOT NULL,
  MaVung VARCHAR2(10) NOT NULL,
  LoaiThuySan VARCHAR2(50),
  DienTich NUMBER(10,2),
  TrangThai VARCHAR2(30),
  FOREIGN KEY (MaVung) REFERENCES VungNuoi(MaVung)
);

-- don vi van chuyen
CREATE TABLE DonViVanChuyen (
  MaDonVi VARCHAR2(10) PRIMARY KEY,
  TenDonVi VARCHAR2(100) NOT NULL,
  DiaChi VARCHAR2(255),
  SoDienThoai VARCHAR2(15)
);

-- lo san pham
CREATE TABLE LoSanPham (
  MaLo VARCHAR2(10) PRIMARY KEY,
  TenLo VARCHAR2(100) NOT NULL,
  MaHo VARCHAR2(10) NOT NULL,
  MaDonVi VARCHAR2(10) NOT NULL,
  NgaySanXuat DATE NOT NULL,
  HanSuDung DATE NOT NULL,
  FOREIGN KEY (MaHo) REFERENCES HoNuoi(MaHo),
  FOREIGN KEY (MaDonVi) REFERENCES DonViVanChuyen(MaDonVi)
);

-- khach hang
CREATE TABLE KhachHang (
  MaKH VARCHAR2(10) PRIMARY KEY,
  TenKH VARCHAR2(100) NOT NULL,
  DiaChi VARCHAR2(255),
  SoDienThoai VARCHAR2(15)
);

-- chi phi
CREATE TABLE ChiPhi (
  MaCP VARCHAR2(10) PRIMARY KEY,
  MaLo VARCHAR2(10) NOT NULL,
  SoTien NUMBER(10,2) NOT NULL,
  NgayChi DATE,
  MoTa VARCHAR2(255),
  FOREIGN KEY (MaLo) REFERENCES LoSanPham(MaLo)
);

-- hoa don
CREATE TABLE HoaDon (
  MaHoaDon VARCHAR2(10) PRIMARY KEY,
  MaLo VARCHAR2(10) NOT NULL,
  SoTien NUMBER(10,2) NOT NULL,
  NgayLap DATE,
  NguoiKy VARCHAR2(100),
  FOREIGN KEY (MaLo) REFERENCES LoSanPham(MaLo)
);

-- khachhang lien ket lo san pham
CREATE TABLE KhachHang_Lo (
  MaKH VARCHAR2(10) NOT NULL,
  MaLo VARCHAR2(10) NOT NULL,
  NgayMua DATE NOT NULL,
  SoLuong NUMBER NOT NULL,
  PRIMARY KEY (MaKH, MaLo),
  FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
  FOREIGN KEY (MaLo) REFERENCES LoSanPham(MaLo)
);


select * from Vungnuoi
select * from HoaDon
select * from ChiPhi
select * from KhachHang
select * from LoSanPham
select * from DonViVanChuyen
select * from HoNuoi


-- lenh xoa ban neu can thiet
-- uu tien xoa dau tien
DROP TABLE KhachHang_Lo;

--cac table con lai
DROP TABLE HoaDon;
DROP TABLE ChiPhi;
DROP TABLE KhachHang;
DROP TABLE LoSanPham;
DROP TABLE DonViVanChuyen;
DROP TABLE HoNuoi;
DROP TABLE VungNuoi;



-- chen du lieu
-- table vung nuoi
INSERT INTO Vungnuoi (Mavung, Tenvung, DienTich, ViTri, MoTa) 
VALUES ('A01', 'V?ng A01', 500, 'Mi?n Trung', 'V?ng nu?i th?y s?n Mi?n Trung');

INSERT INTO Vungnuoi (Mavung, Tenvung, DienTich, ViTri, MoTa) 
VALUES ('B01', 'V?ng B01', 700, 'Mi?n B?c', 'V?ng nu?i th?y s?n Mi?n B?c');

INSERT INTO Vungnuoi (Mavung, Tenvung, DienTich, ViTri, MoTa) 
VALUES ('C02', 'V?ng C02', 900, 'Mi?n Nam', 'V?ng nu?i th?y s?n Mi?n Nam');

INSERT INTO Vungnuoi (Mavung, Tenvung, DienTich, ViTri, MoTa) 
VALUES ('D03', 'V?ng D03', 600, 'Mi?n T?y', 'V?ng nu?i th?y s?n Mi?n T?y');

INSERT INTO Vungnuoi (Mavung, Tenvung, DienTich, ViTri, MoTa) 
VALUES ('E01', 'V?ng E01', 800, 'T?y Nguy?n', 'V?ng nu?i th?y s?n T?y Nguy?n');


-- table HoNuoi
INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H01', 'H? nu?i Mi?n Trung', 'A01', 'C?', 100, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H02', 'H? nu?i Mi?n B?c', 'B01', 'T?m', 150, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H03', 'H? nu?i Mi?n Nam', 'C02', 'Cua', 200, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H04', 'H? nu?i Mi?n T?y', 'D03', 'C?', 120, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H05', 'H? nu?i T?y Nguy?n', 'E01', 'T?m', 130, 'Ng?ng ho?t ??ng');


-- table DonViVanChuyen
INSERT INTO DonViVanChuyen (MaDonVi, TenDonVi, DiaChi, SoDienThoai) 
VALUES ('DV01', '??n v? v?n chuy?n H? N?i', 'H? N?i', '0123456789');

INSERT INTO DonViVanChuyen (MaDonVi, TenDonVi, DiaChi, SoDienThoai) 
VALUES ('DV02', '??n v? v?n chuy?n H? Ch? Minh', 'TP.HCM', '0987654321');

INSERT INTO DonViVanChuyen (MaDonVi, TenDonVi, DiaChi, SoDienThoai) 
VALUES ('DV03', '??n v? v?n chuy?n ?? N?ng', '?? N?ng', '0912345678');

INSERT INTO DonViVanChuyen (MaDonVi, TenDonVi, DiaChi, SoDienThoai) 
VALUES ('DV04', '??n v? v?n chuy?n C?n Th?', 'C?n Th?', '0934567890');

INSERT INTO DonViVanChuyen (MaDonVi, TenDonVi, DiaChi, SoDienThoai) 
VALUES ('DV05', '??n v? v?n chuy?n H?i Ph?ng', 'H?i Ph?ng', '0901234567');


-- table LoSanPham
INSERT INTO LoSanPham (Malo, Tenlo, Maho, MaDonVi, NgaySanXuat, HanSuDung) 
VALUES ('L01', 'L? A', 'H01', 'DV01', TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-01', 'YYYY-MM-DD'));

INSERT INTO LoSanPham (Malo, Tenlo, Maho, MaDonVi, NgaySanXuat, HanSuDung) 
VALUES ('L02', 'L? B', 'H02', 'DV02', TO_DATE('2023-07-10', 'YYYY-MM-DD'), TO_DATE('2024-07-10', 'YYYY-MM-DD'));

INSERT INTO LoSanPham (Malo, Tenlo, Maho, MaDonVi, NgaySanXuat, HanSuDung) 
VALUES ('L03', 'L? C', 'H03', 'DV03', TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2024-08-01', 'YYYY-MM-DD'));

INSERT INTO LoSanPham (Malo, Tenlo, Maho, MaDonVi, NgaySanXuat, HanSuDung) 
VALUES ('L04', 'L? D', 'H04', 'DV04', TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2024-09-01', 'YYYY-MM-DD'));

INSERT INTO LoSanPham (Malo, Tenlo, Maho, MaDonVi, NgaySanXuat, HanSuDung) 
VALUES ('L05', 'L? E', 'H05', 'DV05', TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2024-10-01', 'YYYY-MM-DD'));


-- table KhachHang
INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) 
VALUES ('KH01', 'L? Th?nh Trung', 'H? N?i', '0123456789');

INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) 
VALUES ('KH02', 'Nguy?n V?n C?nh', 'TP.HCM', '0987654321');

INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) 
VALUES ('KH03', 'D??ng Qu?c Tu?n', '?? N?ng', '0912345678');

INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) 
VALUES ('KH04', 'Tr?n Trung Tr?c', 'C?n Th?', '0934567890');

INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) 
VALUES ('KH05', 'B?i Quang C??ng', 'H?i Ph?ng', '0901234567');


-- table ChiPhi
INSERT INTO ChiPhi (MaCP, Malo, SoTien, NgayChi, MoTa) 
VALUES ('CP01', 'L01', 500000, TO_DATE('2023-07-05', 'YYYY-MM-DD'), 'Chi ph? th?c ?n');

INSERT INTO ChiPhi (MaCP, Malo, SoTien, NgayChi, MoTa) 
VALUES ('CP02', 'L02', 600000, TO_DATE('2023-07-15', 'YYYY-MM-DD'), 'Chi ph? thu?c');

INSERT INTO ChiPhi (MaCP, Malo, SoTien, NgayChi, MoTa) 
VALUES ('CP03', 'L03', 700000, TO_DATE('2023-08-05', 'YYYY-MM-DD'), 'Chi ph? v?n chuy?n');

INSERT INTO ChiPhi (MaCP, Malo, SoTien, NgayChi, MoTa) 
VALUES ('CP04', 'L04', 800000, TO_DATE('2023-09-05', 'YYYY-MM-DD'), 'Chi ph? b?o qu?n');

INSERT INTO ChiPhi (MaCP, Malo, SoTien, NgayChi, MoTa) 
VALUES ('CP05', 'L05', 900000, TO_DATE('2023-10-05', 'YYYY-MM-DD'), 'Chi ph? kh?c');


-- table HoaDon
INSERT INTO HoaDon (MaHoaDon, Malo, SoTien, NgayLap, NguoiKy) 
VALUES ('HD01', 'L01', 1500000, TO_DATE('2023-07-15', 'YYYY-MM-DD'), 'Nguy?n V?n A');

INSERT INTO HoaDon (MaHoaDon, Malo, SoTien, NgayLap, NguoiKy) 
VALUES ('HD02', 'L02', 1600000, TO_DATE('2023-07-25', 'YYYY-MM-DD'), 'Nguy?n V?n B');

INSERT INTO HoaDon (MaHoaDon, Malo, SoTien, NgayLap, NguoiKy) 
VALUES ('HD03', 'L03', 1700000, TO_DATE('2023-08-15', 'YYYY-MM-DD'), 'Nguy?n V?n C');

INSERT INTO HoaDon (MaHoaDon, Malo, SoTien, NgayLap, NguoiKy) 
VALUES ('HD04', 'L04', 1800000, TO_DATE('2023-09-15', 'YYYY-MM-DD'), 'Nguy?n V?n D');

INSERT INTO HoaDon (MaHoaDon, Malo, SoTien, NgayLap, NguoiKy) 
VALUES ('HD05', 'L05', 1900000, TO_DATE('2023-10-15', 'YYYY-MM-DD'), 'Nguy?n V?n E');


-- table KhachHang_Lo
INSERT INTO KhachHang_Lo (MaKH, Malo, NgayMua, SoLuong) 
VALUES ('KH01', 'L01', TO_DATE('2023-07-20', 'YYYY-MM-DD'), 100);

INSERT INTO KhachHang_Lo (MaKH, Malo, NgayMua, SoLuong) 
VALUES ('KH02', 'L02', TO_DATE('2023-07-30', 'YYYY-MM-DD'), 200);

INSERT INTO KhachHang_Lo (MaKH, Malo, NgayMua, SoLuong) 
VALUES ('KH03', 'L03', TO_DATE('2023-08-20', 'YYYY-MM-DD'), 150);

INSERT INTO KhachHang_Lo (MaKH, Malo, NgayMua, SoLuong) 
VALUES ('KH04', 'L04', TO_DATE('2023-09-20', 'YYYY-MM-DD'), 180);

INSERT INTO KhachHang_Lo (MaKH, Malo, NgayMua, SoLuong) 
VALUES ('KH05', 'L05', TO_DATE('2023-10-20', 'YYYY-MM-DD'), 120);

drop table users

select * from users


--select user va khach hang
SELECT 
    u.USERNAME, 
    u.MaKH, 
    k.TENKH, 
    k.DIACHI, 
    k.SODIENTHOAI
FROM 
    USERS u
JOIN 
    KHACHHANG k 
ON 
    u.MaKH = k.MaKH;

UPDATE USERS
SET ROLE = 'ADMIN'
WHERE USERNAME = 'admin1';

CREATE TABLE USERS (
    USERNAME VARCHAR2(50) PRIMARY KEY,
    PASSWORD RAW(128) NOT NULL 
);
ALTER TABLE USERS ADD (ROLE VARCHAR2(20));
ALTER TABLE USERS ADD (MaKH VARCHAR2(10));

DELETE FROM USERS
WHERE USERNAME = 'taikhoan10';

SELECT * FROM USERS WHERE USERNAME = 'Tk123';
desc users

-----------------------------------------------------------------------------------------------tao procedure xac thuc nguoi dung
CREATE OR REPLACE PROCEDURE KiemTraDangNhap(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,  -- nhan mat khau ma hoa
    p_result OUT VARCHAR2,
    p_role OUT VARCHAR2
) AS
    v_password_db VARCHAR2(100);  -- lay pass tu database
BEGIN
    -- tim pass tu username trong database
    SELECT PASSWORD, ROLE
    INTO v_password_db, p_role
    FROM USERS
    WHERE USERNAME = p_username;

    -- So sanh
    IF v_password_db = p_password THEN
        p_result := 'SUCCESS';  -- login thanh cong
    ELSE
        p_result := 'FAILURE';  
    END IF;

EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_result := 'FAILURE';
        p_role := NULL;  -- neu ko co du lieu thi role la null
END;


select * from users



-----------------------------------------------------------------------------------------------thu tuc lay thong tin khach hang
CREATE OR REPLACE PROCEDURE thongtinKH(
    p_username IN VARCHAR2,
    p_MaKH OUT VARCHAR2,
    p_TENKH OUT VARCHAR2,
    p_DIACHI OUT VARCHAR2,
    p_SODIENTHOAI OUT VARCHAR2
)
AS
BEGIN
    SELECT u.MaKH, k.TENKH, k.DIACHI, k.SODIENTHOAI
    INTO p_MaKH, p_TENKH, p_DIACHI, p_SODIENTHOAI
    FROM USERS u
    JOIN KHACHHANG k ON u.MaKH = k.MaKH
    WHERE u.USERNAME = p_username;
END;
/

-----------------------------------------------------------------------------------------------thu tuc cap nhat du lieu profile


CREATE OR REPLACE PROCEDURE CapNhatProfile(
    p_USERNAME IN VARCHAR2,
    p_TENKH IN VARCHAR2,
    p_DIACHI IN VARCHAR2,
    p_SODIENTHOAI IN VARCHAR2
)
AS
BEGIN
    UPDATE KHACHHANG k
    SET k.TENKH = p_TENKH, k.DIACHI = p_DIACHI, k.SODIENTHOAI = p_SODIENTHOAI
    WHERE k.MaKH = (SELECT u.MaKH FROM USERS u WHERE u.USERNAME = p_USERNAME);
END;
/


-----------------------------------------------------------------------------------------------thu tuc kiem tra xem username co ton tai khong
CREATE OR REPLACE PROCEDURE KiemTraUsernameTonTai (
    p_username IN VARCHAR2,
    p_exists OUT INT
) AS
BEGIN
    SELECT COUNT(*)
    INTO p_exists
    FROM USERS
    WHERE Username = p_username;
END;
/















-----------------------------------------------------------------------------------------------procedure tao nguoi dung
CREATE OR REPLACE PROCEDURE Tao_NguoiDung (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_tenKhachHang IN VARCHAR2,
    p_diaChi IN VARCHAR2,
    p_soDienThoai IN VARCHAR2,
    p_role IN VARCHAR2
) AS
    l_encrypted_password RAW(128);
    l_key RAW(8) := UTL_I18N.STRING_TO_RAW('1AQ#7T78', 'AL32UTF8');
    l_new_MaKH VARCHAR2(10);
    l_exists INTEGER;
BEGIN
    
    SELECT COUNT(*) INTO l_exists FROM USERS WHERE USERNAME = p_username;
    IF l_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ng??i d?ng ?? t?n t?i');
    END IF;

    
    l_encrypted_password := DBMS_CRYPTO.ENCRYPT(
        src => UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'),
        typ => DBMS_CRYPTO.DES_CBC_PKCS5,
        key => l_key
    );

    
    SELECT 'KH' || LPAD(NVL(MAX(SUBSTR(MaKH, 3)), 0) + 1, 2, '0')
    INTO l_new_MaKH
    FROM KhachHang;

    LOOP
        SELECT COUNT(*) INTO l_exists FROM KhachHang WHERE MaKH = l_new_MaKH;
        EXIT WHEN l_exists = 0;
        l_new_MaKH := 'KH' || LPAD(TO_NUMBER(SUBSTR(l_new_MaKH, 3)) + 1, 2, '0');
    END LOOP;

    INSERT INTO USERS (USERNAME, PASSWORD, ROLE, MaKH)
    VALUES (p_username, l_encrypted_password, p_role, l_new_MaKH);

    INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai)
    VALUES (l_new_MaKH, p_tenKhachHang, p_diaChi, p_soDienThoai);

    COMMIT;
END;


-----------------------------------------------------------------------------------------------procedure kiem tra dang nhap
CREATE OR REPLACE PROCEDURE KiemTraDangNhap (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_result OUT VARCHAR2,
    p_role OUT VARCHAR2
) AS
    l_encrypted_password RAW(128);
    l_stored_password RAW(128);
    l_key RAW(8) := UTL_I18N.STRING_TO_RAW('1AQ#7T78', 'AL32UTF8'); -- khoa bi mat
    
BEGIN
    -- Ma hoa pass nguoi dung dang nhap
    l_encrypted_password := DBMS_CRYPTO.ENCRYPT(
        src => UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'),
        typ => DBMS_CRYPTO.DES_CBC_PKCS5,
        key => l_key
    );

    SELECT PASSWORD, ROLE INTO l_stored_password, p_role
    FROM USERS
    WHERE USERNAME = p_username;

    -- so sanh mat khau ma hoa voi mat khau trong csdl
    IF l_stored_password = l_encrypted_password THEN
        p_result := 'SUCCESS';
    ELSE
        p_result := 'FAILURE';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 'FAILURE';
        p_role := 'UNKNOWN';
END;

-----------------------------------------------------------------------------------------------procedure lay du lieu khach hang
CREATE OR REPLACE PROCEDURE LayDuLieuKH (
    OUT_CURSOR OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN OUT_CURSOR FOR
        SELECT u.USERNAME, u.MaKH, k.TENKH, k.DIACHI, k.SODIENTHOAI
        FROM USERS u
        JOIN KhachHang k ON u.MaKH = k.MaKH;
END LayDuLieuKH;
/

-----------------------------------------------------------------------------------------------procedure xoa tai khoan
CREATE OR REPLACE PROCEDURE XoaTaiKhoan(p_username IN VARCHAR2) IS
BEGIN
    DELETE FROM USERS WHERE USERNAME = p_username;
    COMMIT;
END;
/




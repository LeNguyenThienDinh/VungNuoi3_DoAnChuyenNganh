SELECT logins FROM v$instance;


ALTER SESSION SET CONTAINER = CDB$ROOT;

SELECT name, cause, type, message, status, action 
FROM PDB_PLUG_IN_VIOLATIONS 
WHERE type = 'ERROR' AND status = 'PENDING';

DELETE FROM PDB_PLUG_IN_VIOLATIONS WHERE status = 'PENDING';


ALTER SESSION SET CONTAINER = VUNGNUOI;


--2 CAU LENH DUOI NAY CHI DUOC DUNG DE TEST USER CO DANG NHAP VAO DATABASE DUOC KHONG HAY THOI
ALTER SYSTEM DISABLE RESTRICTED SESSION;--------------------------------------------------------
ALTER SYSTEM ENABLE RESTRICTED SESSION;---------------------------------------------------------
------------------------------------------------------------------------------------------------




SELECT logins FROM v$instance;

--tao plugable database
--kiem tra 
SELECT name, open_mode FROM v$pdbs;

--TAO TABLESPACE
CREATE TABLESPACE VUNGNUOI_TABLESPACE
  DATAFILE 'E:\hufi\DoAnChuyenNganh\tttt\orcl\VUNGNUOI_TABLESPACE.dbf' 
  SIZE 100M 
  AUTOEXTEND ON 
  NEXT 10M 
  MAXSIZE UNLIMITED;
--KIEM TRA 
SELECT TABLESPACE_NAME, STATUS FROM DBA_TABLESPACES WHERE TABLESPACE_NAME = 'VUNGNUOI_TABLESPACE';


--b1
CREATE PLUGGABLE DATABASE VUNGNUOI
  ADMIN USER VUNGNUOI30 IDENTIFIED BY vungnuoi30
  FILE_NAME_CONVERT = ('E:\HUFI\ORACLE\21C\ORADATA\XE\PDBSEED', 'E:\hufi\DoAnChuyenNganh\tttt\orcl\VUNGNUOI');
--b2
ALTER PLUGGABLE DATABASE VUNGNUOI OPEN;
--b3 cap quyen
ALTER SESSION SET CONTAINER = VUNGNUOI;

ALTER USER VUNGNUOI30 QUOTA UNLIMITED ON VUNGNUOI_TABLESPACE;

GRANT ALL PRIVILEGES TO VUNGNUOI30;

GRANT CREATE SESSION TO VUNGNUOI30;
GRANT CREATE USER TO VUNGNUOI30;
GRANT DBA TO VUNGNUOI30; 
GRANT UNLIMITED TABLESPACE TO VUNGNUOI30;
ALTER USER VUNGNUOI30 QUOTA UNLIMITED ON USERS; 
GRANT EXECUTE ON DBMS_CRYPTO TO VUNGNUOI30;

----------------------------------------------------------------------------------------------------nho thay password 
CREATE PROFILE vungnuoiAD LIMIT PASSWORD_LIFE_TIME UNLIMITED;
ALTER USER VUNGNUOI30 PROFILE vungnuoiAD;




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
VALUES ('H01', 'H? nu?i mi?n Trung', 'A01', 'C?', 100, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H02', 'H? nu?i mi?n B?c', 'B01', 'T?m', 150, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H03', 'H? nu?i mi?n Nam', 'C02', 'Cua', 200, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H04', 'H? nu?i mi?n T?y', 'D03', 'C?', 120, '?ang ho?t ??ng');

INSERT INTO HoNuoi (Maho, Tenho, Mavung, LoaiThuySan, DienTich, TrangThai) 
VALUES ('H05', 'H? nu?i T?y Nguy?n', 'E01', '?c', 130, 'Ng?ng ho?t ??ng');


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
select * from khachhang




UPDATE USERS
SET ROLE = 'ADMIN'
WHERE USERNAME = 'admin';

CREATE TABLE USERS (
    USERNAME VARCHAR2(50) PRIMARY KEY,
    PASSWORD RAW(128) NOT NULL 
);
ALTER TABLE USERS ADD (ROLE VARCHAR2(20));
ALTER TABLE USERS ADD (MaKH VARCHAR2(10));
ALTER TABLE USERS ADD (LastSessionID VARCHAR2(255));


DELETE FROM USERS
WHERE USERNAME = 'taikhoan10';

SELECT * FROM USERS WHERE USERNAME = 'Tk123';
desc users

-----------------------------------------------------------------------------------------------tao procedure xac thuc nguoi dung
CREATE OR REPLACE PROCEDURE Kiem_TraDangNhap(
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
select * from khachhang

-- X?a ng??i d?ng t? b?ng USERS
DELETE FROM USERS
WHERE MAKH IN ('KH00000001', 'KH00000002', 'KH00000003', 'KH06', 'KH08');

-- X?a th?ng tin kh?ch h?ng t? b?ng KHACHHANG (n?u c?n)
DELETE FROM KHACHHANG
WHERE MAKH IN ('KH00000001', 'KH00000002', 'KH00000003', 'KH06', 'KH08');


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
SELECT * FROM USERS


SELECT * 
FROM all_objects 
WHERE object_name = 'KIEMTRADANGNHAP' 
  AND object_type = 'PROCEDURE';
  
  SELECT * 
FROM ALL_DEPENDENCIES 
WHERE NAME = 'KIEMTRADANGNHAP' 
  AND OWNER = 'SYS';


ALTER PROCEDURE TAO_NGUOIDUNG COMPILE;
ALTER PROCEDURE SYS.TAO_NGUOIDUNG COMPILE;

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

------------------------------------------------------------------------------------------------thu tuc tao nguoi dung
CREATE SEQUENCE SEQ_MAKH
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

DECLARE
    max_value NUMBER;
BEGIN
    SELECT MAX(TO_NUMBER(SUBSTR(MAKH, 3))) INTO max_value FROM KHACHHANG;
    EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_MAKH INCREMENT BY ' || (max_value + 1) || ' MINVALUE ' || (max_value + 1);
    EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_MAKH INCREMENT BY 1';
END;


CREATE OR REPLACE PROCEDURE TaoNguoiDung(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_tenkh IN VARCHAR2,
    p_diachi IN VARCHAR2,
    p_sodienthoai IN VARCHAR2
)
AS
    v_MaKH VARCHAR2(10);
    v_exists INT;
    v_role VARCHAR2(20) := 'USER'; 
BEGIN
    KiemTraUsernameTonTai(p_username, v_exists);

    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Username ?? t?n t?i!');
    END IF;

    LOOP
        SELECT 'KH' || LPAD(SEQ_MAKH.NEXTVAL, 2, '0') INTO v_MaKH FROM DUAL;

        BEGIN
            SELECT 1 INTO v_exists FROM USERS WHERE MAKH = v_MaKH;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_exists := 0;
        END;

        EXIT WHEN v_exists = 0;
    END LOOP;

    -- Ki?m tra m? kh?ch h?ng kh?ng t?n t?i
    SELECT COUNT(*) INTO v_exists FROM KHACHHANG WHERE MAKH = v_MaKH;
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'M? kh?ch h?ng ?? t?n t?i!');
    END IF;

    INSERT INTO USERS (USERNAME, PASSWORD, ROLE, MAKH)
    VALUES (p_username, p_password, v_role, v_MaKH); 

    INSERT INTO KHACHHANG (MAKH, TENKH, DIACHI, SODIENTHOAI)
    VALUES (v_MaKH, p_tenkh, p_diachi, p_sodienthoai);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'L?i t?o ng??i d?ng: ' || SQLERRM);
END;

SELECT * FROM USERS WHERE USERNAME = 'ohello123';
SELECT * FROM KHACHHANG WHERE MAKH = 'KH01';



----------------------------------------------------------------------------------------------tao nguoi dung 2.0
CREATE OR REPLACE PROCEDURE TAO_NGUOIDUNG( 
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_tenkh IN VARCHAR2,
    p_diachi IN VARCHAR2,
    p_sodienthoai IN VARCHAR2
)
AS
    v_MaKH VARCHAR2(10);
    v_exists INT;
    v_role VARCHAR2(20) := 'USER';
BEGIN
    -- Ki?m tra username ?? t?n t?i ch?a
    KiemTraUsernameTonTai(p_username, v_exists);
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Username ?? t?n t?i!');
    END IF;

    -- T?o m? kh?ch h?ng m?i (MAKH)
    LOOP
        SELECT 'KH' || LPAD(SEQ_MAKH.NEXTVAL, 2, '0') INTO v_MaKH FROM DUAL;
        SELECT COUNT(*) INTO v_exists FROM KHACHHANG WHERE MAKH = v_MaKH;
        EXIT WHEN v_exists = 0;
    END LOOP;

    -- T?o user trong Oracle v?i username v? password
    EXECUTE IMMEDIATE 'CREATE USER "' || p_username || '" IDENTIFIED BY "' || p_password || '"';

    -- Thi?t l?p profile cho user
    EXECUTE IMMEDIATE 'ALTER USER "' || p_username || '" PROFILE DEFAULT';

    -- C?p quy?n CONNECT cho user
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || p_username;

    -- C?p quy?n SELECT cho b?ng KHACHHANG
    EXECUTE IMMEDIATE 'GRANT SELECT ON KHACHHANG TO ' || p_username;

    -- L?u th?ng tin v?o b?ng USERS v? KHACHHANG
    INSERT INTO USERS (USERNAME, PASSWORD, ROLE, MAKH)
    VALUES (p_username, p_password, v_role, v_MaKH);

    INSERT INTO KHACHHANG (MAKH, TENKH, DIACHI, SODIENTHOAI)
    VALUES (v_MaKH, p_tenkh, p_diachi, p_sodienthoai);

    EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT IDLE_TIME 2 PASSWORD_LIFE_TIME 3/12 FAILED_LOGIN_ATTEMPTS 3';

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'L?i t?o ng??i d?ng: ' || SQLERRM || ' | Chi ti?t: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
END;



---------------------------------------------------------------------------------------tao nguoi dung 3.0
CREATE OR REPLACE PROCEDURE TAO_NGUOIDUNG( 
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_tenkh IN VARCHAR2,
    p_diachi IN VARCHAR2,
    p_sodienthoai IN VARCHAR2
)
AS
    v_MaKH VARCHAR2(10);
    v_exists INT;
    v_role VARCHAR2(20) := 'USER';
    v_short_username VARCHAR2(30);
BEGIN
    -- R?t ng?n t?n ng??i d?ng n?u c?n thi?t
    v_short_username := SUBSTR(p_username, 1, 30);

    -- Ki?m tra username ?? t?n t?i ch?a
    KiemTraUsernameTonTai(v_short_username, v_exists);
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Username ?? t?n t?i!');
    END IF;

    -- T?o m? kh?ch h?ng m?i (MAKH)
    LOOP
        SELECT 'KH' || LPAD(SEQ_MAKH.NEXTVAL, 2, '0') INTO v_MaKH FROM DUAL;
        SELECT COUNT(*) INTO v_exists FROM KHACHHANG WHERE MAKH = v_MaKH;
        EXIT WHEN v_exists = 0;
    END LOOP;

    -- T?o user trong Oracle
    EXECUTE IMMEDIATE 'CREATE USER "' || v_short_username || '" IDENTIFIED BY "' || p_password || '"';

    -- Thi?t l?p profile cho user
    EXECUTE IMMEDIATE 'ALTER USER "' || v_short_username || '" PROFILE DEFAULT';

    -- C?p quy?n CONNECT cho user
    EXECUTE IMMEDIATE 'GRANT CONNECT TO "' || v_short_username || '"';

    -- C?p quy?n SELECT cho b?ng KHACHHANG
    EXECUTE IMMEDIATE 'GRANT SELECT ON KHACHHANG TO "' || v_short_username || '"';

    -- L?u th?ng tin v?o b?ng USERS
    INSERT INTO USERS (USERNAME, PASSWORD, ROLE, MAKH)
    VALUES (v_short_username, p_password, v_role, v_MaKH);

    -- L?u th?ng tin v?o b?ng KHACHHANG
    INSERT INTO KHACHHANG (MAKH, TENKH, DIACHI, SODIENTHOAI)
    VALUES (v_MaKH, p_tenkh, p_diachi, p_sodienthoai);

    -- Thi?t l?p c?c gi?i h?n cho profile
    EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT IDLE_TIME 2 PASSWORD_LIFE_TIME 3/12 FAILED_LOGIN_ATTEMPTS 3';

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'L?i t?o ng??i d?ng: ' || SQLERRM || ' | Chi ti?t: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
END;




select * from users
SELECT username FROM dba_users where username = 'watthe7'
grant create session to WA1234






---------------------------------------------------------------------------------------tao profile cho user






SELECT * 
FROM DBA_SYS_PRIVS 
WHERE GRANTEE = 'C##VUNGNUOI';

grant create user to C##VUNGNUOI


create user kh2 identified by kh2;
alter user kh2 profile default
grant connect to kh2
grant select on khachhang to kh2

create user C##kh1 identified by kh1











create user C##taikhoan1 identified by taikhoan1;
grant connect to C##taikhoan1;
grant select on khachhang to C##taikhoan1;


CREATE PROFILE C##my_profile 
LIMIT 
  IDLE_TIME 2 
  PASSWORD_LIFE_TIME 90 
  FAILED_LOGIN_ATTEMPTS 3;


ALTER USER C##taikhoan1 PROFILE C##my_profile;


















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

CREATE USER C##ban IDENTIFIED BY ban;
GRANT DBA TO C##VUNGNUOI;
GRANT CONNECT, RESOURCE TO C##VUNGNUOI;
GRANT CREATE SESSION TO C##VUNGNUOI;
SELECT *
FROM USER_SYS_PRIVS
WHERE USERNAME = 'C##VUNGNUOI';


GRANT EXECUTE ON procedure C##VUNGNUOI.TAO_NGUOIDUNG TO C##VUNGNUOI;
GRANT EXECUTE ON C##VUNGNUOI.TAO_NGUOIDUNG TO C##VUNGNUOI;



SELECT *
FROM USER_ROLE_PRIVS
WHERE USERNAME = 'C##VUNGNUOI';

SELECT *
FROM ALL_OBJECTS
WHERE OBJECT_NAME = 'TAO_NGUOIDUNG'
AND OBJECT_TYPE = 'PROCEDURE'
AND OWNER = 'C##VUNGNUOI';

CREATE OR REPLACE PROCEDURE TAO_NGUOIDUNG_TEST AS
BEGIN
    NULL; 
END;

GRANT EXECUTE ON C##VUNGNUOI.TAO_NGUOIDUNG TO C##VUNGNUOI WITH GRANT OPTION;

SELECT *
FROM USER_SYS_PRIVS
WHERE USERNAME = 'C##VUNGNUOI';

create user C##ban1 identified by ban1;

select * from users

  
GRANT EXECUTE ON C##VUNGNUOI.TAO_NGUOIDUNG TO C##VUNGNUOI;
GRANT EXECUTE ON C##VUNGNUOI.TAO_NGUOIDUNG TO C##VUNGNUOI;


SELECT *
FROM ALL_OBJECTS
WHERE OBJECT_NAME = 'TAO_NGUOIDUNG' 
  AND OBJECT_TYPE = 'PROCEDURE';




 



--step1
SHOW CON_NAME;

--step2
SELECT NAME, OPEN_MODE FROM V$PDBS;

--step3
ALTER SESSION SET CONTAINER = XEPDB1;

--step4
create user VUNGNUOI identified by vungnuoi;

--step5
GRANT CONNECT, RESOURCE TO VUNGNUOI;

--step6
grant dba to VUNGNUOI;

--step7
SELECT NAME, CON_ID, OPEN_MODE FROM V$PDBS;
SELECT name, pdb FROM v$services;


using System;
using System.IO;
using System.Data;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.Mvc;
using Oracle.ManagedDataAccess.Client;
using VungNuoi3.Models;
using System.Linq;
using Oracle.ManagedDataAccess.Types;
using System.Collections.Generic;
using System.ComponentModel.Design;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.OpenSsl;
using Org.BouncyCastle.Security;
using System.Web;

namespace VungNuoi3.Controllers
{
    public class HomeADController : Controller
    {
        // GET: HomeAD
        public ActionResult Index()
        {
			ViewBag.IsUserLoggedIn = IsUserLoggedIn();
			return View();
		}

        //===================================================================rsa

        public string TaoNgauNhienText(int length = 5)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            Random random = new Random();
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }



        private RSAParameters GetPublicKeyFromPEMFile(string pemFilePath)
        {
            using (TextReader reader = new StreamReader(pemFilePath))
            {
                PemReader pemReader = new PemReader(reader);
                var publicKeyParam = (RsaKeyParameters)pemReader.ReadObject();
                return DotNetUtilities.ToRSAParameters(publicKeyParam);
            }
        }

        private RSAParameters GetPrivateKeyFromPEMFile(Stream pemStream)
        {
            using (TextReader reader = new StreamReader(pemStream))
            {
                PemReader pemReader = new PemReader(reader);
                var keyObject = pemReader.ReadObject();

                if (keyObject is AsymmetricCipherKeyPair keyPair)
                {
                    // Nếu đọc được cặp khóa (public/private)
                    var privateKeyParam = (RsaPrivateCrtKeyParameters)keyPair.Private;
                    return DotNetUtilities.ToRSAParameters(privateKeyParam);
                }
                else if (keyObject is RsaPrivateCrtKeyParameters privateKeyParam)
                {
                    // Nếu chỉ đọc được khóa private
                    return DotNetUtilities.ToRSAParameters(privateKeyParam);
                }
                else
                {
                    throw new PemException("Unsupported key format.");
                }
            }
        }

        public string EncryptChallengeWithRSA(string plainText)
        {

            // lay khoa cong khai
            string publicPemFilePath = "E:\\hufi\\DoAnChuyenNganh\\tttt\\chiu\\VungNuoi3\\public.pem";
            var rsaParameters = GetPublicKeyFromPEMFile(publicPemFilePath);

            // ma hoa rsa dung public key
            using (var rsa = new RSACryptoServiceProvider())
            {
                rsa.ImportParameters(rsaParameters);
                var encryptedData = rsa.Encrypt(Encoding.UTF8.GetBytes(plainText), false);
                return Convert.ToBase64String(encryptedData);
            }
        }


        private RSAParameters GetRSAParametersFromPEM(string pem)
        {
            using (TextReader reader = new StringReader(pem))
            {
                PemReader pemReader = new PemReader(reader);
                AsymmetricKeyParameter publicKeyParam = (AsymmetricKeyParameter)pemReader.ReadObject();
                RsaKeyParameters rsaKeyParams = (RsaKeyParameters)publicKeyParam;
                return DotNetUtilities.ToRSAParameters(rsaKeyParams);
            }
        }

        public string EncryptPrivateKeyWithAES(string username)
        {
            var aesKey = Environment.GetEnvironmentVariable("AES_KEY");
            OracleConnect db = new OracleConnect();

            OracleParameter[] parameters = new OracleParameter[]
            {
                new OracleParameter("p_username", username),
                new OracleParameter("p_privateKey", OracleDbType.Varchar2, ParameterDirection.Output)
            };

            db.ExecuteQuery("GetPrivateKey", parameters);
            string privateKey = parameters[1].Value.ToString();

            using (var aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(aesKey);
                aes.GenerateIV();
                var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);

                using (var ms = new MemoryStream())
                {
                    using (var cs = new CryptoStream(ms, encryptor, CryptoStreamMode.Write))
                    {
                        using (var sw = new StreamWriter(cs))
                        {
                            sw.Write(privateKey);
                        }
                    }
                    var iv = aes.IV;
                    var encryptedContent = ms.ToArray();
                    var result = new byte[iv.Length + encryptedContent.Length];
                    Buffer.BlockCopy(iv, 0, result, 0, iv.Length);
                    Buffer.BlockCopy(encryptedContent, 0, result, iv.Length, encryptedContent.Length);
                    return Convert.ToBase64String(result);
                }
            }
        }

        public bool CompareEncryptedPrivateKey(string encryptedPrivateKey, string storedEncryptedPrivateKey)
        {
            return encryptedPrivateKey == storedEncryptedPrivateKey;
        }

        public string DecryptChallengeWithRSA(string encryptedText, Stream privateKeyStream)
        {
            // Đọc khóa riêng từ stream
            var rsaParameters = GetPrivateKeyFromPEMFile(privateKeyStream);

            using (var rsa = new RSACryptoServiceProvider())
            {
                rsa.ImportParameters(rsaParameters);
                var decryptedData = rsa.Decrypt(Convert.FromBase64String(encryptedText), false);
                return Encoding.UTF8.GetString(decryptedData);
            }
        }

        //public bool VerifyDecryptedChallenge(string decryptedChallenge, string originalChallenge)
        //{
        //    return decryptedChallenge == originalChallenge;
        //}

        public bool VerifyDecryptedChallenge(string decryptedChallenge, string originalChallenge)
        {
            return decryptedChallenge == originalChallenge;
        }

        public ActionResult Authentication()
        {
            // Tạo văn bản ngẫu nhiên
            string randomText = TaoNgauNhienText();

            // Mã hóa thách thức với khóa công khai từ file PEM
            string encryptedText = EncryptChallengeWithRSA(randomText);

            // Lưu originalChallenge vào TempData
            TempData["OriginalChallenge"] = randomText;

            var model = new AuthenticationViewModel
            {
                EncryptedText = encryptedText,
                //OriginalChallenge = randomText // Lưu lại văn bản gốc để kiểm tra
            };

            return View(model);
        }


        [HttpPost]
        public ActionResult Authenticate(string encryptedText, string decryptedText, HttpPostedFileBase privateKeyFile)
        {
            if (privateKeyFile != null && privateKeyFile.ContentLength > 0)
            {
                // Đọc nội dung của file
                using (var stream = privateKeyFile.InputStream)
                {
                    // Gọi hàm giải mã thách thức
                    string decryptedChallenge = DecryptChallengeWithRSA(encryptedText, stream);

                    // Lấy originalChallenge từ TempData
                    string originalChallenge = TempData["OriginalChallenge"]?.ToString();

                    // So sánh thông điệp đã giải mã với văn bản gốc
                    if (VerifyDecryptedChallenge(decryptedChallenge, originalChallenge))
                    {
                        TempData["SuccessMessage"] = "Xác thực thành công!";
                        return RedirectToAction("Index", "HomeAD");
                    }
                }
            }

            // Tăng số lần thử nghiệm không thành công
            int failedAttempts = (int)(Session["FailedAttempts"] ?? 0) + 1;
            Session["FailedAttempts"] = failedAttempts;

            // Kiểm tra nếu số lần thử nghiệm vượt quá 3
            if (failedAttempts >= 3)
            {
                Session.Clear();
                return RedirectToAction("Index", "Home");
            }

            TempData["ErrorMessage"] = "Xác thực không thành công!";
            return View("Authentication");
        }



        public User GetUserByPrivateKey(string privateKey)
        {
            User user = null;
            OracleConnect db = new OracleConnect();
            using (var connection = new OracleConnection(db.GetConnectionString()))
            {
                using (var command = new OracleCommand("GetUserByPrivateKey", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("p_privateKey", OracleDbType.Varchar2).Value = privateKey;
                    command.Parameters.Add("p_username", OracleDbType.Varchar2, 50).Direction = ParameterDirection.Output;

                    try
                    {
                        connection.Open();
                        command.ExecuteNonQuery();

                        var usernameObj = command.Parameters["p_username"].Value;

                        if (usernameObj != null && !string.IsNullOrEmpty(usernameObj.ToString()))
                        {
                            string username = usernameObj.ToString();
                            user = new User { Username = username, PrivateKey = privateKey };
                        }
                        else
                        {
                            // Không tìm thấy username
                            throw new Exception("No username found for the given private key.");
                        }
                    }
                    catch (Exception ex)
                    {
                        // Xử lý lỗi kết nối hoặc lỗi từ Oracle
                        Console.WriteLine($"Error: {ex.Message}");
                    }
                }
            }
            return user;
        }

        [HttpPost]
        public JsonResult DecryptText(string encryptedText, string privateKey)
        {
            string decryptedText = Decrypt(encryptedText, privateKey);

            if (!string.IsNullOrEmpty(decryptedText))
            {
                return Json(new { success = true, decryptedText });
            }
            else
            {
                return Json(new { success = false, message = "Giải mã không thành công. Vui lòng kiểm tra khóa bí mật." });
            }
        }

        private string Decrypt(string encryptedText, string secretKey)
        {
            byte[] fullCipher = Convert.FromBase64String(encryptedText);
            byte[] iv = new byte[16];
            byte[] cipherTextBytes = new byte[fullCipher.Length - iv.Length];

            Array.Copy(fullCipher, iv, iv.Length);
            Array.Copy(fullCipher, iv.Length, cipherTextBytes, 0, cipherTextBytes.Length);

            using (Aes aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(secretKey);
                aes.IV = iv; // Use the extracted IV

                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;

                using (ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV))
                {
                    using (MemoryStream ms = new MemoryStream(cipherTextBytes))
                    {
                        using (CryptoStream cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
                        {
                            using (StreamReader sr = new StreamReader(cs))
                            {
                                return sr.ReadToEnd();
                            }
                        }
                    }
                }
            }
        }



        public string EncryptAES(string plainText, string key)
        {
            using (Aes aesAlg = Aes.Create())
            {
                aesAlg.Key = Encoding.UTF8.GetBytes(key);
                aesAlg.IV = new byte[16];

                ICryptoTransform encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV);

                using (MemoryStream msEncrypt = new MemoryStream())
                {
                    using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                    {
                        using (StreamWriter swEncrypt = new StreamWriter(csEncrypt))
                        {
                            swEncrypt.Write(plainText);
                        }
                    }

                    byte[] encrypted = msEncrypt.ToArray();
                    return Convert.ToBase64String(encrypted);
                }
            }
        }

        //=====================================================================ket thuc rsa


        [HttpPost]
		public JsonResult KiemTraUser(string username)
		{
			bool usernameExists = false;

			OracleConnect db = new OracleConnect();

			try
			{
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var command = new OracleCommand("KiemTraUsernameTonTai", connection))
					{
						command.CommandType = CommandType.StoredProcedure;
						command.Parameters.Add(new OracleParameter("p_username", OracleDbType.Varchar2)).Value = username;
						command.Parameters.Add(new OracleParameter("p_exists", OracleDbType.Int32)).Direction = ParameterDirection.Output;

						connection.Open();
						command.ExecuteNonQuery();

						int exists = int.Parse(command.Parameters["p_exists"].Value.ToString());
						usernameExists = exists == 1;
					}
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine("Error: " + ex.Message);
			}

			return Json(new { Exists = usernameExists });
		}

		public ActionResult Register()
		{
			return View();
		}
		[HttpPost]
		public ActionResult Register(string username, string password, string tenKhachHang, string diaChi, string soDienThoai)
		{
			OracleConnect db = new OracleConnect();
			string hashedPassword = EncryptPassword(password);

			try
			{
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					connection.Open();

					// Kiểm tra xem username có tồn tại không
					using (var checkCommand = new OracleCommand("KiemTraUsernameTonTai", connection))
					{
						checkCommand.CommandType = CommandType.StoredProcedure;

						var existsParameter = new OracleParameter("p_exists", OracleDbType.Int32) { Direction = ParameterDirection.Output };
						checkCommand.Parameters.Add(new OracleParameter("p_username", username));
						checkCommand.Parameters.Add(existsParameter);

						checkCommand.ExecuteNonQuery();

						// Chuyển đổi giá trị từ OracleDecimal sang int
						int v_exists = ((OracleDecimal)existsParameter.Value).ToInt32();
						if (v_exists > 0)
						{
							ViewBag.ErrorMessage = "Tài khoản đã tồn tại!";
							return View("Register");
						}
					}

					using (var command = new OracleCommand("TAO_NGUOIDUNG", connection))
					{
						command.CommandType = CommandType.StoredProcedure;

						string oracleUsername = username.Length > 27 ? username.Substring(0, 27) : username;

						command.Parameters.Add(new OracleParameter("p_username", username));
						command.Parameters.Add(new OracleParameter("p_password", hashedPassword));
						command.Parameters.Add(new OracleParameter("p_tenkh", tenKhachHang));
						command.Parameters.Add(new OracleParameter("p_diachi", diaChi));
						command.Parameters.Add(new OracleParameter("p_sodienthoai", soDienThoai));

						command.ExecuteNonQuery();
					}
				}

				return RedirectToAction("Login");
			}
			catch (Exception ex)
			{
				Console.WriteLine("Error: " + ex.Message);
				ViewBag.ErrorMessage = "Đã xảy ra lỗi trong quá trình đăng ký.";
				return View("Register");
			}
		}

		public ActionResult AlreadyLoggedIn()
		{
			return View();
		}
		public ActionResult Login()
		{
			if (IsUserLoggedIn())
			{
				return View("AlreadyLoggedIn");
			}
			return View();
		}

		[HttpPost]
		public ActionResult Login(string taiKhoan, string matKhau)
		{
			if (IsUserLoggedIn())
			{
				ViewBag.ErrorMessage = "Bạn đã đăng nhập rồi";
				return View("AlreadyLoggedIn");
			}

			string hashedPassword = EncryptPassword(matKhau);
			string userRole = ValidateUser(taiKhoan, hashedPassword);

			if (userRole != null)
			{
				string sessionId = Guid.NewGuid().ToString();

				OracleConnect db = new OracleConnect();
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var updateCommand = new OracleCommand("Capnhat_SessionDangNhap", connection))
					{
						updateCommand.CommandType = CommandType.StoredProcedure;
						updateCommand.Parameters.Add("p_username", OracleDbType.Varchar2).Value = taiKhoan;
						updateCommand.Parameters.Add("p_sessionID", OracleDbType.Varchar2).Value = sessionId;

						connection.Open();
						updateCommand.ExecuteNonQuery();
					}
				}

				// Lưu session vào hệ thống
				Session["User"] = taiKhoan;
				Session["Role"] = userRole;
				Session["SessionID"] = sessionId; // Lưu session ID vào Session của ASP.NET

				if (userRole == "ADMIN")
				{
					return RedirectToAction("Index", "HomeAD");
				}
				else
				{
					return RedirectToAction("Index", "Home");
				}
			}
			else
			{
				ViewBag.ErrorMessage = "Tài khoản hoặc mật khẩu không đúng";
				return View();
			}
		}

		private bool IsUserLoggedIn()
		{
			if (Session["User"] != null && Session["SessionID"] != null)
			{
				string sessionId = Session["SessionID"].ToString();
				string username = Session["User"].ToString();

				OracleConnect db = new OracleConnect();
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var command = new OracleCommand("KiemtraSession", connection))
					{
						command.CommandType = CommandType.StoredProcedure;

						command.Parameters.Add("p_username", OracleDbType.Varchar2).Value = username;
						var sessionIDParam = new OracleParameter("p_sessionID", OracleDbType.Varchar2, 255);
						sessionIDParam.Direction = ParameterDirection.Output;
						command.Parameters.Add(sessionIDParam);

						connection.Open();
						command.ExecuteNonQuery();

						string dbSessionID = sessionIDParam.Value.ToString();

						if (dbSessionID == sessionId)
						{
							return true;
						}
						else
						{
							Session.Clear();
							return false;
						}
					}
				}
			}
			return false;
		}
		private string ValidateUser(string username, string password)
		{
			OracleConnect db = new OracleConnect(); // Tạo đối tượng OracleConnect
			string result = null;
			string role = null;

			try
			{
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var command = new OracleCommand("Kiem_TraDangNhap", connection))
					{
						command.CommandType = CommandType.StoredProcedure;

						// su dung tham so cho thu tuc
						command.Parameters.Add(new OracleParameter("p_username", username));
						command.Parameters.Add(new OracleParameter("p_password", password));

						// khai bao output
						command.Parameters.Add(new OracleParameter("p_result", OracleDbType.Varchar2, 100) { Direction = ParameterDirection.Output });
						command.Parameters.Add(new OracleParameter("p_role", OracleDbType.Varchar2, 100) { Direction = ParameterDirection.Output });

						// thuc thi thu tuc
						connection.Open();
						command.ExecuteNonQuery();

						result = command.Parameters["p_result"].Value.ToString();
						role = command.Parameters["p_role"].Value.ToString();

					}
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine("Error: " + ex.Message);
			}

			if (result == "SUCCESS")
			{
				return role;
			}
			else
			{
				return null;
			}
		}


		private string EncryptPassword(string password)
		{
			// Khóa DES (8 bytes)
			byte[] key = Encoding.UTF8.GetBytes("1AQ#7T78"); // Đảm bảo rằng đây là khóa 8 byte
			byte[] iv = new byte[8]; // Tạo một IV (8 bytes) bằng 0 hoặc ngẫu nhiên

			using (var des = DES.Create())
			{
				des.Key = key;
				des.IV = iv; // Thiết lập IV
				des.Mode = CipherMode.CBC;
				des.Padding = PaddingMode.PKCS7; // Padding PKCS7 tương đương với PKCS5

				// Mã hóa
				using (var encryptor = des.CreateEncryptor())
				{
					byte[] inputBytes = Encoding.UTF8.GetBytes(password);
					byte[] encryptedBytes = encryptor.TransformFinalBlock(inputBytes, 0, inputBytes.Length);
					return BitConverter.ToString(encryptedBytes).Replace("-", "").ToUpper();
				}
			}


		}
        




        public ActionResult Logout()
		{
			if (Session["User"] != null)
			{
				string username = Session["User"].ToString();

				OracleConnect db = new OracleConnect();
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var command = new OracleCommand("KiemtraSession", connection))
					{
						command.CommandType = CommandType.StoredProcedure;
						command.Parameters.Add("p_username", OracleDbType.Varchar2).Value = username;

						connection.Open();
						command.ExecuteNonQuery();
					}
				}
			}

			Session.Clear();
			return RedirectToAction("Index");
		}
		public ActionResult Profile()
		{
			if (!IsUserLoggedIn())
			{
				return RedirectToAction("Login");
			}

			string username = Session["User"].ToString();
			var customerData = GetCustomerData(username);

			return View(customerData);
		}
		private CustomerViewModel GetCustomerData(string username)
		{
			CustomerViewModel customer = null;

			OracleConnect db = new OracleConnect();

			try
			{
				using (var connection = new OracleConnection(db.GetConnectionString()))
				{
					using (var command = new OracleCommand("thongtinKH", connection))
					{
						command.CommandType = CommandType.StoredProcedure;

						// input
						command.Parameters.Add(new OracleParameter("p_username", OracleDbType.Varchar2)).Value = username;

						// output
						command.Parameters.Add(new OracleParameter("p_MaKH", OracleDbType.Varchar2, 50)).Direction = ParameterDirection.Output;
						command.Parameters.Add(new OracleParameter("p_TENKH", OracleDbType.Varchar2, 100)).Direction = ParameterDirection.Output;
						command.Parameters.Add(new OracleParameter("p_DIACHI", OracleDbType.Varchar2, 200)).Direction = ParameterDirection.Output;
						command.Parameters.Add(new OracleParameter("p_SODIENTHOAI", OracleDbType.Varchar2, 15)).Direction = ParameterDirection.Output;

						connection.Open();
						command.ExecuteNonQuery();

						// ket qua output
						string maKH = command.Parameters["p_MaKH"].Value.ToString();
						string tenKH = command.Parameters["p_TENKH"].Value.ToString();
						string diaChi = command.Parameters["p_DIACHI"].Value.ToString();
						string soDienThoai = command.Parameters["p_SODIENTHOAI"].Value.ToString();

						string[] nameParts = tenKH.Split(' ');

						customer = new CustomerViewModel
						{
							Username = username,
							MaKH = maKH,
							HoTenLot = nameParts.Length > 1 ? string.Join(" ", nameParts.Take(nameParts.Length - 1)) : "",
							Ten = nameParts.Last(),
							DiaChi = diaChi,
							SoDienThoai = soDienThoai
						};
					}
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine("Error: " + ex.Message);
			}

			return customer;
		}
		public ActionResult Index3()
        {
            return View();
        }
        
        public ActionResult PrivRole()
        {
            var customerDataList = GetAllCustomerData();
            return View(customerDataList);
        }
        private List<CustomerViewModel> GetAllCustomerData()
        {
            List<CustomerViewModel> customers = new List<CustomerViewModel>();

            OracleConnect db = new OracleConnect();

            try
            {
                using (var connection = new OracleConnection(db.GetConnectionString()))
                {
                    using (var command = new OracleCommand("getAllCustomers", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // output cursor
                        command.Parameters.Add(new OracleParameter("p_cursor", OracleDbType.RefCursor)).Direction = ParameterDirection.Output;

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string maKH = reader["MaKH"].ToString();
                                string tenKH = reader["TENKH"].ToString();
                                string diaChi = reader["DIACHI"].ToString();
                                string soDienThoai = reader["SODIENTHOAI"].ToString();

                                string[] nameParts = tenKH.Split(' ');

                                CustomerViewModel customer = new CustomerViewModel
                                {
                                    MaKH = maKH,
                                    HoTenLot = nameParts.Length > 1 ? string.Join(" ", nameParts.Take(nameParts.Length - 1)) : "",
                                    Ten = nameParts.Last(),
                                    DiaChi = diaChi,
                                    SoDienThoai = soDienThoai
                                };

                                customers.Add(customer);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return customers;
        }
        public ActionResult Privilege(string maKH)
        {
            // Tìm kiếm thông tin khách hàng theo Mã KH
            var customerData = GetCustomerDataByMaKH(maKH);

            if (customerData == null)
            {
                ViewBag.ErrorMessage = "Không tìm thấy thông tin khách hàng với Mã KH: " + maKH;
                return RedirectToAction("ErrorPage");
            }

            return View(customerData);
        }




        private CustomerViewModel GetCustomerDataByMaKH(string maKH)
        {
            CustomerViewModel customer = null;

            OracleConnect db = new OracleConnect();

            try
            {
                using (var connection = new OracleConnection(db.GetConnectionString()))
                {
                    using (var command = new OracleCommand("TTKhachHang", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // input (p_MaKH)
                        command.Parameters.Add(new OracleParameter("p_MaKH", OracleDbType.Varchar2)).Value = maKH;

                        // output (p_TENKH, p_DIACHI, p_SODIENTHOAI)
                        command.Parameters.Add(new OracleParameter("p_TENKH", OracleDbType.Varchar2, 100)).Direction = ParameterDirection.Output;
                        command.Parameters.Add(new OracleParameter("p_DIACHI", OracleDbType.Varchar2, 200)).Direction = ParameterDirection.Output;
                        command.Parameters.Add(new OracleParameter("p_SODIENTHOAI", OracleDbType.Varchar2, 15)).Direction = ParameterDirection.Output;

                        connection.Open();
                        command.ExecuteNonQuery();

                        // Kiểm tra xem dữ liệu có được trả về không
                        if (command.Parameters["p_TENKH"].Value != DBNull.Value)
                        {
                            string tenKH = command.Parameters["p_TENKH"].Value.ToString();
                            string diaChi = command.Parameters["p_DIACHI"].Value.ToString();
                            string soDienThoai = command.Parameters["p_SODIENTHOAI"].Value.ToString();

                            string[] nameParts = tenKH.Split(' ');

                            customer = new CustomerViewModel
                            {
                                MaKH = maKH,
                                HoTenLot = nameParts.Length > 1 ? string.Join(" ", nameParts.Take(nameParts.Length - 1)) : "",
                                Ten = nameParts.Last(),
                                DiaChi = diaChi,
                                SoDienThoai = soDienThoai
                            };
                        }
                        else
                        {
                            Console.WriteLine("Không tìm thấy khách hàng với Mã KH: " + maKH);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return customer;
        }

        [HttpPost]
        public JsonResult UpdateCustomer(CustomerViewModel model, string SelectedAttribute, int SoLuong)
        {
            try
            {
                // Call the method to update the user's profile attribute
                UpdateUserProfileInOracle(model.Username, SelectedAttribute, SoLuong);

                // Return success message
                return Json(new { success = true, message = "Cập nhật thông tin thành công!" });
            }
            catch (Exception ex)
            {
                // Return error message
                return Json(new { success = false, message = "Có lỗi xảy ra: " + ex.Message });
            }
        }


        private void UpdateUserProfileInOracle(string username, string attribute, int value)
        {
            OracleConnect db = new OracleConnect();

            try
            {
                using (var connection = new OracleConnection(db.GetConnectionString()))
                {
                    using (var command = new OracleCommand("UpdateUserProfile", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // input parameters
                        command.Parameters.Add(new OracleParameter("p_Username", OracleDbType.Varchar2)).Value = username;
                        command.Parameters.Add(new OracleParameter("p_Attribute", OracleDbType.Varchar2)).Value = attribute;
                        command.Parameters.Add(new OracleParameter("p_Value", OracleDbType.Int32)).Value = value;

                        connection.Open();
                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error updating user profile attribute: " + ex.Message);
            }
        }


    }
}
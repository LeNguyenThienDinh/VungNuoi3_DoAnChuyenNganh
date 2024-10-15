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
        public ActionResult Authentication()
        {
            string randomText = TaoNgauNhienText();

            string aesKey = "1234567890123456"; 

            string encryptedText = EncryptAES(randomText, aesKey);

            var model = new AuthenticationViewModel
            {
                EncryptedText = encryptedText
            };

            return View(model);
        }

        [HttpPost]
        public ActionResult Authenticate(string encryptedText, string privateKey, string decryptedText)
        {
            var user = GetUserByPrivateKey(privateKey);

            if (user != null)
            {
                string decryptedResult = Decrypt(encryptedText, privateKey);

                if (decryptedResult == decryptedText)
                {
                    TempData["SuccessMessage"] = "Xác thực thành công!";
                    return RedirectToAction("Index", "HomeAD");
                }
            }

            int failedAttempts = (int)(Session["FailedAttempts"] ?? 0) + 1;
            Session["FailedAttempts"] = failedAttempts;

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



        //private bool ThucThiXacThucDXung()
        //{
        //    // Thực hiện logic xác thực lẫn nhau ở đây
        //    // Sử dụng khóa đối xứng để mã hóa và xác thực dữ liệu
        //    // Ví dụ: gửi một thông điệp đến server và chờ phản hồi

        //    // Nếu xác thực thành công
        //    return true;

        //    // Nếu xác thực thất bại
        //    // return false;
        //}
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
        [HttpPost]
        public JsonResult DecryptText(string encryptedText, string privateKey)
        {
            // Giải mã đoạn văn bản bằng khóa bí mật
            string decryptedText = Decrypt(encryptedText, privateKey); // Phương thức giải mã

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
        public string TaoNgauNhienText(int length = 5)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            Random random = new Random();
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }

    }
}
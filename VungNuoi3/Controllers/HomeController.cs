using System;
using System.Data;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.Mvc;
using Oracle.ManagedDataAccess.Client;
using VungNuoi3.Models;
using System.Linq;


namespace VungNuoi3.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            ViewBag.IsUserLoggedIn = IsUserLoggedIn();
            return View();
        }
        public ActionResult Success()
        {
            return View();
        }
        public ActionResult Register()
        {
            return View();
        }
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

                Session["User"] = taiKhoan;
                Session["Role"] = userRole;

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
            return Session["User"] != null;
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
                    using (var command = new OracleCommand("KiemTraDangNhap", connection))
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

    }
}

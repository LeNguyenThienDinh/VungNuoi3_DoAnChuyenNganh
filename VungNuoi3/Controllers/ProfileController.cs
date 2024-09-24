using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using VungNuoi3.Models;

namespace VungNuoi3.Controllers
{
    public class ProfileController : Controller
    {
        // GET: Profile
        public ActionResult Index()
        {
            return View();
        }
        [HttpPost]
        public JsonResult UpdateProfile(CustomerViewModel model)
        {
            bool success = false;
            string message = "Chỉnh sửa thất bại";

            OracleConnect db = new OracleConnect();

            try
            {
                using (var connection = new OracleConnection(db.GetConnectionString()))
                {
                    using (var command = new OracleCommand("CapNhatProfile", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Thêm các tham số đầu vào cho stored procedure
                        command.Parameters.Add(new OracleParameter("p_USERNAME", OracleDbType.Varchar2)).Value = model.Username;
                        command.Parameters.Add(new OracleParameter("p_TENKH", OracleDbType.Varchar2)).Value = model.HoTenLot + " " + model.Ten;
                        command.Parameters.Add(new OracleParameter("p_DIACHI", OracleDbType.Varchar2)).Value = model.DiaChi;
                        command.Parameters.Add(new OracleParameter("p_SODIENTHOAI", OracleDbType.Varchar2)).Value = model.SoDienThoai;

                        connection.Open();
                        command.ExecuteNonQuery();

                        success = true;
                        message = "Chỉnh sửa thành công";
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return Json(new { success = success, message = message });
        }


    }
}
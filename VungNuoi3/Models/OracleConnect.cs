using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Configuration;

namespace VungNuoi3.Models
{
    public class OracleConnect
    {
        private string connectionString;

        public OracleConnect()
        {
            connectionString = ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;
        }
        public string GetConnectionString()
        {
            return connectionString;
        }

        public DataTable ExecuteQuery(string query, params OracleParameter[] parameters)
        {
            using (OracleConnection connection = new OracleConnection(connectionString))
            {
                try
                {
                    connection.Open(); 
                    using (OracleCommand command = new OracleCommand(query, connection))
                    {
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters); 
                        }

                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable); 
                        return dataTable;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error: " + ex.Message);
                    return null;
                }
            }
        }
        public void ExecuteProcedure(string procedureName, params OracleParameter[] parameters)
        {
            using (OracleConnection connection = new OracleConnection(connectionString))
            {
                try
                {
                    connection.Open();
                    using (OracleCommand command = new OracleCommand(procedureName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters);
                        }
                        command.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error: " + ex.Message);
                }
            }
        }


    }
}

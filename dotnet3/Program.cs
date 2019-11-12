using System;
using Microsoft.Data.SqlClient;

namespace ConsoleApp2
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");            
            using (var conn = new SqlConnection("Data Source=DESKTOP-K0D29BB;Initial Catalog=TestDB;User ID=test_user;Password=test_pass123;Connect Timeout=30;"))
            {
                //This doesn't work with our SQL Server 2017 when PKI certificate is configured on server
                conn.Open();                
            }
            //This code is never executed
            Console.WriteLine("Goodbye World!");
        }
    }
}
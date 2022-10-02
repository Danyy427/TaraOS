using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaraOS_Compile_Tool
{
    public partial class TaraOSCTool
    {

        static void shellRun(string q)
        {
            if(Environment.OSVersion.Platform == PlatformID.Unix)
            {
                // according to: https://stackoverflow.com/a/15262019/637142
                // thans to this we will pass everything as one command
                q = q.Replace("\"", "\"\"");

                var proc = new Process
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "/bin/zsh",
                        Arguments = "-c \"" + q + "\"",
                        UseShellExecute = false,
                        RedirectStandardOutput = true,
                        CreateNoWindow = true
                    }
                };

                proc.Start();
                proc.WaitForExit();

            }
            else if(Environment.OSVersion.Platform == PlatformID.Win32NT)
            {

                var process = System.Diagnostics.Process.Start("CMD.exe", $"/C {q}");
                process.WaitForExit();

            }
            else
            {
                return;
            }
        }


        static void copyTogether()
        {

            if (Environment.OSVersion.Platform == PlatformID.Unix)
            {
                string query = $"{copyToolUnix} ";

                foreach (var file in copyCatFileOrder)
                {
                    query += $"\"{Path.Combine(currentDir, outputArtifacts, file)}\" ";
                }
                query += "> " + "\"" + Path.Combine(currentDir, outputBin, endFileName) + "\"";

                Console.WriteLine(query);
                shellRun(query);
            }
            else if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                string query = $"{copyTool} /b ";

                foreach (var file in copyCatFileOrder)
                {
                    query += $"\"{Path.Combine(currentDir, outputArtifacts, file)}\" + ";
                }
                query = query.Substring(0, query.Length - 2) + "/b \"" + Path.Combine(currentDir, outputBin, endFileName) + "\"";

                Console.WriteLine(query);
                shellRun(query);
            }
            else
            {
                return;
            }
        }
    }
}

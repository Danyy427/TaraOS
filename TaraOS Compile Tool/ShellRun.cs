using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaraOS_Compile_Tool
{
    public partial class TaraOSCTool
    {
#if __MACOS__
        static void shellRun(string q)
        {
            // according to: https://stackoverflow.com/a/15262019/637142
            // thans to this we will pass everything as one command
            q = q.Replace("\"","\"\"");

            var proc = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "/bin/bash",
                    Arguments = "-c \""+ q + "\"",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                }
            };

            proc.Start();
            proc.WaitForExit();

            return proc.StandardOutput.ReadToEnd();
        }
#else 
        static void shellRun(string q)
        {
            var process = System.Diagnostics.Process.Start("CMD.exe", $"/C {q}");
            process.WaitForExit();
        }
#endif
    }
}

using System.Data;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;

namespace TaraOS_Compile_Tool
{
    public partial class TaraOSCTool
    {
        static string endFileName = "TaraOS.img";

        static string compiler = "gcc";
        static string assembler = "nasm";
        static string linker = "ld";
        static string copyTool = "copy";
        static string emulator = "qemu-system-x86_64";

        static string assemblerFlagsBin = "-fbin";

        static string sourceFolder = ".\\src";
        static string outputBin = ".\\bin";
        static string outputArtifacts = ".\\artifacts";

        static string[] assemblyBinFolders = { Path.Combine(sourceFolder, "boot\\bios\\boot") };
        static string assemblyIncFolder = Path.Combine(sourceFolder, "boot\\bios\\include");
        static string[] copyCatFileOrder = { "mbr.bin" };

        public static void Main(string[] args)
        {
            Console.WriteLine($"> Compiling Tara OS...");
            Console.WriteLine($"> Preffered Assembler is: {assembler}");

            clear();
            compileAssembly(assemblyBinFolders);
            copyTogether();
            run();

            Console.ReadLine();

        }


        static void clear()
        {
            foreach (var file in new DirectoryInfo(outputArtifacts).GetFiles())
            {
                file.Delete();
            }
            foreach (var file in new DirectoryInfo(outputBin).GetFiles())
            {
                file.Delete();
            }
        }



        static void compileAssembly(string[] assemblyBinFolers)
        {
            foreach (var folder in assemblyBinFolders)
            {
                var assemblyFiles = new DirectoryInfo(folder).GetFiles();

                foreach (var assemblyFile in assemblyFiles)
                {
                    shellRun($"{assembler} {assemblerFlagsBin} {assemblyFile} -i {assemblyIncFolder} -o {Path.Combine(outputArtifacts, Path.GetFileNameWithoutExtension(assemblyFile.FullName) + ".bin")}");
                }
            }
        }

        static void copyTogether()
        {
            string query = $"{copyTool} /b ";

            foreach (var file in copyCatFileOrder)
            {
                query += $"\"{Path.Combine(outputArtifacts, file)}\" + ";
            }
            query = query.Substring(0, query.Length - 2) + "/b \"" + Path.Combine(outputBin, endFileName) + "\"";

            Console.WriteLine(query);
            shellRun(query);
        }

        static void run()
        {
            shellRun(emulator + $" -monitor stdio {Path.Combine(outputBin, endFileName)}");
        }
    }
}


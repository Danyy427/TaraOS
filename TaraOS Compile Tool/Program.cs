using System.Data;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;

string endFileName = "TaraOS.img";

string compiler = "gcc";
string assembler = "nasm";
string linker = "ld";
string copyTool = "copy";
string emulator = "qemu-system-x86_64";

string assemblerFlagsBin = "-fbin";

string sourceFolder = ".\\src";
string outputBin = ".\\bin";
string outputArtifacts = ".\\artifacts";

string[] assemblyBinFolders = { Path.Combine(sourceFolder, "boot\\bios\\boot") };
string assemblyIncFolder = Path.Combine(sourceFolder, "boot\\bios\\include");
string[] copyCatFileOrder = { "mbr.bin" };

Console.WriteLine($"> Compiling Tara OS...");
Console.WriteLine($"> Preffered Assembler is: {assembler}");

clear();
compileAssembly(assemblyBinFolders);
copyTogether();
run();

Console.ReadLine();

void clear()
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

void shellRun(string q)
{
    var process = System.Diagnostics.Process.Start("CMD.exe", $"/C {q}");
	process.WaitForExit();
}

void compileAssembly(string[] assemblyBinFolers)
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

void copyTogether()
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

void run()
{
	shellRun(emulator + $" -monitor stdio {Path.Combine(outputBin, endFileName)}");
}
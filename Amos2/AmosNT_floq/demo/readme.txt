This folder contains some Visual Studio 6.0 project files to
illustrate how to integrate Amos II based systems in a C/C++
environment.

The most basic example project is amos2.dsw. It defines a minimal
'template' Amos II driver program in C, amos2.exe, that initializes
the system and then calls the Amos II top loop. Open the project an
run it to make sure your system is set up correctly.

Notice that to call the driver program from the command line you have
to provide the standard amos2.dmp as command line argument.

Base your own project file on the template project. Read the comment
in the main C source file for how to set up your own project.

Once you have your own empty project running correctly you can start
adding new code along with the instructions in external.pdf. There are
several other demo projects in the folder to illustrate different
kinds of applications in C using the Amos II kernel.

To save a project it is sufficient to save the .dsw, .dsp, .opt
file. The .opt file is a binary file that contains all project
options.




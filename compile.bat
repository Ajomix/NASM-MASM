set projectName=RC4_MASM
D:\masm32\bin\ml /c /Zd /coff %projectName%.asm
D:\masm32\bin\Link /SUBSYSTEM:CONSOLE %projectName%.obj
%projectName%.exe
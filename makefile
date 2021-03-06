# Set up the default build type. Build for release with: nmake build=release
!IF "$(BUILD)" == "RELEASE" || "$(build)" == "release"
_BUILD=release
!ELSE
_BUILD=debug
!ENDIF

BINDIR=bin\$(_BUILD)^\

!IF !EXIST("$(BINDIR)")
!  IF [MKDIR $(BINDIR)] != 0
!    ERROR Could not create the $(BINDIR) directory.
!  ENDIF
!ENDIF

LNK=link.exe
PCH=$(BINDIR)common.pch

# /Zi to generate PDB file. /Gy for funtion level linking. /EHsc for C++ exceptions
# /Yu to use precompiled header. /Fp for precompiled header path.
# /Fo for obj file path. /Fd for pdb file path.
CPPFLAGS=/Zi /EHsc /Yucommon.h /Fp$(PCH) /Fo$(BINDIR) /Fd$(BINDIR)
# C++17 with compliance and extra security checks. Production level warnings/errors.
CPPFLAGS=$(CPPFLAGS) /std:c++17 /sdl /permissive- /W3 /WX /Zc:inline
LNKFLAGS=/DEBUG /NOLOGO

# For release, enable optimizations and disable asserts. Debug uses the debug CRT.
# /OPT:REF,ICF off by default when generating debug info.
# /OPT:REF also disables incremental linking (i.e. no need to specify for release).
!IF "$(_BUILD)" == "release"
CPPFLAGS=$(CPPFLAGS) /O2 /Gy /MD /DNDEBUG
LNKFLAGS=$(LNKFLAGS) /OPT:REF,ICF
!ELSE
CPPFLAGS=$(CPPFLAGS) /Od /JMC /MDd /D_DEBUG
LNKFLAGS=$(LNKFLAGS) /INCREMENTAL
!ENDIF

OBJS=$(BINDIR)common.obj $(BINDIR)utils.obj $(BINDIR)main.obj
LIBS=kernel32.lib user32.lib advapi32.lib

# First target is the default. $@ is the target path. $** is all dependents.
$(BINDIR)myapp.exe: $(OBJS)
  $(LNK) $(LNKFLAGS) /OUT:$@ $** $(LIBS)

# List translation units explicitly, so header dependencies can be stated.

# Create the precompiled header and corresponding object file.
$(BINDIR)common.obj $(PCH): src\common.cpp src\common.h
  $(CPP) /c /Yccommon.h $(CPPFLAGS) src\common.cpp

# Remaining .obj files have the precompiled header as a dependency.
$(BINDIR)utils.obj: $(PCH) src\utils.cpp src\utils.h
  $(CPP) /c $(CPPFLAGS) src\utils.cpp

$(BINDIR)main.obj: $(PCH) src\main.cpp src\utils.h
  $(CPP) /c $(CPPFLAGS) src\main.cpp

clean:
  -rmdir /s /q .\bin

================================================================================
    MICROSOFT FOUNDATION CLASS LIBRARY : Shoting Range Manager Project Overview
===============================================================================

The application wizard has created this Shoting Range Manager application for 
you.  This application not only demonstrates the basics of using the Microsoft 
Foundation Classes but is also a starting point for writing your application.

This file contains a summary of what you will find in each of the files that
make up your Shoting Range Manager application.

Shoting Range Manager.vcproj
    This is the main project file for VC++ projects generated using an application wizard. 
    It contains information about the version of Visual C++ that generated the file, and 
    information about the platforms, configurations, and project features selected with the
    application wizard.

Shoting Range Manager.h
    This is the main header file for the application.  It includes other
    project specific headers (including Resource.h) and declares the
    CShotingRangeManagerApp application class.

Shoting Range Manager.cpp
    This is the main application source file that contains the application
    class CShotingRangeManagerApp.

Shoting Range Manager.rc
    This is a listing of all of the Microsoft Windows resources that the
    program uses.  It includes the icons, bitmaps, and cursors that are stored
    in the RES subdirectory.  This file can be directly edited in Microsoft
    Visual C++. Your project resources are in 1033.

res\ShotingRangeManager.ico
    This is an icon file, which is used as the application's icon.  This
    icon is included by the main resource file Shoting Range Manager.rc.

res\ShotingRangeManager.rc2
    This file contains resources that are not edited by Microsoft 
    Visual C++. You should place all resources not editable by
    the resource editor in this file.
Shoting Range Manager.reg
    This is an example .reg file that shows you the kind of registration
    settings the framework will set for you.  You can use this as a .reg
    file to go along with your application or just delete it and rely
    on the default RegisterShellFileTypes registration.
/////////////////////////////////////////////////////////////////////////////

For the main frame window:
    Windows Explorer Style: The project will include a Windows Explorer-like
    interface, with two frames.
SRMMainFrm.h, SRMMainFrm.cpp
    These files contain the frame class CSRMMainFrame, which is derived from
    CFrameWnd and controls all SDI frame features.
NavView.h, NavView.cpp
    These files contain the left frame class CNavView, which is derived from
    CTreeView.
res\Toolbar.bmp
    This bitmap file is used to create tiled images for the toolbar.
    The initial toolbar and status bar are constructed in the CSRMMainFrame
    class. Edit this toolbar bitmap using the resource editor, and
    update the IDR_MAINFRAME TOOLBAR array in Shoting Range Manager.rc to add
    toolbar buttons.
/////////////////////////////////////////////////////////////////////////////

The application wizard creates one document type and one view:

SRMDoc.h, SRMDoc.cpp - the document
    These files contain your CSRMDoc class.  Edit these files to
    add your special document data and to implement file saving and loading
    (via CSRMDoc::Serialize).
    The Document will have the following strings:
        File extension:      srdb
        File type ID:        ShotingRangeManager.Document
        Main frame caption:  Shoting Range Manager
        Doc type name:       RangeDatabase
        Filter name:         Shoting Range Database Files (*.srdb)
        File new short name: Range Database
        File type long name: Shoting Range Manager.Document
EventView.h, EventView.cpp - the view of the document
    These files contain your CEventView class.
    CEventView objects are used to view CSRMDoc objects.
/////////////////////////////////////////////////////////////////////////////

Other Features:

ActiveX Controls
    The application includes support to use ActiveX controls.

Printing and Print Preview support
    The application wizard has generated code to handle the print, print setup, and print preview
    commands by calling member functions in the CView class from the MFC library.
/////////////////////////////////////////////////////////////////////////////

Other standard files:

StdAfx.h, StdAfx.cpp
    These files are used to build a precompiled header (PCH) file
    named Shoting Range Manager.pch and a precompiled types file named StdAfx.obj.

Resource.h
    This is the standard header file, which defines new resource IDs.
    Microsoft Visual C++ reads and updates this file.

Shoting Range Manager.manifest
	Application manifest files are used by Windows XP to describe an applications 
	dependency on specific versions of Side-by-Side assemblies. The loader uses this 
	information to load the appropriate assembly from the assembly cache or private 
	from the application. The Application manifest  maybe included for redistribution 
	as an external .manifest file that is installed in the same folder as the application 
	executable or it may be included in the executable in the form of a resource. 
/////////////////////////////////////////////////////////////////////////////

Other notes:

The application wizard uses "TODO:" to indicate parts of the source code you
should add to or customize.

If your application uses MFC in a shared DLL, and your application is in a 
language other than the operating system's current language, you will need 
to copy the corresponding localized resources MFC70XXX.DLL from the Microsoft
Visual C++ CD-ROM under the Win\System directory to your computer's system or 
system32 directory, and rename it to be MFCLOC.DLL.  ("XXX" stands for the 
language abbreviation.  For example, MFC70DEU.DLL contains resources 
translated to German.)  If you don't do this, some of the UI elements of 
your application will remain in the language of the operating system.

/////////////////////////////////////////////////////////////////////////////

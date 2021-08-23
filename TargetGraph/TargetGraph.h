// TargetGraph.h : main header file for the TargetGraph application
//
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols


// CTargetGraphApp:
// See TargetGraph.cpp for the implementation of this class
//

class CTargetGraphApp : public CWinApp
{
public:
	CTargetGraphApp();


// Overrides
public:
	virtual BOOL InitInstance();

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CTargetGraphApp theApp;
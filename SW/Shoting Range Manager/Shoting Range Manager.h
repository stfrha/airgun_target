// Shoting Range Manager.h : main header file for the Shoting Range Manager application
//
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols


// CShotingRangeManagerApp:
// See Shoting Range Manager.cpp for the implementation of this class
//

class CShotingRangeManagerApp : public CWinApp
{
public:
	CShotingRangeManagerApp();


// Overrides
public:
	virtual BOOL InitInstance();

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CShotingRangeManagerApp theApp;
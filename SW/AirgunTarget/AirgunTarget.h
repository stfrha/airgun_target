// AirgunTarget.h : main header file for the AirgunTarget application
//
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols


// CAirgunTargetApp:
// See AirgunTarget.cpp for the implementation of this class
//

class CAirgunTargetApp : public CWinApp
{
public:
	CAirgunTargetApp();


// Overrides
public:
	virtual BOOL InitInstance();

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CAirgunTargetApp theApp;
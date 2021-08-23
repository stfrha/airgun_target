// ExtractDeltaTime.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols


// CExtractDeltaTimeApp:
// See ExtractDeltaTime.cpp for the implementation of this class
//

class CExtractDeltaTimeApp : public CWinApp
{
public:
	CExtractDeltaTimeApp();

// Overrides
	public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern CExtractDeltaTimeApp theApp;
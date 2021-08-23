#include "..\targetgraph\mainfrm.h"
// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "AirgunTarget.h"
#include "AirgunTargetView.h"
#include "AirgunTargetDoc.h"
#include "TargetPoint.h"

#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMainFrame

IMPLEMENT_DYNCREATE(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
	ON_WM_CREATE()
	ON_UPDATE_COMMAND_UI(IDS_MOUSE_POS, OnUpdateMousePos)
	ON_UPDATE_COMMAND_UI(IDS_DEBUG_1, OnUpdateDebug1)
END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
	IDS_DEBUG_1,
	IDS_MOUSE_POS,
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
	ID_INDICATOR_SCRL,
};


// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
	// TODO: add member initialization code here
}

CMainFrame::~CMainFrame()
{
}


int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
	if (!m_wndToolBar.CreateEx(this, TBSTYLE_FLAT, WS_CHILD | WS_VISIBLE | CBRS_TOP
		| CBRS_GRIPPER | CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC) ||
		!m_wndToolBar.LoadToolBar(IDR_MAINFRAME))
	{
		TRACE0("Failed to create toolbar\n");
		return -1;      // fail to create
	}

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}
	// TODO: Delete these three lines if you don't want the toolbar to be dockable
	m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
	EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndToolBar);

	return 0;
}

BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	if( !CFrameWnd::PreCreateWindow(cs) )
		return FALSE;
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return TRUE;
}


// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CFrameWnd::Dump(dc);
}

#endif //_DEBUG


// CMainFrame message handlers
void CMainFrame::OnUpdateMousePos(CCmdUI *pCmdUI)
{
	CString	msg;

	CAirgunTargetView* mView = (CAirgunTargetView*) GetActiveView();
//	CTargetPoint pnt = mView->m_mousePnt;
//	msg.Format("%04.2f ; %04.2f", pnt.m_x, pnt.m_y);
	CPoint pnt = mView->m_logMousePnt;
	msg.Format("%d ; %d", pnt.x, pnt.y);
	pCmdUI->SetText(msg);
}

void CMainFrame::OnUpdateDebug1(CCmdUI *pCmdUI)
{
	CAirgunTargetView* mView = (CAirgunTargetView*) GetActiveView();

	ASSERT_VALID(mView);

	if (mView->m_pathExists) {
		CString msg;
		msg.Format("%f", mView->m_pathAE[0].m_y);
		pCmdUI->SetText(msg);
	}
}


// SRMMainFrm.cpp : implementation of the CSRMMainFrame class
//

#include "stdafx.h"
#include "Shoting Range Manager.h"

#include "SRMMainFrm.h"
#include "NavView.h"
#include "EventView.h"
#include "ShotView.h"
#include "PlayerSeriesView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CSRMMainFrame

IMPLEMENT_DYNCREATE(CSRMMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CSRMMainFrame, CFrameWnd)
	ON_WM_CREATE()
	ON_WM_SIZE()
END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
	ID_INDICATOR_SCRL,
};


// CSRMMainFrame construction/destruction

CSRMMainFrame::CSRMMainFrame()
{
	// TODO: add member initialization code here
	m_bSplitterCreated = FALSE;
}

CSRMMainFrame::~CSRMMainFrame()
{
}


int CSRMMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
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

BOOL CSRMMainFrame::OnCreateClient(LPCREATESTRUCT /*lpcs*/,
	CCreateContext* pContext)
{
	// create splitter window
	if (!m_wndSplitter.CreateStatic(this, 1, 2))
		return FALSE;

	if (!m_wndSplitter.CreateView(0, 0, RUNTIME_CLASS(CNavView), CSize(100, 100), pContext))	{
		m_wndSplitter.DestroyWindow();
		return FALSE;
	}

	if (!m_wndSplitter2.CreateStatic(
		&m_wndSplitter,     // our parent window is the first splitter
		2, 1,               // the new splitter is 2 rows, 1 column
		WS_CHILD | WS_VISIBLE | WS_BORDER,  // style, WS_BORDER is needed
		m_wndSplitter.IdFromRowCol(0, 1)
			// new splitter is in the first row, 2nd column of first splitter
	   ))
	{
		m_wndSplitter.DestroyWindow();
		return FALSE;
	}

	if (!m_wndSplitter3.CreateStatic(
		&m_wndSplitter2,    // our parent window is the second splitter
		1, 2,               // the new splitter is 1 rows, 2 column
		WS_CHILD | WS_VISIBLE | WS_BORDER,  // style, WS_BORDER is needed
		m_wndSplitter.IdFromRowCol(0, 0)
			// new splitter is in the first row, first column of second splitter
	   ))
	{
		m_wndSplitter.DestroyWindow();
		return FALSE;
	}

	if (!m_wndSplitter3.CreateView(0, 0, RUNTIME_CLASS(CShotView), CSize(50, 200), pContext))	{
		m_wndSplitter.DestroyWindow();
		m_wndSplitter3.DestroyWindow();
		return FALSE;
	}

	if (!m_wndSplitter3.CreateView(0, 1, RUNTIME_CLASS(CPlayerSeriesView), CSize(50, 200), pContext))	{
		m_wndSplitter.DestroyWindow();
		m_wndSplitter.DestroyWindow();
		return FALSE;
	}

	if (!m_wndSplitter2.CreateView(1, 0, RUNTIME_CLASS(CEventView), CSize(0, 100), pContext))	{
		m_wndSplitter.DestroyWindow();
		m_wndSplitter2.DestroyWindow();
		m_wndSplitter3.DestroyWindow();
		return FALSE;
	}

	m_bSplitterCreated = TRUE;
	ResizeSplitters();

	return TRUE;
}

BOOL CSRMMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	if( !CFrameWnd::PreCreateWindow(cs) )
		return FALSE;
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	cs.style = WS_OVERLAPPED | WS_CAPTION | FWS_ADDTOTITLE
		 | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_MAXIMIZE | WS_SYSMENU;

	return TRUE;
}


// CSRMMainFrame diagnostics

#ifdef _DEBUG
void CSRMMainFrame::AssertValid() const
{
	CFrameWnd::AssertValid();
}

void CSRMMainFrame::Dump(CDumpContext& dc) const
{
	CFrameWnd::Dump(dc);
}

#endif //_DEBUG


// CSRMMainFrame message handlers
afx_msg void CSRMMainFrame::OnSize(UINT nType, int cx, int cy)
{
	CFrameWnd::OnSize(nType, cx, cy);
	ResizeSplitters();

}

void	CSRMMainFrame::ResizeSplitters( void )
{
	CRect rect;
	GetWindowRect( &rect );
	if( m_bSplitterCreated ) { // m_bSplitterCreated set in OnCreateClient
		m_wndSplitter.SetColumnInfo(0, rect.Width()/5, 20);
		m_wndSplitter.SetColumnInfo(1, 4*rect.Width()/5, 20);
		m_wndSplitter2.SetRowInfo(0, 2*rect.Height()/3, 20);
		m_wndSplitter2.SetRowInfo(1, rect.Height()/3, 20);
		m_wndSplitter3.SetColumnInfo(0, 2*rect.Width()/5, 20);
		m_wndSplitter3.SetColumnInfo(1, 2*rect.Width()/5, 20);
		m_wndSplitter.RecalcLayout();
		m_wndSplitter2.RecalcLayout();
		m_wndSplitter3.RecalcLayout();

	}

}
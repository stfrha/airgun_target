// EventView.cpp : implementation of the CEventView class
//

#include "stdafx.h"
#include "Shoting Range Manager.h"

#include "SRMDoc.h"
#include "EventView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CEventView

IMPLEMENT_DYNCREATE(CEventView, CListView)

BEGIN_MESSAGE_MAP(CEventView, CListView)
	ON_WM_STYLECHANGED()
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CListView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CListView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CListView::OnFilePrintPreview)
END_MESSAGE_MAP()

// CEventView construction/destruction

CEventView::CEventView()
{
	// TODO: add construction code here

}

CEventView::~CEventView()
{
}

BOOL CEventView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CListView::PreCreateWindow(cs);
}


void CEventView::OnDraw(CDC* /*pDC*/)
{
	CSRMDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);

	// TODO: add draw code for native data here
}


void CEventView::OnInitialUpdate()
{
	CListView::OnInitialUpdate();

	// TODO: You may populate your ListView with items by directly accessing
	//  its list control through a call to GetListCtrl().
}


// CEventView printing

BOOL CEventView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CEventView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CEventView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}


// CEventView diagnostics

#ifdef _DEBUG
void CEventView::AssertValid() const
{
	CListView::AssertValid();
}

void CEventView::Dump(CDumpContext& dc) const
{
	CListView::Dump(dc);
}

CSRMDoc* CEventView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CSRMDoc)));
	return (CSRMDoc*)m_pDocument;
}
#endif //_DEBUG


// CEventView message handlers
void CEventView::OnStyleChanged(int /*nStyleType*/, LPSTYLESTRUCT /*lpStyleStruct*/)
{
	//TODO: add code to react to the user changing the view style of your window
	
	Default();
}

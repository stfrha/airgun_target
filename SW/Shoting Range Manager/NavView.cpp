// NavView.cpp : implementation of the CNavView class
//

#include "stdafx.h"
#include "Shoting Range Manager.h"

#include "SRMDoc.h"
#include "NavView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CNavView

IMPLEMENT_DYNCREATE(CNavView, CTreeView)

BEGIN_MESSAGE_MAP(CNavView, CTreeView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CTreeView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CTreeView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CTreeView::OnFilePrintPreview)
END_MESSAGE_MAP()


// CNavView construction/destruction

CNavView::CNavView()
{
	// TODO: add construction code here
}

CNavView::~CNavView()
{
}

BOOL CNavView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying the CREATESTRUCT cs

	return CTreeView::PreCreateWindow(cs);
}


// CNavView printing

BOOL CNavView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CNavView::OnDraw(CDC* /*pDC*/)
{
	CSRMDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);

	// TODO: add draw code for native data here
}

void CNavView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CNavView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}

void CNavView::OnInitialUpdate()
{
	CTreeView::OnInitialUpdate();

	// TODO: You may populate your TreeView with items by directly accessing
	//  its tree control through a call to GetTreeCtrl().
}


// CNavView diagnostics

#ifdef _DEBUG
void CNavView::AssertValid() const
{
	CTreeView::AssertValid();
}

void CNavView::Dump(CDumpContext& dc) const
{
	CTreeView::Dump(dc);
}

CSRMDoc* CNavView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CSRMDoc)));
	return (CSRMDoc*)m_pDocument;
}
#endif //_DEBUG


// CNavView message handlers

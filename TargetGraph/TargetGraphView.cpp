// TargetGraphView.cpp : implementation of the CTargetGraphView class
//

#include "stdafx.h"
#include "TargetGraph.h"

#include "TargetGraphDoc.h"
#include "TargetGraphView.h"
#include ".\targetgraphview.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CTargetGraphView

IMPLEMENT_DYNCREATE(CTargetGraphView, CView)

BEGIN_MESSAGE_MAP(CTargetGraphView, CView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CView::OnFilePrintPreview)
END_MESSAGE_MAP()

// CTargetGraphView construction/destruction

CTargetGraphView::CTargetGraphView()
{
	// TODO: add construction code here

}

CTargetGraphView::~CTargetGraphView()
{
}

BOOL CTargetGraphView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

// CTargetGraphView drawing

void CTargetGraphView::OnDraw(CDC* /*pDC*/)
{
	CTargetGraphDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	// TODO: add draw code for native data here
}


// CTargetGraphView printing

BOOL CTargetGraphView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CTargetGraphView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CTargetGraphView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}


// CTargetGraphView diagnostics

#ifdef _DEBUG
void CTargetGraphView::AssertValid() const
{
	CView::AssertValid();
}

void CTargetGraphView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CTargetGraphDoc* CTargetGraphView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CTargetGraphDoc)));
	return (CTargetGraphDoc*)m_pDocument;
}
#endif //_DEBUG


// CTargetGraphView message handlers

void CTargetGraphView::OnInitialUpdate()
{
	CView::OnInitialUpdate();

	

	// TODO: Add your specialized code here and/or call the base class
}

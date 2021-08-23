// PlayerSeriesView.cpp : implementation file
//

#include "stdafx.h"
#include "Shoting Range Manager.h"
#include "PlayerSeriesView.h"


// CPlayerSeriesView

IMPLEMENT_DYNCREATE(CPlayerSeriesView, CView)

CPlayerSeriesView::CPlayerSeriesView()
{
}

CPlayerSeriesView::~CPlayerSeriesView()
{
}

BEGIN_MESSAGE_MAP(CPlayerSeriesView, CView)
END_MESSAGE_MAP()


// CPlayerSeriesView drawing

void CPlayerSeriesView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
	// TODO: add draw code here
}


// CPlayerSeriesView diagnostics

#ifdef _DEBUG
void CPlayerSeriesView::AssertValid() const
{
	CView::AssertValid();
}

void CPlayerSeriesView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}
#endif //_DEBUG


// CPlayerSeriesView message handlers

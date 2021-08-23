// ShotView.cpp : implementation file
//

#include "stdafx.h"
#include "Shoting Range Manager.h"
#include "ShotView.h"


// CShotView

IMPLEMENT_DYNCREATE(CShotView, CView)

CShotView::CShotView()
{
}

CShotView::~CShotView()
{
}

BEGIN_MESSAGE_MAP(CShotView, CView)
END_MESSAGE_MAP()


// CShotView drawing

void CShotView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
	// TODO: add draw code here
}


// CShotView diagnostics

#ifdef _DEBUG
void CShotView::AssertValid() const
{
	CView::AssertValid();
}

void CShotView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}
#endif //_DEBUG


// CShotView message handlers

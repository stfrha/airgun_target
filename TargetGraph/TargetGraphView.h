// TargetGraphView.h : interface of the CTargetGraphView class
//


#pragma once


class CTargetGraphView : public CView
{
protected: // create from serialization only
	CTargetGraphView();
	DECLARE_DYNCREATE(CTargetGraphView)

// Attributes
public:
	CTargetGraphDoc* GetDocument() const;

// Operations
public:

// Overrides
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);

// Implementation
public:
	virtual ~CTargetGraphView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
public:
	virtual void OnInitialUpdate();
};

#ifndef _DEBUG  // debug version in TargetGraphView.cpp
inline CTargetGraphDoc* CTargetGraphView::GetDocument() const
   { return reinterpret_cast<CTargetGraphDoc*>(m_pDocument); }
#endif


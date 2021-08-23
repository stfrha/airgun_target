// NavView.h : interface of the CNavView class
//


#pragma once

class CSRMDoc;

class CNavView : public CTreeView
{
protected: // create from serialization only
	CNavView();
	DECLARE_DYNCREATE(CNavView)

// Attributes
public:
	CSRMDoc* GetDocument();

// Operations
public:

// Overrides
	public:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnDraw(CDC* pDC);
	virtual void OnInitialUpdate(); // called first time after construct

// Implementation
public:
	virtual ~CNavView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in NavView.cpp
inline CSRMDoc* CNavView::GetDocument()
   { return reinterpret_cast<CSRMDoc*>(m_pDocument); }
#endif


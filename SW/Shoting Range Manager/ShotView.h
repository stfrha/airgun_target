#pragma once


// CShotView view

class CShotView : public CView
{
	DECLARE_DYNCREATE(CShotView)

protected:
	CShotView();           // protected constructor used by dynamic creation
	virtual ~CShotView();

public:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	DECLARE_MESSAGE_MAP()
};



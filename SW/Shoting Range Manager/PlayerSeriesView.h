#pragma once


// CPlayerSeriesView view

class CPlayerSeriesView : public CView
{
	DECLARE_DYNCREATE(CPlayerSeriesView)

protected:
	CPlayerSeriesView();           // protected constructor used by dynamic creation
	virtual ~CPlayerSeriesView();

public:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	DECLARE_MESSAGE_MAP()
};



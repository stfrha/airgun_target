// AirgunTargetView.h : interface of the CAirgunTargetView class
//


#pragma once

#include "AirgunTargetDoc.h"
#include "TargetPoint.h"
#include "Constants.h"


class CAirgunTargetView : public CScrollView
{
protected: // create from serialization only
	CAirgunTargetView();
	DECLARE_DYNCREATE(CAirgunTargetView)

// Data
public:
	CPoint				m_logMousePnt;
	CTargetPoint		m_mousePnt;
	CTargetPoint		m_impactPnt;
	CTargetPoint		m_pathAE[ACN_NUMOF_PATH_PNTS];
	CTargetPoint		m_pathBA[ACN_NUMOF_PATH_PNTS];
	CTargetPoint		m_pathCB[ACN_NUMOF_PATH_PNTS];
	CTargetPoint		m_pathDC[ACN_NUMOF_PATH_PNTS];
	CTargetPoint		m_pathED[ACN_NUMOF_PATH_PNTS];
	bool				m_isec_AE_BA;
	bool				m_isec_AE_CB;
	bool				m_isec_AE_DC;
	bool				m_isec_AE_ED;
	bool				m_isec_BA_CB;
	bool				m_isec_BA_DC;
	bool				m_isec_BA_ED;
	bool				m_isec_CB_DC;
	bool				m_isec_CB_ED;
	bool				m_isec_DC_ED;
	CTargetPoint		m_isec_AE_BA_pnt;
	CTargetPoint		m_isec_AE_CB_pnt;
	CTargetPoint		m_isec_AE_DC_pnt;
	CTargetPoint		m_isec_AE_ED_pnt;
	CTargetPoint		m_isec_BA_CB_pnt;
	CTargetPoint		m_isec_BA_DC_pnt;
	CTargetPoint		m_isec_BA_ED_pnt;
	CTargetPoint		m_isec_CB_DC_pnt;
	CTargetPoint		m_isec_CB_ED_pnt;
	CTargetPoint		m_isec_DC_ED_pnt;
	bool				m_pathExists;
	bool				m_debug;


// Attributes
public:
	CAirgunTargetDoc*	GetDocument() const;

// Operations
public:
	double		CalcDistance(CTargetPoint fromPt, CTargetPoint toPt);
	void		CalcImpactPath(double dd, CTargetPoint* path);
	void		TransformPath(double rtf, CTargetPoint mtf, CTargetPoint* path);
	void		DrawPath(CDC* pDC, CTargetPoint* path);
	void		DrawIntersection(CDC* pDC, CTargetPoint pnt);

	bool		FindIntersections(CTargetPoint* path1, CTargetPoint* path2, CTargetPoint* intersectionPoint);
	bool		CalcLineIntersection(CTargetPoint l1p1, CTargetPoint l1p2, CTargetPoint l2p1, 
									 CTargetPoint l2p2, CTargetPoint* intPoint);
	void		OnDebugBreak1( void );

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
	virtual ~CAirgunTargetView();
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
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
};

#ifndef _DEBUG  // debug version in AirgunTargetView.cpp
inline CAirgunTargetDoc* CAirgunTargetView::GetDocument() const
   { return reinterpret_cast<CAirgunTargetDoc*>(m_pDocument); }
#endif


// AirgunTargetView.cpp : implementation of the CAirgunTargetView class
//

#include "stdafx.h"
#include "AirgunTarget.h"

#include "TargetPoint.h"

#include "constants.h"
#include "AirgunTargetDoc.h"
#include "AirgunTargetView.h"
#include ".\airguntargetview.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAirgunTargetView

IMPLEMENT_DYNCREATE(CAirgunTargetView, CScrollView)

BEGIN_MESSAGE_MAP(CAirgunTargetView, CScrollView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CScrollView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CScrollView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CScrollView::OnFilePrintPreview)
	ON_COMMAND(ID_DEBUG_BREAK1, OnDebugBreak1)
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDOWN()
END_MESSAGE_MAP()

// CAirgunTargetView construction/destruction

CAirgunTargetView::CAirgunTargetView()
{
	// TODO: add construction code here
	m_pathExists = false;
	m_debug = false;
}

CAirgunTargetView::~CAirgunTargetView()
{
}

BOOL CAirgunTargetView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

// CAirgunTargetView drawing

void CAirgunTargetView::OnDraw(CDC* pDC)
{
	CAirgunTargetDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	// TODO: add draw code for native data here

	pDC->MoveTo(ACN_ORIGO_A + ACN_OA_OFFSET);
	pDC->LineTo(ACN_ORIGO_B + ACN_OA_OFFSET);
	pDC->LineTo(ACN_ORIGO_C + ACN_OA_OFFSET);
	pDC->LineTo(ACN_ORIGO_D + ACN_OA_OFFSET);
	pDC->LineTo(ACN_ORIGO_E + ACN_OA_OFFSET);
	pDC->LineTo(ACN_ORIGO_A + ACN_OA_OFFSET);
	CRect circBound(CPoint(0, 0), CPoint(1000, 1000));
	circBound.OffsetRect((CPoint)(ACN_CENTER_PNT + ACN_OA_OFFSET) - circBound.CenterPoint());
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
	circBound.DeflateRect(50, 50);
	pDC->Ellipse(circBound);
/*
	int	x, y;
	for (x=0 ; x<10000 ; x+=100) {
		for (y=0 ; y>=-10000 ; y-=100) {
			pDC->MoveTo(x, y);
			pDC->LineTo(x+100, y);
			pDC->LineTo(x+100, y-100);
			pDC->LineTo(x, y-100);
			pDC->LineTo(x, y);
		}
	}
*/
	if (m_pathExists) {
		DrawPath(pDC, m_pathAE);
		DrawPath(pDC, m_pathBA);
		DrawPath(pDC, m_pathCB);
		DrawPath(pDC, m_pathDC);
		DrawPath(pDC, m_pathED);
		if (m_isec_AE_BA) DrawIntersection(pDC, m_isec_AE_BA_pnt);
//		if (m_isec_AE_CB) DrawIntersection(pDC, m_isec_AE_CB_pnt);
//		if (m_isec_AE_DC) DrawIntersection(pDC, m_isec_AE_DC_pnt);
//		if (m_isec_AE_ED) DrawIntersection(pDC, m_isec_AE_ED_pnt);
		if (m_isec_BA_CB) DrawIntersection(pDC, m_isec_BA_CB_pnt);
//		if (m_isec_BA_DC) DrawIntersection(pDC, m_isec_BA_DC_pnt);
//		if (m_isec_BA_ED) DrawIntersection(pDC, m_isec_BA_ED_pnt);
		if (m_isec_CB_DC) DrawIntersection(pDC, m_isec_CB_DC_pnt);
//		if (m_isec_CB_ED) DrawIntersection(pDC, m_isec_CB_ED_pnt);
		if (m_isec_DC_ED) DrawIntersection(pDC, m_isec_DC_ED_pnt);
	}
}


void	CAirgunTargetView::DrawPath(CDC* pDC, CTargetPoint* path)
{
	int i;
	pDC->MoveTo(path[0] + ACN_OA_OFFSET);
	for (i=1 ; i<ACN_NUMOF_PATH_PNTS ; i++) pDC->LineTo(path[i] + ACN_OA_OFFSET);
}

void	CAirgunTargetView::DrawIntersection(CDC* pDC, CTargetPoint pnt)
{
	CTargetPoint	l(-30.0, 0.0);
	CTargetPoint	r(30.0, 0.0);
	CTargetPoint	t(0.0, -30.0);
	CTargetPoint	b(0.0, 30.0);

	pDC->MoveTo(pnt + l + ACN_OA_OFFSET);
	pDC->LineTo(pnt + r + ACN_OA_OFFSET);
	pDC->MoveTo(pnt + t + ACN_OA_OFFSET);
	pDC->LineTo(pnt + b + ACN_OA_OFFSET);

	/*CRect circBound(CPoint(0, 0), CPoint(60, 60));
	circBound.OffsetRect((CPoint)(pnt + ACN_OA_OFFSET) - circBound.CenterPoint());
	pDC->Ellipse(circBound);*/
}

// CAirgunTargetView printing

BOOL CAirgunTargetView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CAirgunTargetView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CAirgunTargetView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}


// CAirgunTargetView diagnostics

#ifdef _DEBUG
void CAirgunTargetView::AssertValid() const
{
	CView::AssertValid();
}

void CAirgunTargetView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CAirgunTargetDoc* CAirgunTargetView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CAirgunTargetDoc)));
	return (CAirgunTargetDoc*)m_pDocument;
}
#endif //_DEBUG


// CAirgunTargetView message handlers

void CAirgunTargetView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();
	ASSERT(GetDocument() != NULL);

	// TODO: Add your specialized code here and/or call the base class
	SetScrollSizes(MM_LOMETRIC, CSize(17 * 100, 17 * 100));
}

void CAirgunTargetView::OnMouseMove(UINT nFlags, CPoint point)
{
	// TODO: Add your message handler code here and/or call default

	CScrollView::OnMouseMove(nFlags, point);

	CClientDC	dc(this);
	CPoint	tp = point - GetScrollPosition();
	CSize	s;
	s.SetSize(tp.x - 1, tp.y);
	dc.LPtoHIMETRIC(&s);
//	m_mousePnt.m_x = (double) s.cx;
//	m_mousePnt.m_y = (double) s.cy;
	m_mousePnt.m_x = (double) s.cx / 10.0 - ACN_OA_OFFSET.m_x;
	m_mousePnt.m_y = (double) s.cy / 10.0 + ACN_OA_OFFSET.m_y;
}

void CAirgunTargetView::OnLButtonDown(UINT nFlags, CPoint point)
{
	// TODO: Add your message handler code here and/or call default

	CScrollView::OnLButtonDown(nFlags, point);

	m_logMousePnt = point;

	CClientDC	dc(this);
	CPoint	tp = point - GetScrollPosition();
	CSize	s;
	s.SetSize(tp.x - 1, tp.y);
	dc.LPtoHIMETRIC(&s);
//	m_impactPnt.m_x = (double) s.cx;
//	m_impactPnt.m_y = (double) s.cy;
	m_impactPnt.m_x = (double) s.cx / 10.0 - ACN_OA_OFFSET.m_x;
	m_impactPnt.m_y = (double) -s.cy / 10.0 - ACN_OA_OFFSET.m_y;

	double	distanceToA = CalcDistance(m_impactPnt, ACN_ORIGO_A);
	double	distanceToB = CalcDistance(m_impactPnt, ACN_ORIGO_B);
	double	distanceToC = CalcDistance(m_impactPnt, ACN_ORIGO_C);
	double	distanceToD = CalcDistance(m_impactPnt, ACN_ORIGO_D);
	double	distanceToE = CalcDistance(m_impactPnt, ACN_ORIGO_E);
/*
	In reality, we get an integer (dt, LSB=62.5ns) with the difference in time
	between two mics. This must be recalced to difference in distance (dd [0.1 mm]) 
	using the speed of sound (ACN_SONIC_SPEED [m/s]) according to:
	dd = dt * 62.5E-9 + ACN_SONIC_SPEED * 10000.0;
*/

/*
	Assume dd is calculated below
*/

	double	ddAE = distanceToA - distanceToE;
	double	ddBA = distanceToB - distanceToA;
	double	ddCB = distanceToC - distanceToB;
	double	ddDC = distanceToD - distanceToC;
	double	ddED = distanceToE - distanceToD;

	CalcImpactPath(ddAE, m_pathAE);
	CalcImpactPath(ddBA, m_pathBA);
	CalcImpactPath(ddCB, m_pathCB);
	CalcImpactPath(ddDC, m_pathDC);
	CalcImpactPath(ddED, m_pathED);
	TransformPath(ACN_RTF_AE_BA, ACN_ORIGO_B, m_pathBA);
	TransformPath(ACN_RTF_AE_CB, ACN_ORIGO_C, m_pathCB);
	TransformPath(ACN_RTF_AE_DC, ACN_ORIGO_D, m_pathDC);
	TransformPath(ACN_RTF_AE_ED, ACN_ORIGO_E, m_pathED);

	m_isec_AE_BA = FindIntersections(m_pathAE, m_pathBA, &m_isec_AE_BA_pnt);
	m_isec_BA_CB = FindIntersections(m_pathBA, m_pathCB, &m_isec_BA_CB_pnt);
	m_isec_CB_DC = FindIntersections(m_pathCB, m_pathDC, &m_isec_CB_DC_pnt);
	m_isec_DC_ED = FindIntersections(m_pathDC, m_pathED, &m_isec_DC_ED_pnt);

//	m_isec_AE_CB = FindIntersections(m_pathAE, m_pathCB, &m_isec_AE_CB_pnt);
//	m_isec_AE_DC = FindIntersections(m_pathAE, m_pathDC, &m_isec_AE_DC_pnt);
//	m_isec_AE_ED = FindIntersections(m_pathAE, m_pathED, &m_isec_AE_ED_pnt);
//	m_isec_BA_DC = FindIntersections(m_pathBA, m_pathDC, &m_isec_BA_DC_pnt);
//	m_isec_BA_ED = FindIntersections(m_pathBA, m_pathED, &m_isec_BA_ED_pnt);
//	m_isec_CB_ED = FindIntersections(m_pathCB, m_pathED, &m_isec_CB_ED_pnt);


	m_pathExists = true;
	Invalidate(TRUE);
	OnUpdate(NULL, 0, NULL);
}

double	CAirgunTargetView::CalcDistance(CTargetPoint fromPt, CTargetPoint toPt)
// Remember distance unit is 0.1mm.
{
	return sqrt(pow(fromPt.m_x - toPt.m_x, 2) + pow(fromPt.m_y - toPt.m_y, 2));
}

void	CAirgunTargetView::CalcImpactPath(double dd, CTargetPoint* path)
{
	double	startX = dd + (ACN_SL - dd) / 2.0;
	
	int	i;
	int dummy=0;

	for (i=0 ; i<ACN_NUMOF_PATH_PNTS ; i++) {
		path[i].m_x = (pow(startX, 2)+pow(ACN_SL,2)-pow(startX-dd, 2))/2.0/ACN_SL;
		path[i].m_y = sqrt(abs(pow(startX, 2)-pow(path[i].m_x, 2)));
		startX += ACN_PATH_PNTS_DELTA;
	}
}

void	CAirgunTargetView::TransformPath(double rtf, CTargetPoint mtf, CTargetPoint* path)
{
	int		i;
	double	absVal;
	double	angle;

	int dummy=0;

	for (i=0 ; i<ACN_NUMOF_PATH_PNTS ; i++) {
		absVal = sqrt(pow(path[i].m_x, 2) + pow(path[i].m_y, 2));
		angle = atan(path[i].m_y / path[i].m_x);
		if (angle < 0.0) angle = pi + angle;
		path[i].m_x = absVal * cos(rtf + angle);
		path[i].m_y = absVal * sin(rtf + angle);
		path[i] = path[i] + mtf;
	}
}

bool	CAirgunTargetView::FindIntersections(CTargetPoint* path1, CTargetPoint* path2, CTargetPoint* intersectionPoint)
//Terminates when first intersection is found
{
	int	x, y;

	for (x=0 ; x<ACN_NUMOF_PATH_PNTS - 1 ; x++) {
		for (y=0 ; y<ACN_NUMOF_PATH_PNTS - 1 ; y++) {
			if (CalcLineIntersection(path1[x], path1[x+1], path2[y], path2[y+1], intersectionPoint)) return true;
		}
	}
	return false;
}

bool	CAirgunTargetView::CalcLineIntersection(CTargetPoint l1p1, CTargetPoint l1p2, CTargetPoint l2p1, CTargetPoint l2p2, CTargetPoint* intPoint)
{
	double	den, t1, t2;

	/* From webpage: http://www.csc.ncsu.edu/faculty/healey/csc562/intersect.html
	We use parametric line equations to identify an intersection. Given two line segments AB and ST, A = (l1p1.m_x,l1p1.m_y), B = (l1p2.m_x,l1p2.m_y), S = (l2p1.m_x,l2p1.m_y), and T = (l2p2.m_x,l2p2.m_y), the parametric equations of the lines are:

	P1 = A + t1(B - A), 0 < t1 < 1 (1) 
	P2 = S + t2(T - S), 0 < t2 < 1 (2) 

	Solving for P1 = P2 gives two equations and two unknowns (t1 and t2):

	l1p1.m_x + t1(l1p2.m_x - l1p1.m_x) = l2p1.m_x + t2(l2p2.m_x - l2p1.m_x) (3) 
	l1p1.m_y + t1(l1p2.m_y - l1p1.m_y) = l2p1.m_y + t2(l2p2.m_y - l2p1.m_y) (4) 

	Solving for t1 and t2 yields:

	den = (l2p2.m_y - l2p1.m_y)(l1p2.m_x - l1p1.m_x) - (l2p2.m_x - l2p1.m_x)(l1p2.m_y - l1p1.m_y) (5) 
	t1 = [ (l2p2.m_x - l2p1.m_x)(l1p1.m_y - l2p1.m_y) - (l2p2.m_y - l2p1.m_y)(l1p1.m_x - l2p1.m_x) ] / den (6) 
	t2 = [ (l1p2.m_x - l1p1.m_x)(l1p1.m_y - l2p1.m_y) - (l1p2.m_y - l1p1.m_y)(l1p1.m_x - l2p1.m_x) ] / den (7) 

	If den = 0, the lines are parallel. In this case, if the numerator for t1 (or t2) is also 0, the lines are coincident. Otherwise, the lines do not intersect.

	If den != 0 and 0 < t1 < 1, the line segments intersect. If t1 < 0 or t1 > 1, the line segments do not intersect (note that if 0 < t1 < 1 then by default 0 < t2 < 1 also).
	*/

	den = ((l2p2.m_y - l2p1.m_y)*(l1p2.m_x - l1p1.m_x)) - ((l2p2.m_x - l2p1.m_x)*(l1p2.m_y - l1p1.m_y));
	t1 = ( ((l2p2.m_x - l2p1.m_x)*(l1p1.m_y - l2p1.m_y)) - ((l2p2.m_y - l2p1.m_y)*(l1p1.m_x - l2p1.m_x)) ) / den;
	t2 = ( ((l1p2.m_x - l1p1.m_x)*(l1p1.m_y - l2p1.m_y)) - ((l1p2.m_y - l1p1.m_y)*(l1p1.m_x - l2p1.m_x)) ) / den;
	
	if ((den /= 0.0) && (t1>=0.0) && (t1 <= 1.0) && (t2 >= 0.0) && (t2 <= 1.0)) {
		intPoint->m_x = l1p1.m_x + t1*(l1p2.m_x-l1p1.m_x);
		intPoint->m_y = l1p1.m_y + t1*(l1p2.m_y-l1p1.m_y);
		return true;
	} else {
		intPoint->m_x = -10e9;
		intPoint->m_y = -10e9;
		return false;
	}
}

void	CAirgunTargetView::OnDebugBreak1( void )
{
	m_debug = true;
	//OnLButtonDown(0, CPoint(271, 211));
	OnLButtonDown(0, CPoint(320, 437));
}






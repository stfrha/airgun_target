#include "StdAfx.h"
#include ".\shot.h"


CShot::CShot(void)
{
	m_docTarget = NULL;
	m_hitPointValid = false;
	m_selected = false;
	m_shotValid = true;
	m_ulMicActive = true;
	m_urMicActive = true;
	m_llMicActive = true;
	m_lrMicActive = true;
}

CShot::CShot(CTargetHW* docTarget)
{ 
	CShot::CShot();
	m_docTarget = docTarget; 
//	m_hitPointValid = false;
//	m_selected = false;
}

CShot::~CShot(void)
{
}


IMPLEMENT_SERIAL(CShot, CObject, VERSIONABLE_SCHEMA | 4);

void CShot::Serialize( CArchive& ar )
{
    CObject::Serialize( ar );

	m_hitPoint.Serialize(ar);
	m_time.Serialize64(ar);

	if( ar.IsStoring() ) {
        ar << m_name;
		ar << m_hitPointValid;
		ar << m_llt;
		ar << m_lrt;
		ar << m_ult;
		ar << m_urt;
		ar << m_foldedPaper;
		ar << m_shotInShot;
		ar << m_comment;
	} else {
		ar >> m_name;
		ar >> m_hitPointValid;
		ar >> m_llt;
		ar >> m_lrt;
		ar >> m_ult;
		ar >> m_urt;

		int version = ar.GetObjectSchema();

		if (version > 3) {
			ar >> m_foldedPaper;
			ar >> m_shotInShot;
			ar >> m_comment;
		}
	}

}

void	CShot::UpdateShotData(CString name, double llt, double lrt, double ult, double urt, CTime time)
// Fills all data and calculate all derivate data
{
	m_name = name;
	m_llt = llt;
	m_lrt = lrt;
	m_ult = ult;
	m_urt = urt;
	m_time = time;
	CalcShot();
}

void	CShot::UpdateHitPoint(CTargetPoint hitPoint)
{
	m_hitPoint = hitPoint;
	m_hitPointValid = true;
	CalcShot();
}

double	CShot::CalcShot( void )
{
	bool	topRightOk, topLeftOk, bottomRightOk, bottomLeftOk;

	m_shotValid = IsDeltaTimesWithinTarget();

	if ((m_ulMicActive) && (m_urMicActive)) {
		CalcShotPath(TOP_PATH_INDEX, m_ult - m_urt, m_docTarget->m_ulMicPos, m_docTarget->m_urMicPos, m_topPath);
	}
	if ((m_urMicActive) && (m_lrMicActive)) {
		CalcShotPath(RIGHT_PATH_INDEX, m_urt - m_lrt, m_docTarget->m_urMicPos, m_docTarget->m_lrMicPos, m_rightPath);
	}
	if ((m_lrMicActive) && (m_llMicActive)) {
		CalcShotPath(BOTTOM_PATH_INDEX, m_lrt - m_llt, m_docTarget->m_lrMicPos, m_docTarget->m_llMicPos, m_bottomPath);
	}
	if ((m_llMicActive) && (m_ulMicActive)) {
		CalcShotPath(LEFT_PATH_INDEX, m_llt - m_ult, m_docTarget->m_llMicPos, m_docTarget->m_ulMicPos, m_leftPath);
	}

	if ((m_lrMicActive) && (m_ulMicActive)) {
		CalcDiagonals(m_lrt - m_ult, DSI_POSITIVE_SLOPE, &m_posSlopeDiagLeft, &m_posSlopeDiagRight);
	}
	if ((m_urMicActive) && (m_llMicActive)) {
		CalcDiagonals(m_urt - m_llt, DSI_NEGATIVE_SLOPE, &m_negSlopeDiagLeft, &m_negSlopeDiagRight);
	}

	// Assume all mics are disabled
	topRightOk = false;
	topLeftOk = false;
	bottomRightOk = false;
	bottomLeftOk = false;

	if ((m_ulMicActive) && (m_urMicActive) && (m_lrMicActive)) {
		topRightOk = FindIntersections(m_topPath, m_rightPath, &m_intSectTopRight);
	}
	if ((m_ulMicActive) && (m_urMicActive) && (m_llMicActive)) {
		topLeftOk = FindIntersections(m_topPath, m_leftPath, &m_intSectTopLeft);
	}
	if ((m_llMicActive) && (m_urMicActive) && (m_lrMicActive)) {
		bottomRightOk = FindIntersections(m_bottomPath, m_rightPath, &m_intSectBottomRight);
	}
	if ((m_ulMicActive) && (m_llMicActive) && (m_lrMicActive)) {
		bottomLeftOk = FindIntersections(m_bottomPath, m_leftPath, &m_intSectBottomLeft);
	}

	if (!CalcAverageHitPoint(topRightOk, topLeftOk, bottomRightOk, bottomLeftOk)) {
//		MessageBox(NULL, "No path intersected on this shot", "Error", MB_OK | MB_ICONWARNING);
		m_errorDistance = 1000000000.0;
		return m_errorDistance;
	}

	if (m_hitPointValid) {
//		m_errorDistance = sqrt(pow(m_avgTargetPoint.m_x - m_hitPoint.m_x, 2.0) + pow(m_avgTargetPoint.m_y - m_hitPoint.m_y, 2.0));
		m_errorDistance = GetDistanceToShot(m_hitPoint);
	} else {
		m_errorDistance = 1000000000.0;
	}
	return m_errorDistance;
}
	
int CShot::CalcShotPath(int pathIndex, double deltaTime, CTargetPoint mlpos, CTargetPoint mrpos, CTargetPoint* path)
// Returns a two colum matrix with 100 x-y coordinate pairs of the
// calculated shot path. 
// Input data is the deltatime of the impact sound pulse and the position of
// two microphone. Coordinates refer to a 0.01 millimeter unit coordinate system 
// with origo in bulls-eye.
{
	double	dd;			// Deltadistance from microphones to shot position
	double	sl;			// Distance metween microphones
	double	alpha;		// Rotation angle of microphone parallell coordinate system

	// Calculate delta distance:
//	dd = ACN_SONIC_SPEED * deltaTime / 10; // [0.01 mm]
	dd = m_docTarget->m_sonicSpeed * deltaTime / 10.0; // [0.01 mm]

	// Calculate distance between microphones
	sl = mlpos.Distance(mrpos);
//	sl = sqrt( pow(mlpos.m_x - mrpos.m_x, 2) + pow(mlpos.m_y - mrpos.m_y, 2) );

	// Rotation angle of microphone parallell coordinate system
	alpha = atan( (mrpos.m_y-mlpos.m_y) / (mrpos.m_x-mlpos.m_x));
	if (pathIndex == BOTTOM_PATH_INDEX) alpha = alpha - pi;
	if ((pathIndex == LEFT_PATH_INDEX) || (pathIndex == RIGHT_PATH_INDEX)) alpha = -alpha;

	// -------------------------------------------------------------------------
	//% Calc path
	//% -------------------------------------------------------------------------
	// Refer to document: Hitta H.doc for description of the mathematics.

	// Number of points on path
	int	nx = ACN_NUMOF_PATH_PNTS;

	// Step size of each iteration of path
	double ystep = ACN_PATH_PNTS_DELTA; 

	double s;
	double h = sl / 2.0;	// Simply rename to match equations in doc above.
	double m = dd;	    	// Simply rename to match equations in doc above.

	// Calc all path points
	for (int index = 0 ; index < nx ; index++) {
		s = (double) index * ystep;
		path[index].m_y = -s;
		
		double t1 = 8.0*pow(h,3);
		double t2 = 2*h*pow(m,2);
		double t3 = pow(m,2);
		double t4 = -4*pow(h,2)+pow(m,2);
		double t5 = -4*pow(h,2)+pow(m,2)-4*pow(s,2);
		double t6 = t3 * t4 * t5 ;

		double s1 = sqrt(t6);

		double t7 = 8*pow(h,2);
		double t8 = 2*pow(m,2);

		double debug1 = (t1 - t2 + s1)/(t7-t8);
		double debug2 = -(-t1 + t2 + s1)/(t7-t8);

//		double debug1 = (8.0*pow(h,3)-2*h*pow(m,2)+sqrt(pow(m,2)*(-4*pow(h,2)+pow(m,2))*(-4*pow(h,2)+pow(m,2)-4*pow(s,2))))/(8*pow(h,2)-2*pow(m,2));
//		double debug2 = -(-8.0*pow(h,3)+2*h*pow(m,2)+sqrt(pow(m,2)*(-4*pow(h,2)+pow(m,2))*(-4*pow(h,2)+pow(m,2)-4*pow(s,2))))/(8*pow(h,2)-2*pow(m,2));


		if (m >= 0.0) {
			path[index].m_x = debug1;
		} else {
			path[index].m_x = debug2;
		}

/*
		if (m >= 0.0) {
			if (debug1 > 0.0) {
			} else {
				path[index].m_x = debug2;
			}
		} else {
			if (debug2 > 0.0) {
				path[index].m_x = debug2;
			} else {
				path[index].m_x = debug1;
			}

		}
*/
	}

	// -------------------------------------------------------------------------
	// Transform path to target coordinate system
	// -------------------------------------------------------------------------
	
	// Rotational transformation:
	CTargetPoint	p;
	for (index = 0 ; index < nx ; index++) {
		p = path[index];
		path[index].m_x = p.m_x*cos(alpha)+p.m_y*sin(alpha);
		path[index].m_y = -p.m_x*sin(alpha)+p.m_y*cos(alpha);
	}

	// Coordinates moving:
	for (index = 0 ; index < nx ; index++) {
		path[index] = path[index] + mlpos;
	}

	return 0;
}

bool	CShot::FindIntersections(CTargetPoint* path1, CTargetPoint* path2, CTargetPoint* intersectionPoint)
//Terminates when first intersection is found
{
	int	x, y;

	//There must be a way of makeing this more effective, Investigate!

	for (x=0 ; x<ACN_NUMOF_PATH_PNTS - 1 ; x++) {
		for (y=0 ; y<ACN_NUMOF_PATH_PNTS - 1 ; y++) {
			if (CalcLineIntersection(path1[x], path1[x+1], path2[y], path2[y+1], intersectionPoint)) {
				return true;
			}
		}
	}
	return false;
}

bool	CShot::CalcLineIntersection(CTargetPoint l1p1, CTargetPoint l1p2, CTargetPoint l2p1, CTargetPoint l2p2, CTargetPoint* intPoint)
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

	// Fast test for non-overlapping line segments:
	double	l1minX = min(l1p1.m_x, l1p2.m_x);
	double	l2minX = min(l2p1.m_x, l2p2.m_x);;
	double	l1maxX = max(l1p1.m_x, l1p2.m_x);
	double	l2maxX = max(l2p1.m_x, l2p2.m_x);;
	if ((l1minX > l2maxX) || (l1maxX < l2minX)) {
		intPoint->m_x = -10e9;
		intPoint->m_y = -10e9;
		return false;
	}


	den = ((l2p2.m_y - l2p1.m_y)*(l1p2.m_x - l1p1.m_x)) - ((l2p2.m_x - l2p1.m_x)*(l1p2.m_y - l1p1.m_y));
	t1 = ( ((l2p2.m_x - l2p1.m_x)*(l1p1.m_y - l2p1.m_y)) - ((l2p2.m_y - l2p1.m_y)*(l1p1.m_x - l2p1.m_x)) ) / den;
	t2 = ( ((l1p2.m_x - l1p1.m_x)*(l1p1.m_y - l2p1.m_y)) - ((l1p2.m_y - l1p1.m_y)*(l1p1.m_x - l2p1.m_x)) ) / den;

	double dummy;

	if ((den != 0.0) && (t1>=0.0) && (t1 <= 1.0) && (t2 >= 0.0) && (t2 <= 1.0)) {
		intPoint->m_x = l1p1.m_x + t1*(l1p2.m_x-l1p1.m_x);
		dummy = l1p1.m_y + t2*(l1p2.m_y-l1p1.m_y);
		intPoint->m_y = l1p1.m_y + t1*(l1p2.m_y-l1p1.m_y);
		return true;
	} else {
		intPoint->m_x = -10e9;
		intPoint->m_y = -10e9;
		return false;
	}
}

bool	CShot::CalcAverageHitPoint(bool topRightOk, bool topLeftOk, bool bottomRightOk, bool bottomLeftOk)
// Calc averaged target point, ie center of mass from all intersection points and places this in 
// m_avgTargetPoint. The input parameters shows if there are any intersection between the corresponding 
// paths. Function returns true if any intersection exists, false if no intersection exist.
{
	CTargetPoint	tmpA;
	CTargetPoint	tmpB;

	if ((topRightOk) && (topLeftOk)) {
		tmpA.m_x = (m_intSectTopRight.m_x - m_intSectTopLeft.m_x) / 2.0 + m_intSectTopLeft.m_x;
		tmpA.m_y = (m_intSectTopRight.m_y - m_intSectTopLeft.m_y) / 2.0 + m_intSectTopLeft.m_y;
	} else if (topRightOk) {
		tmpA = m_intSectTopRight;
	} else if (topLeftOk) {
		tmpA = m_intSectTopLeft;
	}

	if ((bottomRightOk) && (bottomLeftOk)) {
		tmpB.m_x = (m_intSectBottomRight.m_x - m_intSectBottomLeft.m_x) / 2.0 + m_intSectBottomLeft.m_x;
		tmpB.m_y = (m_intSectBottomRight.m_y - m_intSectBottomLeft.m_y) / 2.0 + m_intSectBottomLeft.m_y;
	} else if (bottomRightOk) {
		tmpB = m_intSectBottomRight;
	} else if (bottomLeftOk) {
		tmpB = m_intSectBottomLeft;
	}

	if (((topRightOk) || (topLeftOk)) && ((bottomRightOk) || (bottomLeftOk))) {
		m_avgTargetPoint.m_x = (tmpA.m_x - tmpB.m_x) / 2.0 + tmpB.m_x;
		m_avgTargetPoint.m_y = (tmpA.m_y - tmpB.m_y) / 2.0 + tmpB.m_y;
	} else if ((topRightOk) || (topLeftOk)) {
		m_avgTargetPoint = tmpA;
	} else if ((bottomRightOk) || (bottomRightOk)) {
		m_avgTargetPoint = tmpB;
	} else {
		return false;
	}
	return true;
}

void	CShot::CalcDiagonals(double deltaTime, int diagonalSlopeIndex, CTargetPoint* left, CTargetPoint* right)
{
	double dd = deltaTime * ACN_SONIC_SPEED / 10.0; // [0.01mm]

	CTargetPoint A;
	CTargetPoint B;
	CTargetPoint P;
	CTargetPoint Q;
	CTargetPoint I;

	if (diagonalSlopeIndex == DSI_POSITIVE_SLOPE) {
		A = m_docTarget->m_ulMicPos;
		B = m_docTarget->m_lrMicPos;
	} else {
		A = m_docTarget->m_llMicPos;
		B = m_docTarget->m_urMicPos;
	}

	double L = A.Distance(B);
	double d = (L - dd) / 2.0;

	double alpha = atan((B.m_y - A.m_y)/(B.m_x - A.m_x));
	double beta;
	
	if (diagonalSlopeIndex == DSI_POSITIVE_SLOPE) {
		beta = pi / 2.0 + alpha;
	} else {
		beta = alpha - pi / 2.0;
	}

	I.m_x = d*cos(alpha) + A.m_x;
	I.m_y = d*sin(alpha) + A.m_y;

	P.m_x = DIAGONAL_START_X;
	P.m_y = (P.m_x - I.m_x) * tan(beta) + I.m_y;

	Q.m_x = DIAGONAL_LEN * cos(beta) + P.m_x;
	Q.m_y = DIAGONAL_LEN * sin(beta) + P.m_y;

	*left = P;
	*right = Q;
}


void	CShot::DrawShot(CDC* dc, CViewStpDlg* viewSetup)
{
	if (!m_shotValid) return;

	if (viewSetup->m_drawPaths) {
		DrawPath(dc, m_topPath, (COLORREF) 0x0000ff);
		DrawPath(dc, m_rightPath, (COLORREF) 0xff0000);
		DrawPath(dc, m_bottomPath, (COLORREF) 0x00ff00);
		DrawPath(dc, m_leftPath, (COLORREF) 0xff00ff);
	}

	if (viewSetup->m_drawDiagonals) {
		DrawShotLine(dc, m_posSlopeDiagLeft, m_posSlopeDiagRight, (COLORREF) 0xcccccc, (COLORREF) 0xcccccc);
		DrawShotLine(dc, m_negSlopeDiagLeft, m_negSlopeDiagRight, (COLORREF) 0xcccccc, (COLORREF) 0xcccccc);
	}

	if ((m_hitPointValid) && (viewSetup->m_drawInterconnects)) {
		DrawShotLine(dc, m_hitPoint, m_avgTargetPoint, (COLORREF) 0x00ff00, (COLORREF) 0x00ff00);
	}

	if (viewSetup->m_drawIntersections) {
		DrawShotRing(dc, m_intSectTopRight, (COLORREF) 0x00ffff, (COLORREF) 0xcccccc);
		DrawShotRing(dc, m_intSectTopLeft, (COLORREF) 0x00ffff, (COLORREF) 0xcccccc);
		DrawShotRing(dc, m_intSectBottomRight, (COLORREF) 0x00ffff, (COLORREF) 0xcccccc);
		DrawShotRing(dc, m_intSectBottomLeft, (COLORREF) 0x00ffff, (COLORREF) 0xcccccc);
	}
	if (viewSetup->m_drawCalcHitPoints) {
		DrawShotRing(dc, m_avgTargetPoint, (COLORREF) 0x0000ff, (COLORREF) 0x00ff00);
	}

	if ((m_hitPointValid) && (viewSetup->m_drawActualHitPoints)) {
		DrawShotRing(dc, m_hitPoint, (COLORREF) 0xff0000, (COLORREF) 0xff0000);
	}
}

void	CShot::DrawShotLine(CDC* dc, CTargetPoint p1, CTargetPoint p2, COLORREF cNormal, COLORREF cSelected)
{
	CPen*	oldPen;
	CPen	newPen;

	if (m_selected) {
		newPen.CreatePen(PS_SOLID, 1, cSelected);
	} else {
		newPen.CreatePen(PS_SOLID, 1, cNormal);
	}
	oldPen = dc->SelectObject(&newPen);

	dc->MoveTo(p1 + ORIGO_POS + DO);
	dc->LineTo(p2 + ORIGO_POS + DO);

	dc->SelectObject(oldPen);
}

void	CShot::DrawShotRing(CDC* dc, CTargetPoint p, COLORREF cNormal, COLORREF cSelected)
{
	CPen*	oldPen;
	CPen	newPen;

	if (m_selected) {
		newPen.CreatePen(PS_SOLID, 1, cSelected);
	} else {
		newPen.CreatePen(PS_SOLID, 1, cNormal);
	}
	oldPen = dc->SelectObject(&newPen);

	CRect r = CRect(CPoint((int) p.m_x - ICR, (int) p.m_y + ICR) + ORIGO_POS + DO, 
		            CPoint((int) p.m_x + ICR, (int) p.m_y - ICR) + ORIGO_POS + DO);
	dc->Ellipse(r);

	dc->SelectObject(oldPen);
}

void	CShot::DrawPath(CDC* dc, CTargetPoint* path, COLORREF c)
{
	CPen*	oldPen;
	CPen	newPen;

	newPen.CreatePen(PS_SOLID, 1, c);
	oldPen = dc->SelectObject(&newPen);

	int i;
	dc->MoveTo(path[0] + ORIGO_POS + DO);
	for (i=1 ; i<ACN_NUMOF_PATH_PNTS ; i++) dc->LineTo(path[i] + ORIGO_POS + DO);

	dc->SelectObject(oldPen);
}

CString	CShot::GetInfoString( void )
{	
	CString a;
	if (m_shotValid) {
		a.Format("Name: %s, Calculated hit point: %2.2f;%2.2f mm, Actual hit point: %2.2f;%2.2f mm, LLT: %2.2f us, LRT: %2.2f us, ULT: %2.2f us, URT: %2.2f us", 
				m_name, m_avgTargetPoint.m_x, m_avgTargetPoint.m_y, m_hitPoint.m_x, m_hitPoint.m_y,
				m_llt, m_lrt, m_ult, m_urt);
	} else {
		a.Format("Name: %s, SHOT IS INVALID!! LLT: %2.2f us, LRT: %2.2f us, ULT: %2.2f us, URT: %2.2f us", 
				m_name, m_llt, m_lrt, m_ult, m_urt);
	}
	return a;
}

double	CShot::GetDistanceToShot( CTargetPoint point )
{
	return m_avgTargetPoint.Distance(point);
}

CString	CShot::GetShotInfo( void )
{
	CString msg;
	double	h_top[2];
	double	h_right[2];
	double	h_bottom[2];
	double	h_left[2];

	if (!m_shotValid) {
		msg.Format("Shot Name:\t%s\nTime:\t\t%s\nUpper Left dt:\t%.2f us\nUpper Right dt:\t%.2f us\nLower Left dt:\t%.2f us\nLower Right dt:\t%.2f us\nSHOT IS INVALID!!!",
			m_name,
			m_time.Format("%Y-%m-%d %H:%M:%S"),
			m_ult, m_urt, m_llt, m_lrt);
		return msg;
	}

	CalcMicHeight(m_ult - m_urt, m_hitPoint, h_top, SID_TOP);
	CalcMicHeight(m_urt - m_lrt, m_hitPoint, h_right, SID_RIGHT);
	CalcMicHeight(m_lrt - m_llt, m_hitPoint, h_bottom, SID_BOTTOM);
	CalcMicHeight(m_llt - m_ult, m_hitPoint, h_left, SID_LEFT);

	msg.Format("Shot Name:\t%s\nTime:\t\t%s\nUpper Left dt:\t%.2f us\nUpper Right dt:\t%.2f us\nLower Left dt:\t%.2f us\nLower Right dt:\t%.2f us\nCalc:ed pos:\t%.2f;%.2f\nActual hit point:\t%.2f;%.2f\nMic dist 1 top:\t%.2f\nMic dist 1 right:\t%.2f\nMic dist 1 bot:\t%.2f\nMic dist 1 left:\t%.2f\nMic dist 2 top:\t%.2f\nMic dist 2 right:\t%.2f\nMic dist 2 bot:\t%.2f\nMic dist 2 left:\t%.2f\n---------------------------------\nTop:\na len:\t%.2f\nb len:\t%.2f\nDiff ab:\t%.2f\nCompard:\t%.2f",
		m_name,
		m_time.Format("%Y-%m-%d %H:%M:%S"),
		m_ult, m_urt, m_llt, m_lrt,
		m_avgTargetPoint.m_x/100, m_avgTargetPoint.m_y/100, 
		m_hitPoint.m_x/100, m_hitPoint.m_y/100,
		h_top[0]/100, h_right[0]/100, h_bottom[0]/100,h_left[0]/100,
		h_top[1]/100, h_right[1]/100, h_bottom[1]/100,h_left[1]/100,
		m_hitPoint.Distance(CTargetPoint(h_top[0], h_top[0]))/100, m_hitPoint.Distance(CTargetPoint(-h_top[0],h_top[0]))/100,
		abs(m_hitPoint.Distance(CTargetPoint(h_top[0], h_top[0])) - m_hitPoint.Distance(CTargetPoint(-h_top[0],h_top[0])))/100,
		abs((m_ult - m_urt) * ACN_SONIC_SPEED / 10.0)/100	);

	return msg;
}

void	CShot::CalcMicHeight(double deltaTime, CTargetPoint xy, double* h, int micPair)
{
	double m = abs(deltaTime * ACN_SONIC_SPEED / 10.0); // [0.01mm]

	double x, y;

	switch (micPair) {
		case SID_TOP:
			x = xy.m_x;
			y = xy.m_y;
			break;
		case SID_RIGHT:
			x = -xy.m_y;
			y = xy.m_x;
			break;
		case SID_BOTTOM:
			x = -xy.m_x;
			y = -xy.m_y;
			break;
		case SID_LEFT:
			x = xy.m_y;
			y = -xy.m_x;
			break;
	}

	double d = sqrt(pow(x, 2) + pow(y, 2));
	double delta = atan(y/x);

	double alpha = -1.0;		// Dummy initial value
	double beta = -1.0;			// Dummy initial value

	if ((delta > -pi/4.0) && (delta < pi/4.0)) {				// Case II anf case V
		alpha = pi/4.0 - delta;
		beta = pi/2.0 + alpha;
	} else if ((delta >= pi/4.0) && (delta < 3.0*pi/4.0)) {		// Case I
		alpha = delta - pi/4.0;
		beta = pi/2.0 - alpha;
	} else if ((delta >= 3.0*pi/4.0) && (delta <= pi)) {		// Case III
		alpha = delta - pi/4.0;
		beta = alpha - pi/2.0;
	} else if ((delta > -3.0*pi/4.0) && (delta <= -pi/4.0)) {	// Case VI
		alpha = pi/4.0 - delta;
		beta = 2.0*pi - alpha - pi/2.0;
	} else if ((delta >= -pi) && (delta <= -3.0*pi/4.0)) {		// Case IV
		alpha = 2.0*pi + delta - pi/4.0;
		beta = alpha - pi/2.0;
	}

	// Debug checks:
	if (alpha < 0.0) MessageBox(NULL, "Illegal alpha value", "Error i A", MB_OK);
	if (beta < 0.0) MessageBox(NULL, "Illegal beta value", "Error i B", MB_OK);

	double P = 2 * sqrt(2.0) * cos(alpha);
	double Q = 2 * sqrt(2.0) * cos(beta);

	// According to "Hitta H.doc". Two solutions, which is the right? The first gives positive reults, 
	// the second gives negative. The first is the one to use.
	double t1 = d*pow(m,2)*(P+Q);
	double t2_1 = pow(m,2)*(2.0*pow(m,4)+pow(d,4)*pow(P+Q,2));
	double t2_2 = pow(d,2)*pow(m,2)*(P*Q-8.0);
	double t2_3 = t2_1 + t2_2;
	double t2 = 2.0 * sqrt( t2_3 ); 
	double denom = 8.0 * pow(m,2)-pow(d,2)*pow(P-Q,2);
	h[0] = (t1+t2)/denom;
	h[1] = (t1-t2)/denom;
//	h[0] = (d*pow(m,2)*(P+Q)+2*sqrt(pow(m,2)*(2*pow(m,2)+pow(d,4)*pow(P+Q,2)+pow(d,2)*pow(m,2)*(P*Q-8))))/(8*pow(m,2)-pow(d,2)*pow(P-Q,2));
//	h[1] = (d*pow(m,2)*(P+Q)+2*sqrt(pow(m,2)*(2*pow(m,2)+pow(d,4)*pow(P+Q,2)+pow(d,2)*pow(m,2)*(P*Q-8))))/(8*pow(m,2)-pow(d,2)*pow(P-Q,2));
}

bool CShot::IsDeltaTimesWithinTarget( void )
// For each mic pair, calculate the least deltadistance (dd). Then calc the distance between the mics for that pair (md).
// For a valid shot (one that inside the target) dd must not be greater then md.
{
	if ((LeastDeltaDistance(m_ult, m_urt) > MicDistance(TOP_PATH_INDEX)) ||
	(LeastDeltaDistance(m_urt, m_lrt) > MicDistance(RIGHT_PATH_INDEX)) ||
	(LeastDeltaDistance(m_lrt, m_llt) > MicDistance(BOTTOM_PATH_INDEX)) ||
	(LeastDeltaDistance(m_llt, m_ult) > MicDistance(LEFT_PATH_INDEX))) {
		return false;
	}
	return true;
}

double CShot::LeastDeltaDistance(double time1, double time2)
// Calculate the least delta distance (absolut value thereof) that corresponds to the two times.
// time1 and time2 is in microseconds. Returned distance will be in 0.01 mm
{
	return abs((time1 - time2) * ACN_SONIC_SPEED  / 10.0);		// [0.01mm]
}

double CShot::MicDistance(int pathIndex)
// Calculate the distance between the two mic pairs that corresponds the the supplied pathIndex
{
	switch (pathIndex) {
		case TOP_PATH_INDEX :
			return m_docTarget->m_ulMicPos.Distance(m_docTarget->m_urMicPos);
			break;
		case RIGHT_PATH_INDEX :
			return m_docTarget->m_urMicPos.Distance(m_docTarget->m_lrMicPos);
			break;
		case BOTTOM_PATH_INDEX :
			return m_docTarget->m_lrMicPos.Distance(m_docTarget->m_llMicPos);
			break;
		case LEFT_PATH_INDEX :
			return m_docTarget->m_llMicPos.Distance(m_docTarget->m_ulMicPos);
			break;
	}
	return 0.0;
}



/*
	This code is leftover from DrawShot, it written som text on the screen of each shot.

	CString	lls;
	CString	lrs;
	CString	uls;
	CString	urs;
	lls.Format("%2.2f", m_llt);
	lrs.Format("%2.2f", m_lrt);
	urs.Format("%2.2f", m_urt);
	uls.Format("%2.2f", m_ult);

	CString msg;
	msg.Format("Lower left: %s", lls);
	dc->TextOut(17000, -7000, msg);
	msg.Format("Lower right: %s", lrs);
	dc->TextOut(17000, -7500, msg);
	msg.Format("Upper Left: %s", uls);
	dc->TextOut(17000, -8000, msg);
	msg.Format("Upper Right: %s", urs);
	dc->TextOut(17000, -8500, msg);

	msg.Format("Top-Right Intersection point: %2.2f;%2.2f", m_intSectTopRight.m_x, m_intSectTopRight.m_y);
	dc->TextOut(17000, -9000, msg);
	msg.Format("Top-Left Intersection point: %2.2f;%2.2f", m_intSectTopLeft.m_x, m_intSectTopLeft.m_y);
	dc->TextOut(17000, -9500, msg);
	msg.Format("Bottom-Right Intersection point: %2.2f;%2.2f", m_intSectBottomRight.m_x, m_intSectBottomRight.m_y);
	dc->TextOut(17000, -10000, msg);
	msg.Format("Bottom-Left Intersection point: %2.2f;%2.2f", m_intSectBottomLeft.m_x, m_intSectBottomLeft.m_y);
	dc->TextOut(17000, -10500, msg);

	msg.Format("Averaged Target point: %2.2f;%2.2f", m_avgTargetPoint.m_x, m_avgTargetPoint.m_y);
	dc->TextOut(17000, -11000, msg);
*/


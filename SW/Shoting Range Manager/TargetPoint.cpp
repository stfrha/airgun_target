#include "StdAfx.h"
#include "targetpoint.h"

CTargetPoint::CTargetPoint(void)
{
	m_x = 0.0;
	m_y = 0.0;
}

CTargetPoint::CTargetPoint(CTargetPoint& copy)
{
	m_x = copy.m_x;
	m_y = copy.m_y;
}

CTargetPoint::CTargetPoint(double x, double y)
{
	m_x = x;
	m_y = y;
}


CTargetPoint::~CTargetPoint(void)
{
}

IMPLEMENT_SERIAL(CTargetPoint, CObject, VERSIONABLE_SCHEMA | 2);

void CTargetPoint::Serialize( CArchive& ar )
{
    CObject::Serialize( ar );

	if( ar.IsStoring() ) {
        ar << m_x;
        ar << m_y;
	} else {
        ar >> m_x;
        ar >> m_y;
	}
}

CTargetPoint CTargetPoint::operator+(CTargetPoint &other)
{
	return CTargetPoint(m_x + other.m_x, m_y + other.m_y);
}

CTargetPoint CTargetPoint::operator-(CTargetPoint &other)
{
	return CTargetPoint(m_x - other.m_x, m_y - other.m_y);
}

CTargetPoint CTargetPoint::operator*(CTargetPoint &other)
{
	return CTargetPoint(m_x * other.m_x, m_y * other.m_y);
}

CTargetPoint& CTargetPoint::operator=(const CTargetPoint& other)
{
	if (this == &other) return *this;
	m_x = other.m_x;
	m_y = other.m_y;
	return *this;
}

CTargetPoint::operator CPoint()
{
	CPoint n;
	n.x = (int) m_x;
	n.y = (int) m_y;
	return n;
}

double	CTargetPoint::Distance(CTargetPoint other)
{
	double d = sqrt(pow(other.m_y-m_y, 2.0) + pow(other.m_x - m_x, 2.0));
	return d;
}

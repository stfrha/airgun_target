#include "StdAfx.h"
#include ".\targetpoint.h"

CTargetPoint::CTargetPoint(void)
{
	m_x = 0.0;
	m_y = 0.0;
}

CTargetPoint::CTargetPoint(double x, double y)
{
	m_x = x;
	m_y = y;
}


CTargetPoint::~CTargetPoint(void)
{
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

CTargetPoint::operator CPoint()
{
	CPoint n;
	n.x = (int) m_x;
	n.y = (int) m_y;
	return n;
}
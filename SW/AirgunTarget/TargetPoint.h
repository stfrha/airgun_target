#pragma once
#include "afx.h"

class CTargetPoint /*:
	public CObject*/
{
public:
	CTargetPoint(void);
	CTargetPoint(double x, double y);
	virtual ~CTargetPoint(void);

	double	m_x;
	double	m_y;

	CTargetPoint operator+(CTargetPoint &other);
	CTargetPoint operator-(CTargetPoint &other);
	CTargetPoint operator*(CTargetPoint &other);
	operator CPoint();
};

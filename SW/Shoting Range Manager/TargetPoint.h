#pragma once
#include "afx.h"
#include "Constants.h"

class CTargetPoint :
	public CObject
{
public:
	CTargetPoint(void);
	CTargetPoint(CTargetPoint& copy);
	CTargetPoint(double x, double y);
	virtual ~CTargetPoint(void);
	void Serialize( CArchive& archive );
	DECLARE_SERIAL(CTargetPoint)

	double	m_x;							// [0.01 mm]
	double	m_y;							// [0.01 mm]

	CTargetPoint operator+(CTargetPoint &other);
	CTargetPoint operator-(CTargetPoint &other);
	CTargetPoint operator*(CTargetPoint &other);
	CTargetPoint& operator=(const CTargetPoint& other);
	operator CPoint();
	double		Distance(CTargetPoint other);

};

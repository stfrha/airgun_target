#pragma once
#include "afx.h"
#include "Shot.h"
#include "Player.h"

class CPlayerSeries :
	public CObject
{
public:
	CPlayerSeries(void);
	~CPlayerSeries(void);

	void				Serialize(CArchive &ar);
	DECLARE_SERIAL(CPlayerSeries)

protected:
	CPlayer*			m_player;
	CTypedPtrList<CObList, CShot*>	m_shots;
};

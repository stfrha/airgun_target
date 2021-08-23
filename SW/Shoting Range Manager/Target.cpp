#include "StdAfx.h"
#include ".\target.h"
#include "Constants.h"

CTargetHW::CTargetHW(void)
{
	ReinitializeTarget();
}

CTargetHW::CTargetHW(CTargetHW& copy)
{
	m_llMicPos = copy.m_llMicPos;
	m_lrMicPos = copy.m_lrMicPos;
	m_ulMicPos = copy.m_ulMicPos;
	m_urMicPos = copy.m_urMicPos;
	m_pathName = copy.m_pathName;
	m_sampleRate = copy.m_sampleRate;
	m_sonicSpeed = copy.m_sonicSpeed;
}

CTargetHW::~CTargetHW(void)
{
}

CTargetHW& CTargetHW::operator=(const CTargetHW& other)
{
	if (this == &other) return *this;
	m_llMicPos = other.m_llMicPos;
	m_lrMicPos = other.m_lrMicPos;
	m_ulMicPos = other.m_ulMicPos;
	m_urMicPos = other.m_urMicPos;
	m_pathName = other.m_pathName;
	m_sampleRate = other.m_sampleRate;
	m_sonicSpeed = other.m_sonicSpeed;
	return *this;
}


void CTargetHW::ReinitializeTarget( void )
{
	m_llMicPos = UNCAL_LL_MICPOS;
	m_lrMicPos = UNCAL_LR_MICPOS;
	m_ulMicPos = UNCAL_UL_MICPOS;
	m_urMicPos = UNCAL_UR_MICPOS;
	m_pathName = "StdTarget.tdf";
	m_sampleRate = DEF_SAMPLERATE;
	m_sonicSpeed = (int) ACN_SONIC_SPEED;
}

IMPLEMENT_SERIAL(CTargetHW, CObject, VERSIONABLE_SCHEMA | 3);

void CTargetHW::Serialize( CArchive& ar )
{
    CObject::Serialize( ar );

	m_llMicPos.Serialize(ar);
	m_lrMicPos.Serialize(ar);
	m_ulMicPos.Serialize(ar);
	m_urMicPos.Serialize(ar);

	if ((ar.GetObjectSchema() > 1) && (ar.IsLoading())) {
		ar >> m_sampleRate;
	} else if (ar.IsStoring()) {
		ar << m_sampleRate;
	}
}

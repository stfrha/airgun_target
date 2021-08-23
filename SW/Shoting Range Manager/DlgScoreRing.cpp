// DlgScoreRing.cpp : implementation file
//

#include "stdafx.h"
#include "Shoting Range Manager.h"
#include "DlgScoreRing.h"


// CDlgScoreRing dialog

IMPLEMENT_DYNAMIC(CDlgScoreRing, CDialog)
CDlgScoreRing::CDlgScoreRing(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgScoreRing::IDD, pParent)
	, m_diameter(0)
	, m_score(0)
	, m_penalty(0)
	, m_color((COLORREF) 0x00000000)
{
}

CDlgScoreRing::~CDlgScoreRing()
{
}

void CDlgScoreRing::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_COLOR_BUT, m_colorPicker);

	DDX_Text(pDX, IDC_DIAMETER, m_diameter);
	DDX_Text(pDX, IDC_SCORE, m_score);
	DDX_Text(pDX, IDC_PENALTY, m_penalty);
	DDX_ColorButton(pDX, IDC_COLOR_BUT, m_color);
}


BEGIN_MESSAGE_MAP(CDlgScoreRing, CDialog)
END_MESSAGE_MAP()


// CDlgScoreRing message handlers

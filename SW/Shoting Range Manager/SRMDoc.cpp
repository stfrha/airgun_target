// SRMDoc.cpp : implementation of the CSRMDoc class
//

#include "stdafx.h"
#include "Shoting Range Manager.h"

#include "SRMDoc.h"
#include ".\srmdoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CSRMDoc

IMPLEMENT_DYNCREATE(CSRMDoc, CDocument)

BEGIN_MESSAGE_MAP(CSRMDoc, CDocument)
	ON_COMMAND(ID_DEBUG_SCORERINGDIALOG, OnDebugScoreringdialog)
END_MESSAGE_MAP()


// CSRMDoc construction/destruction

CSRMDoc::CSRMDoc()
{
	// TODO: add one-time construction code here
	m_activeTournament = NULL;	// Default to no active tournament

}

CSRMDoc::~CSRMDoc()
{
}

BOOL CSRMDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CSRMDoc serialization

void CSRMDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		// TODO: add storing code here
	}
	else
	{
		// TODO: add loading code here
	}
}


// CSRMDoc diagnostics

#ifdef _DEBUG
void CSRMDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CSRMDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CSRMDoc commands

void CSRMDoc::OnDebugScoreringdialog()
{
	m_scoreRingDlg.DoModal()
}

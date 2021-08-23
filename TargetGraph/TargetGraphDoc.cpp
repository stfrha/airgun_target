// TargetGraphDoc.cpp : implementation of the CTargetGraphDoc class
//

#include "stdafx.h"
#include "TargetGraph.h"

#include "TargetGraphDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CTargetGraphDoc

IMPLEMENT_DYNCREATE(CTargetGraphDoc, CDocument)

BEGIN_MESSAGE_MAP(CTargetGraphDoc, CDocument)
END_MESSAGE_MAP()


// CTargetGraphDoc construction/destruction

CTargetGraphDoc::CTargetGraphDoc()
{
	// TODO: add one-time construction code here

}

CTargetGraphDoc::~CTargetGraphDoc()
{
}

BOOL CTargetGraphDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CTargetGraphDoc serialization

void CTargetGraphDoc::Serialize(CArchive& ar)
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


// CTargetGraphDoc diagnostics

#ifdef _DEBUG
void CTargetGraphDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CTargetGraphDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CTargetGraphDoc commands

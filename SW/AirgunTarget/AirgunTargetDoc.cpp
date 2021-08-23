// AirgunTargetDoc.cpp : implementation of the CAirgunTargetDoc class
//

#include "stdafx.h"
#include "AirgunTarget.h"

#include "AirgunTargetDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAirgunTargetDoc

IMPLEMENT_DYNCREATE(CAirgunTargetDoc, CDocument)

BEGIN_MESSAGE_MAP(CAirgunTargetDoc, CDocument)
END_MESSAGE_MAP()


// CAirgunTargetDoc construction/destruction

CAirgunTargetDoc::CAirgunTargetDoc()
{
	// TODO: add one-time construction code here

}

CAirgunTargetDoc::~CAirgunTargetDoc()
{
}

BOOL CAirgunTargetDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CAirgunTargetDoc serialization

void CAirgunTargetDoc::Serialize(CArchive& ar)
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


// CAirgunTargetDoc diagnostics

#ifdef _DEBUG
void CAirgunTargetDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CAirgunTargetDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CAirgunTargetDoc commands

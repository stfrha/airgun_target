// AirgunTargetDoc.h : interface of the CAirgunTargetDoc class
//


#pragma once

class CAirgunTargetDoc : public CDocument
{
protected: // create from serialization only
	CAirgunTargetDoc();
	DECLARE_DYNCREATE(CAirgunTargetDoc)

// Attributes
public:

// Operations
public:

// Overrides
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);

// Implementation
public:
	virtual ~CAirgunTargetDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};



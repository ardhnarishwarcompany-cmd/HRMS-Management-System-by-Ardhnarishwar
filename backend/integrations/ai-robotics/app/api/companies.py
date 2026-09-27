"""
Ardhnarishwar SaaS - Multi-Tenant Company (Client Organization) Management API
Full database CRUD for the Super Admin "Tenant Management" console.
Replaces the legacy client-side localStorage prototype store.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
import re
from datetime import datetime

from ..core.database import get_db
from ..core.security import (
    get_current_user,
    require_super_admin,
    AuthenticatedIdentity,
)
from ..core.rate_limiter import enforce_api_rate_limit
from ..models import Company

router = APIRouter(prefix="/api/v1/companies", tags=["Companies (Tenant Management)"])


class CompanyCreateRequest(BaseModel):
    name: str
    slug: Optional[str] = None
    domain: str
    plan: str = "GROWTH"  # STARTER | GROWTH | ENTERPRISE_ROBOTICS
    status: Optional[str] = "ACTIVE"
    maxJobs: Optional[int] = 20
    maxCandidatesPerMonth: Optional[int] = 500
    contactEmail: str
    contactPerson: str
    industry: str
    aiCustomRulesEnabled: Optional[bool] = False
    recordingStorageQuotaMb: Optional[int] = 10000


class CompanyUpdateRequest(BaseModel):
    name: Optional[str] = None
    domain: Optional[str] = None
    plan: Optional[str] = None
    status: Optional[str] = None
    maxJobs: Optional[int] = None
    maxCandidatesPerMonth: Optional[int] = None
    contactEmail: Optional[str] = None
    contactPerson: Optional[str] = None
    industry: Optional[str] = None
    aiCustomRulesEnabled: Optional[bool] = None
    recordingStorageQuotaMb: Optional[int] = None


def _serialize(c: Company) -> dict:
    """Maps DB snake_case columns to the camelCase shape the frontend Company type expects."""
    return {
        "id": c.id,
        "name": c.name,
        "slug": c.slug,
        "domain": c.domain,
        "plan": c.plan_tier,
        "status": c.status,
        "maxJobs": c.max_jobs,
        "maxCandidatesPerMonth": c.max_candidates_per_month,
        "maxEmployees": c.max_employees,
        "contactEmail": c.contact_email,
        "contactPerson": c.contact_person,
        "industry": c.industry,
        "aiCustomRulesEnabled": c.ai_custom_rules_enabled,
        "recordingStorageUsedMb": c.recording_storage_used_mb,
        "recordingStorageQuotaMb": c.recording_storage_quota_mb,
        "createdAt": c.created_at.isoformat() if c.created_at else None,
    }


def _slugify(name: str) -> str:
    return re.sub(r'[^a-z0-9]+', '-', name.strip().lower()).strip('-')


@router.get("", dependencies=[Depends(enforce_api_rate_limit)])
async def list_companies_endpoint(
    current_user: AuthenticatedIdentity = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Lists companies. SUPER_ADMIN sees every tenant (Tenant Management console);
    every other authenticated role only sees its own company record.
    """
    query = db.query(Company)
    if current_user.role != "SUPER_ADMIN":
        if not current_user.company_id:
            return {"total": 0, "companies": []}
        query = query.filter(Company.id == current_user.company_id)

    companies = query.order_by(Company.created_at.desc()).all()
    return {"total": len(companies), "companies": [_serialize(c) for c in companies]}


@router.post("", dependencies=[Depends(enforce_api_rate_limit)])
async def create_company_endpoint(
    req: CompanyCreateRequest,
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
    db: Session = Depends(get_db)
):
    """
    Onboards a new client organization. Super Admin only.
    """
    slug = _slugify(req.slug or req.name)
    if db.query(Company).filter(Company.slug == slug).first():
        raise HTTPException(status_code=409, detail=f"A company with slug '{slug}' already exists.")
    if db.query(Company).filter(Company.domain == req.domain).first():
        raise HTTPException(status_code=409, detail=f"A company with domain '{req.domain}' already exists.")

    new_company = Company(
        id=f"comp_{uuid.uuid4().hex[:10]}",
        name=req.name.strip(),
        slug=slug,
        domain=req.domain.strip(),
        plan_tier=req.plan,
        status=req.status or "ACTIVE",
        max_jobs=req.maxJobs or 20,
        max_candidates_per_month=req.maxCandidatesPerMonth or 500,
        contact_email=req.contactEmail.strip(),
        contact_person=req.contactPerson.strip(),
        industry=req.industry.strip(),
        ai_custom_rules_enabled=bool(req.aiCustomRulesEnabled),
        recording_storage_used_mb=0,
        recording_storage_quota_mb=req.recordingStorageQuotaMb or 10000,
        created_at=datetime.utcnow(),
    )
    db.add(new_company)
    db.commit()
    db.refresh(new_company)
    return {"success": True, "company": _serialize(new_company)}


@router.put("/{company_id}")
async def update_company_endpoint(
    company_id: str,
    req: CompanyUpdateRequest,
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
    db: Session = Depends(get_db)
):
    company = db.query(Company).filter(Company.id == company_id).first()
    if not company:
        raise HTTPException(status_code=404, detail="Company not found.")

    if req.name is not None:
        company.name = req.name.strip()
    if req.domain is not None:
        company.domain = req.domain.strip()
    if req.plan is not None:
        company.plan_tier = req.plan
    if req.status is not None:
        company.status = req.status
    if req.maxJobs is not None:
        company.max_jobs = req.maxJobs
    if req.maxCandidatesPerMonth is not None:
        company.max_candidates_per_month = req.maxCandidatesPerMonth
    if req.contactEmail is not None:
        company.contact_email = req.contactEmail.strip()
    if req.contactPerson is not None:
        company.contact_person = req.contactPerson.strip()
    if req.industry is not None:
        company.industry = req.industry.strip()
    if req.aiCustomRulesEnabled is not None:
        company.ai_custom_rules_enabled = req.aiCustomRulesEnabled
    if req.recordingStorageQuotaMb is not None:
        company.recording_storage_quota_mb = req.recordingStorageQuotaMb

    db.commit()
    db.refresh(company)
    return {"success": True, "company": _serialize(company)}


@router.patch("/{company_id}/status")
async def toggle_company_status_endpoint(
    company_id: str,
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
    db: Session = Depends(get_db)
):
    """
    Flips a company between ACTIVE and INACTIVE (Suspend / Activate button).
    """
    company = db.query(Company).filter(Company.id == company_id).first()
    if not company:
        raise HTTPException(status_code=404, detail="Company not found.")

    company.status = "INACTIVE" if company.status == "ACTIVE" else "ACTIVE"
    db.commit()
    db.refresh(company)
    return {"success": True, "company": _serialize(company)}


@router.delete("/{company_id}")
async def delete_company_endpoint(
    company_id: str,
    current_user: AuthenticatedIdentity = Depends(require_super_admin),
    db: Session = Depends(get_db)
):
    company = db.query(Company).filter(Company.id == company_id).first()
    if not company:
        raise HTTPException(status_code=404, detail="Company not found.")

    db.delete(company)
    db.commit()
    return {"success": True, "message": f"Company {company_id} deleted successfully."}

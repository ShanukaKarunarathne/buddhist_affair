# app/db/seed.py
"""
Seed script to populate initial data including roles
"""
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import Role
from datetime import datetime


def seed_roles(db: Session):
    """Seed initial roles"""
    roles_data = [
        {
            "ro_role_id": "ADMIN",
            "ro_role_name": "Administrator",
            "ro_description": "Full system access with all permissions",
            "ro_is_system_role": True,
        },
        {
            "ro_role_id": "MANAGER",
            "ro_role_name": "Manager",
            "ro_description": "Can manage bhikku records and view reports",
            "ro_is_system_role": True,
        },
        {
            "ro_role_id": "CLERK",
            "ro_role_name": "Clerk",
            "ro_description": "Can create and update bhikku records",
            "ro_is_system_role": True,
        },
        {
            "ro_role_id": "VIEWER",
            "ro_role_name": "Viewer",
            "ro_description": "Read-only access to bhikku records",
            "ro_is_system_role": True,
        },
        {
            "ro_role_id": "GUEST",
            "ro_role_name": "Guest",
            "ro_description": "Limited access for external users",
            "ro_is_system_role": True,
        },
    ]

    for role_data in roles_data:
        existing_role = db.query(Role).filter(
            Role.ro_role_id == role_data["ro_role_id"]
        ).first()
        
        if not existing_role:
            role = Role(**role_data)
            db.add(role)
            print(f"✓ Created role: {role_data['ro_role_name']}")
        else:
            print(f"→ Role already exists: {role_data['ro_role_name']}")
    
    db.commit()


def main():
    """Main seeding function"""
    print("Starting database seeding...")
    db = SessionLocal()
    
    try:
        seed_roles(db)
        print("\n✓ Database seeding completed successfully!")
    except Exception as e:
        print(f"\n✗ Error during seeding: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()
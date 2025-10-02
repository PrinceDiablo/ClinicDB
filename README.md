# Design Document

By Nirupam Mandal

Video overview: <URL HERE>

## Scope

The purpose of this database is to manage the core operations of a **clinic with an integrated pharmacy and diagnostic lab system**.  
It supports patients, doctors, staff, pharmacies, labs, and products while ensuring proper audit, licensing, and inventory management.

**In scope**:
- Entities: clinics, pharmacies, labs, distributors, product manufacturers.
- People: patients, doctors, staff, buyers.
- Healthcare operations: appointments, prescriptions, lab tests, sales, purchases, inventory.
- Administrative details: user profiles, authentication, documents, staff logs, licences.

**Out of scope**:
- Detailed insurance and billing integrations.
- Real-time IoT devices (lab machines, biometric attendance).
- Full HR systems beyond attendance, salaries, and reviews.
- Advanced pharmacy analytics or AI-driven diagnosis.

## Functional Requirements

**Users should be able to**:
- Register and authenticate.
- Record and manage patients, doctors, staff.
- Schedule appointments and maintain doctor time slots.
- Issue prescriptions with medicines and tests.
- Record lab test orders, reports, and statuses.
- Manage products (medicines, surgicals, OTC) and compositions.
- Track pharmacy purchases, sales (Rx and OTC), inventory, and stock adjustments.
- Maintain licences, documents, and audit logs.

**Beyond scope**:
- Handling online payments.
- Multi-currency financial accounting.
- AI-based recommendations.

## Representation

### Entities

The main entities are:
- **entities**: general-purpose organizations (clinic, pharmacy, lab, distributor, company).
  - Attributes: `id`, `name`, `kind_id`, `ownership`, `status`, `address`.
- **kinds**: type classification for entities.
- **user_details**: core user profiles.
- **authenticate_users**: credentials for login.
- **staff**: linked to both user and entity, includes role, salary, status.
- **doctors**: medical practitioners with specialization and registration.
- **patients**: clinic-registered users.
- **products**: medicines and other pharmacy items.
- **tests**: lab investigations.
- **appointments**, **prescriptions**, **sales**, **purchases** as operational records.

**Types and constraints**:
- Text used for descriptive attributes, with `CHECK` for controlled values (e.g., role, status, gender).
- Integers for identifiers, fees, salaries, rates.
- Triggers enforce consistency (no overlapping doctor slots, soft deletes, stock checks).

### Relationships

![ER Diagram](images\clinic-er-diagram.png)

Key relationships:
- `entities` ↔ `kinds`: one kind classifies many entities.
- `entities` ↔ `licences`: one entity may hold multiple licences.
- `user_details` ↔ `staff`, `doctors`, `patients`: a person may act in different roles.
- `doctors` ↔ `doctor_time_slots` ↔ `appointments`: manage consultations.
- `patients` ↔ `appointments` ↔ `doctors`: capture clinic interactions.
- `prescriptions` ↔ `products`/`tests`: capture prescribed items/tests.
- `tests` ↔ `test_records`: record lab processing and reports.
- `products` ↔ `purchase_lines`/`sales`/`inventory_ledger`: manage pharmacy flow.

## Optimizations

- **Unique indexes** on critical identifiers (`licence_no`, `doctor_id+slot`, etc.) ensure integrity.
- **Views** for common queries:
  - Doctor schedules with capacity.
  - Upcoming appointments.
  - Prescription histories.
  - Current stock, low stock, expiring batches.
  - Lab test statuses.
  - Staff check-ins.
- **Triggers** enforce business rules:
  - Soft deletes with audit logs.
  - Time slot overlap prevention.
  - Inventory ledger synchronization from purchases, sales, and adjustments.

## Limitations

- Financial handling is minimal (only rates/MRPs, no profit/loss or taxes beyond `tax_rate`).
- Roles are fixed (staff roles and doctor specialties are predefined).
- Patient billing and insurance workflows are not modeled.
- Complex hospital features (in-patient admissions, nursing care, multi-branch networks) are excluded.



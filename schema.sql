PRAGMA foreign_keys = ON

---- Entities and related Tables ----

CREATE TABLE IF NOT EXISTS "entities" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "kind_id" INTEGER ,
    "ownership" TEXT NOT NULL DEFAULT 'owned' CHECK ("ownership" IN ('owned','outsourced')),
    "address" TEXT,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("kind_id") REFERENCES "kinds"("id")
);

CREATE TABLE IF NOT EXISTS "kinds" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "licences" (
    "id" INTEGER,
    "entity_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "licence_no" TEXT NOT NULL UNIQUE,
    "issue_date" TEXT,
    "expiry_date" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id")
);
 
---- User Details and related Tables ----

CREATE TABLE IF NOT EXISTS "user_details" (
    "id" INTEGER,
    "name" TEXT,
    "dob" TEXT,
    "gender" TEXT CHECK("gender" IN ('male','female','other','prefer_not_to_say')),
    "permanent_address" TEXT,
    "temp_address" TEXT,
    "primary_contact_no" TEXT NOT NULL UNIQUE,
    "secondary_contact_no" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "authenticate_users" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL UNIQUE,
    "email" TEXT NOT NULL COLLATE NOCASE UNIQUE,
    "password_hash" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id")
);

CREATE TABLE IF NOT EXISTS "gov_documents" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "card_name" TEXT NOT NULL,
    "card_number" TEXT UNIQUE NOT NULL,
    "card_photo" BLOB,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id")
);

CREATE TABLE IF NOT EXISTS "education_certificates" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "school_name" TEXT,
    "course_name" TEXT,
    "certificate_details" TEXT,
    "certificate_id" TEXT UNIQUE,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id")
);

CREATE TABLE IF NOT EXISTS "bank_details" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "bank_ac_holder_name" TEXT NOT NULL,
    "bank_ac_number" TEXT NOT NULL UNIQUE,
    "bank_name" TEXT NOT NULL,
    "bank_IFSC_code" TEXT NOT NULL,
    "bank_branch" TEXT NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id")
);

---- Staff Details  ----

CREATE TABLE IF NOT EXISTS "staff" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "role" TEXT NOT NULL CHECK ("role" IN ('manager','pharmacist','receptionist','technician')),
    "join_date" TEXT,
    "salary" INTEGER NOT NULL,
    "rating" INTEGER CHECK ("rating" BETWEEN 0 AND 5),
    "review" TEXT,
    "cause" TEXT NOT NULL DEFAULT 'recruitment' CHECK("cause" IN('promotion', 'demotion', 'salary_hike', 'termination', 'resignation','recruitment')),
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER,
    UNIQUE("user_id","entity_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

-- Staff Attendance Records
CREATE TABLE IF NOT EXISTS "staff_attendance_records" (
    "id" INTEGER,
    "staff_id" INTEGER NOT NULL,
    "in_date_time_stamp" TEXT,
    "out_date_time_stamp" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("staff_id") REFERENCES "staff"("id")
);

---- Staff logs and trigger conditions ----

CREATE TABLE IF NOT EXISTS "staff_and_entity_logs" (
    "id" INTEGER,
    "action" TEXT NOT NULL CHECK ("action" IN ('ADD','UPDATE','DELETE')),
    "staff_id" INTEGER,
    "entity_id" INTEGER,
    "role" TEXT NOT NULL,
    "salary" INTEGER,
    "rating" INTEGER,
    "cause" TEXT NOT NULL CHECK("cause" IN('promotion', 'demotion', 'salary_hike', 'termination', 'resignation','recruitment')),
    "review" TEXT,
    "status" TEXT NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id"),
    FOREIGN KEY("staff_id") REFERENCES "staff"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

CREATE TRIGGER IF NOT EXISTS "trg_new_staff"
AFTER INSERT ON "staff"
FOR EACH ROW
BEGIN
  INSERT INTO "staff_and_entity_logs" ("action","staff_id", "entity_id", "role", "salary", "rating", "cause", "review", "status", "created_by")
  VALUES ('ADD', NEW."id", NEW."entity_id", NEW."role", NEW."salary", NEW."rating", COALESCE(NEW."cause", 'recruitment'), NEW."review", NEW."status", NEW."created_by");
END;

CREATE TRIGGER IF NOT EXISTS "trg_update_staff"
BEFORE UPDATE OF "role", "salary", "rating", "review" ON "staff"
FOR EACH ROW
WHEN OLD."status" = 'active' AND NEW."status" = 'active' AND (OLD."role" IS NOT NEW."role" OR OLD."salary" IS NOT NEW."salary" OR OLD."rating" IS NOT NEW."rating" OR OLD."review" IS NOT NEW."review")
BEGIN
  SELECT CASE WHEN NEW."cause" IS NULL THEN RAISE(ABORT,'cause required for staff update') END;
  INSERT INTO "staff_and_entity_logs" ("action", "staff_id", "entity_id", "role", "salary", "rating", "cause", "review", "status", "created_by")
  VALUES ('UPDATE', NEW."id", NEW."entity_id", NEW."role", NEW."salary", NEW."rating", NEW."cause", NEW."review", NEW."status", NEW."created_by");
END;

-- Block hard deletes
CREATE TRIGGER IF NOT EXISTS "trg_block_delete_staff"
BEFORE DELETE ON "staff"
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Use status=inactive for soft delete');
END;

-- Log soft delete
CREATE TRIGGER IF NOT EXISTS "trg_soft_delete_staff"
BEFORE UPDATE OF "status" ON "staff"
FOR EACH ROW
WHEN OLD."status" = 'active' AND NEW."status" = 'inactive'
BEGIN
  SELECT CASE WHEN NEW."cause" IS NULL THEN RAISE(ABORT,'cause required for soft delete') END;
  INSERT INTO "staff_and_entity_logs" ("action","staff_id","entity_id","role","salary","rating","cause","review","status","created_by")
  VALUES ('DELETE', NEW."id", NEW."entity_id", NEW."role", NEW."salary", NEW."rating", NEW."cause", NEW."review", NEW."status", NEW."created_by");
END;

---- Doctor's Details ----

CREATE TABLE IF NOT EXISTS "doctors" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "reg_no" TEXT NOT NULL UNIQUE,
    "specialty" TEXT,
    "consultation_fees" INTEGER,
    "entity_commission" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

CREATE TABLE IF NOT EXISTS "doctor_time_slots" (
    "id" INTEGER,
    "doctor_id" INTEGER NOT NULL,
    "chamber_no" TEXT NOT NULL,
  "day" TEXT NOT NULL CHECK ("day" IN ('mon','tue','wed','thu','fri','sat','sun')),
    "time_slot_start" INTEGER NOT NULL,
    "time_slot_end" INTEGER NOT NULL,
    "appointments_per_slot" INTEGER NOT NULL CHECK("appointments_per_slot" > 0),
    CHECK ("time_slot_start" < "time_slot_end"),
  UNIQUE("doctor_id","chamber_no","day","time_slot_start","time_slot_end"),
    PRIMARY KEY("id"),
    FOREIGN KEY("doctor_id") REFERENCES "doctors"("id")
);
-- time_slot_start/time_slot_end are INTEGER minutes from midnight (e.g., 09:30 => 570)

-- Trigger: Prevent overlapping slots for the same doctor, chamber and day
CREATE TRIGGER IF NOT EXISTS "trg_time_slot_no_overlap_ins"
BEFORE INSERT ON "doctor_time_slots"
FOR EACH ROW
BEGIN
  SELECT CASE
    WHEN EXISTS (
      SELECT 1 FROM "doctor_time_slots"
       WHERE "doctor_id" = NEW."doctor_id"
         AND "chamber_no" = NEW."chamber_no"
         AND "day" = NEW."day"
         AND NOT (NEW."time_slot_end" <= "time_slot_start" OR NEW."time_slot_start" >= "time_slot_end")
    )
    THEN RAISE(ABORT,'Time-slot overlaps existing')
  END;
END;

CREATE TRIGGER IF NOT EXISTS "trg_time_slot_no_overlap_upd"
BEFORE UPDATE OF "doctor_id","chamber_no","day","time_slot_start","time_slot_end" ON "doctor_time_slots"
FOR EACH ROW
BEGIN
  SELECT CASE
    WHEN EXISTS (
      SELECT 1 FROM "doctor_time_slots"
       WHERE "doctor_id" = NEW."doctor_id"
         AND "chamber_no" = NEW."chamber_no"
         AND "day" = NEW."day"
         AND "id" <> OLD."id"
         AND NOT (NEW."time_slot_end" <= "time_slot_start" OR NEW."time_slot_start" >= "time_slot_end")
    )
    THEN RAISE(ABORT,'Time-slot overlaps existing')
  END;
END;

---- Patient Details ----

CREATE TABLE IF NOT EXISTS "patients" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "clinic_id" INTEGER NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("clinic_id") REFERENCES "entities"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

---- Appointment Details ----

CREATE TABLE IF NOT EXISTS "appointments" (
-- Note: appointment_date format: YYYY-MM-DD
    "id" INTEGER,
    "patient_id" INTEGER NOT NULL,
    "appointment_date" TEXT NOT NULL,
    "doctor_time_slot_id" INTEGER NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    UNIQUE("patient_id", "doctor_time_slot_id", "appointment_date"),
    PRIMARY KEY("id"),
    FOREIGN KEY("patient_id") REFERENCES "patients"("id"),
    FOREIGN KEY("doctor_time_slot_id") REFERENCES "doctor_time_slots"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

---- Prescription Details and related Tables ----

CREATE TABLE IF NOT EXISTS "prescriptions" (
    "id" INTEGER,
    "patient_id" INTEGER NOT NULL,
    "doctor_id" INTEGER NOT NULL,
  "prescription" BLOB,
    "note" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("patient_id") REFERENCES "patients"("id"),
    FOREIGN KEY("doctor_id") REFERENCES "doctors"("id")
);

CREATE TABLE IF NOT EXISTS "prescribed_products" (
    "id" INTEGER,
    "prescription_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("prescription_id") REFERENCES "prescriptions"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id")
);

CREATE TABLE IF NOT EXISTS "prescribed_tests" (
    "id" INTEGER,
    "prescription_id" INTEGER NOT NULL,
    "test_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("prescription_id") REFERENCES "prescriptions"("id"),
    FOREIGN KEY("test_id") REFERENCES "tests"("id")
);

---- Test Details ----

CREATE TABLE IF NOT EXISTS "tests" (
    "id" INTEGER,
    "name" TEXT,
    "description" TEXT,
    "picture" BLOB,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

-- Test Records
CREATE TABLE IF NOT EXISTS "test_records" (
    "id" INTEGER,
    "prescribed_tests_id" INTEGER NOT NULL,
    "lab_id" INTEGER NOT NULL,
    "collection_date_time" TEXT NOT NULL,
    "test_start_date_time" TEXT NOT NULL,
    "test_end_date_time" TEXT,
    "report" BLOB,
    "report_by_doctor_id" INTEGER NOT NULL,
    "mrp" DECIMAL,
    "rate" DECIMAL,
    "recorded_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "recorded_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("prescribed_tests_id") REFERENCES "prescribed_tests"("id"),
    FOREIGN KEY("lab_id") REFERENCES "entities"("id"),
    FOREIGN KEY("report_by_doctor_id") REFERENCES "doctors"("id"),
    FOREIGN KEY("recorded_by") REFERENCES "staff"("id")
);

---- Product Details and related Tables ----

CREATE TABLE IF NOT EXISTS "products" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "tax_rate" INTEGER NOT NULL,
    "schedule" TEXT NOT NULL CHECK("schedule" IN ('scheduled','not-scheduled','scheduled-H','scheduled-H1')),
    "category" TEXT,
    "company_id" INTEGER,
    "description" TEXT,
    "picture" BLOB,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("company_id") REFERENCES "entities"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

CREATE TABLE IF NOT EXISTS "compositions" (
    "id" INTEGER,
    "product_id" INTEGER NOT NULL,
    "composition_name" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id")
);

---- Purchase Details ----

CREATE TABLE IF NOT EXISTS "purchase_headers" (
    "id" INTEGER,
    "pharmacy_id" INTEGER NOT NULL,
    "distributor_id" INTEGER,
    "invoice_no" TEXT NOT NULL,
    "invoice_date" TEXT NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    UNIQUE("pharmacy_id","distributor_id","invoice_no"), 
    PRIMARY KEY("id"),
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("distributor_id") REFERENCES "entities"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

CREATE TABLE IF NOT EXISTS "purchase_lines" (
    "id" INTEGER,
    "header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 1,
    "product_id" INTEGER NOT NULL,
    "batch_no" TEXT NOT NULL,
    "exp_date" TEXT,
    "rate" DECIMAL NOT NULL,
    "mrp" DECIMAL NOT NULL,
    "quantity" INTEGER NOT NULL CHECK("quantity" > 0),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    UNIQUE("header_id","line_no"),
    UNIQUE("header_id","product_id","batch_no"),
    PRIMARY KEY("id"),
    FOREIGN KEY("header_id")  REFERENCES "purchase_headers"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

---- Sales Details ----

CREATE TABLE IF NOT EXISTS "sales" (
    "id" INTEGER,
    "pharmacy_id" INTEGER NOT NULL,
    "prescription_id" INTEGER,
    "buyer_user_id" INTEGER,
    "product_id" INTEGER NOT NULL,
    "batch_no" TEXT NOT NULL,    
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    "rate" DECIMAL NOT NULL,
    "mrp" DECIMAL NOT NULL,
    "sold_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sold_by" INTEGER NOT NULL,
  -- Exactly one of prescription_id (Rx) or buyer_user_id (OTC) must be present
    CHECK ( ("prescription_id" IS NOT NULL) <> ("buyer_user_id" IS NOT NULL) ),
    PRIMARY KEY("id"), 
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("prescription_id") REFERENCES "prescriptions"("id"),
    FOREIGN KEY("buyer_user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("sold_by") REFERENCES "staff"("id")
);

---- Inventory Details ----

CREATE TABLE IF NOT EXISTS "inventory_ledger" (
    "id" INTEGER,
    "pharmacy_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "batch_no" TEXT NOT NULL,
    "exp_date" TEXT,
    "source_type" TEXT NOT NULL CHECK ("source_type" IN ('PURCHASE','SALE','ADJUSTMENT')),
    "source_id" INTEGER,
    "quantity_delta" INTEGER NOT NULL,
    "rate" DECIMAL NOT NULL,
    "mrp" DECIMAL NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("created_by") REFERENCES "staff"("id")
);

-- Manual Inventory Adjustments
CREATE TABLE IF NOT EXISTS "inventory_adjustments" (
    "id" INTEGER,
    "pharmacy_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "batch_no" TEXT NOT NULL,
    "exp_date" TEXT,
    "reason" TEXT,
    "quantity_delta" INTEGER NOT NULL,
    "rate" DECIMAL NOT NULL,
    "mrp" DECIMAL NOT NULL,
    "adjusted_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "adjusted_by" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("adjusted_by") REFERENCES "staff"("id")
);

-- Trigger: purchase -> ledger (+)
CREATE TRIGGER IF NOT EXISTS "trg_purchase_line_to_ledger"
AFTER INSERT ON "purchase_lines"
FOR EACH ROW
BEGIN
    INSERT INTO "inventory_ledger" ("pharmacy_id", "product_id", "batch_no", "exp_date", "source_type", "source_id", "quantity_delta", "rate", "mrp", "created_by")
    VALUES ((SELECT "pharmacy_id"
               FROM "purchase_headers"
              WHERE "id" = NEW."header_id"), 
    NEW."product_id", NEW."batch_no", NEW."exp_date", 'PURCHASE', NEW."id", NEW."quantity", NEW."rate", NEW."mrp", NEW."created_by");
END;

-- Trigger: sale -> check stock then ledger (-)
CREATE TRIGGER  IF NOT EXISTS "trg_sale_to_ledger"
AFTER INSERT ON "sales"
FOR EACH ROW
BEGIN
  -- Ensure sufficient stock before writing a negative movement
  SELECT CASE
    WHEN (
      (SELECT COALESCE(SUM("quantity_delta"), 0)
         FROM "inventory_ledger"
        WHERE "pharmacy_id" = NEW."pharmacy_id"
          AND "product_id" = NEW."product_id"
          AND "batch_no" = NEW."batch_no"
      ) < NEW."quantity"
    )
    THEN RAISE(ABORT,'Insufficient stock')
  END;

  INSERT INTO "inventory_ledger"("pharmacy_id","product_id","batch_no","exp_date","source_type","source_id","quantity_delta","rate","mrp","created_by")
  VALUES (NEW."pharmacy_id", NEW."product_id", NEW."batch_no",
      (SELECT pl."exp_date" 
         FROM "purchase_lines" AS "pl"
         JOIN "purchase_headers" AS "ph"
           ON ph."id" = pl."header_id"
        WHERE ph."pharmacy_id" = NEW."pharmacy_id"
          AND pl."product_id" = NEW."product_id"
          AND pl."batch_no" = NEW."batch_no"
        ORDER BY ph."invoice_date" DESC, pl."id" DESC 
        LIMIT 1),
      'SALE', NEW."id", -NEW."quantity", NEW."rate", NEW."mrp", NEW."sold_by"
    );
END;

CREATE TRIGGER IF NOT EXISTS "trg_adjustment_to_ledger"
AFTER INSERT ON "inventory_adjustments"
FOR EACH ROW
BEGIN
  INSERT INTO "inventory_ledger"("pharmacy_id","product_id","batch_no", "exp_date", "source_type","source_id","quantity_delta", "rate", "mrp", "created_by")
  VALUES (NEW."pharmacy_id", NEW."product_id", NEW."batch_no", NEW."exp_date", 'ADJUSTMENT', NEW."id", NEW."quantity_delta", NEW."rate", NEW."mrp", NEW."adjusted_by");
END;

---- Views ----

-- Doctor schedule (weekly slots only)
CREATE VIEW IF NOT EXISTS "view_doctor_schedule" AS
SELECT ts."id" AS "time_slot_id", d."id" AS "doctor_id", ud."name" AS "doctor_name", d."entity_id" AS "clinic_id", ts."day",
       (CAST(ts."time_slot_start" AS TEXT) || '-' || CAST(ts."time_slot_end" AS TEXT)) AS "time_slot", 
       ts."appointments_per_slot"
  FROM "doctor_time_slots" AS "ts"
  JOIN "doctors" AS "d"
    ON d."id" = ts."doctor_id"
  JOIN "user_details" AS "ud"
    ON ud."id" = d."user_id";

-- Upcoming appointments
CREATE VIEW IF NOT EXISTS "view_upcoming_appointments" AS 
SELECT ap."id" AS "appointment_id", ap."appointment_date" AS "date",
       (CAST(ts."time_slot_start" AS TEXT) || '-' || CAST(ts."time_slot_end" AS TEXT)) AS "time_slot",
       p."id" AS "patient_id",
       up."name" AS "patient_name", d."id" AS "doctor_id", ud."name" AS "doctor_name",
       d."entity_id" AS "clinic_id", e."name" AS "clinic_name", ap."created_at"
  FROM "appointments" AS "ap"
  JOIN "doctor_time_slots" AS "ts"
    ON ts."id" = ap."doctor_time_slot_id"
  JOIN "patients" AS "p"
    ON p."id" = ap."patient_id"
  JOIN "user_details" AS "up"
    ON up."id" = p."user_id"
  JOIN "doctors" AS "d"
    ON d."id" = ts."doctor_id"
  JOIN "user_details" AS "ud" 
    ON ud."id" = d."user_id"
  JOIN "entities" AS "e" 
    ON e."id" = d."entity_id"
 WHERE DATE(ap."appointment_date") >= DATE('now')
 ORDER BY ap."appointment_date", ts."time_slot_start", ts."time_slot_end";

-- Patient prescription history
CREATE VIEW IF NOT EXISTS "view_patient_prescription_history" AS
SELECT pr."id" AS "prescription_id", pr."created_at", p."id" AS "patient_id",
       up."name" AS "patient_name",d."id" AS "doctor_id", ud."name" AS "doctor_name"
  FROM "prescriptions" AS "pr"
  JOIN "patients" AS "p"
    ON p."id" = pr."patient_id"
  JOIN "user_details" AS "up"
    ON up."id" = p."user_id"
  JOIN "doctors" AS "d"
    ON d."id" = pr."doctor_id"
  JOIN "user_details" AS "ud"
    ON ud."id" = d."user_id"
 ORDER BY pr."created_at" DESC;

-- Prescription items
CREATE VIEW IF NOT EXISTS "view_prescription_items" AS
SELECT pr."id" AS "prescription_id", pdt."id" AS "prescribed_product_id",
       prod."id" AS "product_id", prod."name" AS "product_name", prod."tax_rate", prod."schedule"
  FROM "prescribed_products" AS "pdt"
  JOIN "prescriptions" AS "pr" 
    ON pr."id" = pdt."prescription_id"
  JOIN "products" AS "prod" 
    ON prod."id" = pdt."product_id"; 

-- Current stock
CREATE VIEW IF NOT EXISTS "view_current_stock" AS
SELECT "pharmacy_id", "product_id", "batch_no", SUM("quantity_delta") AS "quantity"
  FROM "inventory_ledger"
 GROUP BY "pharmacy_id", "product_id", "batch_no"
HAVING SUM("quantity_delta") <> 0;

-- Current stock by batch with attributes (exp_date, rate, mrp)
CREATE VIEW IF NOT EXISTS "view_stock_by_batch" AS
SELECT vcs."pharmacy_id", vcs."product_id", vcs."batch_no", vcs."quantity",
  (
    SELECT pl."exp_date"
      FROM "purchase_lines" AS pl
      JOIN "purchase_headers" AS ph
        ON ph."id" = pl."header_id"
     WHERE ph."pharmacy_id" = vcs."pharmacy_id"
       AND pl."product_id" = vcs."product_id"
       AND pl."batch_no" = vcs."batch_no"
     ORDER BY ph."invoice_date" DESC, pl."id" DESC
     LIMIT 1
  ) AS "exp_date",
  (
    SELECT pl."rate"
      FROM "purchase_lines" AS "pl"
      JOIN "purchase_headers" AS "ph"
        ON ph."id" = pl."header_id"
     WHERE ph."pharmacy_id" = vcs."pharmacy_id"
       AND pl."product_id" = vcs."product_id"
       AND pl."batch_no" = vcs."batch_no"
     ORDER BY ph."invoice_date" DESC, pl."id" DESC
     LIMIT 1
  ) AS "rate",
  (
    SELECT pl."mrp"
      FROM "purchase_lines" AS "pl"
      JOIN "purchase_headers" AS "ph"
        ON ph."id" = pl."header_id"
     WHERE ph."pharmacy_id" = vcs."pharmacy_id"
       AND pl."product_id" = vcs."product_id"
       AND pl."batch_no" = vcs."batch_no"
     ORDER BY ph."invoice_date" DESC, pl."id" DESC
     LIMIT 1
  ) AS "mrp"
FROM "view_current_stock" AS vcs;

-- Product-level totals across batches
CREATE VIEW IF NOT EXISTS "view_product_stock_totals" AS
SELECT "pharmacy_id", "product_id", SUM("quantity") AS "total_quantity"
  FROM "view_stock_by_batch"
 GROUP BY "pharmacy_id", "product_id";

-- Expiring batches (next 30 days)
CREATE VIEW IF NOT EXISTS "view_expiring_batches_30d" AS
SELECT *
  FROM "view_stock_by_batch"
 WHERE "quantity" > 0
   AND "exp_date" IS NOT NULL
   AND DATE("exp_date") <= DATE('now', '+30 days');

-- Low stock (threshold 10)
CREATE VIEW IF NOT EXISTS "view_low_stock" AS
SELECT *
  FROM "view_current_stock"
 WHERE "quantity" <= 10
    ORDER BY "quantity" ASC;

-- Lab test status
CREATE VIEW IF NOT EXISTS "view_lab_test_status" AS
SELECT pt."id" AS "prescribed_test_id", t."name" AS "test_name", pr."id" AS "prescription_id",
       p."id" AS "patient_id", up."name" AS "patient_name", d."id" AS "doctor_id", 
       ud."name" AS "doctor_name", tr."lab_id", tr."collection_date_time", 
       tr."test_start_date_time", tr."test_end_date_time",
  CASE
    WHEN tr."id" IS NULL THEN 'PENDING'
    WHEN tr."test_end_date_time" IS NULL THEN 'IN-PROGRESS'
    ELSE 'COMPLETED'
  END AS "status"
  FROM "prescribed_tests" AS "pt"
  JOIN "tests" AS "t"
    ON t."id" = pt."test_id"
  JOIN "prescriptions" AS "pr"
    ON pr."id" = pt."prescription_id"
  JOIN "patients" AS "p"
    ON p."id" = pr."patient_id"
  JOIN "user_details" AS "up"
    ON up."id" = p."user_id"
  JOIN "doctors" AS "d"
    ON d."id" = pr."doctor_id"
  JOIN "user_details" AS "ud"
    ON ud."id" = d."user_id"
  LEFT JOIN "test_records" AS "tr" 
    ON tr."prescribed_tests_id" = pt."id";

-- Staff current check-in (today)
CREATE VIEW IF NOT EXISTS "view_staff_checked_in_today" AS
SELECT sar."id" AS "attendance_id", s."id" AS "staff_id", u."name" AS "staff_name",
       s."entity_id" AS "clinic_id", sar."in_date_time_stamp"
  FROM "staff_attendance_records" AS "sar"
  JOIN "staff" AS "s"
    ON s."id" = sar."staff_id"
  JOIN "user_details" AS "u" 
    ON u."id" = s."user_id"
 WHERE sar."out_date_time_stamp" IS NULL
   AND DATE(sar."in_date_time_stamp") = DATE('now');

-- Helper views for soft deletes / active rows
CREATE VIEW IF NOT EXISTS "view_active_entities" AS
SELECT * FROM "entities" WHERE "status" = 'active';

CREATE VIEW IF NOT EXISTS "view_active_staff" AS
SELECT * FROM "staff" WHERE "status" = 'active';

-- Sales OTC or Rx
CREATE VIEW IF NOT EXISTS "view_sales_party" AS
SELECT s."id" AS "sale_id", s."pharmacy_id", s."prescription_id", 
       s."buyer_user_id", s."product_id", s."batch_no", s."quantity", 
       s."rate", s."mrp", s."sold_at", s."sold_by",
  CASE 
    WHEN s."prescription_id" IS NOT NULL THEN 'Rx' 
    ELSE 'OTC' 
   END AS "sale_type",
  CASE 
    WHEN s."prescription_id" IS NOT NULL THEN up."name"
    ELSE bu."name"
   END AS "party_name"
  FROM "sales" AS "s"
  LEFT JOIN "prescriptions" AS "pr"
    ON pr."id" = s."prescription_id"
  LEFT JOIN "patients" AS "p"
    ON p."id" = pr."patient_id"
  LEFT JOIN "user_details" AS "up"
    ON up."id" = p."user_id"
  LEFT JOIN "user_details" AS "bu"
    ON bu."id" = s."buyer_user_id";

---- Uniqueness and performance indexes ----

CREATE UNIQUE INDEX IF NOT EXISTS "ux_entities_name_kind"
    ON "entities"("name", "kind_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_doctors_person"
    ON "doctors"("user_id", "entity_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_patients_person"
    ON "patients"("user_id", "clinic_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_doctor_time_slot"
  ON "doctor_time_slots"("doctor_id", "chamber_no", "day", "time_slot_start", "time_slot_end");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_appointments"
  ON "appointments"("patient_id", "doctor_time_slot_id", "appointment_date");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_prescribed_tests"
    ON "prescribed_tests"("prescription_id", "test_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_prescribed_products"
    ON "prescribed_products"("prescription_id", "product_id");

CREATE INDEX IF NOT EXISTS "idx_licences_entity"    ON "licences"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_doctors_clinic"     ON "doctors"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_appt_slot"          ON "appointments"("doctor_time_slot_id");
CREATE INDEX IF NOT EXISTS "idx_appt_slot_date"     ON "appointments"("doctor_time_slot_id", "appointment_date");
CREATE INDEX IF NOT EXISTS "idx_staff_entity"       ON "staff"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_staff_person"       ON "staff"("user_id");
CREATE INDEX IF NOT EXISTS "idx_staff_att_staff"    ON "staff_attendance_records"("staff_id");
CREATE INDEX IF NOT EXISTS "idx_patients_clinic"    ON "patients"("clinic_id");
CREATE INDEX IF NOT EXISTS "idx_presc_patient"      ON "prescriptions"("patient_id");
CREATE INDEX IF NOT EXISTS "idx_presc_doctor"       ON "prescriptions"("doctor_id");
CREATE INDEX IF NOT EXISTS "idx_tr_lab"             ON "test_records"("lab_id");
CREATE INDEX IF NOT EXISTS "idx_tr_ptid"            ON "test_records"("prescribed_tests_id");
CREATE INDEX IF NOT EXISTS "idx_tr_report_doctor"   ON "test_records"("report_by_doctor_id");
CREATE INDEX IF NOT EXISTS "idx_ph_hdr_pharmacy"    ON "purchase_headers"("pharmacy_id");
CREATE INDEX IF NOT EXISTS "idx_pl_hdr"             ON "purchase_lines"("header_id");
CREATE INDEX IF NOT EXISTS "idx_pl_header_line"     ON "purchase_lines"("header_id","line_no");
CREATE INDEX IF NOT EXISTS "idx_pl_prod_batch"      ON "purchase_lines"("product_id","batch_no");
CREATE INDEX IF NOT EXISTS "idx_pl_hdr_pb"          ON "purchase_lines"("header_id", "product_id", "batch_no");
CREATE INDEX IF NOT EXISTS "idx_ledger_ppb"         ON "inventory_ledger"("pharmacy_id","product_id","batch_no");
CREATE INDEX IF NOT EXISTS "idx_sales_ppb"          ON "sales"("pharmacy_id","product_id","batch_no");
CREATE INDEX IF NOT EXISTS "idx_sales_presc"        ON "sales"("prescription_id");
CREATE INDEX IF NOT EXISTS "idx_sales_buyer_user"   ON "sales"("buyer_user_id");
CREATE INDEX IF NOT EXISTS "idx_sales_sold_by"      ON "sales"("sold_by");
CREATE INDEX IF NOT EXISTS "idx_sales_sold_at"      ON "sales"("sold_at");

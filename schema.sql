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
    "entity_id" INTEGER,
    "name" TEXT NOT NULL,
    "licence_no" TEXT NOT NULL UNIQUE,
    "issue_date" TEXT,
    "expiry_date" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id")
);
 
---- Person Details and related Tables ----

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
    "email" TEXT NOT NULL UNIQUE,
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
    "user_id" INTEGER,
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
    "user_id" INTEGER,
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

CREATE TABLE IF NOT EXISTS "staffs" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "role" TEXT NOT NULL CHECK ("role" IN ('manager','pharmacist','receptionist','technician')),
    "join_date" TEXT,
    "salary" INTEGER NOT NULL,
    "rating" INTEGER CHECK ("rating" BETWEEN 0 AND 5),
    "review" TEXT,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK ("status" IN ('active','inactive')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("user_id","entity_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id")
);

-- Staff Attendence Records
CREATE TABLE IF NOT EXISTS "staff_attendance_records" (
    "id" INTEGER,
    "staff_id" INTEGER,
    "in_date_time_stamp" TEXT,
    "out_date_time_stamp" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("staff_id") REFERENCES "staffs"("id")
);

---- Staff logs and trigger conditions ----

CREATE TABLE IF NOT EXISTS "staff_and_entity_logs" (
    "id" INTEGER,
    "action" TEXT NOT NULL CHECK ("action" IN ('ADD','UPDATE','DELETE')),
    "time_stamp" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "staff_id" INTEGER,
    "entity_id" INTEGER,
    "role" TEXT NOT NULL,
    "salary" INTEGER,
    "rating" INTEGER CHECK("rating" <= 5),
    "review" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id") ON DELETE SET NULL,
    FOREIGN KEY("staff_id") REFERENCES "staffs"("id") ON DELETE SET NULL
);

CREATE TRIGGER IF NOT EXISTS "trg_new_staff"
    AFTER INSERT ON "staffs"
    FOR EACH ROW
    BEGIN
        INSERT INTO "staff_and_entity_logs" ("action","staff_id", "entity_id", "role", "salary", "rating", "review")
        VALUES ('ADD', NEW."id", NEW."entity_id", NEW."role", NEW."salary", NEW."rating", NEW."review");
    END;

CREATE TRIGGER IF NOT EXISTS "trg_update_staff"
    BEFORE UPDATE ON "staffs"
    FOR EACH ROW
    BEGIN
        INSERT INTO "staff_and_entity_logs" ("action", "staff_id", "entity_id", "role", "salary", "rating", "review")
        VALUES ('UPDATE', NEW."id", NEW."entity_id", NEW."role", NEW."salary", NEW."rating", NEW."review");
    END;

CREATE TRIGGER IF NOT EXISTS "trg_delete_staff"
    BEFORE DELETE ON "staffs"
    FOR EACH ROW
    BEGIN
        INSERT INTO "staff_and_entity_logs" ("action","staff_id", "entity_id", "role", "salary", "rating", "review")
        VALUES ('DELETE', OLD."id", OLD."entity_id", OLD."role", OLD."salary", OLD."rating", OLD."review");
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
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("entity_id") REFERENCES "entities"("id")
);

CREATE TABLE IF NOT EXISTS "doctor_time_slots" (
    "id" INTEGER,
    "doctor_id" INTEGER NOT NULL,
    "date" TEXT NOT NULL,
    "time_slot" INTEGER NOT NULL,
    "appointments_per_slot" INTEGER NOT NULL CHECK("appointments_per_slot" > 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("doctor_id") REFERENCES "doctors"("id")
);

---- Patient Details ----

CREATE TABLE IF NOT EXISTS "patients" (
    "id" INTEGER,
    "user_id" INTEGER,
    "clinic_id" INTEGER,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "user_details"("id"),
    FOREIGN KEY("clinic_id") REFERENCES "entities"("id")
);

---- Appointment Details ----

CREATE TABLE IF NOT EXISTS "appointments" (
    "id" INTEGER,
    "patient_id" INTEGER NOT NULL,
    "doctor_time_slot_id" INTEGER NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("patient_id", "doctor_time_slot_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("patient_id") REFERENCES "patients"("id"),
    FOREIGN KEY("doctor_time_slot_id") REFERENCES "doctor_time_slots"("id")
);

---- Prescription Details and related Tables ----

CREATE TABLE IF NOT EXISTS "prescriptions" (
    "id" INTEGER,
    "patient_id" INTEGER NOT NULL,
    "doctor_id" INTEGER NOT NULL,
    "prescription" Blob,
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
    PRIMARY KEY("id")
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
    PRIMARY KEY("id"),
    FOREIGN KEY("prescribed_tests_id") REFERENCES "prescribed_tests"("id"),
    FOREIGN KEY("lab_id") REFERENCES "entities"("id"),
    FOREIGN KEY("report_by_doctor_id") REFERENCES "doctors"("id")
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
    PRIMARY KEY("id"),
    FOREIGN KEY("company_id") REFERENCES "entities"("id")
);

CREATE TABLE IF NOT EXISTS "compositions" (
    "id" INTEGER,
    "product_id" INTEGER,
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
    UNIQUE("pharmacy_id","distributor_id","invoice_no"), 
    PRIMARY KEY("id"),
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("distributor_id") REFERENCES "entities"("id")
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
    UNIQUE("header_id","line_no"),
    UNIQUE("header_id","product_id","batch_no"),
    PRIMARY KEY("id"),
    FOREIGN KEY("header_id")  REFERENCES "purchase_headers"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id")
);

---- Sales Details ----

CREATE TABLE IF NOT EXISTS "sales" (
    "id" INTEGER,
    "pharmacy_id" INTEGER NOT NULL,
    "prescription_id" INTEGER,
    "product_id" INTEGER NOT NULL,
    "batch_no" TEXT NOT NULL,    
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    "rate" DECIMAL NOT NULL,
    "mrp" DECIMAL NOT NULL,
    "sold_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sold_by" INTEGER NOT NULL,
    PRIMARY KEY("id"), 
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("prescription_id") REFERENCES "prescriptions"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("sold_by") REFERENCES "user_details"("id")
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
    PRIMARY KEY("id"),
    FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id")
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
  PRIMARY KEY("id"),
  FOREIGN KEY("pharmacy_id") REFERENCES "entities"("id"),
  FOREIGN KEY("product_id") REFERENCES "products"("id")
);

-- Trigger: purchase -> ledger (+)
CREATE TRIGGER IF NOT EXISTS "trg_purchase_line_to_ledger"
AFTER INSERT ON "purchase_lines"
FOR EACH ROW
BEGIN
    INSERT INTO "inventory_ledger" ("pharmacy_id", "product_id", "batch_no", "exp_date", "source_type", "source_id", "quantity_delta", "rate", "mrp")
    VALUES ((SELECT "pharmacy_id"
               FROM "purchase_headers"
              WHERE "id" = NEW."header_id"), 
    NEW."product_id", NEW."batch_no", NEW."exp_date", 'PURCHASE', NEW."id", NEW."quantity", NEW."rate", NEW."mrp");
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

  INSERT INTO "inventory_ledger"("pharmacy_id","product_id","batch_no","exp_date","source_type","source_id","quantity_delta","rate","mrp")
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
      'SALE', NEW."id", -NEW."quantity", NEW."rate", NEW."mrp"
    );
END;

CREATE TRIGGER "trg_adjustment_to_ledger"
AFTER INSERT ON "inventory_adjustments"
FOR EACH ROW
BEGIN
  INSERT INTO "inventory_ledger"("pharmacy_id","product_id","batch_no", "exp_date", "source_type","source_id","quantity_delta", "rate", "mrp")
  VALUES (NEW."pharmacy_id", NEW."product_id", NEW."batch_no", NEW."exp_date", 'ADJUSTMENT', NEW."id", NEW."quantity_delta", NEW."rate", NEW."mrp");
END;

---- Views ----

CREATE VIEW IF NOT EXISTS "view_doctor_schedule" AS
SELECT ts.id AS "time_slot_id", d.id AS "doctor_id", ud.name AS "doctor_name", 
       d.entity_id AS "clinic_id", ts.date, ts.time_slot, 
       ts.appointments_per_slot, COALESCE(a.booked, 0) AS "booked",
       (ts.appointments_per_slot - COALESCE(a.booked, 0)) AS "remaining"
  FROM "doctor_time_slots" AS "ts"
  JOIN "doctors" AS "d"
    ON d.id = ts.doctor_id
  JOIN "user_details" AS "ud"
    ON ud.id = d.user_id
    LEFT JOIN (
        SELECT doctor_time_slot, COUNT(*) AS "booked"
          FROM appointments
            GROUP BY "doctor_time_slot_id"
    ) AS "a" ON a.doctor_time_slot_id = ts.id;

-- Stock View
CREATE VIEW IF NOT EXISTS "view_current_stock" AS
SELECT "pharmacy_id", "product_id", "batch_no", SUM("quantity_delta") AS "quantity"
  FROM "inventory_ledger"
    GROUP BY "pharmacy_id", "product_id", "batch_no"
HAVING SUM("quantity_delta") <> 0;

---- Uniqueness and performance indexes ----

CREATE UNIQUE INDEX IF NOT EXISTS "ux_entities_name_kind"
    ON "entities"("name","kind_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_doctors_person"
    ON "doctors"("user_id", "entity_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_patients_person"
    ON "patients"("user_id", "clinic_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_doctor_time_slot"
    ON "doctor_time_slots"("doctor_id","date","time_slot");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_appointments"
    ON "appointments"("patient_id", "doctor_time_slot_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_prescribed_tests"
    ON "prescribed_tests"("prescription_id","test_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_prescribed_products"
    ON "prescribed_products"("prescription_id","product_id");

CREATE INDEX IF NOT EXISTS "idx_licences_entity"  ON "licences"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_doctors_clinic"   ON "doctors"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_appt_slot"        ON "appointments"("doctor_time_slot_id");
CREATE INDEX IF NOT EXISTS "idx_staffs_entity"    ON "staffs"("entity_id");
CREATE INDEX IF NOT EXISTS "idx_staffs_person"    ON "staffs"("user_id");
CREATE INDEX IF NOT EXISTS "idx_patients_clinic"  ON "patients"("clinic_id");
CREATE INDEX IF NOT EXISTS "idx_presc_patient"    ON "prescriptions"("patient_id");
CREATE INDEX IF NOT EXISTS "idx_presc_doctor"     ON "prescriptions"("doctor_id");
CREATE INDEX IF NOT EXISTS "idx_test_records_lab" ON "test_records"("lab_id");
CREATE INDEX IF NOT EXISTS "idx_ph_hdr_pharmacy"  ON "purchase_headers"("pharmacy_id");
CREATE INDEX IF NOT EXISTS "idx_pl_hdr"           ON "purchase_lines"("header_id");
CREATE INDEX IF NOT EXISTS "idx_pl_header_line"   ON "purchase_lines"("header_id","line_no");
CREATE INDEX IF NOT EXISTS "idx_pl_prod_batch"    ON "purchase_lines"("product_id","batch_no");
CREATE INDEX IF NOT EXISTS "idx_ledger_ppb"       ON "inventory_ledger"("pharmacy_id","product_id","batch_no");
CREATE INDEX IF NOT EXISTS "idx_sales_ppb"        ON "sales"("pharmacy_id","product_id","batch_no");


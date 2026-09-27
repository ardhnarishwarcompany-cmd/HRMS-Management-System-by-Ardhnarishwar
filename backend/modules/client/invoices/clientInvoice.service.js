import { db } from "../../../config/db.js";

// helper
const getClientId = async (client_code) => {
  const [rows] = await db.query(
    `SELECT id FROM clients WHERE client_code=? LIMIT 1`,
    [client_code]
  );
  if (!rows.length) throw new Error("Client not found");
  return rows[0].id;
};


let invoiceSchemaPromise;

const ensureInvoiceSchema = () => {
  if (invoiceSchemaPromise) return invoiceSchemaPromise;

  invoiceSchemaPromise = (async () => {
    await db.query(`CREATE TABLE IF NOT EXISTS client_invoices (
      id INT AUTO_INCREMENT PRIMARY KEY, client_id INT NOT NULL, employee_id INT NULL,
      invoice_no VARCHAR(50) UNIQUE, client_name VARCHAR(255), client_address TEXT,
      client_gstin VARCHAR(50), state VARCHAR(100), state_code VARCHAR(10), invoice_date DATE,
      taxable_amount DECIMAL(10,2), cgst DECIMAL(10,2), sgst DECIMAL(10,2), total_amount DECIMAL(10,2),
      amount_in_words TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_client(client_id), INDEX idx_employee(employee_id)
    )`);

    await db.query(`CREATE TABLE IF NOT EXISTS client_invoice_items (
      id INT AUTO_INCREMENT PRIMARY KEY, invoice_id INT, description TEXT, hsn_sac VARCHAR(50),
      gst_rate DECIMAL(5,2), quantity INT, rate DECIMAL(10,2), amount DECIMAL(10,2),
      INDEX idx_invoice(invoice_id)
    )`);

    const [[c]] = await db.query(
      `SELECT COUNT(*) c FROM information_schema.columns
       WHERE table_schema=DATABASE() AND table_name='invoices' AND column_name='client_id'`,
    );
    if (!Number(c?.c)) {
      await db.query(
        `ALTER TABLE invoices ADD COLUMN client_id INT NULL, ADD INDEX idx_invoices_client (client_id)`,
      );
    }
  })().catch((err) => {
    invoiceSchemaPromise = null;
    throw err;
  });

  return invoiceSchemaPromise;
};

// CREATE
export const createInvoice = async (
  client_code,
  employee_id,
  data
) => {
  await ensureInvoiceSchema();
  const client_id = await getClientId(client_code);

  const {
    invoice_no,
    client_name,
    client_address,
    client_gstin,
    invoice_date,
    taxable_amount,
    cgst,
    sgst,
    total_amount,
    items,
  } = data;

  const [invoiceResult] = await db.query(
    `INSERT INTO client_invoices
     (client_id, employee_id, invoice_no, client_name, client_address,
      client_gstin, invoice_date, taxable_amount, cgst, sgst, total_amount)
     VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
    [
      client_id,
      employee_id || null,
      invoice_no,
      client_name,
      client_address,
      client_gstin,
      invoice_date,
      taxable_amount,
      cgst,
      sgst,
      total_amount,
    ]
  );

  const invoiceId = invoiceResult.insertId;

  for (const item of items) {
    await db.query(
      `INSERT INTO client_invoice_items
       (invoice_id, description, hsn_sac, gst_rate, quantity, rate, amount)
       VALUES (?,?,?,?,?,?,?)`,
      [
        invoiceId,
        item.description,
        item.hsn_sac,
        item.gst_rate,
        item.quantity,
        item.rate,
        item.amount,
      ]
    );
  }

  return { invoiceId };
};

// GET ALL
export const getInvoices = async (
  client_code,
  employee_id
) => {
  await ensureInvoiceSchema();
  const client_id = await getClientId(client_code);

  let where = `WHERE client_id=?`;
  const params = [client_id];

  if (employee_id) {
    where += ` AND employee_id=?`;
    params.push(employee_id);
  }

  const [rows] = await db.query(
    `SELECT *, 'client' AS source FROM client_invoices ${where} ORDER BY id DESC`,
    params
  );

  // Invoices raised by the Sales team against this client (invoices.client_id).
  // Only shown on the client-admin view (no employee filter) since they are
  // company-level billing documents, not per-employee.
  if (employee_id) return rows;

  // Keep this query compatible with older invoices tables. Different
  // deployments may not have optional billing columns such as status/due_date.
  // Only select columns guaranteed by the base invoices schema.
  const [salesRows] = await db.query(
    `SELECT i.id, i.client_id, i.employee_id, i.invoice_no, i.client_name,
            i.client_address, i.client_gstin, i.state, i.state_code,
            i.invoice_date, i.taxable_amount, i.cgst, i.sgst, i.total_amount,
            i.amount_in_words, i.created_at, 'sales' AS source
       FROM invoices i
       WHERE i.client_id = ? ORDER BY i.id DESC`,
    [client_id]
  );

  return [...rows, ...salesRows].sort(
    (a, b) => new Date(b.invoice_date || b.created_at) - new Date(a.invoice_date || a.created_at)
  );
};

// GET BY ID
export const getInvoiceById = async (client_code, id, source = "client") => {
  await ensureInvoiceSchema();
  const client_id = await getClientId(client_code);

  if (source === "sales") {
    const [inv] = await db.query(
      `SELECT *, 'sales' AS source FROM invoices WHERE id=? AND client_id=?`,
      [id, client_id]
    );
    if (!inv.length) throw new Error("Not found");
    const [items] = await db.query(
      `SELECT * FROM invoice_items WHERE invoice_id=?`,
      [id]
    );
    return { ...inv[0], items };
  }

  const [invoice] = await db.query(
    `SELECT * FROM client_invoices WHERE id=? AND client_id=?`,
    [id, client_id]
  );

  if (!invoice.length) throw new Error("Not found");

  const [items] = await db.query(
    `SELECT * FROM client_invoice_items WHERE invoice_id=?`,
    [id]
  );

  return { ...invoice[0], items };
};

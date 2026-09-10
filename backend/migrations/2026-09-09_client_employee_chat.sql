CREATE TABLE IF NOT EXISTS client_employee_conversations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  employee_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_client_employee_chat (client_id, employee_id),
  FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES client_employees(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS client_employee_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  conversation_id INT NOT NULL,
  sender_type ENUM('employee','client') NOT NULL,
  sender_id INT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (conversation_id) REFERENCES client_employee_conversations(id) ON DELETE CASCADE
);

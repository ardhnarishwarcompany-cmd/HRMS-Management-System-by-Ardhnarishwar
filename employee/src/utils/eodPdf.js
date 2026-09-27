import jsPDF from "jspdf";
import dayjs from "dayjs";

const COLORS = {
  primary: [79, 70, 229],
  dark: [30, 27, 75],
  gray: [100, 116, 139],
  light: [241, 245, 249],
};

function addSection(doc, y, label, text, pageWidth, margin) {
  const usableWidth = pageWidth - margin * 2;

  doc.setFont("helvetica", "bold");
  doc.setFontSize(10.5);
  doc.setTextColor(...COLORS.primary);
  doc.text(label.toUpperCase(), margin, y);
  y += 5.5;

  doc.setFont("helvetica", "normal");
  doc.setFontSize(10.5);
  doc.setTextColor(30, 30, 40);

  const content = text && text.trim() ? text.trim() : "Not provided";
  const lines = doc.splitTextToSize(content, usableWidth);
  doc.text(lines, margin, y);
  y += lines.length * 5.2 + 7;

  return y;
}

export function generateEodPdf(report, employee) {
  const doc = new jsPDF({ unit: "mm", format: "a4" });
  const pageWidth = doc.internal.pageSize.getWidth();
  const pageHeight = doc.internal.pageSize.getHeight();
  const margin = 16;
  let y = 0;

  doc.setFillColor(...COLORS.primary);
  doc.rect(0, 0, pageWidth, 32, "F");

  doc.setFont("helvetica", "bold");
  doc.setFontSize(16);
  doc.setTextColor(255, 255, 255);
  doc.text("ARDHNARISHWAR", margin, 14);

  doc.setFont("helvetica", "normal");
  doc.setFontSize(9.5);
  doc.text("Employee End-of-Day Report", margin, 21);

  doc.setFontSize(9);
  doc.text(dayjs(report.date).format("MMMM D, YYYY"), pageWidth - margin, 14, { align: "right" });
  doc.text(`Status: ${(report.status || "pending").toUpperCase()}`, pageWidth - margin, 21, { align: "right" });

  y = 42;

  doc.setDrawColor(226, 232, 240);
  doc.setFillColor(...COLORS.light);
  doc.roundedRect(margin, y, pageWidth - margin * 2, 20, 2, 2, "FD");

  doc.setFont("helvetica", "bold");
  doc.setFontSize(11);
  doc.setTextColor(...COLORS.dark);
  doc.text(employee?.name || "Employee", margin + 5, y + 8);

  doc.setFont("helvetica", "normal");
  doc.setFontSize(9);
  doc.setTextColor(...COLORS.gray);
  const subLine = [employee?.department, employee?.email].filter(Boolean).join("  |  ");
  doc.text(subLine || "—", margin + 5, y + 14.5);

  y += 30;

  y = addSection(doc, y, "Tasks Completed", report.tasksCompleted, pageWidth, margin);
  y = addSection(doc, y, "Tasks In Progress", report.tasksInProgress, pageWidth, margin);
  y = addSection(doc, y, "Blockers", report.blockers, pageWidth, margin);
  y = addSection(doc, y, "Tomorrow's Plan", report.tomorrowPlan, pageWidth, margin);
  if (report.notes && report.notes.trim()) {
    y = addSection(doc, y, "Additional Notes", report.notes, pageWidth, margin);
  }

  doc.setDrawColor(226, 232, 240);
  doc.line(margin, pageHeight - 16, pageWidth - margin, pageHeight - 16);
  doc.setFont("helvetica", "normal");
  doc.setFontSize(8);
  doc.setTextColor(...COLORS.gray);
  doc.text(`Generated on ${dayjs().format("MMM D, YYYY [at] h:mm A")}`, margin, pageHeight - 10);
  doc.text("ARDHNARISHWAR HRMS", pageWidth - margin, pageHeight - 10, { align: "right" });

  const fileName = `EOD_${(employee?.name || "Employee").replace(/\s+/g, "_")}_${dayjs(report.date).format("YYYY-MM-DD")}.pdf`;
  doc.save(fileName);
}
